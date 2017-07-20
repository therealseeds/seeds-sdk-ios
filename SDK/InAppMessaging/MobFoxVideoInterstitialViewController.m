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
//  Changed by Oleksii Pelykh
//
//  Changes: removed unused imports; removed video support; kept only text&image ads support;
//

#import "MobFoxVideoInterstitialViewController.h"
#import "NSString+MobFox.h"

#import "NSURL+MobFox.h"
#import "MobFoxAdBrowserViewController.h"
#import "MobFoxToolBar.h"

#import "MobFoxHTMLBannerView.h"

#import "UIImage+MobFox.h"
#import "UIButton+MobFox.h"

#import "UIDevice+MFIdentifierAddition.h"

#include "MobFoxInterstitialPlayerViewController.h"

#import "MFCustomEventFullscreen.h"
#import "Seeds.h"
#import "Seeds_Private.h"
#import "SeedsInAppMessageDelegate.h"

NSString * const MobFoxVideoInterstitialErrorDomain = @"MobFoxVideoInterstitial";

@interface MobFoxVideoInterstitialViewController ()<UIGestureRecognizerDelegate, UIActionSheetDelegate, MFCustomEventFullscreenDelegate, MobFoxHTMLBannerViewDelegate> {
    BOOL interstitialSkipButtonShow;
    NSTimeInterval interstitialSkipButtonDisplayDelay;
    BOOL interstitialSkipButtonDisplayed;
    BOOL interstitialAutoCloseDisabled;
    NSTimeInterval interstitialAutoCloseDelay;
    BOOL interstitialTimerShow;
    BOOL alreadyRequestedInterstitial;

    UIInterfaceOrientation requestedAdOrientation;
    
    BOOL currentlyPlayingInterstitial;
    float buttonSize;
    MobFoxAdType advertTypeCurrentlyPlaying;
    BOOL advertRequestInProgress;

    NSString *adInterstitialOrientation;

    UIViewController *viewController;
    UIViewController *interstitialViewController;

    NSInteger HTMLOverlayWidth;
    NSInteger HTMLOverlayHeight;

    UIView *tempView;
}

@property (nonatomic, strong) MobFoxInterstitialPlayerViewController *mobFoxInterstitialPlayerViewController;

@property (nonatomic, strong) MFCustomEventFullscreen *customEventFullscreen;

@property (nonatomic, strong) MobFoxToolBar *interstitialTopToolbar;
@property (nonatomic, strong) MobFoxToolBar *interstitialBottomToolbar;
@property (nonatomic, strong) NSMutableArray *interstitialTopToolbarButtons;
@property (nonatomic, strong) UIView *interstitialHoldingView;
@property (nonatomic, strong) UIWebView *interstitialWebView;
@property (nonatomic, strong) NSDate *timerStartTime;
@property (nonatomic, strong) NSTimer *interstitialTimer;
@property (nonatomic, strong) UILabel *interstitialTimerLabel;
@property (nonatomic, copy) NSString *interstitialMarkup;
@property (nonatomic, strong) UIButton *browserBackButton;
@property (nonatomic, strong) UIButton *browserForwardButton;
@property (nonatomic, copy) NSString *interstitialURL;
@property (nonatomic, copy) NSString *videoClickThrough;
@property (nonatomic, copy) NSString *overlayClickThrough;

@property (nonatomic, strong) UIButton *interstitialSkipButton;

@property (nonatomic, strong) NSMutableArray *videoAdvertTrackingEvents;

@property (nonatomic, strong) NSString *IPAddress;

@property (nonatomic, assign) CGFloat currentLatitude;
@property (nonatomic, assign) CGFloat currentLongitude;

@property(nonatomic, readwrite, getter=isAdvertLoaded) BOOL advertLoaded;
@property(nonatomic, readwrite, getter=isAdvertViewActionInProgress) BOOL advertViewActionInProgress;

@property (nonatomic, strong) NSString *userAgent;

@property (nonatomic, strong) NSMutableDictionary *browserUserAgentDict;

- (void)interstitialStartTimer;
- (void)interstitialStopTimer;
- (void)interstitialSkipAction:(id)sender;

- (void)advertAddNotificationObservers:(MobFoxAdGroupType)adGroup;
- (void)advertRemoveNotificationObservers:(MobFoxAdGroupType)adGroup;
- (void)advertCreationFailed;
- (void)advertCreatedSuccessfully:(MobFoxAdType)advertType;
- (void)advertActionTrackingEvent:(NSString*)eventType;
- (void)advertShow:(MobFoxAdType)advertType viewToShow:(UIView*)viewToShow;
- (void)advertTidyUpAfterAd:(MobFoxAdType)advertType;

- (void)setup;

- (void)updateAllFrames:(UIInterfaceOrientation)interfaceOrientation;
- (CGRect)returnVideoHTMLOverlayFrame;
- (CGRect)returnInterstitialWebFrame;
- (NSString*)returnDeviceIPAddress;

@end


@implementation MobFoxVideoInterstitialViewController

@synthesize delegate;
@synthesize locationAwareAdverts;
@synthesize enableInterstitialAds;
@synthesize currentLatitude;
@synthesize currentLongitude;
@synthesize advertViewActionInProgress;
@synthesize requestURL;

