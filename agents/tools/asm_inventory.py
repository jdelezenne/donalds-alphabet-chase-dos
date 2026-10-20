#!/usr/bin/env python3
"""Verify the named hand-written assembly inventory against the actual sources/objects.

--sources-only needs neither NASM nor original game files. It checks annotations,
labels, direct-call entries, and the three function catalogs. --objects DIR also
preprocesses and instruments the real modules, assembles temporary OMF objects,
and measures every emitted statement and every catalog label. Instrumentation
uses NASM's non-scoping ..@ labels and must preserve production bytes, publics,
segments and relocation records. Both retail and alt use retail logical addresses;
variant paragraph biases live in the operands, not in object-local positions.

This is an inventory/layout regression check, not a proof that a semantic name or
an evidence description is correct. Indirect-call destinations require manual
analysis. The whole-executable hash checks remain independent evidence of fidelity.
"""
import argparse
from collections import Counter, defaultdict
import csv
from dataclasses import dataclass
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
import re
import struct
import subprocess
import tempfile

import omf

ROOT = Path(__file__).resolve().parents[2]
SEGMENT = re.compile(r";\s*SEGMENT:\s*DONALD\s+([0-9A-Fa-f]{4})\s+([0-9A-Fa-f]{4})-([0-9A-Fa-f]{4})")
FUNCTION = re.compile(r";\s*FUNCTION:\s*DONALD\s+([0-9A-Fa-f]{4}):([0-9A-Fa-f]{4})\s*$")
IDENT = r"[A-Za-z_.$?@][\w.$?@]*"
LABEL = re.compile(r"^\s*(" + IDENT + r")\s*:\s*(.*)$")
ALIAS = re.compile(r"^\s*(" + IDENT + r")\s+equ\s+(" + IDENT + r")\s*$", re.I)
EQU = re.compile(r"^\s*" + IDENT + r"\s+equ\b", re.I)
DATA = re.compile(r"^(?:times\s+.+?\s+)?(db|dw|dd|dq|dt|do|dy|dz|resb|resw|resd|resq|rest|reso|resy|resz|incbin)\b", re.I)
LINE = re.compile(r"^%line\s+(\d+)\+(\d+)\s+(.+)$")
GFX_BASES = {"graphics_rect": 0x000e, "graphics_core": 0x0026, "graphics_mode3": 0x14b6}


def uncomment(line):
    """Strip a NASM comment without truncating a quoted semicolon in a table."""
    quote = None
    escaped = False
    for i, char in enumerate(line):
        if escaped:
            escaped = False
        elif quote:
            if char == "\\" and quote == "`":
                escaped = True
            elif char == quote:
                quote = None
        elif char in "'\"`":
            quote = char
        elif char == ";":
            return line[:i]
    return line


def csv_rows(path, columns, errors):
    try:
        with path.open(newline="") as handle:
            reader = csv.DictReader(handle)
            if reader.fieldnames != columns:
                errors.append(f"{path.name}: expected columns {','.join(columns)}")
                return []
            rows = list(reader)
        valid = []
        for number, row in enumerate(rows, 2):
            if None in row or any(not (row.get(key) or "").strip() for key in columns):
                errors.append(f"{path.name}:{number}: blank or malformed inventory field")
            else:
                valid.append(row)
        return valid
    except OSError as exc:
        errors.append(str(exc))
        return []


@dataclass
class Source:
    path: Path
    segment: str
    start: int
    end: int
    labels: dict
    aliases: dict
    markers: dict
    calls: list

    def resolve(self, name):
        """Resolve exact aliases, including the public C underscore fallback."""
        if name not in self.labels and name not in self.aliases:
            name = "_" + name
        visited = set()
        while name in self.aliases and name not in visited:
            visited.add(name)
            name = self.aliases[name]
        return name if name in self.labels else None


