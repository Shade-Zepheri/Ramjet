var intFunc = @encode(void(int));

var handle = dlopen("/usr/lib/Ramjet.dylib", RTLD_NOW);

var updateTaskLimit = intFunc(dlsym(handle, "ramjet_updateTaskLimit"));
var updateTaskLimitForPID = intFunc(dlsym(handle, "ramjet_updateTaskLimitForPID"));
