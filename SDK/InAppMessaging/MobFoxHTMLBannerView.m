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
//  Changes: removed unused import; removed unused code; removed custom event banner;
//
#import "MobFoxHTMLBannerView.h"
#import "UIView+FindViewController.h"
#import "NSURL+MobFox.h"
#import "MobFoxAdBrowserViewController.h"
#import "MFRedirectChecker.h"

#import "MFCustomEventBanner.h"

#import "Seeds.h"

#import <StoreKit/StoreKit.h>
#import "SKProductHelper.h"

NSString * const MobFoxErrorDomain = @"MobFox";

@interface MobFoxHTMLBannerView () <UIWebViewDelegate, MFCustomEventBannerDelegate, UIGestureRecognizerDelegate> {
    SKProductHelper *productHelper;
}

@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *adType;
@property (nonatomic, assign) CGFloat currentLatitude;
@property (nonatomic, assign) CGFloat currentLongitude;
@property (nonatomic, copy) NSString* htmlString;

@property (nonatomic, retain) UIView *bannerView;

@property (nonatomic, strong) NSMutableDictionary *browserUserAgentDict;

@end

@implementation MobFoxHTMLBannerView
{
	MFRedirectChecker *redirectChecker;
}

- (void)setup
{
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];

    [self setUpBrowserUserAgentStrings];
    self.autoresizingMask = UIViewAutoresizingNone;
	self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
	refreshAnimation = UIViewAnimationTransitionFlipFromLeft;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    productHelper = [[SKProductHelper alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
	[self setup];
}

- (void)dealloc
{
    self.bannerView = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    delegate = nil;
    if(_refreshTimer){
        [_refreshTimer invalidate], _refreshTimer = nil;
    }
}

#pragma mark Utilities

- (UIImage*)darkeningImageOfSize:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetGrayFillColor(ctx, 0, 1);
	CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return cropped;
}

- (NSURL *)serverURL
{
	return [NSURL URLWithString:self.requestURL];
}

#pragma mark Properties

- (void)setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	for (UIView *oneView in self.subviews)
	{
		oneView.center = CGPointMake(roundf(self.bounds.size.width / 2.0), roundf(self.bounds.size.height / 2.0));
	}
}

- (void)setTransform:(CGAffineTransform)transform
{
	[super setTransform:transform];
	for (UIView *oneView in self.subviews)
	{
		oneView.center = CGPointMake(roundf(self.bounds.size.width / 2.0), roundf(self.bounds.size.height / 2.0));
	}
}

- (void)setDelegate:(id <MobFoxHTMLBannerViewDelegate>)newDelegate
{
    delegate = newDelegate;
}

- (void)setRefreshTimerActive:(BOOL)active
{
    if(_refreshTimer){
        [_refreshTimer invalidate], _refreshTimer = nil;
    }
    
    if (refreshTimerOff) {
        return;
    }
    
//	if (active && !bannerViewActionInProgress && (_refreshInterval || _customReloadTime))
//	{
//        if(_customReloadTime) {
//            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:_customReloadTime target:self selector:@selector(requestAd) userInfo:nil repeats:YES];
//        } else {
//            _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:_refreshInterval target:self selector:@selector(requestAd) userInfo:nil repeats:YES];
//        }
//        
//	}
}

#pragma - mark Utilities

- (void)hideStatusBar
{
	UIApplication *app = [UIApplication sharedApplication];
	if (!app.statusBarHidden)
	{
		if ([app respondsToSelector:@selector(setStatusBarHidden:withAnimation:)])
		{
			[app setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		}
		else
		{
			[app setStatusBarHidden:YES];
		}

		_statusBarWasVisible = YES;
	}
}

- (void)showStatusBarIfNecessary
{
	if (_statusBarWasVisible)
	{
		UIApplication *app = [UIApplication sharedApplication];

		if ([app respondsToSelector:@selector(setStatusBarHidden:withAnimation:)])
		{
			[app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
		}
		else
		{
			[app setStatusBarHidden:NO];
		}
	}
}

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


#pragma mark MRAID (MOPUB required)

- (UIViewController *)viewControllerForPresentingModalView
{
	return [self firstAvailableUIViewController];
}

#pragma mark Ad Handling
- (void)reportSuccess
{
	bannerLoaded = YES;
	if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewDidLoadMobFoxAd:)])
	{
		[delegate mobfoxHTMLBannerViewDidLoadMobFoxAd:self];
	}
}

