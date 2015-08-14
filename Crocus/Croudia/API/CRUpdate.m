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

#import "CRUpdate.h"

@implementation CRUpdate {

}

- (id)initWithStatus:(NSString *)status updateFinished:(UpdateStatusFinished)updateFinished {
    self = [super init];
    if (self) {
        _status = status;
        _updateFinished = updateFinished;
    }

    return self;
}

- (void)load {
    [super load];
}


- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    if (error) {
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Crocus", @"Crocus") message:[NSString stringWithFormat:@"%@\nerror code %i", @"投稿に失敗しました、時間をおいて再度お試し下さい。 ", error.code] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlertView show];
    } else {
        if (_updateFinished)_updateFinished(@{}, nil);
    }
}

- (NSString *)path {
    return @"statuses/update.json";
}

- (enum CR_REQUEST_METHOD)HTTPMethod {
    return POST;
}

- (NSDictionary *)requestParams {
    _params = [NSMutableDictionary dictionary];
    if (_status.length < 372) {
        [_params setValue:_status forKey:@"status"];
    }

    if (_inReplyToStatusId) {
        [_params setValue:_inReplyToStatusId forKey:@"in_reply_to_status_id"];
    }

    if (_inReplyWithQuote) {
        [_params setValue:_inReplyWithQuote forKey:@"in_reply_with_quote"];
    }

    if (_timer) {
        [_params setValue:@"true" forKey:@"timer"];
    }
    return _params;
}

@end