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

@class CROAuthParams;
@class CROAuth;

static BOOL showOAuth;
static NSString *const kCROAuthTokenURL = @"https://api.croudia.com/oauth/token";

static NSString *const kCRAuthorizeURLFormat = @"https://api.croudia.com/oauth/authorize?response_type=code&client_id=%@&state=%@";

@interface CROAuthViewController : UIViewController <UIWebViewDelegate>
@property(nonatomic, strong) CROAuth *auth;

+ (void)showWithCROAuth:(CROAuth *)auth;

+ (void)close;
@end

@interface CROAuth : NSObject <UIWebViewDelegate>
@property(nonatomic, readonly) CROAuthParams *oAuthParams;

- (BOOL)authorized;

- (void)authorize:(void (^)(BOOL result))didFinishedRequest;


- (void)authorizeWebView:(void (^)(BOOL result))didFinishedRequest;

- (NSURL *)authorizeURL;

- (void)URLHandler:(NSURL *)url;

- (void)refreshToken:(void (^)(BOOL result))pFunction;

- (void)logout;
@end

