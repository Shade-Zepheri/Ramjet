#import "Ramjet-Private.h"
#import "Logging.h"

#include <memory.h>
#include <dlfcn.h>

#define MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT 6

typedef int (*dlysm_memoryStatus)(uint32_t command, pid_t pid, uint32_t flags, void *buffer, size_t buffersize);

static int updateTaskLimit(int taskLimitMB, char *requester, pid_t pid) {
		int response = -1;

		dlysm_memoryStatus memoryStatus;
		void *handle = dlopen(NULL, 0);
		memoryStatus = (dlysm_memoryStatus)dlsym(handle, "memorystatus_control");
		if (memoryStatus) {
				response = memoryStatus(MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT, pid, taskLimitMB, NULL, 0);
				if (response != 0) {
						RTLogError(@"Error in setting taskLimit to %d by \"%s\" error: %s", taskLimitMB, requester, strerror(errno));
				} else {
						RTLogInfo(@"Sucessfully set taskLimit to %d by \"%s\"", taskLimitMB, requester);
				}
		} else {
				RTLogError(@"Error in creating dlysm_memoryStatus");
		}

		return response;
}

static void receivedNotifcation(CFMachPortRef port, LMMessage *request, CFIndex size, void *info) {
		if ((size_t)size < sizeof(LMMessage)) {
				RTLogError(@"received a bad message? size = %li", size);
				return;
		}

		//convert to NSDictionary
		const void *rawData = LMMessageGetData(request);
		size_t length = LMMessageGetDataLength(request);
		CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)rawData, length, kCFAllocatorNull);
		NSDictionary *userInfo = LMPropertyListForData((__bridge NSData *)data);

		NSValue *infoStruct = [userInfo objectForKey:@"Request"];
		RamjetInfo requestInfo;
		[infoStruct getValue:&requestInfo];

		updateTaskLimit(requestInfo.memorySize, requestInfo.requester, requestInfo.pid);
}

int main(int argc, char **argv, char **envp) {
		kern_return_t error = LMStartService(connection.serverName, CFRunLoopGetCurrent(), (CFMachPortCallBack)receivedNotifcation);

		if (error) {
				RTLogError(@"Failed to start daemon: error %i", error);
		}

		return 0;
}