@synthesize videoAdvertTrackingEvents, IPAddress;
@synthesize interstitialTimer;
@synthesize timerStartTime, interstitialTimerLabel;
@synthesize interstitialTopToolbar, interstitialBottomToolbar, interstitialTopToolbarButtons, interstitialSkipButton;
@synthesize interstitialURL, interstitialHoldingView, interstitialWebView, interstitialMarkup, browserBackButton, browserForwardButton;
@synthesize userAgent;
@synthesize userAge, userGender, keywords;
@synthesize seedsMessageId, seedsMessageContext, seedsMessageVariant;
@synthesize manuallyEnteredLocalizedPrice;

#pragma mark - Init/Dealloc Methods

- (UIColor *)randomColor
{
    CGFloat red = (arc4random()%256)/256.0;
    CGFloat green = (arc4random()%256)/256.0;
    CGFloat blue = (arc4random()%256)/256.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    enableInterstitialAds = YES;

    [self setUpBrowserUserAgentStrings];

    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        buttonSize = 40.0f;
    }
    else
    {
        buttonSize = 50.0f;
    }

    CGRect mainFrame = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:mainFrame];
    self.view.backgroundColor = [UIColor clearColor];

	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.view.autoresizesSubviews = YES;

    self.view.alpha = 0.0f;
    self.view.hidden = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    self.IPAddress = [self returnDeviceIPAddress];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.delegate = nil;
    [self interstitialStopTimer];
}

#pragma mark - Utilities

- (void)setUpBrowserUserAgentStrings {

    NSArray *array;
    self.browserUserAgentDict = [NSMutableDictionary dictionaryWithCapacity:0];
	array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.2.2"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.2.1"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.2"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.9"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.8"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.7"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.6"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.5"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.4"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.3"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.2"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1.1"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.1"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.0.2"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.0.1"];
    array = @[@" Version/6.0", @" Safari/8536.25"];
    [self.browserUserAgentDict setObject:array forKey:@"6.0"];
    array = @[@" Version/5.1", @" Safari/7534.48.3"];
    [self.browserUserAgentDict setObject:array forKey:@"5.1.1"];
    array = @[@" Version/5.1", @" Safari/7534.48.3"];
    [self.browserUserAgentDict setObject:array forKey:@"5.1"];
    array = @[@" Version/5.1", @" Safari/7534.48.3"];
    [self.browserUserAgentDict setObject:array forKey:@"5.0.1"];
    array = @[@" Version/5.1", @" Safari/7534.48.3"];
    [self.browserUserAgentDict setObject:array forKey:@"5.0"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.5"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.4"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.3"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.2"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3.1"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.3"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.10"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.9"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.8"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.7"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.6"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.5"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2.1"];
    array = @[@" Version/5.0.2", @" Safari/6533.18.5"];
    [self.browserUserAgentDict setObject:array forKey:@"4.2"];
    array = @[@" Version/4.0.5", @" Safari/6531.22.7"];
    [self.browserUserAgentDict setObject:array forKey:@"4.1"];
}

- (NSString*)browserAgentString
{

    NSString *osVersion = [UIDevice currentDevice].systemVersion;
    NSArray *agentStringArray = self.browserUserAgentDict[osVersion];

    NSMutableString *agentString = [NSMutableString stringWithString:self.userAgent];
    NSRange range = [agentString rangeOfString:@"like Gecko)"];

    if (range.location != NSNotFound && range.length) {

        NSInteger theIndex = range.location + range.length;

		if ([agentStringArray objectAtIndex:0]) {
			[agentString insertString:[agentStringArray objectAtIndex:0] atIndex:theIndex];
			[agentString appendString:[agentStringArray objectAtIndex:1]];
		}
        else {
			[agentString insertString:@" Version/unknown" atIndex:theIndex];
			[agentString appendString:@" Safari/unknown"];
		}

    }

    return agentString;
}

- (NSString*)returnDeviceIPAddress {

    NSString *IPAddressToReturn;

    #if TARGET_IPHONE_SIMULATOR
        IPAddressToReturn = [UIDevice localSimulatorIPAddress];
    #else

        IPAddressToReturn = [UIDevice localWiFiIPAddress];

        if(!IPAddressToReturn) {
            IPAddressToReturn = [UIDevice localCellularIPAddress];
        }

    #endif

    return IPAddressToReturn;
}

- (id) traverseResponderChainForUIViewController 
{
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}

- (UIViewController *) firstAvailableUIViewController 
{
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (void)removeUIWebViewBounce:(UIWebView*)theWebView {

    for (id subview in theWebView.subviews) {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
            ((UIScrollView *)subview).bounces = NO;
        }
    }

}

- (void)showErrorLabelWithText:(NSString *)text
{
	UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
	label.numberOfLines = 0;
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont boldSystemFontOfSize:12];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor redColor];

	label.text = text;
	[self.view addSubview:label];
}

