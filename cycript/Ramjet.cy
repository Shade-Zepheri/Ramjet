var intFunc = @encode(int(int, char*));
var pidFunc = @encode(int(int, char*, int));

var handle = dlopen("/usr/lib/libramjet.dylib", RTLD_NOW);

var updateTaskLimit = intFunc(dlsym(handle, "ramjet_updateTaskLimit"));
var updateTaskLimitForPID = pidFunc(dlsym(handle, "ramjet_updateTaskLimitForPID"));
