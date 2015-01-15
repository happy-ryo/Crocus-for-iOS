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

#import "CRUser.h"
#import "CREntities.h"
#import "CRSource.h"
#import "CRStatus.h"
#import "CRTimeLineService.h"


@implementation CRService {

}
- (CRStatus *)parseStatus:(NSDictionary *)dictionary {
    CRStatus *status = [[CRStatus alloc] init];
    status.idNum = dictionary[@"id"];
    status.idStr = dictionary[@"id_str"];
    status.spread = [self numberToBool:dictionary[@"spread"]];
    status.createdAt = dictionary[@"created_at"];
    status.inReplyToScreenName = [self nullToNil:dictionary key:@"in_reply_to_screen_name"];
    status.source = [self parseSource:dictionary[@"source"]];
    status.spreadCount = dictionary[@"spread_count"];
    status.favoritedCount = dictionary[@"favorited_count"];
    status.inReplyToStatusId = [self nullToNil:dictionary key:@"in_reply_to_status_id"];
    status.inReplyToStatusIdStr = [self nullToNil:dictionary key:@"in_reply_to_status_id_str"];
    status.text = dictionary[@"text"];
    status.favorited = [self numberToBool:dictionary[@"favorited"]];
    status.entities = [self parseEntities:dictionary[@"entities"]];
    status.inReplyToUserId = [self nullToNil:dictionary key:@"in_reply_to_user_id"];
    status.inReplyToUserIdStr = [self nullToNil:dictionary key:@"in_reply_to_user_id_str"];
    status.user = [self parseUser:dictionary[@"user"]];
    if (dictionary[@"reply_status"] != nil) {
        status.replyStatus = [self parseStatus:dictionary[@"reply_status"]];
    }
    if (dictionary[@"spread_status"] != nil) {
        status.spreadStatus = [self parseStatus:dictionary[@"spread_status"]];
    }
    return status;
}

- (BOOL)numberToBool:(NSNumber *)number {
    return number.boolValue;
}

- (id)nullToNil:(NSDictionary *)dictionary key:(NSString *)key {
    return dictionary[key] != [NSNull null] ? dictionary[key] : nil;
}

- (CRUser *)parseUser:(NSDictionary *)dictionary {
    CRUser *user = [[CRUser alloc] init];
    user.idNum = dictionary[@"id"];
    user.idStr = dictionary[@"id_str"];
    user.userDescription = [self nullToNil:dictionary key:@"description"];
    user.followRequestSent = (Boolean) dictionary[@"follow_request_sent"];
    user.followersCount = dictionary[@"followers_count"];
    user.friendsCount = dictionary[@"friends_count"];
    user.createdAt = dictionary[@"created_at"];
    user.statusesCount = dictionary[@"statuses_count"];
    user.userProtected = [self numberToBool:dictionary[@"protected"]];
    user.profileImageUrlHttps = [self nullToNil:dictionary key:@"profile_image_url_https"];
    user.url = [self nullToNil:dictionary key:@"url"];
    user.coverImageUrlHttps = [self nullToNil:dictionary key:@"cover_image_url_https"];
    user.location = dictionary[@"location"];
    user.favoritesCount = dictionary[@"favorites_count"];
    user.following = [self numberToBool:dictionary[@"following"]];
    user.name = dictionary[@"name"];
    user.screenName = dictionary[@"screen_name"];
    return user;
}

- (CREntities *)parseEntities:(NSDictionary *)dictionary {
    if (dictionary == nil) {
        return nil;
    }
    NSDictionary *media = dictionary[@"media"];
    return [[CREntities alloc] initWithMediaURL:media[@"media_url_https"] type:dictionary[@"type"]];
}

- (CRSource *)parseSource:(NSDictionary *)dictionary {
    return [[CRSource alloc] initWithName:dictionary[@"name"] url:dictionary[@"url"]];
}
@end