#import <substrate.h>
#import <Foundation/Foundation.h>

#include <memory.h>
#include <dlfcn.h>

#import "Ramjet.h"
#import "Ramjet-Private.h"
#import "Logging.h"

#define MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT 6

static int maxRequestedTaskLimit;
static char maxRequestor[MAX_REQUEST_NAME];

typedef int (*dlysm_memoryStatus)(uint32_t command, pid_t pid, uint32_t flags, void *buffer, size_t buffersize);

extern int ramjet_updateTaskLimit(int taskLimitMB, char* requester) {
		return ramjet_updateTaskLimitForPID(taskLimitMB, requester, getpid());
}

int updateTaskLimit(int taskLimitMB, char* requester, int pid) {
	int response = -1;

	dlysm_memoryStatus memoryStatus;
	memoryStatus = (dlysm_memoryStatus)MSFindSymbol(NULL, "memorystatus_control");
	if (memoryStatus) {
			response = memoryStatus(MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT, pid, taskLimitMB, NULL, 0);
			if (response != 0) {
					RTLogError(@"Error in setting taskLimit to %d by \"%s\"", taskLimitMB, requester);
			} else {
					RTLogInfo(@"Sucessfully set taskLimit to %d b \"%s\"", taskLimitMB, requester);
			}
	} else {
			RTLogError(@"Error in creating dlysm_memoryStatus");
	}

	return response;
}

extern int ramjet_updateTaskLimitForPID(int taskLimitMB, char* requester, int pid) {
		if (taskLimitMB < 1) {
				RTLogError(@"Requested Tasklimit is bellow 1 (%d) ", taskLimitMB);
				return -3;
		} else if (taskLimitMB > 1024) {
				RTLogError(@"Tasklimit is in MB. %d too high", taskLimitMB);
				return -2;
		} else if (taskLimitMB < maxRequestedTaskLimit) {
				RTLogWarn(@"Not updating Tasklimit to %d, previous requestor %s already updated to %d mb", taskLimitMB, maxRequestor, maxRequestedTaskLimit);
		} else {
				if (updateTaskLimit(taskLimitMB, requester, pid) == 0) {
						strncpy(maxRequestor, requester, MAX_REQUEST_NAME-1);
						maxRequestedTaskLimit = taskLimitMB;
				}
		}

		return 0;
}
