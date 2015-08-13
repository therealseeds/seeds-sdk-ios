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
//  MobFoxCreativeTypesManager.h
//  MobFoxSDKSource
//
//  Created by Michał Kapuściński on 28.04.2015.
//  Changed by Oleksii Pelykh
//
//  Changes: removed unused Creative types;
//


#import <UIKit/UIKit.h>

typedef enum {
    MobFoxCreativeBanner = 1,
} MobFoxCreativeType;

@interface MobFoxCreative : NSObject

@property (nonatomic, assign) MobFoxCreativeType type;
@property (nonatomic, assign) float prob;

-(id) initWithType:(MobFoxCreativeType)type andProb:(float)prob;

@end

@interface MobFoxCreativesQueueManager : NSObject

+(id)sharedManagerWithPublisherId:(NSString*)publisherId;

- (NSMutableArray*) getCreativesQueueForBanner;

- (NSMutableArray*) getCreativesQueueForFullscreen;

-(MobFoxCreative*)getCreativeFromQueue:(NSMutableArray*)queue;

@end
