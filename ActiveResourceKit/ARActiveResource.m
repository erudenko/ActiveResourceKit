// ActiveResourceKit ARActiveResource.m
//
// Copyright © 2011, Roy Ratcliffe, Pioneering Software, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the “Software”), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "ARActiveResource.h"

#import <ActiveModelKit/ActiveModelKit.h>
#import <ActiveSupportKit/ActiveSupportKit.h>
#import <RRFoundation/RRFoundation.h>

@interface ARActiveResource(Private)

- (NSString *)defaultPrefix;
- (NSString *)defaultElementName;
- (NSString *)defaultCollectionName;

@end

@implementation ARActiveResource

@synthesize site = _site;

//------------------------------------------------------------------------------
#pragma mark                                                              Prefix
//------------------------------------------------------------------------------

@synthesize prefix = _prefix;

- (NSString *)prefix
{
	if (_prefix == nil)
	{
		NSString *prefix = [self defaultPrefix];
		if ([prefix length] == 0 || ![[prefix substringFromIndex:[prefix length] - 1] isEqualToString:@"/"])
		{
			prefix = [prefix stringByAppendingString:@"/"];
		}
		[self setPrefix:prefix];
	}
	return _prefix;
}

// It would be nice for the compiler to provide the setter. If you make the
// property non-atomic, the compiler will let you define just the custom
// getter. But not so if you make the property atomic. Is this a compiler
// feature or bug? It outputs a warning message, “writable atomic property
// cannot pair a synthesised setter/getter with a user defined setter/getter.”

- (void)setPrefix:(NSString *)newPrefix
{
	if (_prefix != newPrefix)
	{
		[_prefix autorelease];
		_prefix = [newPrefix copy];
	}
}

//------------------------------------------------------------------------------
#pragma mark                                                        Element Name
//------------------------------------------------------------------------------

@synthesize elementName = _elementName;

- (NSString *)elementName
{
	if (_elementName == nil)
	{
		[self setElementName:[self defaultElementName]];
	}
	return _elementName;
}

- (void)setElementName:(NSString *)newElementName
{
	if (_elementName != newElementName)
	{
		[_elementName autorelease];
		_elementName = [newElementName copy];
	}
}

//------------------------------------------------------------------------------
#pragma mark                                                     Collection Name
//------------------------------------------------------------------------------

@synthesize collectionName = _collectionName;

- (NSString *)collectionName
{
	if (_collectionName == nil)
	{
		[self setCollectionName:[self defaultCollectionName]];
	}
	return _collectionName;
}

- (void)setCollectionName:(NSString *)newCollectionName
{
	if (_collectionName != newCollectionName)
	{
		[_collectionName autorelease];
		_collectionName = [newCollectionName copy];
	}
}

- (NSSet *)prefixParameters
{
	NSMutableSet *parameters = [NSMutableSet set];
	NSString *prefix = [self prefix];
	for (NSString *match in [[NSRegularExpression regularExpressionWithPattern:@":\\w+" options:0 error:NULL] matchesInString:[self prefix] options:0 range:NSMakeRange(0, [prefix length])])
	{
		[parameters addObject:[match substringFromIndex:1]];
	}
	return [[parameters copy] autorelease];
}

- (NSString *)prefixWithOptions:(NSDictionary *)options
{
	return [[NSRegularExpression regularExpressionWithPattern:@":(\\w+)" options:0 error:NULL] replaceMatchesInString:[self prefix] replacementStringForResult:^NSString *(NSTextCheckingResult *result, NSString *inString, NSInteger offset) {
		return [[[options objectForKey:[[result regularExpression] replacementStringForResult:result inString:inString offset:offset template:@"$1"]] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}];
}

- (NSString *)elementPathForID:(NSNumber *)ID prefixOptions:(NSDictionary *)prefixOptions
{
	return [NSString stringWithFormat:@"%@%@/%@", [self prefixWithOptions:prefixOptions], [self collectionName], [[ID stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

@end

@implementation ARActiveResource(Private)

- (NSString *)defaultPrefix
{
	return [[self site] path];
}

- (NSString *)defaultElementName
{
	return [[[[AMName alloc] initWithClass:[self class]] autorelease] element];
}

- (NSString *)defaultCollectionName
{
	return [[ASInflector defaultInflector] pluralize:[self elementName]];
}

@end
