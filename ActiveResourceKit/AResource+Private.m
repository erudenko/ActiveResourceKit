// ActiveResourceKit AResource+Private.m
//
// Copyright © 2011, Roy Ratcliffe, Pioneering Software, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "AResource+Private.h"

#import "ARBase.h"

NSNumber *ARIDFromResponse(NSHTTPURLResponse *response)
{
	NSString *location = [[response allHeaderFields] objectForKey:@"Location"];
	if (location == nil)
	{
		return nil;
	}
	NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\\/([^\\/]*?)(\\.\\w+)?$" options:0 error:NULL];
	NSTextCheckingResult *match = [re firstMatchInString:location options:0 range:NSMakeRange(0, [location length])];
	if (match == nil || [match numberOfRanges] < 2)
	{
		return nil;
	}
	NSString *string = [location substringWithRange:[match rangeAtIndex:1]];
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	return [numberFormatter numberFromString:string];
}

BOOL ARResponseCodeAllowsBody(NSInteger statusCode)
{
	return !((100 <= statusCode && statusCode <= 199) || statusCode == 204 || statusCode == 304);
}

@implementation AResource(Private)

- (void)loadAttributesFromResponse:(NSHTTPURLResponse *)response data:(NSData *)data
{
	NSDictionary *headerFields;
	NSString *contentLength;
	NSDictionary *attributes;
	
	if (ARResponseCodeAllowsBody([response statusCode]) &&
		((contentLength = [headerFields = [response allHeaderFields] objectForKey:@"Content-Length"]) == nil || ![contentLength isEqualToString:@"0"]) &&
		data && (attributes = [[[self baseLazily] formatLazily] decode:data error:NULL]))
	{
		[self loadAttributes:attributes removeRoot:YES];
		[self setPersisted:YES];
	}
}

@end