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

	// Create handler for new connections
	xpc_connection_set_event_handler(connection, ^(xpc_object_t peer) {
		os_log_debug(OS_LOG_DEFAULT, "Received new peer: %p", peer);

		// Create handler for data
		xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
			// Set defaults
			kern_return_t error = KERN_SUCCESS;

			if (event == XPC_ERROR_CONNECTION_INVALID) {
				// Invalid connection, cant do anything
				os_log_error(OS_LOG_DEFAULT, "Connection is invalid");
				return;
			}

			if (xpc_get_type(event) != XPC_TYPE_DATA) {
				// Not data, cant parse
				error = KERN_ABORTED;
			} else {
				// Parse data
				RamjetInfo receivedInfo;
				size_t receivedSize = xpc_data_get_bytes(event, &receivedInfo, 0, sizeof(receivedInfo));

				// So it can stop bugging me
				os_log_debug(OS_LOG_DEFAULT, "Got size %zu", receivedSize);

				// Update limit
				error = updateTaskLimit(receivedInfo.memorySize, receivedInfo.requester, receivedInfo.pid);
			}

			// Send response
			xpc_object_t response = xpc_int64_create(error);
			xpc_connection_send_message(peer, response);
		});

		// Resume connection
		xpc_connection_resume(peer);
	});

	// Run forever
	dispatch_main();

	// Should never reach this point
	exit(EXIT_FAILURE);
}
