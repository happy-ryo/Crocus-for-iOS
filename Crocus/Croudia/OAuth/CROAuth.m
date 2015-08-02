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

#import "CROAuth.h"
#import "CROAuthParams.h"
#import "NSDictionary+CRURLParams.h"
#import "CRHTTPLoader.h"
#import <objc/runtime.h>

#define CONSUMER_KEY @"0497b369a2ed39c6010bf9ad95ac914b514af065e7450305edc235022efbc1a2"
#define CONSUMER_SECRET @"2b604d62bff0e0d901171ba0f7fe128690e773283d411a7d87178c98fe68a322"
#define CR_URL_SCHEME @"crocusurlscheme"

@implementation CROAuth {
    NSString *_uuid;

    void (^DidFinishedRequest)(BOOL result);
}

- (id)init {
    self = [super init];
    if (self) {
        _oAuthParams = [CROAuthParams loadParams];
    }

    return self;
}

- (BOOL)authorized {
    if (![self.oAuthParams.refreshToken isEqualToString:@""]) {
        return self.oAuthParams.refreshToken != nil;
    } else {
        return NO;
    }
}

- (void)setupUUID {
    NSUUID *uuid = [NSUUID UUID];
    _uuid = uuid.UUIDString;
}

- (void)authorize:(void (^)(BOOL result))didFinishedRequest {
    DidFinishedRequest = didFinishedRequest;
    [[UIApplication sharedApplication] openURL:self.authorizeURL];
}

- (void)authorizeWebView:(void (^)(BOOL result))didFinishedRequest {
    DidFinishedRequest = ^(BOOL result) {
        if (didFinishedRequest) {
            [CROAuthViewController close];
            didFinishedRequest(result);
        }
    };
    [CROAuthViewController showWithCROAuth:self];
}

- (NSURL *)authorizeURL {
    [self setupUUID];
    return [NSURL URLWithString:[NSString stringWithFormat:kCRAuthorizeURLFormat, CONSUMER_KEY, _uuid]];
}

- (void)URLHandler:(NSURL *)url {
    if (![url.scheme isEqualToString:CR_URL_SCHEME]) {
        return;
    }

    NSDictionary *dictionary = [self dictionaryFromQueryString:url];

    if ([dictionary valueForKey:@"error"]) {
        DidFinishedRequest(NO);
        return;
    }

    NSString *stateString = [dictionary valueForKey:@"state"];

    if ([stateString isEqualToString:_uuid] || _uuid == nil) {
        NSDictionary *params = @{@"code" : [dictionary valueForKey:@"code"],
                @"client_id" : CONSUMER_KEY,
                @"client_secret" : CONSUMER_SECRET,
                @"grant_type" : @"authorization_code"
        };
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kCROAuthTokenURL]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:params.serializeParams];
        [CRHTTPLoader loadRequest:urlRequest complete:^(NSData *data) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            self.oAuthParams.refreshToken = [response valueForKey:@"refresh_token"];
            self.oAuthParams.accessToken = [response valueForKey:@"access_token"];
            self.oAuthParams.expiresIn = [response valueForKey:@"expires_in"];
            self.oAuthParams.tokenType = [response valueForKey:@"token_type"];
            [self.oAuthParams save];
            if (DidFinishedRequest) DidFinishedRequest(YES);
        }                    fail:^(NSError *error) {
            if (DidFinishedRequest) DidFinishedRequest(NO);
        }];
    } else {
        if (DidFinishedRequest) DidFinishedRequest(NO);
    }

}

- (NSDictionary *)dictionaryFromQueryString:(NSURL *)url {
    NSString *query = [url query];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];

    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [elements[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [elements[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        dict[key] = val;
    }
    return dict;
}

- (void)refreshToken:(void (^)(BOOL result))pFunction {
    if (_oAuthParams.refreshToken == nil) {
        _oAuthParams = [CROAuthParams loadParams];
        return;
    }
    NSDictionary *params = @{@"refresh_token" : _oAuthParams.refreshToken,
            @"client_id" : CONSUMER_KEY,
            @"client_secret" : CONSUMER_SECRET,
            @"grant_type" : @"refresh_token"
    };
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kCROAuthTokenURL]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:params.serializeParams];
    [CRHTTPLoader loadRequest:urlRequest complete:^(NSData *data) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        self.oAuthParams.refreshToken = [response valueForKey:@"refresh_token"];
        self.oAuthParams.accessToken = [response valueForKey:@"access_token"];
        self.oAuthParams.expiresIn = [response valueForKey:@"expires_in"];
        self.oAuthParams.tokenType = [response valueForKey:@"token_type"];
        [self.oAuthParams save];
        pFunction(YES);
    }                    fail:^(NSError *error) {
        pFunction(NO);
    }];
}

- (void)logout {
    [self.oAuthParams delete];
}

@end


static const char kOAuthWindow;

@implementation CROAuthViewController {
    IBOutlet UIWebView *_webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_webView loadRequest:[NSURLRequest requestWithURL:self.auth.authorizeURL]];
}


- (IBAction)loadHome {
    [_webView loadRequest:[NSURLRequest requestWithURL:self.auth.authorizeURL]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self.auth URLHandler:request.URL];
    return YES;
}


+ (void)showWithCROAuth:(CROAuth *)auth {
    if (showOAuth) {
        return;
    } else {
        showOAuth = YES;
    }
    CGRect screenRect = [UIScreen mainScreen].bounds;
    UIWindow *window = [[UIWindow alloc] initWithFrame:screenRect];
    window.alpha = 0;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"OAuth" bundle:nil];
    window.rootViewController = [storyboard instantiateInitialViewController];
    window.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [window makeKeyAndVisible];
    window.transform = CGAffineTransformMakeTranslation(0, screenRect.size.height);
    window.windowLevel = UIWindowLevelNormal + 5;

    CROAuthViewController *authViewController = (CROAuthViewController *) window.rootViewController;
    authViewController.auth = auth;

    objc_setAssociatedObject([UIApplication sharedApplication], &kOAuthWindow, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [UIView transitionWithView:window duration:0.6 options:UIViewAnimationOptionTransitionNone animations:^{
        window.alpha = 1.0;
        window.transform = CGAffineTransformIdentity;
    }               completion:nil];
}

+ (void)close {
    if (showOAuth) {
        showOAuth = NO;
    }
    UIWindow *window = objc_getAssociatedObject([UIApplication sharedApplication], &kOAuthWindow);
    CGRect screenRect = [UIScreen mainScreen].bounds;
    [UIView transitionWithView:window
                      duration:0.6
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        window.transform = CGAffineTransformMakeTranslation(0, screenRect.size.height);
                        window.alpha = 0;
                    }
                    completion:^(BOOL finished) {
                        [window.rootViewController.view removeFromSuperview];
                        window.rootViewController = nil;
                        objc_setAssociatedObject([UIApplication sharedApplication], &kOAuthWindow, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    }];
}
@end