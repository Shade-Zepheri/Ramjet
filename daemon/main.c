#include "Ramjet-Private.h"
#include <errno.h>
#include <sys/kern_memorystatus.h>
#include <os/log.h>
#include <xpc/xpc.h>

static int updateTaskLimit(uint32_t taskLimitMB, char *requester, pid_t pid) {
	// Set high water mark
	int response = memorystatus_control(MEMORYSTATUS_CMD_SET_JETSAM_HIGH_WATER_MARK, pid, taskLimitMB, NULL, 0);
		if (response != 0) {
			os_log_error(OS_LOG_DEFAULT, "Error in setting taskLimit to %u by \"%s\" error: %s", taskLimitMB, requester, strerror(errno));
		} else {
			os_log_info(OS_LOG_DEFAULT, "Successfully set taskLimit to %u by \"%s\"", taskLimitMB, requester);
		}

	return response;
}

int main(int argc, const char *argv[]) {
	// Create connection
	xpc_connection_t connection = xpc_connection_create_mach_service("com.shade.ramjetd", NULL, XPC_CONNECTION_MACH_SERVICE_LISTENER);

	// Set handler
	xpc_connection_set_event_handler(connection, ^(xpc_object_t object) {
		if (xpc_get_type(object) != XPC_TYPE_DATA) {
			// Not data, cant work
			os_log_error(OS_LOG_DEFAULT, "Received object is not data");
			return;
		}

		// Parse data
		RamjetInfo receivedInfo;
		size_t receivedSize = xpc_data_get_bytes(object, &receivedInfo, 0, sizeof(receivedInfo));

		// So it can stop bugging me
		os_log_debug(OS_LOG_DEFAULT, "Got size %zu", receivedSize);

		// Update limit
		updateTaskLimit(receivedInfo.memorySize, receivedInfo.requester, receivedInfo.pid);
	});

	xpc_connection_resume(connection);

	// Should never reach this point
	exit(EXIT_FAILURE);
}