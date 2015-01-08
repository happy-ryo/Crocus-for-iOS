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


@implementation CRUserInfoService {

    CRVerifyCredentials *_verifyCredentials;
    CRUser *_user;
}

- (void)loadUserInfo {
    __weak CRUserInfoService *weakSelf = self;

    _verifyCredentials = [[CRVerifyCredentials alloc] initWithGetFinished:^(NSDictionary *userDic, NSError *error) {
        if (error == nil) {
            CRUser *user = [weakSelf parseUser:userDic];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
            [userDefaults setObject:userData forKey:USER_INFO_KEY];
            [userDefaults synchronize];
        }
    }];
    [_verifyCredentials load];
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
@end