- (NSString *)extractStringFromContents:(NSString *)beginningString endingString:(NSString *)endingString contents:(NSString *)contents {
    if (!contents) {
        return nil;
    }

	NSMutableString *localContents = [NSMutableString stringWithString:contents];
	NSRange theRangeBeginning = [localContents rangeOfString:beginningString options:NSCaseInsensitiveSearch];
	if (theRangeBeginning.location == NSNotFound) {
		return nil;
	}
	long location = theRangeBeginning.location + theRangeBeginning.length;
	long length = [localContents length] - location;
	NSRange theRangeToSearch = {location, length};
	NSRange theRangeEnding = [localContents rangeOfString:endingString options:NSCaseInsensitiveSearch range:theRangeToSearch];
	if (theRangeEnding.location == NSNotFound) {
		return nil;
	}
	location = theRangeBeginning.location + theRangeBeginning.length ; 
	length = theRangeEnding.location - location;
	if (length == 0) {
		return nil;
	}
	NSRange theRangeToGet = {location, length};
	return [localContents substringWithRange:theRangeToGet];	
}

- (NSURL *)serverURL
{
	return [NSURL URLWithString:self.requestURL];
}

#pragma mark Properties

#pragma mark - Location

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    self.currentLatitude = latitude;
    self.currentLongitude = longitude;
}

#pragma mark - Ad Request

- (BOOL)isAdvertLoaded:(NSString*)messageId
{
    if (!self.advertLoaded)
        return NO;
    return messageId == nil || [messageId isEqualToString:seedsMessageId];
}

- (void)requestAd:(NSString*)messageId
{
    if (self.advertLoaded || self.advertViewActionInProgress || advertRequestInProgress) {
        return;
    }

    if (!delegate)
	{
		[self showErrorLabelWithText:@"MobFoxVideoInterstitialViewDelegate not set"];

		return;
	}
	if (![delegate respondsToSelector:@selector(publisherIdForMobFoxVideoInterstitialView:)])
	{
		[self showErrorLabelWithText:@"MobFoxVideoInterstitialViewDelegate does not implement publisherIdForMobFoxBannerView:"];

		return;
	}

	NSString *publisherId = [delegate publisherIdForMobFoxVideoInterstitialView:self];
	if (![publisherId length])
	{
		[self showErrorLabelWithText:@"MobFoxVideoInterstitialViewDelegate returned invalid publisher ID."];

        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Invalid publisher ID or Publisher ID not set" forKey:NSLocalizedDescriptionKey];

        NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorInventoryUnavailable userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];

		return;
	}
    advertRequestInProgress = YES;
    alreadyRequestedInterstitial = NO;
    
    if (enableInterstitialAds) {
        [self performSelectorInBackground:@selector(asyncRequestAdWrapper:) withObject:[NSArray arrayWithObjects:publisherId, messageId, nil]];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error creating ad- both video and interstitial ads disabled" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
        advertRequestInProgress = NO;
    }
}

- (void)asyncRequestAdWrapper:(NSArray*)args
{
    [self asyncRequestAdWithPublisherId:[args objectAtIndex:0]
                           andMessageId:[args count] == 2 ? [args objectAtIndex:1] : nil];
}

- (void)asyncRequestAdWithPublisherId:(NSString *)publisherId
{
    [self asyncRequestAdWithPublisherId:publisherId andMessageId:nil];
}

- (void)asyncRequestAdWithPublisherId:(NSString *)publisherId andMessageId:(NSString*)messageId
{
    alreadyRequestedInterstitial = YES;
	@autoreleasepool
	{
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        requestedAdOrientation = interfaceOrientation;
        NSString *orientation = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? @"portrait" : @"landscape";
        NSString *deviceId = Seeds.sharedInstance.deviceId;

        NSString *fullRequestString = [NSString stringWithFormat:@"app_key=%@&orientation=%@&device_id=%@",
                                       [publisherId stringByUrlEncoding],
                                       [orientation stringByUrlEncoding],
                                       [deviceId stringByUrlEncoding]];
        if (messageId != nil)
        {
            fullRequestString = [fullRequestString stringByAppendingString:[NSString stringWithFormat:@"&message_id=%@",
                                                                            [messageId stringByUrlEncoding]]];
        }

        NSURL *serverURL = [self serverURL];
        
        if (!serverURL) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error - no or invalid requestURL. Please set requestURL" forKey:NSLocalizedDescriptionKey];
            
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }
        
        NSURL *url;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/o/messages?%@", serverURL, fullRequestString]];

        //DEBUG
        NSLog(@"request = %@, fullRequestString = %@", url, fullRequestString);
        
        NSMutableURLRequest *request;
        NSError *error;
        NSURLResponse *response;
        NSData *dataReply;
        
        request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod: @"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [paths objectAtIndex:0];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString* cacheFile = [cachePath stringByAppendingPathComponent:fullRequestString];

        dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (!dataReply) {
            if ([fileManager fileExistsAtPath:cacheFile])
                dataReply = [NSData dataWithContentsOfFile:cacheFile];
        }
        if (!dataReply)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error reading response from server"
                                                                 forKey:NSLocalizedDescriptionKey];

            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain
                                                 code:MobFoxInterstitialViewErrorUnknown
                                             userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }

        error = nil;
        NSDictionary* jsonReply = [NSJSONSerialization JSONObjectWithData:dataReply options:0 error:&error];

        if (!jsonReply)
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Error parsing json response from server"
                                                                 forKey:NSLocalizedDescriptionKey];
            
            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain
                                                 code:MobFoxInterstitialViewErrorUnknown
                                             userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            return;
        }

        [dataReply writeToFile:cacheFile atomically:YES];

        jsonReply = [NSMutableDictionary dictionaryWithDictionary:jsonReply];
        if (messageId != nil && [jsonReply objectForKey:@"message_id"] == nil)
            [(NSMutableDictionary*)jsonReply setObject:messageId forKey:@"message_id"];

        [self performSelectorOnMainThread:@selector(advertCreateFromJSON:) withObject:jsonReply waitUntilDone:YES];
	}
    
}

