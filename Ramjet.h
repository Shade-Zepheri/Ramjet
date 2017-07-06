#ifndef RAMJET_H
#define RAMJET_H

#include <objc/objc.h>

int ramjet_updateTaskLimit(int taskLimitMB, char* requester);
int ramjet_updateTaskLimitForPID(int taskLimitMB, char* requester, int pid);

#endif
