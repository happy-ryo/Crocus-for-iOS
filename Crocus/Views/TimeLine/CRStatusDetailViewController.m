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
#import <SDWebImage/UIImageView+WebCache.h>
#import <objc/runtime.h>
#import "CRStatusDetailViewController.h"
#import "CRStatus.h"
#import "CRStatusService.h"
#import "CRUser.h"
#import "CRSource.h"
#import "CREntities.h"
#import "CRUserInfoService.h"

static const char kStatusDetailWindow;

@implementation CRStatusDetailViewController {
    IBOutlet UIImageView *_iconImageView;
    IBOutlet UIImageView *_spreadIconImageView;
    IBOutlet UILabel *_userNameLabel;
    IBOutlet UILabel *_userScreenNameLabel;
    IBOutlet UILabel *_postDateLabel;
    IBOutlet UILabel *_viaLabel;
    IBOutlet UITextView *_textView;
    IBOutlet UIImageView *_mediaImageView;
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIView *_backgroundView;
    IBOutlet UIBarButtonItem *_deleteButton;

    CRStatus *_status;
    CRStatusService *_statusService;
    UIImageView *_expandImageView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak CRStatusDetailViewController *weakSelf = self;

    _statusService = [[CRStatusService alloc] initWithStatus:_status callback:^(BOOL status) {
        NSString *message = @"";
        if (status) {
            message = @"Success";
        } else {
            message = @"Fail";
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAlert:message];
        });
    }];

    CRStatus *loadStatus = self.loadStatus;
    CRUserInfoService *userInfoService = [[CRUserInfoService alloc] init];
    if (!userInfoService.isExistUserInfo || ![userInfoService checkMineStatus:_status]) {
        _deleteButton.title = @"";
        _deleteButton.enabled = NO;
    }
    [_iconImageView sd_setImageWithURL:[[NSURL alloc] initWithString:loadStatus.user.profileImageUrlHttps] placeholderImage:nil];
    _userNameLabel.text = loadStatus.user.name;
    _userScreenNameLabel.text = [NSString stringWithFormat:@"@%@", loadStatus.user.screenName];
    _postDateLabel.text = loadStatus.createdAt;
    _viaLabel.text = [NSString stringWithFormat:@"via %@", loadStatus.source.name];
    _textView.text = loadStatus.text;
    if (loadStatus.isExistImage) {
        [_mediaImageView sd_setImageWithURL:[[NSURL alloc] initWithString:loadStatus.entities.mediaURL]];
        [_mediaImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandImage)]];
    }
    [_backgroundView.layer setCornerRadius:5];
}

- (void)expandImage {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 4.0;
    scrollView.backgroundColor = [UIColor darkGrayColor];

    CRStatus *loadStatus = self.loadStatus;
    _expandImageView = [[UIImageView alloc] initWithFrame:scrollView.frame];
    [_expandImageView sd_setImageWithURL:[[NSURL alloc] initWithString:loadStatus.entities.mediaURL]];
    _expandImageView.userInteractionEnabled = YES;
    _expandImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_expandImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:scrollView action:@selector(removeFromSuperview)]];
    [scrollView addSubview:_expandImageView];
    [self.view addSubview:scrollView];
}

- (CRStatus *)loadStatus {
    CRStatus *loadStatus;
    if (_status.isSpreadStatus) {
        loadStatus = _status.spreadStatus;
        [_spreadIconImageView sd_setImageWithURL:[[NSURL alloc] initWithString:_status.user.profileImageUrlHttps]];
    } else {
        loadStatus = _status;
    }
    return loadStatus;
}

- (void)showAlert:(NSString *)message {
    __weak CRStatusDetailViewController *weakSelf = self;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (NSEC_PER_SEC * 0.5)), dispatch_get_main_queue(), ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

- (IBAction)reply {
    [_statusService reply];
}

- (IBAction)spread {
    [_statusService spread];
}

- (IBAction)favourite {
    [_statusService favourite];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _expandImageView;
}

+ (void)show:(CRStatus *)status {
    CGRect rect = [UIScreen mainScreen].bounds;
    UIWindow *window = [[UIWindow alloc] initWithFrame:rect];
    window.alpha = 0.3;
    window.rootViewController = [[CRStatusDetailViewController alloc] initWithNibName:@"StatusDetailView" bundle:nil];
    window.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
    [window makeKeyAndVisible];
    window.transform = CGAffineTransformMakeScale(1.3, 1.3);
    window.transform = CGAffineTransformMakeTranslation(0, 0);
    window.windowLevel = UIWindowLevelNormal + 5;


    CRStatusDetailViewController *statusUpdateViewController = (CRStatusDetailViewController *) window.rootViewController;
    statusUpdateViewController.status = status;

    objc_setAssociatedObject([UIApplication sharedApplication], &kStatusDetailWindow, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [UIView transitionWithView:window duration:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        window.alpha = 1.0;
        window.transform = CGAffineTransformIdentity;
    }               completion:^(BOOL finished) {

    }];
}

- (IBAction)close {
    UIWindow *window = objc_getAssociatedObject([UIApplication sharedApplication], &kStatusDetailWindow);
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

                        objc_setAssociatedObject([UIApplication sharedApplication], &kStatusDetailWindow, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

                        UIWindow *nextWindow = [[UIApplication sharedApplication].delegate window];
                        [nextWindow makeKeyAndVisible];
                        [UIView setAnimationsEnabled:YES];
                    }];

}

@end