#pragma mark - Ad Creation

- (void)advertCreateFromJSON:(NSDictionary*)json
{
	advertTypeCurrentlyPlaying = MobFoxAdTypeText;

    switch (advertTypeCurrentlyPlaying) {
        case MobFoxAdTypeText:
        case MobFoxAdTypeImage: {
            if ([self interstitialFromBannerCreateAdvert:json]) {
                if(!_customEventFullscreen) {
                    [self advertCreatedSuccessfully:advertTypeCurrentlyPlaying];
                } else {
                    self.advertLoaded = YES;
                }
            } else if(!_customEventFullscreen){
                [self advertCreationFailed];
            }
            break;
        }

        case MobFoxAdTypeUnknown:
        case MobFoxAdTypeNoAdInventory:
            return;
        case MobFoxAdTypeError:{
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unknown error" forKey:NSLocalizedDescriptionKey];

            NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
            [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
            break;
        }
    }
}

- (BOOL)interstitialFromBannerCreateAdvert:(NSDictionary*)json {
    interstitialAutoCloseDisabled = YES;
    interstitialSkipButtonDisplayed = NO;
    
    self.mobFoxInterstitialPlayerViewController = [[MobFoxInterstitialPlayerViewController alloc] init];

    if(UIInterfaceOrientationIsPortrait(requestedAdOrientation))
    {
        adInterstitialOrientation = @"portrait";
    }
    else
    {
        adInterstitialOrientation = @"landscape";
    }

    
    [self updateAllFrames:requestedAdOrientation];
    
    self.mobFoxInterstitialPlayerViewController.adInterstitialOrientation = adInterstitialOrientation;
    self.mobFoxInterstitialPlayerViewController.view.frame = self.view.bounds;
    self.interstitialHoldingView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.interstitialHoldingView.backgroundColor = [UIColor clearColor];
    self.interstitialHoldingView.opaque = NO;
    self.interstitialHoldingView.autoresizesSubviews = YES;

    seedsMessageVariant = json[@"messageVariant"] != nil ? json[@"messageVariant"] : @"";

    MobFoxHTMLBannerView* bannerView = [[MobFoxHTMLBannerView alloc] initWithFrame:interstitialHoldingView.frame];

    bannerView.manuallyEnteredLocalizedPrice = self.manuallyEnteredLocalizedPrice;
    bannerView.delegate = self;
    bannerView.adspaceHeight = interstitialHoldingView.bounds.size.height;
    bannerView.adspaceWidth = interstitialHoldingView.bounds.size.width;

    bannerView.refreshTimerOff = YES;
    
    bannerView.bannerImage = _bannerImage;

    [bannerView performSelectorOnMainThread:@selector(setupAdFromJson:) withObject:json waitUntilDone:YES];

    [self.interstitialHoldingView addSubview:bannerView];

    // TODO Should this be removed?
    interstitialSkipButtonShow = YES;

    return [bannerView isBannerLoaded];
}


- (NSInteger)getTimeFromString:(NSString*)string {
    
    NSArray *components = [string componentsSeparatedByString:@":"];
    
    NSInteger hours   = [[components objectAtIndex:0] integerValue];
    NSInteger minutes = [[components objectAtIndex:1] integerValue];
    NSInteger seconds = [[components objectAtIndex:2] integerValue];
    
    return (hours * 60 * 60) + (minutes * 60) + seconds;
}

- (void)advertCreationFailed {

    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Advert could not be created" forKey:NSLocalizedDescriptionKey];

    NSError *error = [NSError errorWithDomain:MobFoxVideoInterstitialErrorDomain code:MobFoxInterstitialViewErrorUnknown userInfo:userInfo];
    [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
}

- (void)advertCreatedSuccessfully:(MobFoxAdType)advertType {

    NSNumber *advertTypeNumber = [NSNumber numberWithInt:advertType];
    [self performSelectorOnMainThread:@selector(reportSuccess:) withObject:advertTypeNumber waitUntilDone:YES];
}

#pragma mark - CustomEventFullscreenDelegate methods
-(UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (void)customEventFullscreenDidLoadAd:(MFCustomEventFullscreen *)fullscreen
{
    [self advertCreatedSuccessfully:advertTypeCurrentlyPlaying];
}

- (void)customEventFullscreenDidFailToLoadAd
{
    if(_customEventFullscreen) {
        return;
    } else if(_advertLoaded) {
        [self advertCreatedSuccessfully:advertTypeCurrentlyPlaying];
        return;
    } else if (enableInterstitialAds && !alreadyRequestedInterstitial && !_customEventFullscreen) {
        NSString *publisherId = [delegate publisherIdForMobFoxVideoInterstitialView:self];
        [self performSelectorInBackground:@selector(asyncRequestAdWithPublisherId:) withObject:publisherId];
    } else {
        [self advertCreationFailed];
    }
}

- (void)customEventFullscreenWillAppear
{
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillPresentScreen:)])
	{
		[delegate mobfoxVideoInterstitialViewActionWillPresentScreen:self];
	}
}

