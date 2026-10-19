/* Engine services and low-level hardware ABI. Include through donald.h. */
#ifndef DONALD_ENGINE_H
#define DONALD_ENGINE_H

/* engine/input.c */
int key_ready(void);
int get_key(void);
/* engine/egablit.c */
void blit_ega(int x, int y, int sx, int sy, int w, int h, char far *p1, char far *p2);
/* engine/retrace.c */
void wait_frame_intervals(int n);
/* engine/text.c */
void print_text(char far *s, int col, int y, int fg, int bg);
/* engine/fillrect.c */
void fill_rect(int x1, int y, int x2, int y2, int c);
/* engine/lines.c */
void hline(int y, int x, int x2, int c);
void draw_line(int x1, int y1, int x2, int y2, int c);
void plot(int x, int y, int c);
/* engine/picture.c */
void draw_pic(char far *p, char far *dst);
/* engine/palette.c */
void set_palette(char far *pal);
/* engine/xalloc.c */
char far *xalloc(long size);
/* engine/loadfile.c */
void load_file(char far *name, void far *buf);
/* engine/calibrat.c */
void calibrate(void);
/* engine/capture.c */
char far *grab(int x, int y, int w, int h);
char far *grab_vga(int x, int y, int w, int h);
/* engine/drive.c */
void select_drive(int disk);
/* engine/setwin.c */
void set_window(int n);
/* engine/redraw.c */
void redraw_rect(void);
/* engine/wraptext.c */
void print_wrapped(char far *s);
/* engine/wordtext.c */
void print_word(char far *s, int nl);
/* engine/sprite.c */
void draw_sprite(char far *dst, char far *src, int x, int y, int idx);
/* engine/mirror.c */
void draw_sprite_mirrored(char far *dst, char far *src, int x, int y, int idx);
/* engine/harderr.c */
int harderr_handler(int errval, int ax, int bp, int si);
void install_harderr(void);
/* engine/window.c */
void select_and_clear_window(int x);
/* engine/files.c */
void fatal(char far *msg);
void quit(int code);
int Open_File(char far *name, int mode);
void Close_File(int i);
long Read_File(int slot, char far *buf, long len);
long Write_File(int slot, char far *buf, long len);
long Seek_File(int slot, long off, int whence);
int File_Exists(char far *name);
int Delete_File(char far *name);
int Create_File(char far *name);
int Find_Disk_Number(char far *name);
void show_error(void);
void error_msg(void);
void free_resident(void);
void load_resources(void);
int is_loaded(char far *name);
int Get_Resident_Index(char far *name);
long Read_Resident(int i, char far *buf, long len);
void inset_rect(int n);

/* Original assembly interfaces (src/engine), with types from the call sites.
   Keep the declaration order, including sound, interrupts and keyboard
   primitives at the end: donald.h preserves the original compiler input. */
int ega_present(void);
void set_text_mode(void);
void ega_select_palette(int pal);
void hspan(int x, int y, int n, int c);
void copy_rect(char far *src, char far *dst, int x, int y, int w, int h);
void copy_rect_ega(char far *src, char far *dst, int x, int y, int w, int h);
void blit_ega_core(int x, int y, int sx, int sy, int w, int h, char far *p1, char far *p2);
void clear_screen(void);
void fill_rect_cells(int x, int y, int w, int h, int c);
void far_copy(char far *src, char far *dst, long len);
void present_buffer(char far *buf, uint seg);
void sprite_put_ega(char far *dst, char far *src, int x, int y);
void cga_shift_rows(char far *buf);
int pack_rect(char far *src, char far *dst, int w, int h, int skip);
void gfx_fill_rect(int x, int y, int w, int h, int c);
int dos_free_kb(void);
void cmp_unpack_planar(char far *src, char far *dst);
void cmp_unpack_cga(char far *src, char far *dst);
void enable_ints(void);
void disable_ints(void);
void set_palette16(char far *pal);
void cga_convert(char far *src, char far *dst, int n, int len);
void convert_cga_pixels_and_masks(char far *buf, int c);
char far *normalize_ptr(char far *p);
void dos_putc(int c);
uchar rand8(void);
void sprite_mirror_ega(char far *dst, char far *src, int x, int y);
void dos_set_drive(int drive);
void cga_select_palette(int pal);
void set_palette_reg(int reg, int v);
void set_video_type(int mode);
void set_bios_mode(int mode);
void sprite_put_cga(char far *dst, char far *src, int x, int y);
void sprite_mirror_packed(char far *dst, char far *src, int x, int y);
void set_text_colours(int fg, int bg);
void draw_char_tandy4bpp(int ch, int off, int x);
void draw_char_cga2bpp(int ch, int off, int x);
void draw_char_ega(int ch, int off, int x);
void draw_char_vga8bpp(int ch, int off, int x);
void gfx_init(void);
void set_palette_regs(char far *pal);
int in_vretrace(void);
void wait_vretrace(int n);
void vline(int x, int y1, int y2, int c);
void set_dac_regs(char far *pal);
void save_window(int x, int y, int w, int h, char far *buf);
void blit_generic(int x, int y, int w, int h, char far *src);
void sprite_put_m3(char far *dst, char far *src, int x, int y);
void sprite_mirror_m3(char far *dst, char far *src, int x, int y);
int snd_get_option(void);
void snd_set_option(int opt);
void snd_init(void);
void snd_shutdown(void);
void snd_play(char far *tune);
void snd_stop(void);
void ctrlc_install(void);
void ctrlc_remove(void);
void kbbreak_install(void);
void kbbreak_remove(void);
int timer_ticks(void);
int kbd_hit(void);
void kbd_flush(void);
int kbd_getcode(void);
int kbd_getchar(void);
void kbd_install(void);
void kbd_remove(void);

#endif
