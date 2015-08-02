//  Copyright 2015 happy_ryo
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
#import "CRUser.h"


@implementation CRUser {
    NSString *_createdAt;
    NSString *_userDescription;
    NSNumber *_favoritesCount;
    BOOL _followRequestSent;
    NSNumber *_followersCount;
    BOOL _following;
    NSNumber *_friendsCount;
    NSString *_idStr;
    NSNumber *_idNum;
    NSString *_location;
    NSString *_name;
    NSString *_profileImageUrlHttps;
    NSString *_coverImageUrlHttps;
    BOOL _userProtected;
    NSString *_screenName;
    NSNumber *_statusesCount;
    NSString *_url;
    NSString *_timerSec;
    BOOL _timerStart;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.createdAt = [coder decodeObjectForKey:@"self.createdAt"];
        self.userDescription = [coder decodeObjectForKey:@"self.userDescription"];
        self.favoritesCount = [coder decodeObjectForKey:@"self.favoritesCount"];
        self.followRequestSent = [coder decodeBoolForKey:@"self.followRequestSent"];
        self.followersCount = [coder decodeObjectForKey:@"self.followersCount"];
        self.following = [coder decodeBoolForKey:@"self.following"];
        self.friendsCount = [coder decodeObjectForKey:@"self.friendsCount"];
        self.idStr = [coder decodeObjectForKey:@"self.idStr"];
        self.idNum = [coder decodeObjectForKey:@"self.idNum"];
        self.location = [coder decodeObjectForKey:@"self.location"];
        self.name = [coder decodeObjectForKey:@"self.name"];
        self.profileImageUrlHttps = [coder decodeObjectForKey:@"self.profileImageUrlHttps"];
        self.coverImageUrlHttps = [coder decodeObjectForKey:@"self.coverImageUrlHttps"];
        self.userProtected = [coder decodeBoolForKey:@"self.userProtected"];
        self.screenName = [coder decodeObjectForKey:@"self.screenName"];
        self.statusesCount = [coder decodeObjectForKey:@"self.statusesCount"];
        self.url = [coder decodeObjectForKey:@"self.url"];
        self.timerSec = [coder decodeObjectForKey:@"self.timerSec"];
        self.timerStart = [coder decodeBoolForKey:@"self.timerStart"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.createdAt forKey:@"self.createdAt"];
    [coder encodeObject:self.userDescription forKey:@"self.userDescription"];
    [coder encodeObject:self.favoritesCount forKey:@"self.favoritesCount"];
    [coder encodeBool:self.followRequestSent forKey:@"self.followRequestSent"];
    [coder encodeObject:self.followersCount forKey:@"self.followersCount"];
    [coder encodeBool:self.following forKey:@"self.following"];
    [coder encodeObject:self.friendsCount forKey:@"self.friendsCount"];
    [coder encodeObject:self.idStr forKey:@"self.idStr"];
    [coder encodeObject:self.idNum forKey:@"self.idNum"];
    [coder encodeObject:self.location forKey:@"self.location"];
    [coder encodeObject:self.name forKey:@"self.name"];
    [coder encodeObject:self.profileImageUrlHttps forKey:@"self.profileImageUrlHttps"];
    [coder encodeObject:self.coverImageUrlHttps forKey:@"self.coverImageUrlHttps"];
    [coder encodeBool:self.userProtected forKey:@"self.userProtected"];
    [coder encodeObject:self.screenName forKey:@"self.screenName"];
    [coder encodeObject:self.statusesCount forKey:@"self.statusesCount"];
    [coder encodeObject:self.url forKey:@"self.url"];
    [coder encodeObject:self.timerSec forKey:@"self.timerSec"];
    [coder encodeBool:self.timerStart forKey:@"self.timerStart"];
}

@end