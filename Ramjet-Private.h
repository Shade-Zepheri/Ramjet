#ifndef RAMJET_PRIVATE_H
#define RAMJET_PRIVATE_H

#include <stdint.h>
#include <sys/proc.h>

typedef struct {
	uint32_t memorySize;
	char *requester;
	pid_t pid;
} RamjetInfo;

#endif