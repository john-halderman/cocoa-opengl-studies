#import "NSString+Study.h"

@implementation NSString (Study)

+ (NSString *)stringWithCATransform3D:(CATransform3D)transform {
	return [NSString stringWithFormat:@"[\n[%.6f, %.6f, %.6f, %.6f],\n[%.6f, %.6f, %.6f, %.6f],\n[%.6f, %.6f, %.6f, %.6f],\n[%.6f, %.6f, %.6f, %.6f]]",
			transform.m11, transform.m12, transform.m13, transform.m14,
			transform.m21, transform.m22, transform.m23, transform.m24,
			transform.m31, transform.m32, transform.m33, transform.m34,
			transform.m41, transform.m42, transform.m43, transform.m44];
}

//+ (NSString *)stringWithSCNVector3:(SCNVector3)vector {
//	return [NSString stringWithFormat:@"[%.6f, %.6f, %.6f]", vector.x, vector.y, vector.z];
//}
//
//+ (NSString *)stringWithSCNVector4:(SCNVector4)vector {
//	return [NSString stringWithFormat:@"[%.6f, %.6f, %.6f, %.6f]", vector.x, vector.y, vector.z, vector.w];
//}

@end
