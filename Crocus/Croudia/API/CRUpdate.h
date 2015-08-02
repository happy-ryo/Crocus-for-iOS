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

#import <Foundation/Foundation.h>
#import "CRAPIRequest.h"


typedef void (^UpdateStatusFinished)(NSDictionary *dictionary, NSError *error);

@interface CRUpdate : CRAPIRequest {
    NSString *_status;
    NSString *_inReplyToStatusId;
    NSString *_inReplyWithQuote;
    NSString *_trimUser;
    NSString *_includeEntities;
    BOOL _timer;
    NSMutableDictionary *_params;
    UpdateStatusFinished _updateFinished;
}
@property(nonatomic, copy) NSString *inReplyToStatusId;
@property(nonatomic, copy) NSString *inReplyWithQuote;
@property(nonatomic, copy) NSString *trimUser;
@property(nonatomic, copy) NSString *includeEntities;

@property(nonatomic) BOOL timer;

- (id)initWithStatus:(NSString *)status updateFinished:(UpdateStatusFinished)updateFinished;

@end