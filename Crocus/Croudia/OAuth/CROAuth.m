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

#import "CROAuth.h"
#import "CROAuthParams.h"
#import "NSDictionary+CRURLParams.h"
#import "CRHTTPLoader.h"

#define CONSUMER_KEY @""
#define CONSUMER_SECRET @""
#define CR_URL_SCHEME @""

@implementation CROAuth {
    NSString *_uuid;

    void (^didRequest)(BOOL result);
}

- (id)init {
    self = [super init];
    if (self) {
        _oAuthParams = [CROAuthParams loadParams];
    }

    return self;
}

- (BOOL)authorized {
    return [self.oAuthParams.refreshToken isEqualToString:@""] == NO && self.oAuthParams.refreshToken != nil;
}

- (void)authorize:(void (^)(BOOL result))pFunction {
    didRequest = pFunction;
    NSUUID *uuid = [NSUUID UUID];
    _uuid = uuid.UUIDString;
    [[UIApplication sharedApplication] openURL:self.authorizeURL];
}

- (UIViewController *)authorizeWebView:(void (^)(BOOL result))pFunction {
    didRequest = pFunction;
    NSUUID *uuid = [NSUUID UUID];
    _uuid = uuid.UUIDString;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"Auth"];
    return nc;
}

- (NSURL *)authorizeURL {
    return [NSURL URLWithString:[NSString stringWithFormat:kCRAuthorizeURLFormat, CONSUMER_KEY, _uuid]];
}

- (void)URLHandler:(NSURL *)url {
    if ([url.scheme isEqualToString:CR_URL_SCHEME] == NO) {
        return;
    }

    NSDictionary *dictionary = [self dictionaryFromQueryString:url];

    if ([dictionary valueForKey:@"error"]) {
        didRequest(NO);
        return;
    }

    NSString *stateString = [dictionary valueForKey:@"state"];

    if ([stateString isEqualToString:_uuid] || _uuid == nil) {
        NSDictionary *params = @{@"code" : [dictionary valueForKey:@"code"],
                @"client_id" : CONSUMER_KEY,
                @"client_secret" : CONSUMER_SECRET,
                @"grant_type" : @"authorization_code"
        };
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kCROAuthTokenURL]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:params.serializeParams];
        [CRHTTPLoader loadRequest:urlRequest complete:^(NSData *data) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            self.oAuthParams.refreshToken = [response valueForKey:@"refresh_token"];
            self.oAuthParams.accessToken = [response valueForKey:@"access_token"];
            self.oAuthParams.expiresIn = [response valueForKey:@"expires_in"];
            self.oAuthParams.tokenType = [response valueForKey:@"token_type"];
            [self.oAuthParams save];
            if (didRequest) didRequest(YES);
        }                    fail:^(NSError *error) {
            if (didRequest) didRequest(NO);
        }];
    } else {
        if (didRequest) didRequest(NO);
    }

}

- (NSDictionary *)dictionaryFromQueryString:(NSURL *)url {
    NSString *query = [url query];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];

    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [dict setObject:val forKey:key];
    }
    return dict;
}

- (void)refreshToken:(void (^)(BOOL result))pFunction {
    if (_oAuthParams.refreshToken == nil) {
        _oAuthParams = [CROAuthParams loadParams];
        return;
    }
    NSDictionary *params = @{@"refresh_token" : _oAuthParams.refreshToken,
            @"client_id" : CONSUMER_KEY,
            @"client_secret" : CONSUMER_SECRET,
            @"grant_type" : @"refresh_token"
    };
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kCROAuthTokenURL]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:params.serializeParams];
    [CRHTTPLoader loadRequest:urlRequest complete:^(NSData *data) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        self.oAuthParams.refreshToken = [response valueForKey:@"refresh_token"];
        self.oAuthParams.accessToken = [response valueForKey:@"access_token"];
        self.oAuthParams.expiresIn = [response valueForKey:@"expires_in"];
        self.oAuthParams.tokenType = [response valueForKey:@"token_type"];
        [self.oAuthParams save];
        pFunction(YES);
    }                    fail:^(NSError *error) {
        pFunction(NO);
    }];
}

- (void)logout {
    [self.oAuthParams delete];
}

@end