- (void)customEventFullscreenWillClose
{
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWillDismissScreen:)])
	{
		[delegate mobfoxVideoInterstitialViewWillDismissScreen:self];
	}
    [self advertTidyUpAfterAd:currentlyPlayingInterstitial];
}

- (void)customEventFullscreenWillLeaveApplication
{
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:withUrl:)])
    {
        [delegate mobfoxVideoInterstitialViewWasClicked:self withUrl:nil];
    }

    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillLeaveApplication:)])
    {
        [delegate mobfoxVideoInterstitialViewActionWillLeaveApplication:self];
    }
}

#pragma mark - Ad Presentation
- (void)presentCustomEventFullscreen {
    @try {
        [_customEventFullscreen showFullscreenFromRootViewController:[self firstAvailableUIViewController]];
    }
    @catch (NSException *exception) {
        _customEventFullscreen = nil;
        [self advertTidyUpAfterAd:currentlyPlayingInterstitial];
        [self advertCreationFailed];
    }
    
}


- (void)presentAd:(MobFoxAdType)advertType {
    switch (advertType) {
        case MobFoxAdTypeImage:
        case MobFoxAdTypeText:
            if(_customEventFullscreen) {
                [self presentCustomEventFullscreen];
            }
            else if (self.interstitialHoldingView) {

                [self.mobFoxInterstitialPlayerViewController.view addSubview:self.interstitialHoldingView];

                interstitialViewController = [self firstAvailableUIViewController];

                [interstitialViewController addChildViewController:self.mobFoxInterstitialPlayerViewController];
                [interstitialViewController.view addSubview:self.mobFoxInterstitialPlayerViewController.view];

                [self advertShow:advertType viewToShow:self.mobFoxInterstitialPlayerViewController.view];

            }
            break;
        case MobFoxAdTypeUnknown:
        case MobFoxAdTypeError:
            break;
        case MobFoxAdTypeNoAdInventory:
            if(_customEventFullscreen) {
                [self presentCustomEventFullscreen];
            }
            break;
    }
}

- (void)interstitialStopAdvert {
    currentlyPlayingInterstitial = NO;

    [self advertRemoveNotificationObservers:MobFoxAdGroupInterstitial];

    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWillDismissScreen:)])
	{
		[delegate mobfoxVideoInterstitialViewWillDismissScreen:self];
	}
    
    [self advertTidyUpAfterAd:advertTypeCurrentlyPlaying];
    [self.mobFoxInterstitialPlayerViewController.view removeFromSuperview];
    [self.mobFoxInterstitialPlayerViewController removeFromParentViewController];
    [self interstitialTidyUpAfterAd];

}

- (void)interstitialTidyUpAfterAd {
    
    if (self.interstitialWebView) {
        
        [self interstitialStopTimer];
        
        [self.interstitialTopToolbar removeFromSuperview];
        [self.interstitialBottomToolbar removeFromSuperview];
        
        self.interstitialTopToolbar = nil;
        self.interstitialBottomToolbar = nil;
        
        self.interstitialSkipButton = nil;
        
        interstitialSkipButtonDisplayed = NO;
        
        self.interstitialWebView.delegate = nil;
        [self.interstitialWebView removeFromSuperview];
        self.interstitialWebView = nil;
        
        [self.interstitialHoldingView removeFromSuperview];
        self.interstitialHoldingView = nil;
        
    }
}

- (void)playAdvert:(MobFoxAdType)advertType {

    if (!self.advertViewActionInProgress) {
        return;
    }

    self.advertViewActionInProgress = YES;

}

#pragma mark - Ad presentation

- (void)advertShow:(MobFoxAdType)advertType viewToShow:(UIView*)viewToShow {
    if (advertTypeCurrentlyPlaying == advertType) {

        if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillPresentScreen:)])
        {
            [delegate mobfoxVideoInterstitialViewActionWillPresentScreen:self];
        }

    }

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];;
    [self updateAllFrames:interfaceOrientation];

    viewToShow.alpha = 1.0f;
    viewToShow.hidden = NO;
    [self playAdvert:advertType];
    

}

- (void)advertTidyUpAfterAd:(MobFoxAdType)advertType {

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];;
    [self updateAllFrames:interfaceOrientation];

    self.view.hidden = YES;
    self.view.alpha = 0.0;

    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewDidDismissScreen:)])
    {
        [delegate mobfoxVideoInterstitialViewDidDismissScreen:self];
    }

    self.advertViewActionInProgress = NO;
}

#pragma mark - Request Status Reporting

- (void)reportSuccess:(NSNumber*)advertTypeNumber
{
    advertRequestInProgress = NO;

    MobFoxAdType advertType = (MobFoxAdType)[advertTypeNumber intValue];

    self.advertLoaded = YES;
	if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewDidLoadMobFoxAd:advertTypeLoaded:)])
	{
		[delegate mobfoxVideoInterstitialViewDidLoadMobFoxAd:self advertTypeLoaded:advertType];
	}
}