- (void)reportRefresh
{
	if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewDidLoadRefreshedAd:)])
	{
		[delegate mobfoxHTMLBannerViewDidLoadRefreshedAd:self];
	}
}

- (void)reportError:(NSError *)error
{
	bannerLoaded = NO;
	if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerView:didFailToReceiveAdWithError:)])
	{
		[delegate mobfoxHTMLBannerView:self didFailToReceiveAdWithError:error];
	}
}

- (void)setupAdFromJson:(NSDictionary*)json
{
    NSLog(@"Initializing the Seeds interstitial using the downloaded JSON");

    NSArray *previousSubviews = [NSArray arrayWithArray:self.subviews];

	NSString *clickType = [json objectForKey:@"clicktype"];
	if ([clickType isEqualToString:@"inapp"])
	{
		_tapThroughLeavesApp = NO;
	}
	else
	{
		_tapThroughLeavesApp = YES;
	}

    NSString *productId = [json objectForKey:@"productIdIos"];

    _shouldScaleWebView = NO; //[[xml.documentRoot getNamedChild:@"scale"].text isEqualToString:@"yes"];
    _shouldSkipLinkPreflight = YES; //[[xml.documentRoot getNamedChild:@"skippreflight"].text isEqualToString:@"yes"];
	self.bannerView = nil;
	adType = @"textAd";//[xml.documentRoot.attributes objectForKey:@"type"];
    _refreshInterval = 60;//[[xml.documentRoot getNamedChild:@"refresh"].text intValue];
	[self setRefreshTimerActive:YES];
	if ([adType isEqualToString:@"textAd"])
	{
		NSString *html = [json objectForKey:@"htmlString"];

        CGSize bannerSize;
        if(adspaceHeight > 0 && adspaceWidth > 0)
        {
            bannerSize = CGSizeMake(adspaceWidth, adspaceHeight);
        }
		else if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
		{
			bannerSize = CGSizeMake(728, 90);
		}
        else
        {
            bannerSize = CGSizeMake(320, 50);
        }

		UIWebView *webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, bannerSize.width, bannerSize.height)];

        _htmlString = html;

        NSString *productPrice = [self getProductPrice: productId];
        _htmlString = [_htmlString stringByReplacingOccurrencesOfString:@"%{LocalizedPrice}" withString:productPrice];

        webView.delegate = (id)self;
        webView.userInteractionEnabled = YES;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];

        [webView addGestureRecognizer:tap];

        tap.delegate = self;


		webView.backgroundColor = [UIColor clearColor];
        webView.opaque = NO;
        webView.scrollView.scrollsToTop = false;

		self.bannerView = webView;
	}
    else if ([adType isEqualToString:@"noAd"])
	{
        //do nothing, there still can be custom events.
	}
	else if ([adType isEqualToString:@"error"])
	{
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unknown error" forKey:NSLocalizedDescriptionKey];

		NSError *error = [NSError errorWithDomain:MobFoxErrorDomain code:MobFoxErrorUnknown userInfo:userInfo];
		[self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
		return;
	}
	else
	{
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unknown ad type '%@'", adType] forKey:NSLocalizedDescriptionKey];

		NSError *error = [NSError errorWithDomain:MobFoxErrorDomain code:MobFoxErrorUnknown userInfo:userInfo];
		[self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
		return;
	}

    if (self.bannerView)
	{
        [self showBannerView:self.bannerView withPreviousSubviews:previousSubviews];
	}
}

- (NSString *)getProductPrice:(NSString *)productId {
    if (manuallyEnteredLocalizedPrice != NULL && [manuallyEnteredLocalizedPrice length] > 0) {
      return manuallyEnteredLocalizedPrice;
    } else if (productId != nil && [SKPaymentQueue canMakePayments]) {
        __block BOOL finished = false;
        __block SKProduct *product;

        [productHelper getProductsByIdentifiers:@[productId] withResult:^(NSArray *products, NSError *error) {
            if (products) {
                product = [products firstObject];
            }

            finished = true;
        }];

        while (!finished) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }

        if (product != nil) {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [formatter setLocale:product.priceLocale];

            return [formatter stringFromNumber:product.price];
        }
    }

    return @"BUY";
}

