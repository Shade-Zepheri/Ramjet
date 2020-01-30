#include "Ramjet.h"
#include "Ramjet-Private.h"
#include <os/log.h>
#include <xpc/xpc.h>

static uint32_t maxRequestedTaskLimit;
static char *maxRequester;

extern kern_return_t ramjet_updateTaskLimit(uint32_t taskLimitMB, char *requester) {
	return ramjet_updateTaskLimitForPID(taskLimitMB, requester, getpid());
}

static bool sendInfo(uint32_t taskLimitMB, char *requester, pid_t pid) {
	// Create connection
	xpc_connection_t connection =  xpc_connection_create_mach_service("com.shade.ramjetd", NULL, 0);
	if (connection == NULL) {
		// Couldnt create connection
		os_log_error(OS_LOG_DEFAULT, "Failed to create xpc connection");
		return false;
	}

	xpc_connection_resume(connection);

	// Init struct
	RamjetInfo info;
	info.memorySize = taskLimitMB;
	info.pid = pid;
	info.requester = requester;

	// Send over data
	xpc_object_t data = xpc_data_create(&info, sizeof(info));
	xpc_connection_send_message(connection, data);

	return true;
}

extern kern_return_t ramjet_updateTaskLimitForPID(uint32_t taskLimitMB, char *requester, pid_t pid) {
	if (taskLimitMB < 1) {
		os_log_error(OS_LOG_DEFAULT, "Requested Tasklimit is bellow 1 (%u) ", taskLimitMB);
		return KERN_INVALID_VALUE;
	} else if (taskLimitMB > 1024) {
		os_log_error(OS_LOG_DEFAULT, "Tasklimit is in MB. %u is too high", taskLimitMB);
		return KERN_INVALID_VALUE;
	} else if (taskLimitMB < maxRequestedTaskLimit) {
		os_log_info(OS_LOG_DEFAULT, "Not updating Tasklimit to %u, previous requester %s already set it to %u mb", taskLimitMB, maxRequester, maxRequestedTaskLimit);
	} else {
		if (!sendInfo(taskLimitMB, requester, pid)) {
			// Couldnt send info
			os_log_error(OS_LOG_DEFAULT, "Couldn't communicate with daemon");
			return KERN_FAILURE;
		}

		// Update maxes
		maxRequester = requester;
		maxRequestedTaskLimit = taskLimitMB;
	}

	return KERN_SUCCESS;
}