def read_source(path, errors):
    lines = path.read_text().splitlines()
    segments = SEGMENT.findall("\n".join(lines))
    if len(segments) != 1:
        errors.append(f"{path.name}: expected exactly one SEGMENT annotation")
        return None
    segment, start, end = segments[0]
    labels, aliases, markers, calls = {}, {}, {}, []
    pending = None
    scope = ""
    for number, original in enumerate(lines, 1):
        marker = FUNCTION.search(original)
        if "FUNCTION:" in original and not marker:
            errors.append(f"{path.name}:{number}: malformed FUNCTION annotation")
        if marker:
            address = ":".join(marker.groups()).upper()
            if pending:
                errors.append(f"{path.name}:{number}: previous FUNCTION has no label")
            if address in markers:
                errors.append(f"{path.name}:{number}: duplicate FUNCTION {address}")
            pending = address
        line = uncomment(original).strip()
        match = LABEL.match(line)
        if match:
            name, line = match.groups()
            if name.startswith(".") and not name.startswith("..@"):
                name = scope + name
            elif not name.startswith("..@"):
                scope = name
            if name in labels:
                errors.append(f"{path.name}:{number}: duplicate label {name}")
            labels[name] = number
            if pending:
                markers[pending] = name
                pending = None
        alias = ALIAS.match(line)
        if alias:
            name, target = alias.groups()
            if name in aliases or name in labels:
                errors.append(f"{path.name}:{number}: duplicate alias {name}")
            aliases[name] = target
        # Direct near calls and the existing explicit far-call form. Memory and
        # register indirect calls are deliberately not guessed from the text.
        call = re.match(r"call\s+(?:(?:near|far|word)\s+)*(" + IDENT + r")\s*$", line, re.I)
        far_call = re.match(r"call\s+\(seg\s+(" + IDENT + r")\):(" + IDENT + r")\s*$", line, re.I)
        target = call.group(1) if call else far_call.group(2) if far_call else None
        if target and target.lower() not in {"ax", "bx", "cx", "dx", "si", "di", "bp", "sp"}:
            if target.startswith("."):
                target = scope + target
            calls.append((number, target))
    if pending:
        errors.append(f"{path.name}: final FUNCTION has no label")
    return Source(path, segment.upper(), int(start, 16), int(end, 16), labels, aliases, markers, calls)


