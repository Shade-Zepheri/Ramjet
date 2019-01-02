#import "Ramjet-Private.h"
#import "Logging.h"

#include <memory.h>
#include <dlfcn.h>

#define MEMORYSTATUS_CMD_SET_JETSAM_HIGH_WATER_MARK   5    /* Set active memory limit = inactive memory limit, both non-fatal	*/
#define MEMORYSTATUS_CMD_SET_JETSAM_TASK_LIMIT	      6    /* Set active memory limit = inactive memory limit, both fatal	*/

typedef int (*dlysm_memoryStatus)(uint32_t command, pid_t pid, uint32_t flags, void *buffer, size_t buffersize);

static int updateTaskLimit(uint32_t taskLimitMB, char *requester, pid_t pid) {
	int response = -1;

	dlysm_memoryStatus memoryStatus;
	void *handle = dlopen(NULL, 0);
	memoryStatus = (dlysm_memoryStatus)dlsym(handle, "memorystatus_control");
	if (memoryStatus) {
		response = memoryStatus(MEMORYSTATUS_CMD_SET_JETSAM_HIGH_WATER_MARK, pid, taskLimitMB, NULL, 0);
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

static void receivedNotifcation(CFMachPortRef port, void *bytes, CFIndex size, void *info) {
	LMMessage *request = bytes;
	if (!LMDataWithSizeIsValidMessage(bytes, size)) {
		RTLogError(@"received a bad message? size = %li", size);
		LMResponseBufferFree(bytes);
		return;
	}

	// Retrieve and unarchive data
	CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)LMMessageGetData(request), LMMessageGetDataLength(request), kCFAllocatorNull);
	RamjetInfo requestInfo;
	[(__bridge NSData *)data getBytes:&requestInfo length:sizeof(requestInfo)];

	updateTaskLimit(requestInfo.memorySize, requestInfo.requester, requestInfo.pid);
	LMResponseBufferFree(bytes);
}

int main() {
	kern_return_t result = LMCheckInService(connection.serverName, CFRunLoopGetCurrent(), receivedNotifcation, NULL);

	if (result != KERN_SUCCESS) {
		RTLogError(@"Failed to start daemon: error %i", result);
	}

	CFRunLoopRun();
	return 0;
}
