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


#import "CRUpdateWithMedia.h"
#import "NSDictionary+CRURLParams.h"
#import "CROAuth.h"
#import "CROAuthParams.h"

@implementation CRUpdateWithMedia {
    UIImage *_media;
    UIBackgroundTaskIdentifier _bgTask;
}

- (id)initWithStatus:(NSString *)status media:(UIImage *)media updateFinished:(UpdateStatusFinished)updateFinished {
    self = [super init];
    if (self) {
        _status = status;
        _updateFinished = updateFinished;
        _media = media;
    }

    return self;
}

- (NSString *)path {
    return @"statuses/update_with_media.json";
}


- (NSURLRequest *)createURLRequest {
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] init];
    NSString *stringURL;

    if (self.HTTPMethod == GET) {
        stringURL = [NSString stringWithFormat:@"%@?%@", self.requestURL, self.requestParams.paramsString];
        [mutableURLRequest setHTTPMethod:@"GET"];
    } else if (self.HTTPMethod == POST) {
        stringURL = [self requestURL];
        NSData *pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation(_media)];

        NSString *boundary = @"_insert_some_boundary_here";
        NSMutableData *result = [[NSMutableData alloc] init];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
        [result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"status\"\r\n\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
        [result appendData:[_status dataUsingEncoding:NSUTF8StringEncoding]];
        [result appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];

        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
        [result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media\"; filename=\"%@\"\r\n", @"hoge.png"] dataUsingEncoding:NSASCIIStringEncoding]];
        [result appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
        [result appendData:pngData];
        [result appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];


        [mutableURLRequest setHTTPMethod:@"POST"];
        [mutableURLRequest setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        [mutableURLRequest setHTTPBody:result];
    }

    NSURL *url = [NSURL URLWithString:stringURL];
    [mutableURLRequest setURL:url];
    [mutableURLRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];


    if (_oAuth.authorized) {
        NSString *authHeaderString = [NSString stringWithFormat:@"%@ %@", _oAuth.oAuthParams.tokenType, _oAuth.oAuthParams.accessToken];
        [mutableURLRequest addValue:authHeaderString forHTTPHeaderField:@"Authorization"];
    }

    return mutableURLRequest;
}

- (void)load {
    UIApplication *application = [UIApplication sharedApplication];
    _bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }];
    [super load];
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
    _bgTask = UIBackgroundTaskInvalid;
    [super parseResponse:data error:error];
}

@end