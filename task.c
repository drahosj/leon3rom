#include "task.h"

// TODO: Don't hardcode 8 windows
int _nwin = 8;
int _wtab[32];

int get_task_for_window(int win)
{
	return _wtab[win];
}

int set_window_owner(int win, int tid)
{
	_wtab[win] = tid;
	return 0;
}

unsigned int get_wim_for_task(int tid)
{
	unsigned int wim = 0;
	for (int i = 0; i < _nwin; i++) {
		wim |= (tid != _wtab[i]) << i;
	}
	return wim;
}

/* Current task id */
int _ctid;