- (void)reportError:(NSError *)error
{

    advertRequestInProgress = NO;

    self.advertLoaded = NO;
	if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialView:didFailToReceiveAdWithError:)])
	{
		[delegate mobfoxVideoInterstitialView:self didFailToReceiveAdWithError:error];
	}
}

#pragma mark - Frame Sizing

- (void)updateAllFrames:(UIInterfaceOrientation)interfaceOrientation {

    [self applyFrameSize:interfaceOrientation];

    if (self.interstitialWebView) {
        self.interstitialWebView.frame = [self returnInterstitialWebFrame];
    }

    if (tempView) {
        tempView.frame = [self returnVideoHTMLOverlayFrame];
    }

}

- (void)applyFrameSize:(UIInterfaceOrientation)interfaceOrientation {

     CGSize size = [UIScreen mainScreen].bounds.size;

    if (UIInterfaceOrientationIsPortrait(interfaceOrientation) ||
        [[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) { //version higher or equal to iOS 8
        self.view.frame = CGRectMake(0, 0, size.width, size.height);
    } else {
        self.view.frame = CGRectMake(0, 0, size.height, size.width);
    }

}

- (CGRect)returnInterstitialWebFrame {

    float topToolbarHeight = 0.0f;
    float bottomToolbarHeight = 0.0f;

    if (self.interstitialTopToolbar) {
        topToolbarHeight = self.interstitialTopToolbar.frame.size.height;
    }

    if (self.interstitialBottomToolbar) {
        bottomToolbarHeight = self.interstitialBottomToolbar.frame.size.height;
    }
    CGRect webFrame = CGRectMake(0, topToolbarHeight, self.view.bounds.size.width, self.view.bounds.size.height - topToolbarHeight - bottomToolbarHeight);

    return webFrame;

}

- (CGRect)returnVideoHTMLOverlayFrame {

    CGRect webFrame = CGRectMake(0, self.view.bounds.size.height-HTMLOverlayHeight, HTMLOverlayWidth, HTMLOverlayHeight);

    webFrame.origin.x = self.view.center.x - HTMLOverlayWidth/2;
    return webFrame;
}

#pragma mark - Timers

- (void)interstitialStartTimer {

    self.timerStartTime = [NSDate date];

    self.interstitialTimer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self 
                                                            selector:@selector(updateInterstitialTimer) userInfo:nil repeats:YES];

}

- (void)interstitialStopTimer {

    if([self.interstitialTimer isValid]) {
        [self.interstitialTimer invalidate];
        self.interstitialTimer = nil;
    }

    self.timerStartTime = nil;

}

#pragma mark Timer Action Selectors

- (void)showInterstitialSkipButton {

    if (interstitialSkipButtonDisplayed) {
        return;
    }

    if (self.interstitialTopToolbar) {
        self.interstitialTopToolbar.items = self.interstitialTopToolbarButtons;
    } else if (self.interstitialSkipButton) {
        float skipButtonSize = buttonSize + 4.0f;
        CGRect buttonFrame = self.interstitialSkipButton.frame;
        buttonFrame.origin.x = self.view.frame.size.width - (skipButtonSize+10.0f);
        buttonFrame.origin.y = 10.0f;

        self.interstitialSkipButton.frame = buttonFrame;

        [self.interstitialHoldingView addSubview:self.interstitialSkipButton]; 
    }

    interstitialSkipButtonDisplayed = YES;
}

- (void)updateInterstitialTimer {

    NSDate *currentDate = [NSDate date];
    NSTimeInterval progress = [currentDate timeIntervalSinceDate:self.timerStartTime];

    int timeToCheckAgainst = (int)roundf(progress);
    if (!interstitialAutoCloseDisabled) {
        if (timeToCheckAgainst == interstitialAutoCloseDelay) {

            [self interstitialStopTimer];

            [self interstitialSkipAction:nil];

            return;
        }
    }

    if(!interstitialSkipButtonDisplayed) {
        if(interstitialSkipButtonShow) {
            if(interstitialSkipButtonDisplayDelay == timeToCheckAgainst) {
                [self showInterstitialSkipButton];
            }
        }
    }

    if(interstitialTimerShow) {

        float countDownProgress = interstitialAutoCloseDelay - progress;

        int minutes = floor(countDownProgress/60);
        int seconds = trunc(countDownProgress - minutes * 60);
        self.interstitialTimerLabel.text = [NSString stringWithFormat:@"%i:%.2d", minutes, seconds];
    }
}

#pragma mark - Interaction

- (void)tapThrough:(BOOL)tapThroughLeavesApp tapThroughURL:(NSURL*)tapThroughURL
{
    tapThroughLeavesApp = YES;

	if (tapThroughLeavesApp || [tapThroughURL isDeviceSupported])
	{
        if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:withUrl:)])
        {
            [delegate mobfoxVideoInterstitialViewWasClicked:self withUrl:nil];
        }

        if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillLeaveApplication:)])
        {
            [delegate mobfoxVideoInterstitialViewActionWillLeaveApplication:self];
        }

        [[UIApplication sharedApplication]openURL:tapThroughURL];
		return;
	}
    viewController = [self firstAvailableUIViewController];

	MobFoxAdBrowserViewController *browser = [[MobFoxAdBrowserViewController alloc] initWithUrl:tapThroughURL];
    browser.delegate = (id)self;
	browser.userAgent = self.userAgent;
    browser.webView.scalesPageToFit = YES;
	browser.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [viewController presentViewController:browser animated:YES completion:nil];
}

