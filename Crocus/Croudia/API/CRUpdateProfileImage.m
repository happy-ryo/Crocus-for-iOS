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


#import "CRUpdateProfileImage.h"
#import "CROAuth.h"
#import "CROAuthParams.h"


@implementation CRUpdateProfileImage {
    UIImage *_media;
    UpdateProfileImageFinished _updateFinished;
}

- (id)initWithMedia:(UIImage *)media updateFinished:(UpdateProfileImageFinished)updateFinished {
    self = [super init];
    if (self) {
        _media = media;
        _updateFinished = updateFinished;
    }

    return self;
}

- (NSString *)path {
    return @"account/update_profile_image.json";
}

- (enum CR_REQUEST_METHOD)HTTPMethod {
    return POST;
}


- (NSURLRequest *)createURLRequest {
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] init];
    NSString *stringURL;


    stringURL = [self requestURL];
    NSData *pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation(_media)];

    NSString *boundary = @"_insert_some_boundary_here";
    NSMutableData *result = [[NSMutableData alloc] init];
    [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];

    [result appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", @"hoge.png"] dataUsingEncoding:NSASCIIStringEncoding]];
    [result appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [result appendData:pngData];
    [result appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];


    [mutableURLRequest setHTTPMethod:@"POST"];
    [mutableURLRequest setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    NSLog(@"%@", [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding]);
    [mutableURLRequest setHTTPBody:result];

    NSURL *url = [NSURL URLWithString:stringURL];
    [mutableURLRequest setURL:url];
    [mutableURLRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];


    if (_oAuth.authorized) {
        NSString *authHeaderString = [NSString stringWithFormat:@"%@ %@", _oAuth.oAuthParams.tokenType, _oAuth.oAuthParams.accessToken];
        [mutableURLRequest addValue:authHeaderString forHTTPHeaderField:@"Authorization"];
    }

    return mutableURLRequest;
}

- (void)parseResponse:(NSData *)data error:(NSError *)error {
    [super parseResponse:data error:error];
    if (_updateFinished)_updateFinished(error == nil);
}


@end