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

#import "CROAuthParams.h"


#define CR_OAUTH_PARAMS @"crocusoauthparams"

@implementation CROAuthParams {
    NSString *_code;
    NSString *_accessToken;
    NSString *_tokenType;
    NSString *_expiresIn;
    NSString *_refreshToken;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _code = [coder decodeObjectForKey:@"_code"];
        _accessToken = [coder decodeObjectForKey:@"_accessToken"];
        _tokenType = [coder decodeObjectForKey:@"_tokenType"];
        _expiresIn = [coder decodeObjectForKey:@"_expiresIn"];
        _refreshToken = [coder decodeObjectForKey:@"_refreshToken"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_code forKey:@"_code"];
    [coder encodeObject:_accessToken forKey:@"_accessToken"];
    [coder encodeObject:_tokenType forKey:@"_tokenType"];
    [coder encodeObject:_expiresIn forKey:@"_expiresIn"];
    [coder encodeObject:_refreshToken forKey:@"_refreshToken"];
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [defaults setObject:data forKey:CR_OAUTH_PARAMS];
    [defaults synchronize];
}

- (void)delete {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:CR_OAUTH_PARAMS];
    defaults.synchronize;
    _accessToken = nil;
    _refreshToken = nil;
}

+ (CROAuthParams *)loadParams {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults valueForKey:CR_OAUTH_PARAMS];
    CROAuthParams *authParams;
    if (data == nil) {
        authParams = [[CROAuthParams alloc] init];
    } else {
        authParams = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return authParams;
}
@end