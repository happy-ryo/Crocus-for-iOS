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

#import "CRFriendShipsCreate.h"


@implementation CRFriendShipsCreate {
    NSString *_userId;
    NSString *_screenName;
    didCreate _didFollowCreate;
}

- (id)initWithUserId:(NSString *)userId didFollow:(didCreate)didFollow {
    self = [super init];
    if (self) {
        _userId = userId;
        _didFollowCreate = didFollow;
    }

    return self;
}

- (NSString *)path {
    return @"friendships/create.json";
}

- (enum CR_REQUEST_METHOD)HTTPMethod {
    return POST;
}

- (NSDictionary *)requestParams {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (_userId) {
        [dictionary setValue:_userId forKey:@"user_id"];
    }

    if (_screenName) {
        [dictionary setValue:_screenName forKey:@"screen_name"];
    }
    return dictionary;
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    if (error.code == 400) {
        if (_didFollowCreate)_didFollowCreate(NO);
    } else if (error) {
        return;
    } else {
        if (_didFollowCreate)_didFollowCreate(YES);
    }
}


@end