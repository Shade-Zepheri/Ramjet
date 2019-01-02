#import <Foundation/Foundation.h>

#import "Ramjet.h"
#import "Ramjet-Private.h"
#import "Logging.h"

static int maxRequestedTaskLimit;
static char maxRequester[MAX_REQUEST_NAME];

extern int ramjet_updateTaskLimit(uint32_t taskLimitMB, char *requester) {
	return ramjet_updateTaskLimitForPID(taskLimitMB, requester, getpid());
}

static BOOL sendInfo(uint32_t taskLimitMB, char *requester, pid_t pid) {
	__block BOOL result;

	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_queue_t queue = dispatch_queue_create([NSString stringWithFormat:@"com.shade.ramjet%f", [NSDate date].timeIntervalSince1970].UTF8String, DISPATCH_QUEUE_SERIAL);
	dispatch_async(queue, ^{
		RamjetInfo info;
		info.memorySize = taskLimitMB;
		info.pid = pid;
		strncpy(info.requester, requester, MAX_REQUEST_NAME-1);

		NSData *input = [NSData dataWithBytes:&info length:sizeof(info)];
		result = LMConnectionSendOneWayData(&connection, 0, (__bridge CFDataRef)input);

		dispatch_semaphore_signal(semaphore);
	});

	dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));

	return result;
}

extern int ramjet_updateTaskLimitForPID(uint32_t taskLimitMB, char *requester, pid_t pid) {
	if (taskLimitMB < 1) {
		RTLogError(@"Requested Tasklimit is bellow 1 (%d) ", taskLimitMB);
		return -3;
	} else if (taskLimitMB > 1024) {
		RTLogError(@"Tasklimit is in MB. %d is too high", taskLimitMB);
		return -2;
	} else if (taskLimitMB < maxRequestedTaskLimit) {
		RTLogWarn(@"Not updating Tasklimit to %d, previous requester %s already set it to %d mb", taskLimitMB, maxRequester, maxRequestedTaskLimit);
	} else {
		if (!sendInfo(taskLimitMB, requester, pid)) {
			RTLogError(@"Couldn't communicate with daemon");
			return -1;
		}

		strncpy(maxRequester, requester, MAX_REQUEST_NAME-1);
		maxRequestedTaskLimit = taskLimitMB;
	}

	return 0;
}
