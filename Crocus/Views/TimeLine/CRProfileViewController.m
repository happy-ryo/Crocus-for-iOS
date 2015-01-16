//  Copyright 2015 happy_ryo
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
#import <objc/runtime.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "CRProfileViewController.h"
#import "CRUser.h"

static const char kProfileWindow;

@implementation CRProfileViewController {
    CRUser *_user;
    IBOutlet UIImageView *_coverImageView;
    IBOutlet UIImageView *_iconImageView;
    IBOutlet UILabel *_userNameLabel;
    IBOutlet UILabel *_screenNameLabel;
    IBOutlet UITextView *_profileTextView;
    IBOutlet UIView *_backgroundView;

    void (^_callback)();
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_backgroundView.layer setCornerRadius:5];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_coverImageView sd_setImageWithURL:[[NSURL alloc] initWithString:_user.coverImageUrlHttps] placeholderImage:nil];
    [_iconImageView sd_setImageWithURL:[[NSURL alloc] initWithString:_user.profileImageUrlHttps] placeholderImage:nil];
    _userNameLabel.text = _user.name;
    _screenNameLabel.text = [NSString stringWithFormat:@"@%@", _user.screenName];
    _profileTextView.text = _user.userDescription;
}


+ (void)show:(CRUser *)user {
    [CRProfileViewController show:user callback:nil];
}

+ (void)show:(CRUser *)user callback:(void (^)())callback {
    CGRect rect = [UIScreen mainScreen].bounds;
    UIWindow *window = [[UIWindow alloc] initWithFrame:rect];
    window.alpha = 0.3;
    window.rootViewController = [[CRProfileViewController alloc] initWithNibName:@"ProfileView" bundle:nil];
    window.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
    window.transform = CGAffineTransformMakeScale(1.3, 1.3);
    window.transform = CGAffineTransformMakeTranslation(0, 0);
    window.windowLevel = UIWindowLevelNormal + 5;

    [window makeKeyAndVisible];

    CRProfileViewController *profileViewController = (CRProfileViewController *) window.rootViewController;
    profileViewController.user = user;
    profileViewController.callback = callback;

    objc_setAssociatedObject([UIApplication sharedApplication], &kProfileWindow, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [UIView transitionWithView:window duration:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        window.alpha = 1.0;
        window.transform = CGAffineTransformIdentity;
    }               completion:^(BOOL finished) {

    }];
}

- (IBAction)close {
    __weak CRProfileViewController *weakSelf = self;

    UIWindow *window = objc_getAssociatedObject([UIApplication sharedApplication], &kProfileWindow);
    [UIView transitionWithView:window
                      duration:.2
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        window.transform = CGAffineTransformMakeScale(1.3, 1.3);
                        window.alpha = 0;
                    }
                    completion:^(BOOL finished) {

                        [window.rootViewController.view removeFromSuperview];
                        window.rootViewController = nil;

                        objc_setAssociatedObject([UIApplication sharedApplication], &kProfileWindow, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

                        UIWindow *nextWindow = [[UIApplication sharedApplication].delegate window];
                        [nextWindow makeKeyAndVisible];
                        [UIView setAnimationsEnabled:YES];
                        if (weakSelf.callback) {
                            weakSelf.callback();
                        }
                    }];

}
@end