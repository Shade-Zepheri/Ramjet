#import <substrate.h>
#import <Foundation/Foundation.h>

#include <memory.h>
#include <dlfcn.h>

#import "Ramjet.h"
#import "Ramjet-Private.h"

static int maxRequestedTaskLimit;
static char maxRequestor[MAX_REQUEST_NAME];

#define MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT 6

typedef int (*dlysm_memoryStatus)(uint32_t command, pid_t pid, uint32_t flags, void *buffer, size_t buffersize);


extern int ramjet_updateTaskLimit(int taskLimitMB, char* requester) {
		return ramjet_updateTaskLimitForPID(taskLimitMB, requester, getpid());
}

int updateTaskLimit(int taskLimitMB, char* requester, int pid) {
	int response = -1;

	dlysm_memoryStatus memoryStatus;
	void *handle = dlopen(NULL, 0);
	memoryStatus = *(int*)MSFindSymbol(NULL, "memorystatus_control");
	if (memoryStatus) {
			response = memoryStatus(MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT, pid, taskLimitMB, NULL, 0);
			if (response != 0) {
					HBLogError(@"Error in setting taskLimit to %d by \"%s\"", taskLimitMB, requester);
			} else {
					HBLogInfo(@"Sucessfully set taskLimit to %d b \"%s\"", taskLimitMB, requester);
			}
	} else {
			HBLogError(@"Error in creating dlysm_memoryStatus");
	}

	return response;
}

extern int ramjet_updateTaskLimitForPID(int taskLimitMB, char* requester, int pid) {
		if (taskLimitMB < 1) {
				HBLogError(@"jetslammed: high watermark requested below 1 (%d) ", taskLimitMB);
				return -3;
		} else if (taskLimitMB > 1024) {
				HBLogError(@"jetslammed: high watermark is in MB. %d too high", taskLimitMB);
				return -2;
		} else if (taskLimitMB < maxRequestedWatermark) {
				HBlogWarn(@"jetslammed: not updating high watermark to %d, previous requestor %s already updated to %d mb", taskLimitMB, maxRequestor, maxRequestedWatermark);
		} else {
				if (updateTaskLimit(taskLimitMB, requester, pid) == 0) {
						strncpy(maxRequestor, requester, MAX_REQUEST_NAME-1);
						maxRequestedWatermark = taskLimitMB;
				}
		}

		return 0;
}
