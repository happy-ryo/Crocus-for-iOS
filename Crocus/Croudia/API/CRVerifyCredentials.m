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

#import "CRVerifyCredentials.h"


@implementation CRVerifyCredentials {
    GetFinished _getFinished;
}
- (id)initWithGetFinished:(GetFinished)getFinished {
    self = [super init];
    if (self) {
        _getFinished = getFinished;
    }

    return self;
}


- (NSString *)path {
    return @"account/verify_credentials.json";
}

- (enum CR_REQUEST_METHOD)HTTPMethod {
    return GET;
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    if (error == nil && _getFinished) {
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        _getFinished(obj, error);
    } else if (_getFinished && error) {
        _getFinished(nil, error);
    }
}


@end