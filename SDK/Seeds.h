
// Seeds.h
//
// This code is provided under the MIT License.
//
// Please visit www.count.ly for more information.
//
// Changed by Oleksii Pelykh
//
// Changes: renamed to 'Seeds';
//

#import "SeedsInterstitials.h"
#import "SeedsInterstitial.h"
#import "SeedsEvents.h"

@interface Seeds : NSObject

+ (void)initWithAppKey:(NSString *)appKey;
+ (SeedsInterstitials *)interstitials;
+ (SeedsEvents *)events;

@end