- (void)postTrackingEvent:(NSString*)urlString {

    NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request;

    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"GET"];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:nil];
    [connection start];

}

- (void)advertActionTrackingEvent:(NSString*)eventType {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY @allKeys = %@", eventType];

    NSArray *trackingEvents = [self.videoAdvertTrackingEvents filteredArrayUsingPredicate:predicate];

    NSMutableArray *trackingEventsToRemove = [NSMutableArray arrayWithCapacity:0];

	for (NSDictionary *trackingEvent in trackingEvents)
	{

        NSString *urlString = [trackingEvent objectForKey:eventType];
        urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (urlString) {

            [self postTrackingEvent:urlString];

            [trackingEventsToRemove addObject:trackingEvent];

        }

	}
    if (![eventType isEqualToString:@"mute"] && ![eventType isEqualToString:@"unmute"] && ![eventType isEqualToString:@"pause"] && ![eventType isEqualToString:@"unpause"] && ![eventType isEqualToString:@"skip"] && ![eventType isEqualToString:@"replay"]) {

        if ([trackingEventsToRemove count]) {
            [self.videoAdvertTrackingEvents removeObjectsInArray:trackingEventsToRemove];
        }

    }

}


#pragma mark Interstitial Interaction

- (void)removeAutoClose {
    interstitialTimerShow = NO;
    [self.interstitialTimerLabel removeFromSuperview];

}

- (void)checkAndCancelAutoClose {

    if (!interstitialAutoCloseDisabled) {

        interstitialAutoCloseDisabled = YES;

        if(self.interstitialWebView) {

            if (interstitialTimerShow) {
                [self removeAutoClose];
            }

        }
    }
    if(!interstitialSkipButtonDisplayed) {
        [self showInterstitialSkipButton];
    }

}

#pragma mark Button Actions

- (void)browserBackButtonAction:(id)sender {

    [self.interstitialWebView goBack];

    [self checkAndCancelAutoClose];

}

- (void)browserForwardButtonAction:(id)sender {

    [self.interstitialWebView goForward];

    [self checkAndCancelAutoClose];

}

- (void)browserReloadButtonAction:(id)sender {

    [self checkAndCancelAutoClose];

}

- (void)browserExternalButtonAction:(id)sender {

    [self checkAndCancelAutoClose];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.interstitialURL]];

}

- (void)videoSkipAction:(id)sender {

    [self advertActionTrackingEvent:@"skip"];
    [self advertActionTrackingEvent:@"close"];
}

- (void)navIconAction:(id)sender {

    UIButton *theButton = (UIButton*)sender;
    NSDictionary *buttonObject = theButton.objectTag;

    BOOL clickleavesApp = [[buttonObject objectForKey:@"openType"] isEqualToString:@"external"];
    NSString *urlString = [buttonObject objectForKey:@"clickUrl"];

    NSString *prefix = [urlString substringToIndex:5];

	if ([prefix isEqualToString:@"mfox:"]) {

        NSString *actionString = [urlString substringFromIndex:5];

        if ([actionString isEqualToString:@"skip"]) {

            [self videoSkipAction:nil];
            return;
        }

    } else {
        NSURL *clickUrl = [NSURL URLWithString:urlString];

        [self tapThrough:clickleavesApp tapThroughURL:clickUrl];

    }

}

- (void)interstitialSkipAction:(id)sender {
    [self interstitialStopAdvert];

    [self recordInterstitialEvent:@"message dismissed"];

    id<SeedsInAppMessageDelegate> seedsDelegate = Seeds.sharedInstance.inAppMessageDelegate;
    if (seedsDelegate && [seedsDelegate respondsToSelector:@selector(seedsInAppMessageDismissed:)])
        [seedsDelegate seedsInAppMessageDismissed:seedsMessageId];

    if (seedsDelegate && [seedsDelegate respondsToSelector:@selector(seedsInAppMessageDismissed)])
        [seedsDelegate seedsInAppMessageDismissed];
}

#pragma mark -
#pragma mark Actionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.interstitialURL]];
    }

}

#pragma mark -
#pragma mark - UIWebView Delegates

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    if (webView == self.interstitialWebView) {
        self.browserBackButton.enabled = webView.canGoBack;
        self.browserForwardButton.enabled = webView.canGoForward;
    }

}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {

        NSURL *theUrl = [request URL];

        NSString *requestString = [theUrl absoluteString];

        NSString *prefix = [requestString substringToIndex:5];

        if ([prefix isEqualToString:@"mfox:"]) {

            NSString *actionString = [requestString substringFromIndex:5];
            if ([actionString isEqualToString:@"replayvideo"]) {

                if(self.interstitialWebView) {
                    [self browserReloadButtonAction:nil];
                }

                return NO;
            }
            actionString = [requestString substringToIndex:14];
            if([actionString isEqualToString:@"mfox:external:"]) {

                [self checkAndCancelAutoClose];

                actionString = [requestString substringFromIndex:14];

                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionString]];
            }

            return NO;
        }

    }
    if (webView == self.interstitialWebView) {

        if(navigationType != UIWebViewNavigationTypeOther && navigationType != UIWebViewNavigationTypeReload && navigationType != UIWebViewNavigationTypeBackForward) {
            [self checkAndCancelAutoClose];
        }
        self.browserBackButton.enabled = webView.canGoBack;
        self.browserForwardButton.enabled = webView.canGoForward;

        return YES;

    }

    return YES;
}

