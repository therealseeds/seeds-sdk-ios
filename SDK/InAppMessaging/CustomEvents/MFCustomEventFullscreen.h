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
//  CustomEventFullscreen.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 10.03.2014.
//
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MFCustomEventFullscreenDelegate.h"

@interface MFCustomEventFullscreen : NSObject

- (void)loadFullscreenWithOptionalParameters:(NSString *)optionalParameters trackingPixel:(NSString *)trackingPixel;

- (void)showFullscreenFromRootViewController:(UIViewController *)rootViewController;

- (void)notifyAdFailed;

- (void)notifyAdLoaded;

- (void)notifyAdWillAppear;

- (void)notifyAdWillClose;

- (void)notifyAdWillLeaveApplication;

- (void)finish;


@property (nonatomic, assign) id<MFCustomEventFullscreenDelegate> delegate;
@property (nonatomic, retain) NSString* trackingPixel;

@end