- (void)showBannerView:(UIView*)nextBannerView withPreviousSubviews:(NSArray*)previousSubviews
{
    if([adType isEqualToString:@"textAd"]) {

        [(UIWebView*)nextBannerView loadHTMLString:_htmlString baseURL:nil];
    }
    
    nextBannerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    if (CGRectEqualToRect(self.bounds, CGRectZero))
    {
        self.bounds = nextBannerView.bounds;
    }
    
    if ([previousSubviews count])
    {
        [UIView beginAnimations:@"flip" context:nil];
        [UIView setAnimationDuration:1.5];
        if ([adType isEqualToString:@"mraidAd"])
        {
            [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:NO];
        } else {
            [UIView setAnimationTransition:refreshAnimation forView:self cache:NO];
        }
    }
    
    nextBannerView.center = self.center;
    [self insertSubview:nextBannerView atIndex:0];
    [previousSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if ([previousSubviews count]) {
        [UIView commitAnimations];
        
        [self performSelectorOnMainThread:@selector(reportRefresh) withObject:nil waitUntilDone:YES];
    } else {
        [self performSelectorOnMainThread:@selector(reportSuccess) withObject:nil waitUntilDone:YES];
    }
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    self.currentLatitude = latitude;
    self.currentLongitude = longitude;
}

- (void)showErrorLabelWithText:(NSString *)text
{
	UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
	label.numberOfLines = 0;
	label.backgroundColor = [UIColor whiteColor];
	label.font = [UIFont boldSystemFontOfSize:12];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor redColor];
	label.text = text;
	[self addSubview:label];
}

#pragma mark Interaction

- (void)checker:(MFRedirectChecker *)checker detectedRedirectionTo:(NSURL *)redirectURL
{
	if ([redirectURL isDeviceSupported])
	{
		[[UIApplication sharedApplication] openURL:redirectURL];
		return;
	}
	UIViewController *viewController = [self firstAvailableUIViewController];
	MobFoxAdBrowserViewController *browser = [[MobFoxAdBrowserViewController alloc] initWithUrl:redirectURL];
	browser.delegate = (id)self;
	browser.userAgent = self.userAgent;
	browser.webView.scalesPageToFit = _shouldScaleWebView;
	[self hideStatusBar];
    if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewActionWillPresent:)])
    {
        [delegate mobfoxHTMLBannerViewActionWillPresent:self];
    }
    [viewController presentViewController:browser animated:YES completion:nil];

	bannerViewActionInProgress = YES;
}

- (void)checker:(MFRedirectChecker *)checker didFailWithError:(NSError *)error
{
	bannerViewActionInProgress = NO;
}

- (void)tapThroughFromButton:(id)sender {
    [self tapThrough: nil];
}

- (void)tapThrough:(NSURL*)url
{
	if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewActionShouldBegin:willLeaveApplication:)])
	{
		BOOL allowAd = [delegate mobfoxHTMLBannerViewActionShouldBegin:self willLeaveApplication:_tapThroughLeavesApp];

		if (!allowAd)
		{
			return;
		}
	}
	if (_tapThroughLeavesApp || [url isDeviceSupported])
	{
        if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewActionWillLeaveApplication:withUrl:)])
        {
            [delegate mobfoxHTMLBannerViewActionWillLeaveApplication:self withUrl: url];
        }

        [[UIApplication sharedApplication]openURL:url];
		return;
	}
	UIViewController *viewController = [self firstAvailableUIViewController];
	if (!viewController)
	{
		return;
	}
	[self setRefreshTimerActive:NO];
	if (!_shouldSkipLinkPreflight)
	{
		redirectChecker = [[MFRedirectChecker alloc] initWithURL:url userAgent:self.userAgent delegate:(id)self];
		return;
	}
	MobFoxAdBrowserViewController *browser = [[MobFoxAdBrowserViewController alloc] initWithUrl:url];
	browser.delegate = (id)self;
	browser.userAgent = self.userAgent;
	browser.webView.scalesPageToFit = _shouldScaleWebView;
	[self hideStatusBar];
    if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewActionWillPresent:)])
    {
        [delegate mobfoxHTMLBannerViewActionWillPresent:self];
    }
    [viewController presentViewController:browser animated:YES completion:nil];
	bannerViewActionInProgress = YES;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    // this is called after gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer: so we can safely remove the delegate here
    if (gestureRecognizer.delegate) {
        gestureRecognizer.delegate = nil;
    }
}

