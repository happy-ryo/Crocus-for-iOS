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

#import "CRShow.h"

@implementation CRShow {
}


- (id)initWithShowId:(NSString *)showId loadFinished:(GetFinished)loadFinished {
    self = [super initWithShowId:showId loadFinished:loadFinished];
    if (self) {

    }

    return self;
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
}

@end