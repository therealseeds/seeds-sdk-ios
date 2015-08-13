//
//  Copyright 2015 MobFox
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
#import "NSURL+MobFox.h"

@implementation NSURL (MobFox)

- (BOOL)isDeviceSupported
{
	NSString *scheme = [self scheme];
	NSString *host = [self host];
	if ([scheme isEqualToString:@"tel"] || [scheme isEqualToString:@"sms"] || [scheme isEqualToString:@"mailto"])
	{
		return YES;
	}
	if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])
	{
		if ([host isEqualToString:@"maps.google.com"])
		{
			return YES;
		}

		if ([host isEqualToString:@"www.youtube.com"])
		{
			return YES;
		}

		if ([host isEqualToString:@"phobos.apple.com"])
		{
			return YES;
		}
        
        if ([host hasSuffix:@"itunes.apple.com"])
		{
			return YES;
		}
        
	}
    if (([scheme isEqualToString:@"itms-apps"] && [host hasSuffix:@"itunes.apple.com"]) || ([scheme isEqualToString:@"itms-appss"] && [host hasSuffix:@"itunes.apple.com"]))
    {
        return YES;
    }
	return NO;	
}

@end

@implementation DummyURL

@end