#pragma mark - Modal Web View Display & Dismissal

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{

    if(!_browser)
        return;

    [rootViewController presentViewController:_browser animated:YES completion:nil];

}

- (void)mobfoxAdBrowserControllerDidDismiss:(MobFoxAdBrowserViewController *)mobfoxAdBrowserController
{
    [mobfoxAdBrowserController dismissViewControllerAnimated:YES completion:nil];

    _browser = nil;

    mobfoxAdBrowserController.webView = nil;
    mobfoxAdBrowserController = nil;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];;
    [self updateAllFrames:interfaceOrientation];
}

#pragma mark - UIGestureRecognizer & UIWebView & Tap Detecting Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}


- (void)handleOverlayClick:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded)     {
        
        [self checkAndCancelAutoClose];
        if(_overlayClickThrough) {
            NSString *escapedDataString = [_overlayClickThrough stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *clickUrl = [NSURL URLWithString:escapedDataString];
            
            if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:withUrl:)])
            {
                [delegate mobfoxVideoInterstitialViewWasClicked:self withUrl: clickUrl];
            }
            [self advertActionTrackingEvent:@"overlayClick"];
            [self tapThrough:YES tapThroughURL:clickUrl];
        }
    }
}


- (void)handleVideoClick:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded)     {

        if(_videoClickThrough) {
            [self advertActionTrackingEvent:@"videoClick"];
            if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:withUrl:)])
            {
                [delegate mobfoxVideoInterstitialViewWasClicked:self withUrl:nil];
            }
            NSString *escapedDataString = [_videoClickThrough stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *clickUrl = [NSURL URLWithString:escapedDataString];
            [self tapThrough:YES tapThroughURL:clickUrl];
            
//            [self videoShowSkipButton];
        }
    }
    
}


#pragma mark
#pragma mark Status Bar Handling

#pragma mark
#pragma mark Notifications

- (void)advertAddNotificationObservers:(MobFoxAdGroupType)adGroup {

    if (adGroup == MobFoxAdGroupInterstitial) {
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) 
                                                         name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)advertRemoveNotificationObservers:(MobFoxAdGroupType)adGroup {

    if (adGroup == MobFoxAdGroupInterstitial) {
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                        name:UIDeviceOrientationDidChangeNotification 
                                                        object:nil];
}

- (void) appDidBecomeActive:(NSNotification *)notification
{
    if(self.interstitialWebView) {
        [self advertAddNotificationObservers:MobFoxAdGroupInterstitial];

    }

}

- (void) appWillResignActive:(NSNotification *)notification
{
    if(self.interstitialWebView) {
        [self advertRemoveNotificationObservers:MobFoxAdGroupInterstitial];

    }

}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self updateAllFrames:interfaceOrientation];
}

#pragma mark Banner View Delegate

-(void) mobfoxHTMLBannerViewActionWillPresent:(MobFoxHTMLBannerView *)banner {
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:withUrl:)])
    {
        [delegate mobfoxVideoInterstitialViewWasClicked:self withUrl:nil];
    }
}

-(void) mobfoxHTMLBannerViewActionWillLeaveApplication:(MobFoxHTMLBannerView *)banner withUrl: (NSURL*) url{
    BOOL closeAfterClick = true;
    
    if ([delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewWasClicked:withUrl:)])
    {
        closeAfterClick = [delegate mobfoxVideoInterstitialViewWasClicked:self withUrl: url];
    }

    if (closeAfterClick && [delegate respondsToSelector:@selector(mobfoxVideoInterstitialViewActionWillLeaveApplication:)])
    {
        [delegate mobfoxVideoInterstitialViewActionWillLeaveApplication:self];
    }
}

-(NSString*) publisherIdForMobFoxHTMLBannerView:(MobFoxHTMLBannerView *)banner {
    return [delegate publisherIdForMobFoxVideoInterstitialView:self];
}


- (void)recordInterstitialEvent:(NSString *)key {
    [self recordInterstitialEvent:key withCustomSegments:nil];
}

- (void)recordInterstitialEvent:(NSString *)key withCustomSegments: customSegments  {
    NSMutableDictionary *segments = [NSMutableDictionary new];
    [segments addEntriesFromDictionary:@{
            @"message" : seedsMessageId.length ? seedsMessageId : @"",
            @"variant" : seedsMessageVariant.length ? seedsMessageVariant : @"",
            @"context" : seedsMessageContext.length ? seedsMessageContext : @""
    }];

    if (customSegments != nil) {
        [segments addEntriesFromDictionary:customSegments];
        segments[kEventCountKey] = @(1);
    }

    [Seeds.events logEventWithKey:key parameters:segments];
}

@end
