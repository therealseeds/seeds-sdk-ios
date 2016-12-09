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


#import "MobFoxInterstitialPlayerViewController.h"

@interface MobFoxInterstitialPlayerViewController ()

@end

@implementation MobFoxInterstitialPlayerViewController

@synthesize adInterstitialOrientation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    self.edgesForExtendedLayout = UIRectEdgeAll;

}

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([adInterstitialOrientation isEqualToString:@"landscape"] || [adInterstitialOrientation isEqualToString:@"Landscape"]) {
        return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
    }

    if ([adInterstitialOrientation isEqualToString:@"Portrait"] || [adInterstitialOrientation isEqualToString:@"portrait"]) {
        return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
    }

    return NO;
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if ([adInterstitialOrientation isEqualToString:@"landscape"] || [adInterstitialOrientation isEqualToString:@"Landscape"]) {
        return UIInterfaceOrientationMaskLandscape;
    }

    if ([adInterstitialOrientation isEqualToString:@"Portrait"] || [adInterstitialOrientation isEqualToString:@"portrait"]) {
        return UIInterfaceOrientationMaskPortrait;
    }

    return UIInterfaceOrientationMaskAll;
}


@end