- (void)mobfoxAdBrowserControllerDidDismiss:(MobFoxAdBrowserViewController *)mobfoxAdBrowserController
{
    if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewActionWillFinish:)])
	{
		[delegate mobfoxHTMLBannerViewActionWillFinish:self];
	}
    [self showStatusBarIfNecessary];
    [mobfoxAdBrowserController dismissViewControllerAnimated:YES completion:nil];
	bannerViewActionInProgress = NO;
	[self setRefreshTimerActive:YES];
	if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewActionDidFinish:)])
	{
		[delegate mobfoxHTMLBannerViewActionDidFinish:self];
	}
}

#pragma mark WebView Delegate (Text Ads)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    NSURL *url = [request URL];
    NSString *urlString = [url absoluteString];
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
        if ([urlString isEqualToString:@"about:close"]) {
            [self.delegate interstitialSkipAction:nil];
            return NO;
        } else if (![urlString isEqualToString:@""]) {
            [self tapThrough:url ];
            return NO;
        }
	}
    else if(navigationType == UIWebViewNavigationTypeOther)
    {
        NSString* documentURL = [[request mainDocumentURL] absoluteString];
        BOOL isJavascriptHrefClick = [urlString isEqualToString:documentURL];
        
        if(isJavascriptHrefClick) {
            if (![urlString isEqualToString:@"about:blank"] && ![urlString isEqualToString:@""]) {
                [self tapThrough:url];
                return NO;
            }
        }
    }

    return YES;
}

#pragma mark -
#pragma mark CustomEventBannerDelegate

- (void)customEventBannerDidLoadAd:(UIView *)ad {
    NSArray *previousSubviews = [NSArray arrayWithArray:self.subviews];
    [self showBannerView:ad withPreviousSubviews:previousSubviews];
}

- (void)customEventBannerDidFailToLoadAd
{
    NSArray *previousSubviews = [NSArray arrayWithArray:self.subviews];
    if (self.bannerView)
    {
        [self showBannerView:self.bannerView withPreviousSubviews:previousSubviews];
    }
    else
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No inventory for ad request" forKey:NSLocalizedDescriptionKey];
        
        _refreshInterval = 15;
        [self setRefreshTimerActive:YES];
        
        NSError *error = [NSError errorWithDomain:MobFoxErrorDomain code:MobFoxErrorInventoryUnavailable userInfo:userInfo];
        [self performSelectorOnMainThread:@selector(reportError:) withObject:error waitUntilDone:YES];
    }
}

- (void)customEventBannerWillExpand
{
    if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewActionWillPresent:)])
	{
		[delegate mobfoxHTMLBannerViewActionWillPresent:self];
	}
}

- (void)customEventBannerWillClose
{
    if ([delegate respondsToSelector:@selector(mobfoxHTMLBannerViewActionWillFinish:)])
	{
		[delegate mobfoxHTMLBannerViewActionWillFinish:self];
	}
}

#pragma mark Notifications
- (void) appDidBecomeActive:(NSNotification *)notification
{
	[self setRefreshTimerActive:YES];
}

- (void) appWillResignActive:(NSNotification *)notification
{
	[self setRefreshTimerActive:NO];
}

-(void)setAdspaceHeight:(NSInteger)height {
    if(height > 0) {
        adspaceHeight = height;
    } else {
        NSLog(@"Adspace height must be greater than 0! Ignoring value: %li", (long)height);
    }
}

-(void)setAdspaceWidth:(NSInteger)width {
    if(width > 0) {
        adspaceWidth = width;
    } else {
        NSLog(@"Adspace width must be greater than 0! Ignoring value: %li", (long)width);
    }
}

@synthesize delegate;
@synthesize advertisingSection;
@synthesize bannerLoaded;
@synthesize bannerViewActionInProgress;
@synthesize refreshAnimation;
@synthesize refreshTimerOff;
@synthesize requestURL;
@synthesize userAgent;
@synthesize adType;
@synthesize adspaceHeight;
@synthesize adspaceWidth;
@synthesize adspaceStrict;
@synthesize locationAwareAdverts;
@synthesize userGender,userAge,keywords;
@synthesize manuallyEnteredLocalizedPrice;



@end

