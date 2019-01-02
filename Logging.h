#import <os/log.h>

#define RT_LOG_INTERNAL(level, type, ...) os_log_with_type(OS_LOG_DEFAULT, level, "[RAMJET %{public}s:%{public}d] %{public}@", __BASE_FILE__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])

#define RTLogDebug(...) RT_LOG_INTERNAL(OS_LOG_TYPE_DEBUG, "DEBUG", __VA_ARGS__)
#define RTLogInfo(...) RT_LOG_INTERNAL(OS_LOG_TYPE_INFO, "INFO", __VA_ARGS__)
#define RTLogWarn(...) RT_LOG_INTERNAL(OS_LOG_TYPE_DEFAULT, "WARN", __VA_ARGS__)
#define RTLogError(...) RT_LOG_INTERNAL(OS_LOG_TYPE_ERROR, "ERROR", __VA_ARGS__)