class Inventory:
    def __init__(self, root=ROOT):
        self.root = Path(root)
        self.errors = []
        self.sources = {}
        self.functions = []
        self.data = []

    def check_sources(self):
        errors = self.errors
        for path in sorted((self.root / "src").rglob("*.asm")):
            source = read_source(path, errors)
            if source:
                self.sources[path.relative_to(self.root).as_posix()] = source
        directory = self.root / "agents/config/retail"
        function_rows = csv_rows(directory / "asm_functions.csv", ["addr", "size", "name", "source", "role", "evidence"], errors)
        data_rows = csv_rows(directory / "asm_data.csv", ["source", "segment", "offset", "size", "name", "type", "evidence"], errors)
        for row in function_rows:
            try:
                if not re.fullmatch(r"[0-9A-F]{4}:[0-9A-F]{4}", row["addr"]):
                    raise ValueError("addr must use uppercase SSSS:OOOO")
                item = dict(row, segment=row["addr"][:4], offset=int(row["addr"][5:], 16), size=int(row["size"]))
                self.functions.append(item)
            except (ValueError, TypeError, KeyError) as exc:
                errors.append(f"asm_functions.csv: invalid row {row}: {exc}")
        for row in data_rows:
            try:
                if not re.fullmatch(r"(?:[0-9A-F]{4}|GFX_DATA|KBD_DATA)", row["segment"]):
                    raise ValueError("invalid segment")
                if not re.fullmatch(r"[0-9A-F]{4}", row["offset"]):
                    raise ValueError("offset must use four uppercase hexadecimal digits")
                self.data.append(dict(row, offset=int(row["offset"], 16), size=int(row["size"])))
            except (ValueError, TypeError, KeyError) as exc:
                errors.append(f"asm_data.csv: invalid row {row}: {exc}")
        for kind, items in (("function", self.functions), ("data", self.data)):
            seen = set()
            for item in items:
                name = item["name"]
                identity = (item["source"], name)
                if identity in seen:
                    errors.append(f"duplicate {kind} catalog symbol: {identity}")
                seen.add(identity)
                source = self.sources.get(item["source"])
                if not source:
                    errors.append(f"{name}: source is not a linked assembly source: {item['source']}")
                    continue
                if item["size"] <= 0 or item["offset"] + item["size"] > 0x10000:
                    errors.append(f"{name}: invalid inventory interval")
                if item["segment"] not in (source.segment, "GFX_DATA", "KBD_DATA"):
                    errors.append(f"{name}: segment disagrees with source")
                if item["segment"] == source.segment and not source.start <= item["offset"] < item["offset"] + item["size"] <= source.end:
                    errors.append(f"{name}: interval escapes annotated source CODE range")
                resolved = source.resolve(name)
                if not resolved:
                    errors.append(f"{name}: missing source label or exact alias in {item['source']}")
                if kind == "data" and name not in source.labels:
                    errors.append(f"{name}: data inventory must name its actual storage label")
                item["label"] = resolved
        addresses = Counter(item["addr"] for item in self.functions)
        for address, count in addresses.items():
            if count != 1:
                errors.append(f"duplicate assembly function address {address}")
        for name, count in Counter(item["name"] for item in self.functions).items():
            if count != 1:
                errors.append(f"duplicate assembly function name {name}")
        markers = {}
        for source_name, source in self.sources.items():
            catalog = {item["addr"]: item for item in self.functions if item["source"] == source_name}
            for address, label in source.markers.items():
                if address in markers:
                    errors.append(f"FUNCTION {address} appears in more than one source")
                markers[address] = source_name
                if address not in catalog:
                    errors.append(f"{source_name}: FUNCTION {address} is missing from asm_functions.csv")
                elif catalog[address].get("label") != label:
                    errors.append(f"{source_name}: FUNCTION {address} labels {label}, catalog names {catalog[address]['name']}")
            for address in catalog.keys() - source.markers.keys():
                errors.append(f"{source_name}: catalog function {address} has no FUNCTION marker")
            callable_labels = {item.get("label") for item in catalog.values()}
            for number, target in source.calls:
                resolved = source.resolve(target)
                if resolved and resolved not in callable_labels:
                    errors.append(f"{source_name}:{number}: direct call to uncataloged entry {target}")
        # A data byte can belong to only one object, and never to a routine.
        # Routine intervals may overlap for documented internal/shared entries.
        used = defaultdict(dict)
        for item in self.data:
            identity = (item["source"], item["name"])
            for offset in range(item["offset"], item["offset"] + item["size"]):
                prior = used[item["segment"]].setdefault(offset, identity)
                if prior != identity:
                    errors.append(f"{item['name']}: overlaps data {prior[1]} at {item['segment']}:{offset:04X}")
                    break
        for number, item in enumerate(self.functions):
            hit = next((offset for offset in range(item["offset"], item["offset"] + item["size"]) if offset in used[item["segment"]]), None)
            if hit is not None:
                errors.append(f"{item['name']}: routine overlaps data {used[item['segment']][hit][1]} at {item['segment']}:{hit:04X}")
            for other in self.functions[:number]:
                if item["segment"] != other["segment"] or max(item["offset"], other["offset"]) >= min(item["offset"] + item["size"], other["offset"] + other["size"]):
                    continue
                # An overlapping helper must explicitly document its relation
                # to the other entry; a generic nonempty evidence field is not
                # enough. This checks the declaration, not the semantic claim.
                documented = False
                for left, right in ((item, other), (other, item)):
                    description = left["role"] + " " + left["evidence"]
                    if right["name"] in description and re.search(r"overlap|embedded|shared", description, re.I):
                        documented = True
                if not documented:
                    errors.append(f"undocumented routine overlap: {item['name']} and {other['name']}")
        for file, key, value in (("functions.csv", "kind", "asm"), ("symbols.csv", "status", "asm")):
            try:
                with (directory / file).open(newline="") as handle:
                    rows = [r for r in csv.DictReader(handle) if r[key] == value]
                expected = {item["addr"]: item for item in self.functions}
                actual = {row["addr"]: row for row in rows}
                if len(actual) != len(rows):
                    errors.append(f"{file}: duplicate ASM addresses")
                if actual.keys() != expected.keys():
                    errors.append(f"{file}: ASM addresses disagree with asm_functions.csv (missing {sorted(expected.keys() - actual.keys())}; extra {sorted(actual.keys() - expected.keys())})")
                for address in actual.keys() & expected.keys():
                    if int(actual[address]["size"]) != expected[address]["size"]:
                        errors.append(f"{file}: ASM size disagrees at {address}")
                    if file == "symbols.csv" and actual[address]["name"] != expected[address]["name"]:
                        errors.append(f"{file}: ASM name disagrees at {address}")
            except (OSError, KeyError, ValueError, TypeError) as exc:
                errors.append(f"{file}: {exc}")
        if not self.sources or not self.functions or not self.data:
            errors.append("assembly inventory must not be empty")
        return errors

    def check_objects(self, directory, target="retail", nasm="nasm"):
        if self.errors:
            return self.errors
        for source_name, source in self.sources.items():
            production = Path(directory) / (source.path.stem + ".OBJ")
            if not production.is_file():
                self.errors.append(f"missing production object {production}")
                continue
            try:
                self._check_object(source_name, source, production, target, nasm)
            except (OSError, ValueError, KeyError, IndexError, struct.error) as exc:
                self.errors.append(f"{source_name}: object inventory check failed: {exc}")
        return self.errors

    def _check_object(self, source_name, source, production, target, nasm):
        command = [nasm, "-E", "-i", str(source.path.parent) + "/", "-i", str(self.root / "src/donald/engine") + "/"]
        if target == "alt":
            command.append("-DDONALD_ALT")
        result = subprocess.run(command + [str(source.path)], capture_output=True, text=True)
        if result.returncode:
            raise ValueError("NASM preprocessing failed:\n" + result.stderr)
        entries = [item for item in self.functions + self.data if item["source"] == source_name]
        annotated, statements = instrument(result.stdout, entries, self.root / "src/donald/engine/tasm.inc")
        with tempfile.TemporaryDirectory(prefix="donald-asm-inventory-") as temporary:
            asm = Path(temporary) / source.path.name
            obj = asm.with_suffix(".OBJ")
            asm.write_text(annotated)
            result = subprocess.run([nasm, "-a", "-f", "obj", "-o", str(obj), str(asm)], capture_output=True, text=True)
            if result.returncode:
                raise ValueError("instrumented NASM assembly failed:\n" + result.stderr)
            psegments, ppublics, pdata, pfix = omf.read(production)
            segments, publics, data, fix = omf.read(obj)
            if segments != psegments or data != pdata or fix != pfix or relocation_records(obj) != relocation_records(production):
                raise ValueError("instrumentation changes production segments, bytes, or relocations (or production object is stale)")
            extra = {name: (si, off) for name, si, off in publics if name.startswith("..@inventory_")}
            original_publics = sorted(pub for pub in publics if not pub[0].startswith("..@inventory_"))
            if original_publics != sorted(ppublics):
                raise ValueError("instrumentation changes production public symbols")
        bases, logical = {}, {}
        code_segments = [si for si, segment in enumerate(segments) if segment and segment["class"].upper() == "CODE"]
        if len(code_segments) != 1:
            raise ValueError("expected exactly one CODE segment")
        code_si = code_segments[0]
        if segments[code_si]["len"] != source.end - source.start:
            raise ValueError("CODE size disagrees with SEGMENT annotation")
        for si, segment in enumerate(segments):
            if not segment:
                continue
            if si == code_si:
                bases[si], logical[si] = source.start, source.segment
            elif segment["name"] == "GFX_DATA":
                bases[si], logical[si] = GFX_BASES.get(source.path.stem, 0), "GFX_DATA"
                if segment["len"] and source.path.stem not in GFX_BASES:
                    raise ValueError("unrecognized initialized GFX_DATA fragment")
            elif segment["name"] == "KBD_DATA":
                bases[si], logical[si] = 0, "KBD_DATA"
            elif segment["len"]:
                raise ValueError(f"uncataloged nonempty segment {segment['name']}")
        data_masks = {si: [None] * segment["len"] for si, segment in enumerate(segments) if segment}
        function_masks = {si: bytearray(segment["len"]) for si, segment in enumerate(segments) if segment}
        entry_offsets = set()
        for number, item in enumerate(entries):
            symbol = f"..@inventory_symbol_{number}"
            if symbol not in extra:
                raise ValueError(f"missing assembled catalog label {item['name']}")
            si, offset = extra[symbol]
            if si not in bases or logical[si] != item["segment"] or offset + bases[si] != item["offset"]:
                raise ValueError(f"{item['name']}: assembled location {segments[si]['name']}:{offset:04X} disagrees with {item['segment']}:{item['offset']:04X}")
            end = offset + item["size"]
            if end > segments[si]["len"]:
                raise ValueError(f"{item['name']}: catalog interval escapes object segment")
            if "addr" in item:
                entry_offsets.add((si, offset))
                function_masks[si][offset:end] = b"\1" * item["size"]
            else:
                data_masks[si][offset:end] = [item["name"]] * item["size"]
        for name, si, offset in ppublics:
            if si == code_si and (si, offset) not in entry_offsets:
                if offset >= len(data_masks[si]) or data_masks[si][offset] is None:
                    raise ValueError(f"exported CODE entry {name} at {offset:04X} is not cataloged")
        emitted = {si: bytearray(segment["len"]) for si, segment in enumerate(segments) if segment}
        initialized = {si: bytearray(segment["len"]) for si, segment in enumerate(segments) if segment}
        for number, statement in enumerate(statements):
            si, start = extra[f"..@inventory_before_{number}"]
            end_si, end = extra[f"..@inventory_after_{number}"]
            context = f"{statement['source']}:{statement['line']}"
            if si != end_si or end < start or end > segments[si]["len"]:
                raise ValueError(f"{context}: invalid emitted statement extent")
            if start == end:
                continue  # zero-byte compile-time layout assertions
            if any(emitted[si][start:end]):
                raise ValueError(f"{context}: overlapping emitted statements")
            emitted[si][start:end] = b"\1" * (end - start)
            if statement["kind"] == "data":
                owners = set(data_masks[si][start:end])
                if None in owners or len(owners) != 1:
                    raise ValueError(f"{context}: initializer {start:04X}-{end:04X} is not contained in one named data interval")
                if any(function_masks[si][start:end]):
                    raise ValueError(f"{context}: initializer overlaps a routine")
                initialized[si][start:end] = b"\1" * (end - start)
            else:
                if statement["kind"] == "rr":
                    encoded = bytes(data[si][start:end])
                    if len(encoded) != 2 or encoded[0] not in {0x02, 0x03, 0x0a, 0x0b, 0x12, 0x13, 0x1a, 0x1b, 0x22, 0x23, 0x2a, 0x2b, 0x32, 0x33, 0x3a, 0x3b, 0x8a, 0x8b} or encoded[1] < 0xc0:
                        raise ValueError(f"{context}: rr exception must encode one register-register instruction")
                if any(owner is not None for owner in data_masks[si][start:end]):
                    raise ValueError(f"{context}: instruction overlaps catalog data")
                if not all(function_masks[si][start:end]):
                    # An explicit one-byte NOP is permitted as alignment between
                    # routines; arbitrary gaps and db 90h are not accepted.
                    if statement["kind"] != "nop" or bytes(data[si][start:end]) != b"\x90" * (end - start):
                        raise ValueError(f"{context}: instruction outside every catalog routine at {start:04X}")
        for si, segment in enumerate(segments):
            if not segment or not segment["len"]:
                continue
            if not all(emitted[si]):
                offset = emitted[si].index(0)
                raise ValueError(f"{segment['name']}:{offset:04X}: byte not accounted for by an emitted source statement")
            for offset, owner in enumerate(data_masks[si]):
                if owner is not None and not initialized[si][offset]:
                    raise ValueError(f"{owner}: catalog byte {offset:04X} has no data initializer")


