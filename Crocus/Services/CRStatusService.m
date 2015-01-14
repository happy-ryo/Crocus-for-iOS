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
#import "CRStatusService.h"
#import "CRStatus.h"
#import "CRSpread.h"
#import "CRUpdate.h"
#import "CRUpdateWithMedia.h"
#import "CRFavoritesCreate.h"
#import "CRStatusUpdateViewController.h"
#import "CRStatusesDestroy.h"


@implementation CRStatusService {
    CRStatus *_status;

    void(^_callback)(BOOL requestStatus);
}

- (instancetype)initWithStatus:(CRStatus *)status callback:(void (^)(BOOL status))callback {
    self = [super init];
    if (self) {
        _status = status;
        _callback = callback;
    }

    return self;
}

- (void)post:(NSString *)message callback:(void (^)(BOOL status, NSError *error))callBack {
    if (message.length == 0) {
        callBack(NO, [NSError errorWithDomain:@"crocus" code:500 userInfo:@{@"message" : @"投稿文が空です"}]);
    } else {
        CRUpdate *update = [[CRUpdate alloc] initWithStatus:message updateFinished:^(NSDictionary *dictionary, NSError *error) {
            if (error == nil) {
                callBack(YES, nil);
            } else {
                callBack(NO, error);
            }
        }];
        if (_status != nil) {
            update.inReplyToStatusId = _status.idStr;
        }
        [update load];
    }
}

- (void)postWithMedia:(NSString *)message image:(UIImage *)image callback:(void (^)(BOOL status, NSError *error))callback {
    if (image == nil) {
        [self post:message callback:callback];
    } else {
        CRUpdateWithMedia *updateWithMedia = [[CRUpdateWithMedia alloc] initWithStatus:message
                                                                                 media:image
                                                                        updateFinished:^(NSDictionary *dictionary, NSError *error) {
                                                                            if (error == nil) {
                                                                                callback(YES, nil);
                                                                            } else {
                                                                                callback(NO, error);
                                                                            }
                                                                        }];
        if (_status != nil) {
            updateWithMedia.inReplyToStatusId = _status.idStr;
        }
        [updateWithMedia load];
    }
}

- (void)delete {
    CRStatusesDestroy *statusesDestroy = [[CRStatusesDestroy alloc] initWithShowId:_status.idStr loadFinished:^(NSDictionary *statusDic, NSError *error) {
        _callback(error == nil);
    }];
    [statusesDestroy load];
}

- (void)spread {
    CRSpread *spread = [[CRSpread alloc] initWithShowId:_status.idStr loadFinished:^(NSDictionary *statusDic, NSError *error) {
        _callback(error == nil);
    }];
    [spread load];
}

- (void)favourite {
    CRFavoritesCreate *favoritesCreate = [[CRFavoritesCreate alloc] initWithShowId:_status.idStr loadFinished:^(NSDictionary *statusDic, NSError *error) {
        _callback(error == nil);
    }];
    [favoritesCreate load];
}

- (void)reply {
    [CRStatusUpdateViewController showStatus:_status callBack:^(BOOL reload) {

    }];
}
@end