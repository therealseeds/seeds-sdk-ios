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
#import <UIKit/UIKit.h>

@class MFRedirectChecker;

@protocol MFRedirectCheckerDelegate <NSObject>

- (void)checker:(MFRedirectChecker *)checker detectedRedirectionTo:(NSURL *)redirectURL;
- (void)checker:(MFRedirectChecker *)checker didFinishWithData:(NSData *)data;

@optional
- (void)checker:(MFRedirectChecker *)checker didFailWithError:(NSError *)error;

@end

@interface MFRedirectChecker : NSObject 
{
	__unsafe_unretained id <MFRedirectCheckerDelegate> _delegate;
	NSMutableData *receivedData;
	NSString *mimeType;
	NSString *textEncodingName;
	NSURLConnection *_connection;
}

- (id)initWithURL:(NSURL *)url userAgent:(NSString *)userAgent delegate:(id<MFRedirectCheckerDelegate>) delegate;

@property (nonatomic, assign) __unsafe_unretained id <MFRedirectCheckerDelegate> delegate;

@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *textEncodingName;

@end
