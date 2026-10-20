/* Application interfaces, in recovered declaration order. Use donald.h. */
#ifndef DONALD_GAME_H
#define DONALD_GAME_H

/* game.c: actors, scripts, scene selection and the game loop. */
void present_rect(char far *src, int x, int y, int w, int h);
void propagate_dirty_overlap(void);
void copy_dirty_actor_rects(int mode);
void copy_page_rect(int mode, int x, int y, int w, int h);
void step_jump_path(int i);
void draw_actor_frame(int mode, int i, int x, int y);
void next_level(void);
int detect_tandy_signature(void);
void detect_video(void);
int completed_group_score(void);
void initialize_jump_path(int i);
void reset_actors(void);
void prepare_letter_selection(int lv);
void show_picture(int n);
void load_level_gfx(void);
void run_game(void);
int handle_key(void);
int step_actor_script(int i);
int roll_bounded_random_sum(int n, int max, int base);
void init_slots(void);
int wait_key(int any);
int ending(void);
void prompt_insert_game_disk(void);
/* main.c: application startup and shutdown. */
void init_game(void);
void shutdown(void);

#endif