def instrument(preprocessed, entries, tasm_path):
    """Instrument preprocessed real source, including repeated/include emissions.

    Absolute STRUC fields emit no storage. The rr macro is the sole intentional
    instruction-as-db exception; identify its actual definition's source lines.
    Other db/dw/etc expansions, including include files, are ordinary data.
    """
    rr_lines, in_rr = set(), False
    for number, text in enumerate(tasm_path.read_text().splitlines(), 1):
        if re.match(r"\s*%macro\s+rr\s", text):
            in_rr = True
        if in_rr:
            rr_lines.add(number)
        if re.match(r"\s*%endmacro\b", text):
            in_rr = False
    output, statements = [], []
    source, line_number, increment = "<preprocessed>", 0, 1
    absolute = False
    for original in preprocessed.splitlines():
        location = LINE.match(original)
        if location:
            line_number, increment = map(int, location.groups()[:2])
            source = location.group(3)
            # Do not copy %line: temporary statement indices are sufficient for
            # compiler diagnostics; original locations are saved in statements.
            continue
        line = uncomment(original).strip()
        current_line = line_number
        line_number += increment
        if re.match(r"\[absolute\b", line, re.I):
            absolute = True
        elif re.match(r"\[(?:segment|section)\b", line, re.I):
            absolute = False
        match = LABEL.match(line)
        remainder = match.group(2).strip() if match else line
        if absolute or not remainder or remainder.startswith("[") or EQU.match(remainder):
            output.append(original)
            continue
        if remainder.startswith("%"):
            raise ValueError(f"unexpected unexpanded NASM directive: {remainder}")
        directive = DATA.match(remainder)
        kind = "instruction"
        if directive:
            opcode = directive.group(1).lower()
            if opcode.startswith("res") or opcode == "incbin":
                raise ValueError(f"{source}:{current_line}: opaque or uninitialized storage is not allowed")
            kind = "data"
            if Path(source).resolve() == tasm_path.resolve() and current_line in rr_lines:
                kind = "rr"
        elif re.fullmatch(r"(?:times\s+.+?\s+)?nop", remainder, re.I):
            kind = "nop"
        number = len(statements)
        statements.append({"kind": kind, "source": source, "line": current_line})
        output.extend((f"[global ..@inventory_before_{number}]", f"..@inventory_before_{number}:"))
        output.append(original)
        output.extend((f"[global ..@inventory_after_{number}]", f"..@inventory_after_{number}:"))
    for number, item in enumerate(entries):
        output.extend((f"[global ..@inventory_symbol_{number}]", f"..@inventory_symbol_{number} equ {item['label']}"))
    return "\n".join(output) + "\n", statements


