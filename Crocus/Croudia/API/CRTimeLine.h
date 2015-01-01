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

typedef void (^LoadFinished)(NSArray *statusArray, BOOL reload, NSError *error);

@interface CRTimeLine : CRAPIRequest {
    NSMutableDictionary *_requestParams;
}
@property(nonatomic, copy) NSString *maxId;
@property(nonatomic) BOOL trimUser;
@property(nonatomic) BOOL includeEntities;

@property(nonatomic, copy) LoadFinished loadFinished;

@property(nonatomic, copy) NSString *sinceId;

@property(nonatomic) BOOL reloadMode;

- (id)initWithMaxId:(NSString *)maxId trimUser:(BOOL)trimUser includeEntities:(BOOL)includeEntities loadFinished:(LoadFinished)loadFinished;

- (id)initWithTrimUser:(BOOL)trimUser includeEntities:(BOOL)includeEntities loadFinished:(LoadFinished)loadFinished;

- (id)initWithTrimUser:(BOOL)trimUser loadFinished:(LoadFinished)loadFinished;

- (id)initWithIncludeEntities:(BOOL)includeEntities loadFinished:(LoadFinished)loadFinished;

- (id)initWithLoadFinished:(LoadFinished)loadFinished;

@end