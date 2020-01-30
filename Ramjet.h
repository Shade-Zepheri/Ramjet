#ifndef RAMJET_H
#define RAMJET_H

#include <stdint.h>
#include <sys/proc.h>
#include <mach/mach.h>

extern kern_return_t ramjet_updateTaskLimit(uint32_t taskLimitMB, char *requester);
extern kern_return_t ramjet_updateTaskLimitForPID(uint32_t taskLimitMB, char *requester, pid_t pid);

#endif
