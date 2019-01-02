#ifndef RAMJET_H
#define RAMJET_H

#include <objc/objc.h>

extern int ramjet_updateTaskLimit(uint32_t taskLimitMB, char* requester);
extern int ramjet_updateTaskLimitForPID(uint32_t taskLimitMB, char* requester, pid_t pid);

#endif
