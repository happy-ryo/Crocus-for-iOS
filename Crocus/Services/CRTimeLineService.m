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
#import "CRTimeLineService.h"
#import "CRPublicTimeLine.h"
#import "CRStatus.h"
#import "CRSource.h"
#import "CREntities.h"
#import "CRUser.h"


@interface CRTimeLineService ()
@property(nonatomic, strong) NSMutableArray *statuses;
@property(nonatomic, strong) NSArray *newerStatuses;
@end

@implementation CRTimeLineService {
    CRPublicTimeLine *_publicTimeLine;

    void (^_loaded)(NSArray *array, BOOL reload);
}

- (instancetype)initWithObserver:(id)observer loaded:(void (^)(NSArray *array, BOOL reload))loaded {
    self = [self init];
    if (self) {
        self.statuses = @[].mutableCopy;
        _loaded = loaded;
        [self addObserver:observer];
    }
    return self;
}

- (instancetype)initWithLoaded:(void (^)(NSArray *array, BOOL))loaded {
    self = [self init];
    if (self) {
        _loaded = loaded;
        self.statuses = @[].mutableCopy;
    }

    return self;
}

- (instancetype)initWithObserver:(id)observer {
    self = [self init];
    if (self) {
        self.statuses = @[].mutableCopy;
        [self addObserver:observer];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak CRTimeLineService *weakSelf = self;
        _publicTimeLine = [[CRPublicTimeLine alloc] initWithIncludeEntities:YES
                                                               loadFinished:^(NSArray *statusArray, BOOL reload, NSError *error) {
                                                                   if (error == nil) {
                                                                       NSMutableArray *tmpStatusArray = @[].mutableCopy;
                                                                       for (NSDictionary *dictionary in statusArray) {
                                                                           CRStatus *status = [self parseStatus:dictionary];
                                                                           [tmpStatusArray addObject:status];
                                                                       }
                                                                       if (reload) {
                                                                           [weakSelf.statuses addObjectsFromArray:tmpStatusArray];
                                                                       } else {
                                                                           for (NSUInteger i = 0; tmpStatusArray.count > i; i++) {
                                                                               [weakSelf.statuses insertObject:tmpStatusArray[i] atIndex:i];
                                                                           }
                                                                   }
                                                                       if (_loaded) _loaded(tmpStatusArray, reload);
                                                                       weakSelf.newerStatuses = statusArray;
                                                                   }
                                                               }];
    }

    return self;
}

- (CRStatus *)parseStatus:(NSDictionary *)dictionary {
    __weak CRTimeLineService *weakSelf = self;

    CRStatus *status = [[CRStatus alloc] init];
    status.idNum = dictionary[@"id"];
    status.idStr = dictionary[@"id_str"];
    status.spread = [self numberToBool:dictionary[@"spread"]];
    status.createdAt = dictionary[@"created_at"];
    status.inReplyToScreenName = [self nullToNil:dictionary key:@"in_reply_to_screen_name"];
    status.source = [self parseSource:dictionary[@"source"]];
    status.spreadCount = dictionary[@"spread_count"];
    status.favoritedCount = dictionary[@"favorited_count"];
    status.inReplyToStatusId = dictionary[@"in_reply_to_status_id"];
    status.inReplyToStatusIdStr = dictionary[@"in_reply_to_status_id_str"];
    status.text = dictionary[@"text"];
    status.favorited = [self numberToBool:dictionary[@"favorited"]];
    status.entities = [self parseEntities:dictionary[@"entities"]];
    status.inReplyToUserId = [self nullToNil:dictionary key:@"in_reply_to_user_id"];
    status.inReplyToUserIdStr = [self nullToNil:dictionary key:@"in_reply_to_user_id_str"];
    status.user = [self parseUser:dictionary[@"user"]];
    if (dictionary[@"reply_status"] != nil) {
        status.replyStatus = [weakSelf parseStatus:dictionary[@"reply_status"]];
    }
    if (dictionary[@"spread_status"] != nil) {
        status.spreadStatus = [weakSelf parseStatus:dictionary[@"spread_status"]];
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
    user.userDescription = dictionary[@"description"];
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

- (void)addObserver:(id)observer {
    [self addObserver:observer forKeyPath:@"newerStatuses" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver:(id)observer {
    [self removeObserver:observer forKeyPath:@"newerStatuses"];
}

- (CRStatus *)status:(NSInteger)index {
    return self.statuses[(NSUInteger) index];
}

- (NSInteger)statusCount {
    return self.statuses.count;
}

- (void)update {
    _publicTimeLine.maxId = nil;
    CRStatus *lastStatus = [self status:0];
    _publicTimeLine.sinceId = lastStatus.idStr;
    [_publicTimeLine load];
}

- (void)historyLoad {
    _publicTimeLine.sinceId = nil;
    CRStatus *maxStatus = [self status:self.statusCount - 1];
    _publicTimeLine.maxId = maxStatus.idStr;
    [_publicTimeLine load];
}

- (void)load {
    [_publicTimeLine load];
}
@end