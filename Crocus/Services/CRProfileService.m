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
#import "CRProfileService.h"
#import "CRUser.h"
#import "CRUsersShow.h"
#import "CRUserTimeLine.h"
#import "CRFriendShipsCreate.h"
#import "CRFriendshipsDestroy.h"
#import "CRMutesCreate.h"
#import "CRMutesDestroy.h"


@interface CRProfileService ()
@property(nonatomic, strong) CRUser *user;
@end

@implementation CRProfileService
- (instancetype)initWithUser:(CRUser *)user {
    self = [super init];
    if (self) {
        self.user = user;
    }

    return self;
}

- (void)loadUserInfo:(void (^)(CRUser *user))callback {
    __weak CRProfileService *weakSelf = self;

    CRUsersShow *usersShow = [[CRUsersShow alloc] initWithUserId:self.user.idStr getFinished:^(NSDictionary *statusDic, NSError *error) {
        if (error == nil) {
            weakSelf.user = [weakSelf parseUser:statusDic];
            if (callback)callback(weakSelf.user);
        }
    }];
    [usersShow load];
}

- (void)mute:(void (^)(BOOL b))callback {
    CRMutesCreate *mutesCreate = [[CRMutesCreate alloc] initWithUserId:_user.idStr didFollow:callback];
    [mutesCreate load];
}

- (void)unMute:(void (^)(BOOL b))callback {
    CRMutesDestroy *mutesDestroy = [[CRMutesDestroy alloc] initWithUserId:_user.idStr didFollow:callback];
    [mutesDestroy load];
}

- (BOOL)isFollowed {
    return self.user.following;
}

- (void)follow:(void (^)(BOOL result))callback {
    __weak CRProfileService *weakSelf = self;

    CRFriendShipsCreate *friendShipsCreate = [[CRFriendShipsCreate alloc] initWithUserId:self.user.idStr didFollow:^(BOOL result) {
        if (result) {
            [weakSelf loadUserInfo:nil];
        }
        callback(result);
    }];
    [friendShipsCreate load];
}

- (void)unFollow:(void (^)(BOOL result))callback {
    __weak CRProfileService *weakSelf = self;

    CRFriendshipsDestroy *friendshipsDestroy = [[CRFriendshipsDestroy alloc] initWithUserId:self.user.idStr didFollow:^(BOOL result) {
        if (result) {
            [weakSelf loadUserInfo:nil];
        }
        callback(result);
    }];
    [friendshipsDestroy load];
}

- (void)today:(void (^)(NSUInteger count))callback {
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *todayZero = [formatter dateFromString:[formatter stringFromDate:today]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];

    __block NSUInteger count = 0;
    __block CRUserTimeLine *userTimeLine = [[CRUserTimeLine alloc] initWithLoadFinished:^(NSArray *statusArray, BOOL reload, NSError *error) {
        for (NSDictionary *dictionary in statusArray) {
            NSDate *date = [dateFormatter dateFromString:dictionary[@"created_at"]];
            NSComparisonResult comparisonResult = [todayZero compare:date];
            if (comparisonResult == NSOrderedAscending) {
                count++;
            } else {
                callback(count);
                return;
            }
        }
        NSDictionary *maxDictionary = statusArray.lastObject;
        userTimeLine.maxId = maxDictionary[@"id_str"];
        [userTimeLine load];
    }                                                                            userId:self.user.idStr];
    userTimeLine.count = @"50";
    [userTimeLine load];
}
@end