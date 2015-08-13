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

@class MobFoxAdBrowserViewController;

@protocol MobFoxAdBrowserViewController <NSObject>

- (void)mobfoxAdBrowserControllerDidDismiss:(MobFoxAdBrowserViewController *)mobfoxAdBrowserController;

@end

@interface MobFoxAdBrowserViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>
{
	UIWebView *_webView;
	NSURL *_url;
	NSString *userAgent;
	NSString *mimeType;
	NSString *textEncodingName;
	NSMutableData *receivedData;
    float barSize;

	__unsafe_unretained id <MobFoxAdBrowserViewController> delegate;
}

@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, readonly, strong) NSURL  *url;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, assign) __unsafe_unretained id <MobFoxAdBrowserViewController> delegate;

- (id)initWithUrl:(NSURL *)url;

@end