def relocation_records(path):
    """Compare actual OMF FIXUPP target payloads, not just masked byte positions."""
    content = Path(path).read_bytes()
    records, position, last_data = [], 0, None
    while position < len(content):
        kind, length = content[position], struct.unpack_from("<H", content, position + 1)[0]
        payload = content[position + 3:position + 2 + length]
        position += 3 + length
        if kind in (0xa0, 0xa1):
            segment, cursor = omf._idx(payload, 0)
            offset = struct.unpack_from("<H" if kind == 0xa0 else "<I", payload, cursor)[0]
            last_data = segment, offset
        elif kind in (0x9c, 0x9d):
            records.append((last_data, kind, payload))
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--sources-only", action="store_true", help="check static inventory only (the default)")
    parser.add_argument("--objects", type=Path, help="directory containing real assembled production .OBJ files")
    parser.add_argument("--target", choices=("retail", "alt"), default="retail")
    parser.add_argument("--nasm", default="nasm")
    args = parser.parse_args()
    if args.sources_only and args.objects:
        parser.error("--sources-only and --objects are mutually exclusive")
    inventory = Inventory()
    inventory.check_sources()
    if args.objects:
        inventory.check_objects(args.objects, args.target, args.nasm)
    if inventory.errors:
        parser.exit(1, "assembly inventory check failed:\n" + "\n".join(inventory.errors) + "\n")
    detail = f"; real {args.target} objects, initializer coverage and emitted bytes checked" if args.objects else "; source-only, no byte comparison"
    print(f"ASM inventory OK: {len(inventory.functions)} function entries, {len(inventory.data)} data objects, {len(inventory.sources)} modules{detail}.")


if __name__ == "__main__":
    main()
