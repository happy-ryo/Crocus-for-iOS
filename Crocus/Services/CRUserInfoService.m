/*
 * Copyright (C) 2015 happy_ryo
 *      https://twitter.com/happy_ryo
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "CRUserInfoService.h"
#import "CRVerifyCredentials.h"
#import "CRUser.h"
#import "CRStatus.h"
#import "CRUserTimeLine.h"
#import "CRStatusesDestroy.h"
#import "Parse.h"
#import "CRUpdateProtected.h"
#import "CRUpdateTimerSec.h"


@implementation CRUserInfoService {
    CRUpdateProtected *_updateProtected;
    CRUpdateTimerSec *_updateTimerSec;
    CRVerifyCredentials *_verifyCredentials;
    CRUser *_user;
}

- (void)loadUserInfo {
    __weak CRUserInfoService *weakSelf = self;

    _verifyCredentials = [[CRVerifyCredentials alloc] initWithGetFinished:^(NSDictionary *userDic, NSError *error) {
        if (error == nil) {
            CRUser *user = [weakSelf parseUser:userDic];
            CRUser *oldUser = weakSelf.getUser;
            user.timerSec = oldUser.timerSec;
            [self saveUser:user];
            PFInstallation *installation = [PFInstallation currentInstallation];
            NSString *userName = [NSString stringWithFormat:@"c_%@", user.screenName];
            [installation setChannels:@[userName]];
            [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            }];
        }
    }];
    [_verifyCredentials load];
}

- (void)saveUser:(CRUser *)user {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
    [userDefaults setObject:userData forKey:USER_INFO_KEY];
    [userDefaults synchronize];
}

- (BOOL)isExistUserInfo {
    CRUser *user = [self getUser];
    return user != nil;
}

- (BOOL)isExistUserIcon {
    CRUser *user = [self getUser];
    return user.profileImageUrlHttps != nil && ![user.profileImageUrlHttps isEqualToString:@""] ?: NO;
}

- (BOOL)replyCheck:(CRStatus *)status {
    CRUser *user = [self getUser];
    BOOL result;
    if (user != nil && status.inReplyToUserId != nil) {
        result = [user.idNum isEqualToNumber:status.inReplyToUserId];
    } else {
        result = NO;
    }
    return result;
}

- (BOOL)checkMineStatus:(CRStatus *)status {
    CRUser *user = [self getUser];
    BOOL result;
    if (user != nil) {
        result = [user.idNum isEqualToNumber:status.user.idNum];
    } else {
        result = NO;
    }
    return result;
}

- (CRUser *)getUser {
    if (_user != nil) {
        return _user;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *userData = [userDefaults objectForKey:USER_INFO_KEY];
    if (userData == nil) {
        [self loadUserInfo];
        return nil;
    }
    _user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    return _user;
}

- (void)deleteTodayStatuses:(void (^)(NSUInteger count))callback {
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *todayZero = [formatter dateFromString:[formatter stringFromDate:today]];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];

    __block NSUInteger count = 0;
    __block CRUserTimeLine *userTimeLine = [[CRUserTimeLine alloc] initWithLoadFinished:^(NSArray *statusArray, BOOL reload, NSError *error) {
        if (statusArray.count == 0) {
            callback(0);
            return;
        }
        for (NSDictionary *dictionary in statusArray) {
            NSDate *date = [dateFormatter dateFromString:dictionary[@"created_at"]];
            NSComparisonResult comparisonResult = [todayZero compare:date];
            if (comparisonResult == NSOrderedAscending) {
                count++;
                CRStatusesDestroy *statusesDestroy = [[CRStatusesDestroy alloc] initWithShowId:dictionary[@"id_str"]
                                                                                  loadFinished:^(NSDictionary *statusDic, NSError *error) {
                                                                                  }];
                [statusesDestroy load];
            } else {
                callback(count);
                return;
            }
        }
        if (count == 0) {
            callback(count);
            return;
        }
        NSDictionary *maxDictionary = statusArray.lastObject;
        userTimeLine.maxId = maxDictionary[@"id_str"];
        [userTimeLine load];
    }                                                                            userId:self.getUser.idStr];
    userTimeLine.count = @"50";
    [userTimeLine load];
}

- (void)deleteAllStatuses:(void (^)(NSUInteger count))callback {
    __block CRUserTimeLine *userTimeLine = [[CRUserTimeLine alloc] initWithLoadFinished:^(NSArray *statusArray, BOOL reload, NSError *error) {
        if (statusArray.count == 0) {
            callback(0);
            return;
        }
        for (NSDictionary *dictionary in statusArray) {
            CRStatusesDestroy *statusesDestroy = [[CRStatusesDestroy alloc] initWithShowId:dictionary[@"id_str"]
                                                                              loadFinished:^(NSDictionary *statusDic, NSError *error) {
                                                                              }];
            [statusesDestroy load];
        }

        NSDictionary *maxDictionary = statusArray.lastObject;
        userTimeLine.maxId = maxDictionary[@"id_str"];
        [userTimeLine load];
    }                                                                            userId:self.getUser.idStr];
    [userTimeLine load];
}

- (void)protect:(BOOL)status updateFinish:(UpdateFinished)pFunction {
    __weak CRUserInfoService *weakSelf = self;

    _updateProtected = [[CRUpdateProtected alloc] initWithProtect:status updateFinished:^(BOOL result) {
        if (result) {
            CRUser *user = weakSelf.getUser;
            user.userProtected = status;
            [weakSelf saveUser:user];
        }
    }];
    [_updateProtected load];
}

- (void)timer:(NSString *)timerSec updateFinish:(UpdateFinished)pFunction {
    if (timerSec.integerValue) {
        NSInteger integer = timerSec.integerValue;
        if (integer >= 1 && 300 >= integer) {
            __weak CRUserInfoService *weakSelf = self;
            _updateTimerSec = [[CRUpdateTimerSec alloc] initWithTimerSec:timerSec updateFinished:^(BOOL result) {
                if (result) {
                    CRUser *user = weakSelf.getUser;
                    user.timerSec = timerSec;
                    [weakSelf saveUser:user];
                }
                pFunction(result);
            }];
            [_updateTimerSec load];
        } else {
            pFunction(NO);
        }
    }
}
@end