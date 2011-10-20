// ActiveResourceKit ARBase+Private.h
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

#import <ActiveResourceKit/ARBase.h>

@class AResource;

extern NSString *const kARFromKey;
extern NSString *const kARParamsKey;

/*!
 * @brief Builds a query string given a dictionary of query options.
 * @param options Dictionary (a Ruby hash) of query options.
 * @result The answer is an empty string when you pass @c nil options or the
 * options indicate an empty dictionary. This function assumes that the given
 * options are @e query options only; they should not contain prefix options;
 * otherwise prefix options will appear in the query string. Invoking this
 * helper function assumes you have already filtered any options by splitting
 * apart prefix from query options.
 */
NSString *ARQueryStringForOptions(NSDictionary *options);

@interface ARBase(Private)

- (id<ARFormat>)defaultFormat;
- (NSString *)defaultElementName;
- (NSString *)defaultCollectionName;
- (NSString *)defaultPrimaryKey;
- (NSString *)defaultPrefixSource;

- (void)findEveryWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSArray *resources, NSError *error))completionHandler;

/*!
 * Instantiates a collection of active resources given a collection of
 * attributes; collection here meaning an array. The collection argument
 * specifies an array of dictionaries. Each dictionary specifies attributes for
 * a new active resource. Answers an array of newly instantiated active
 * resources.
 */
- (NSArray *)instantiateCollection:(NSArray *)collection prefixOptions:(NSDictionary *)prefixOptions;
- (AResource *)instantiateRecordWithAttributes:(NSDictionary *)attributes prefixOptions:(NSDictionary *)prefixOptions;

/*!
 * Answers a set of prefix parameters based on the current prefix source. These
 * constitute the current set of prefix parameters: an array of strings without
 * the leading colon. Colon immediately followed by a word marks each parameter
 * in the prefix source.
 */
- (NSSet *)prefixParameters;

/*!
 * Splits an options dictionary into two dictionaries, one containing the prefix
 * options, the other containing the leftovers, i.e. any query options.
 */
- (void)splitOptions:(NSDictionary *)options prefixOptions:(NSDictionary **)outPrefixOptions queryOptions:(NSDictionary **)outQueryOptions;

/*!
 * Sends an asynchronous GET request. When the response successfully arrives,
 * the format decodes the data. If the response body decodes successfully,
 * finally sends the decoded object (or objects) to your given completion
 * handler. Objects may be hashes (dictionaries) or arrays, or even primitives.
 */
- (void)get:(NSString *)path completionHandler:(void (^)(id object, NSError *error))completionHandler;

@end
