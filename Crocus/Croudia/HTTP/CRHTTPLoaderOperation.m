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

#import "CRHTTPLoaderOperation.h"


@interface CRHTTPLoaderOperation ()
@property(nonatomic, strong) NSURLRequest *request;
@property(nonatomic, copy) CompleteBlock requestCompleteBlock;
@property(nonatomic, copy) FailBlock requestFailBlock;
@end

@implementation CRHTTPLoaderOperation {

}

- (id)initWithRequest:(NSURLRequest *)urlRequest complete:(CompleteBlock)completeBlock fail:(FailBlock)failBlock {
    self = [self init];
    if (self) {
        self.request = urlRequest;
        self.requestCompleteBlock = completeBlock;
        self.requestFailBlock = failBlock;
    }
    return self;
}


- (BOOL)isConcurrent {
    return YES;
}

- (void)main {
    __weak CRHTTPLoaderOperation *weakSelf = self;
    NSURLResponse *response = nil;
    NSError *connectionError = nil;
    NSData *responseData;
    responseData = [NSURLConnection sendSynchronousRequest:self.request returningResponse:&response error:&connectionError];
    id obj = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    if (connectionError) {
        NSMutableURLRequest *mutableURLRequest = self.request.mutableCopy;
        [mutableURLRequest setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
        responseData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&connectionError];
    }

    if (connectionError) {
        [self throwError:connectionError];
        return;
    }

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpURlResponse = (NSHTTPURLResponse *) response;
        NSInteger statusCode = httpURlResponse.statusCode;
        if (statusCode != 200) {
            NSError *responseError = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil];
            [self throwError:responseError];
            return;
        }
    }

    if ([NSThread currentThread].isMainThread) {
        self.requestCompleteBlock(responseData);
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.requestCompleteBlock(responseData);
        });
    }

}

- (void)throwError:(NSError *)error {
    __weak CRHTTPLoaderOperation *weakSelf = self;
    if ([NSThread currentThread].isMainThread) {
        self.requestFailBlock(error);
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.requestFailBlock(error);
        });
    }
}

@end