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


#import "CRUpdateProfile.h"


@implementation CRUpdateProfile {
    NSString *_name;
    NSString *_url;
    NSString *_location;
    NSString *_description;
    UpdateFinished _updateFinished;
}

- (id)initWithName:(NSString *)name url:(NSString *)url location:(NSString *)location description:(NSString *)description updateFinished:(UpdateFinished)updateFinished {
    self = [super init];
    if (self) {
        _name = name;
        _url = url;
        _location = location;
        _description = description;
        _updateFinished = updateFinished;
    }

    return self;
}

- (NSString *)path {
    return @"account/update_profile.json";
}

- (enum CR_REQUEST_METHOD)HTTPMethod {
    return POST;
}

- (NSDictionary *)requestParams {
    return @{@"name" : _name, @"url" : _url, @"location" : _location, @"description" : _description};
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    if (_updateFinished)_updateFinished(error ? NO : YES);
}

@end