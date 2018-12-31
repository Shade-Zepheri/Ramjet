#import <Foundation/Foundation.h>
#include <signal.h>

#define MAX_REQUEST_NAME 1024

//Add daemon logic if needed
#define LIGHTMESSAGING_TIMEOUT 500
#define LIGHTMESSAGING_USE_ROCKETBOOTSTRAP 0
#import <LightMessaging/LightMessaging.h>

#define kRamjetDaemon "ramjetdaemon"

LMConnection connection = {
	MACH_PORT_NULL,
	kRamjetDaemon
};

typedef struct {
	int memorySize;
	char *requester;
	pid_t pid;
} RamjetInfo;
