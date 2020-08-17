#ifndef _task_h
#define _task_h

extern int _ctid;
extern int _nwin;
extern int _wtab[32];

int get_task_for_window(int win);
int set_window_owner(int win, int tid);
unsigned int get_wim_for_task(int tid);

#endif
