#import "TouchBar.h"

// required MultitouchSupport.framework
NS_ASSUME_NONNULL_BEGIN

CF_EXPORT CFTypeRef MTActuatorCreateFromDeviceID(UInt64 deviceID);
CF_EXPORT IOReturn MTActuatorOpen(CFTypeRef actuatorRef);
CF_EXPORT IOReturn MTActuatorClose(CFTypeRef actuatorRef);
CF_EXPORT IOReturn MTActuatorActuate(CFTypeRef actuatorRef, SInt32 actuationID, UInt32 arg1, Float32 arg2, Float32 arg3);
CF_EXPORT bool MTActuatorIsOpen(CFTypeRef actuatorRef);

CF_EXPORT void CoreDisplay_Display_SetUserBrightness(int CGDirectDisplayID, double level);
CF_EXPORT double CoreDisplay_Display_GetUserBrightness(int CGDirectDisplayID);

NS_ASSUME_NONNULL_END
