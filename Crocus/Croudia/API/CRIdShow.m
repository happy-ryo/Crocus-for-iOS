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

#import "CRIdShow.h"
#import "CROAuth.h"
#import "CROAuthParams.h"

@implementation CRIdShow {
}

- (id)initWithShowId:(NSString *)showId loadFinished:(GetFinished)loadFinished {
    self = [super init];
    if (self) {
        _targetId = showId;
        _getFinished = loadFinished;
    }

    return self;
}


- (NSURLRequest *)createURLRequest {
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] init];
    NSString *stringURL;

    stringURL = [NSString stringWithFormat:self.requestURL, _targetId];
    if (self.HTTPMethod == GET) {
        [mutableURLRequest setHTTPMethod:@"GET"];
    } else if (self.HTTPMethod == POST) {
        [mutableURLRequest setHTTPMethod:@"POST"];
    }

    NSURL *url = [NSURL URLWithString:stringURL];
    [mutableURLRequest setURL:url];
    [mutableURLRequest setCachePolicy:self.cachePolicy];

    if (_oAuth.authorized) {
        NSString *authHeaderString = [NSString stringWithFormat:@"%@ %@", _oAuth.oAuthParams.tokenType, _oAuth.oAuthParams.accessToken];
        [mutableURLRequest addValue:authHeaderString forHTTPHeaderField:@"Authorization"];
    }

    return mutableURLRequest;
}


- (NSString *)path {
    return @"statuses/show/%@.json";
}

- (enum CR_REQUEST_METHOD)HTTPMethod {
    return GET;
}

- (NSDictionary *)requestParams {
    return [super requestParams];
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    if (error) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (_getFinished)_getFinished(dictionary, error);
}

@end