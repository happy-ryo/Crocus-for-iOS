//  Copyright 2013 happy_ryo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "NSDictionary+CRURLParams.h"


@implementation NSDictionary (CRURLParams)

- (NSData *)serializeParams {
    return [self.paramsString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)paramsString {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [self keyEnumerator]) {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *subValue in value) {
                NSString *escaped_value = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                        (__bridge CFStringRef) subValue,
                        NULL,
                        (CFStringRef) @"!*'()@&=+$,/?%#[];:",
                        kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, escaped_value]];
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            for (NSString *subKey in value) {
                NSString *escaped_value = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                        (__bridge CFStringRef) [value objectForKey:subKey],
                        NULL,
                        (CFStringRef) @"!*'()@&=+$,/?%#[];:",
                        kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, escaped_value]];
            }
        } else {
            NSString *escaped_value = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                    (__bridge CFStringRef) [self objectForKey:key],
                    NULL,
                    (CFStringRef) @"!*'()@&=+$,/?%#[];;",
                    kCFStringEncodingUTF8));
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}

@end