/* Application sound interface. Include through donald.h. */
#ifndef DONALD_SOUND_H
#define DONALD_SOUND_H

/* audio/music.c: tune selection wrappers. The lower-level snd_* driver
   entry points remain in engine.h at their original declaration position. */
void play_sound(int i);
void stop_sound(void);

#endif
