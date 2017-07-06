#include <CoreFoundation/CFLogUtilities.h>

/* Log Levels
enum _CFLogLevel {
  kCFLogLevelEmergency = 0,
  kCFLogLevelAlert     = 1,
  kCFLogLevelCritical  = 2,
  kCFLogLevelError     = 3,
  kCFLogLevelWarning   = 4,
  kCFLogLevelNotice    = 5,
  kCFLogLevelInfo      = 6,
  kCFLogLevelDebug     = 7
};
*/

#define RT_LOG_FORMAT(color) CFSTR("\e[1;3" #color "m[%s] \e[m\e[0;3" #color "m%s:%d\e[m \e[0;30;4" #color "m%s:\e[m %@")

#ifdef __DEBUG__
    #define RT_LOG_INTERNAL(color, level, type, ...) CFLog(level, RT_LOG_FORMAT(color), "Ramjet", __BASE_FILE__, __LINE__, type, (__bridge CFStringRef)[NSString stringWithFormat:__VA_ARGS__]);
#else
    #define RT_LOG_INTERNAL(color, level, type, ...)
#endif

#define RTLogError(...) RT_LOG_INTERNAL(1, kCFLogLevelError, "ERROR", __VA_ARGS__)
#define RTLogWarn(...) RT_LOG_INTERNAL(3, kCFLogLevelWarning, "WARN", __VA_ARGS__)
#define RTLogInfo(...) RT_LOG_INTERNAL(2, kCFLogLevelInfo, "INFO", __VA_ARGS__)
#define RTLogDebug(...) RT_LOG_INTERNAL(6, kCFLogLevelDebug, "DEBUG", __VA_ARGS__)
