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
//  CustomEventFullscreen.m
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 10.03.2014.
//
//

#import "MFCustomEventFullscreen.h"

@implementation MFCustomEventFullscreen

@synthesize delegate;
@synthesize trackingPixel;

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel
{
    //to be overriden by subclasses
}

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController
{
    //must be overriden by subclasses
}

- (void)didDisplayAd;
{
    @try {
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString* userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        
        if(trackingPixel) {
            NSURL *url = [NSURL URLWithString:[trackingPixel stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            [request setHTTPMethod: @"GET"];
            [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {}];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error when tracking custom event interstitial");
    }
    
}

-(void)notifyAdFailed {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        if(delegate) {
            [self.delegate customEventFullscreenDidFailToLoadAd];
        }
        
        [self finish];
    });
}

-(void)notifyAdLoaded {
    if(delegate) {
        [self.delegate customEventFullscreenDidLoadAd:self];
    }
}

-(void)notifyAdWillAppear {
    [self didDisplayAd];
    if(delegate) {
        [self.delegate customEventFullscreenWillAppear];
    }
}

-(void)notifyAdWillClose {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{

        if(delegate) {
            [self.delegate customEventFullscreenWillClose];
        }
        [self finish];
    });
}

-(void)notifyAdWillLeaveApplication {
    if(delegate) {
        [self.delegate customEventFullscreenWillLeaveApplication];
    }
}

-(void)finish
{
    self.delegate = nil;
}


@end
