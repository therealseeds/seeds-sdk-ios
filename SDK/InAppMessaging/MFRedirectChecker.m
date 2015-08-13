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
#import "MFRedirectChecker.h"

@implementation MFRedirectChecker

@synthesize delegate = _delegate;
@synthesize mimeType;
@synthesize textEncodingName;

- (id)initWithURL:(NSURL *)url userAgent:(NSString *)userAgent delegate:(id<MFRedirectCheckerDelegate>) delegate
{
	if (self = [super init])
	{
		_delegate = delegate;

		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		[request addValue:userAgent forHTTPHeaderField:@"User-Agent"];

		_connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];

		receivedData = [[NSMutableData alloc] init];
		[_connection start];
	}
	return self;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
	if (redirectResponse)
	{
		[_delegate checker:self detectedRedirectionTo:[request URL]];

		[_connection cancel];

		return nil;
	}
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.mimeType = [response MIMEType];
	self.textEncodingName = [response textEncodingName];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[_delegate checker:self didFinishWithData:receivedData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
	if ([_delegate respondsToSelector:@selector(checker:didFailWithError:)])
	{
		[_delegate checker:self didFailWithError:error];
	}
}

@end
