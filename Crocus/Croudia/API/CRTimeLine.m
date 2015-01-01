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
                NSString *tmp = [NSString stringWithFormat:@"%@", [statusArray[statusArray.count - 1] valueForKey:@"id_str"]];
                if ([tmp isEqualToString:_maxId]) {
                    _loadFinished(@[], NO, error);
                    return;
                }
                _maxId = tmp;
                _loadFinished(statusArray, statusArray.count == 20, error);
                return;
            }
        }
    }
    _loadFinished(@[], NO, error);
}

@end