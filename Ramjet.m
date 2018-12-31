#import <Foundation/Foundation.h>

#import "Ramjet.h"
#import "Ramjet-Private.h"
#import "Logging.h"

static int maxRequestedTaskLimit;
static char maxRequester[MAX_REQUEST_NAME];

extern int ramjet_updateTaskLimit(int taskLimitMB, char *requester) {
	return ramjet_updateTaskLimitForPID(taskLimitMB, requester, getpid());
}

static void sendInfo(int taskLimitMB, char *requester, pid_t pid) {
	RamjetInfo info;
	info.memorySize = taskLimitMB;
	info.requester = requester;
	info.pid = pid;

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSDictionary *data = @{@"Request": [NSValue valueWithBytes:&info objCType:@encode(RamjetInfo)]};
		LMConnectionSendOneWayData(&connection, 0, (__bridge CFDataRef)LMDataForPropertyList(data));
	});

	strncpy(maxRequester, requester, MAX_REQUEST_NAME-1);
	maxRequestedTaskLimit = taskLimitMB;
}

extern int ramjet_updateTaskLimitForPID(int taskLimitMB, char *requester, pid_t pid) {
	if (taskLimitMB < 1) {
		RTLogError(@"Requested Tasklimit is bellow 1 (%d) ", taskLimitMB);
		return -3;
	} else if (taskLimitMB > 1024) {
		RTLogError(@"Tasklimit is in MB. %d is too high", taskLimitMB);
		return -2;
	} else if (taskLimitMB < maxRequestedTaskLimit) {
		RTLogWarn(@"Not updating Tasklimit to %d, previous requester %s already set it to %d mb", taskLimitMB, maxRequester, maxRequestedTaskLimit);
	} else {
		sendInfo(taskLimitMB, requester, pid);
	}

	return 0;
}
