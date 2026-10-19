/* Prototypes of every function (C definitions in src/seg*, asm publics in src/asm). Included by donald.h. */
#ifndef PROTO_H
#define PROTO_H

/* Semantic API names. Keep the already reconstructed ASM linker aliases so
   public-symbol records and original object ordering remain unchanged. The
   prior cga/tandy glyph names were reversed; sprite_mask_* mirrors the source. */
#define draw_char_tandy4bpp draw_char_cga
#define draw_char_cga2bpp draw_char_tandy
#define draw_char_vga8bpp draw_char_buf
#define convert_cga_pixels_and_masks clear_buffer
#define fill_rect_cells redraw_rect_hw
#define sprite_mirror_ega sprite_mask_ega
#define sprite_mirror_packed sprite_mask_cga
#define sprite_mirror_m3 sprite_mask_m3

/* m0304.c */
void blit_dispatch(char far *src, int x, int y, int w, int h);
void check_collisions(void);
void draw_items(int mode);
void draw_item(int mode, int x, int y, int w, int h);
void step(int i);
void draw_frame(int mode, int i, int x, int y);
void next_level(void);
int rom_check(void);
void detect_video(void);
int level_sum(void);
void aim(int i);
void reset_actors(void);
void setup_level(int lv);
void show_picture(int n);
void load_level_gfx(void);
void game(void);
int handle_key(void);
int run_script(int i);
int roll(int n, int max, int base);
void init_slots(void);
int wait_key(int any);
int ending(void);
void about(void);
/* m04fc.c */
void init_game(void);
void shutdown(void);
/* sound.c */
void play_sound(int i);
void stop_sound(void);
/* input.c */
int key_ready(void);
int get_key(void);
/* m05c5.c */
void blit_ega(int x, int y, int sx, int sy, int w, int h, char far *p1, char far *p2);
/* repeat.c */
void repeat_call(int n);
/* m05d5.c */
void print_text(char far *s, int col, int y, int fg, int bg);
/* m05e7.c */
void fill_rect(int x1, int y, int x2, int y2, int c);
/* m05ed.c */
void hline(int y, int x, int x2, int c);
void draw_line(int x1, int y1, int x2, int y2, int c);
void plot(int x, int y, int c);
/* m0604.c */
void draw_pic(char far *p, char far *dst);
/* m060b.c */
void set_palette(char far *pal);
/* m0612.c */
char far *xalloc(long size);
/* m061a.c */
void load_file(char far *name, void far *buf);
/* m061f.c */
void calibrate(void);
/* m062d.c */
char far *grab(int x, int y, int w, int h);
char far *grab_vga(int x, int y, int w, int h);
/* music.c */
void select_drive(int disk);
/* m065e.c */
void set_window(int n);
/* redraw.c */
void redraw_rect(void);
/* m0671.c */
void print_wrapped(char far *s);
/* m06ad.c */
void print_word(char far *s, int nl);
/* m06c3.c */
void draw_sprite(char far *dst, char far *src, int x, int y, int idx);
/* m06d3.c */
void draw_sprite_mirrored(char far *dst, char far *src, int x, int y, int idx);
/* harderr.c */
int harderr_handler(int errval, int ax, int bp, int si);
void install_harderr(void);
/* m06ef.c */
void set_and_redraw(int x);
/* m06f0.c */
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

/* assembly (src/asm); parameter types follow the call sites */
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
