#import <Foundation/Foundation.h>
#include <signal.h>

#define MAX_REQUEST_NAME 1024

#define LIGHTMESSAGING_USE_ROCKETBOOTSTRAP 0
#import <LightMessaging/LightMessaging.h>

static LMConnection connection = {
	MACH_PORT_NULL,
	"com.shade.ramjetd"
};

typedef struct {
	uint32_t memorySize;
	char requester[MAX_REQUEST_NAME];
	pid_t pid;
} RamjetInfo;
