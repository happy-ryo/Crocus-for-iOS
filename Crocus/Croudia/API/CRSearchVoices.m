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


#import "CRSearchVoices.h"


@implementation CRSearchVoices {
    NSString *_query;
}
- (instancetype)initWithQuery:(NSString *)query function:(LoadFinished)pFunction {
    self = [super init];
    if (self) {
        _query = query;
        self.loadFinished = pFunction;
    }

    return self;
}

- (NSString *)path {
    return @"search/voices.json";
}

- (NSDictionary *)requestParams {
    NSMutableDictionary *mutableData = [super requestParams].mutableCopy;
    [mutableData setValue:_query forKey:@"q"];
    return mutableData;
}


- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    if (data != nil) {
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSMutableArray *tmpArray = @[].mutableCopy;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = obj;
            tmpArray = [dictionary valueForKey:@"statuses"];
        }
        if ([tmpArray isKindOfClass:[NSArray class]]) {
            NSArray *statusArray = tmpArray;
            if (statusArray.count > 0) {
                NSString *tmp = [NSString stringWithFormat:@"%@", [[statusArray objectAtIndex:statusArray.count - 1] valueForKey:@"id_str"]];
                if ([tmp isEqualToString:self.maxId]) {
                    self.loadFinished(@[], NO, error);
                    return;
                }
                self.maxId = tmp;
                if (statusArray.count == 20) {
                    NSArray *array = [self checkMute:statusArray];
                    [self mentionVibration:array];
                    self.loadFinished(array, YES, error);
                } else {
                    NSArray *array = [self checkMute:statusArray];
                    [self mentionVibration:array];
                    self.loadFinished(array, NO, error);
                }
                return;
            }
        }
    }
    self.loadFinished(@[], NO, error);
}

@end