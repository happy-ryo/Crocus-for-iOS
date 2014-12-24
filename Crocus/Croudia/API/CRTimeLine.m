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


#import "CRTimeLine.h"
#import "CRMute.h"
#import "NSObject+Add.h"
#import "CRConfig.h"
#import "CRMentions.h"
#import <AudioToolbox/AudioServices.h>

@implementation CRTimeLine {
    NSString *_maxId;
    NSString *_sinceId;
    BOOL _trimUser;
    BOOL _includeEntities;
    LoadFinished _loadFinished;
    BOOL _reloadMode;
    CRMute *_mute;
}

- (id)initWithMaxId:(NSString *)maxId trimUser:(BOOL)trimUser includeEntities:(BOOL)includeEntities loadFinished:(LoadFinished)loadFinished {
    self = [self init];
    if (self) {
        self.maxId = maxId;
        self.trimUser = trimUser;
        self.includeEntities = includeEntities;
        self.loadFinished = loadFinished;
    }

    return self;
}

- (id)initWithTrimUser:(BOOL)trimUser includeEntities:(BOOL)includeEntities loadFinished:(LoadFinished)loadFinished {
    self = [self init];
    if (self) {
        self.trimUser = trimUser;
        self.includeEntities = includeEntities;
        self.loadFinished = loadFinished;
    }

    return self;
}

- (id)initWithTrimUser:(BOOL)trimUser loadFinished:(LoadFinished)loadFinished {
    self = [self init];
    if (self) {
        self.trimUser = trimUser;
        self.loadFinished = loadFinished;
    }

    return self;
}

- (id)initWithIncludeEntities:(BOOL)includeEntities loadFinished:(LoadFinished)loadFinished {
    self = [self init];
    if (self) {
        self.includeEntities = includeEntities;
        self.loadFinished = loadFinished;
    }

    return self;
}

- (id)initWithLoadFinished:(LoadFinished)loadFinished {
    self = [self init];
    if (self) {
        self.loadFinished = loadFinished;
    }

    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _requestParams = [NSMutableDictionary dictionary];
        _mute = [[CRMute alloc] init];
    }

    return self;
}

- (enum CR_REQUEST_METHOD)HTTPMethod {
    return GET;
}

- (NSDictionary *)requestParams {
    if (_maxId != nil) {
        [_requestParams setValue:_maxId forKey:@"max_id"];
    }

    if (_sinceId != nil) {
        [_requestParams removeObjectForKey:@"max_id"];
        [_requestParams setValue:_sinceId forKey:@"since_id"];
    }

    if (_trimUser) {
        [_requestParams setValue:@"true" forKey:@"trim_user"];
    }

    if (_includeEntities) {
        [_requestParams setValue:@"true" forKey:@"include_entities"];
    }

    return _requestParams;
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    if (data != nil) {
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *statusArray = obj;
            if (statusArray.count > 0) {
                NSString *tmp = [NSString stringWithFormat:@"%@", [[statusArray objectAtIndex:statusArray.count - 1] valueForKey:@"id_str"]];
                if ([tmp isEqualToString:_maxId]) {
                    [self trackEventWithCategory:@"TimeLineRetriever" withAction:@"NoRefresh" withLabel:error.description];
                    _loadFinished(@[], NO, error);
                    return;
                }
                _maxId = tmp;
                if (statusArray.count == 20) {
                    [self trackEventWithCategory:@"TimeLineRetriever" withAction:@"Refresh" withLabel:@"20"];
                    NSArray *array = [self checkMute:statusArray];
                    [self mentionVibration:array];
                    _loadFinished(array, YES, error);
                } else {
                    [self trackEventWithCategory:@"TimeLineRetriever" withAction:@"Refresh" withLabel:[NSString stringWithFormat:@"%u", statusArray.count]];
                    NSArray *array = [self checkMute:statusArray];
                    [self mentionVibration:array];
                    _loadFinished(array, NO, error);
                }
                return;
            }
        }
    }
    [self trackEventWithCategory:@"TimeLineRetriever" withAction:@"NoData" withLabel:error.description];
    _loadFinished(@[], NO, error);
}

- (void)mentionVibration:(NSArray *)statusArray {
    CRConfig *config = [CRConfig loadArchive];
    if ([self isKindOfClass:[CRMentions class]] || config.kanaMode == NO) {
        return;
    }
    void (^Vib)(NSArray *array) = ^(NSArray *array) {
        CRConfig *crConfig = [CRConfig loadArchive];
        BOOL vib = NO;
        for (NSDictionary *dictionary in statusArray) {
            if ([crConfig.userName isEqualToString:[dictionary valueForKey:@"in_reply_to_screen_name"]]) {
                vib = YES;
            }
        }
        if (vib) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    };
    Vib(statusArray);
}

- (NSArray *)checkMute:(NSArray *)statusArray {
    NSMutableArray *removeObjectArray = [NSMutableArray array];
    NSMutableArray *mutableArray = statusArray.mutableCopy;
    for (int j = 0; j < statusArray.count; j++) {
        NSDictionary *dictionary = [statusArray objectAtIndex:(NSUInteger) j];
        if ([_mute check:[[dictionary valueForKey:@"user"] valueForKey:@"id_str"]]) {
            [removeObjectArray addObject:dictionary];
        }
    }
    
    for (int k = 0; k < removeObjectArray.count; k++) {
        [mutableArray removeObject:[removeObjectArray objectAtIndex:(NSUInteger) k]];
    }
    return mutableArray;
}

@end