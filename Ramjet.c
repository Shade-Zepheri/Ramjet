#include "Ramjet.h"
#include "Ramjet-Private.h"
#include <os/log.h>
#include <xpc/xpc.h>

static uint32_t maxRequestedTaskLimit;
static char *maxRequester;

extern kern_return_t ramjet_updateTaskLimit(uint32_t taskLimitMB, char *requester) {
	return ramjet_updateTaskLimitForPID(taskLimitMB, requester, getpid());
}

static kern_return_t sendInfo(uint32_t taskLimitMB, char *requester, pid_t pid) {
	// Set default error
	__block kern_return_t error = KERN_SUCCESS;

	// Create connection
	xpc_connection_t connection =  xpc_connection_create_mach_service("com.shade.ramjetd", NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
	if (connection == NULL) {
		// Couldnt create connection
		os_log_error(OS_LOG_DEFAULT, "Failed to create xpc connection");
		return KERN_FAILURE;
	}

	xpc_connection_resume(connection);

	// Init struct
	RamjetInfo info;
	info.memorySize = taskLimitMB;
	info.pid = pid;
	info.requester = requester;

	// Send over data
	xpc_object_t data = xpc_data_create(&info, sizeof(info));
	xpc_connection_send_message_with_reply(connection, data, NULL, ^(xpc_object_t response) {
		if (xpc_get_type(response) != XPC_TYPE_INT64) {
			// Cant parse response
			error = KERN_INVALID_OBJECT;
		} else {
			// Get reply of failure status
			error = xpc_int64_get_value(response);
		}
	});

	return error;
}

extern kern_return_t ramjet_updateTaskLimitForPID(uint32_t taskLimitMB, char *requester, pid_t pid) {
	if (taskLimitMB < 1) {
		os_log_error(OS_LOG_DEFAULT, "Requested Tasklimit is below 1 (%u) ", taskLimitMB);
		return KERN_INVALID_ARGUMENT;
	} else if (taskLimitMB > 1024) {
		os_log_error(OS_LOG_DEFAULT, "Tasklimit is in MB. %u is too high", taskLimitMB);
		return KERN_INVALID_ARGUMENT;
	} else if (taskLimitMB < maxRequestedTaskLimit) {
		os_log_info(OS_LOG_DEFAULT, "Not updating Tasklimit to %u, previous requester %s already set it to %u mb", taskLimitMB, maxRequester, maxRequestedTaskLimit);
	} else {
		if (sendInfo(taskLimitMB, requester, pid) != KERN_SUCCESS) {
			// Couldnt send info
			os_log_error(OS_LOG_DEFAULT, "Error in setting task limit");
			return KERN_FAILURE;
		}

		// Update maxes
		maxRequester = requester;
		maxRequestedTaskLimit = taskLimitMB;
	}

	return KERN_SUCCESS;
}
