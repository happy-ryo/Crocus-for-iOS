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
#import "CRStatusUpdateViewController.h"
#import "CRStatusService.h"
#import "CRUIImage+rotation.h"
#import "CRStatus.h"
#import "CRUser.h"
#import "CRUserInfoService.h"
#import "CRProfileViewController.h"

static const char kStatusUpdateWindow;

@implementation CRStatusUpdateViewController {
    IBOutlet UITextView *_textView;
    IBOutlet UIView *_textBackGroundView;
    IBOutlet UIImageView *_postImageView;
    IBOutlet UIView *_inputAccessory;
    IBOutlet UIView *_advanceInputAccessory;
    IBOutlet UIBarButtonItem *_statusCountBarButtonItem;
    IBOutlet UIBarButtonItem *_deleteBarButtonItem;
    IBOutlet UIBarButtonItem *_favBarButtonItem;
    IBOutlet UIBarButtonItem *_spreadButtonItem;
    IBOutlet UIBarButtonItem *_toUserNameBarButtonItem;
    CRStatusService *_statusService;
    CRStatus *_status;

    void (^_callBack)(BOOL reload);

    void (^_deleteCallback)(BOOL deleted);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _textView.delegate = self;
    [_textBackGroundView.layer setCornerRadius:5];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak CRStatusUpdateViewController *weakSelf = self;
    if (_status == nil || [UIScreen mainScreen].bounds.size.height < 567) {
        _textView.inputAccessoryView = _inputAccessory;
        _statusService = [[CRStatusService alloc] init];
    } else {
        _textView.inputAccessoryView = _advanceInputAccessory;
        CRUserInfoService *userInfoService = [[CRUserInfoService alloc] init];
        _toUserNameBarButtonItem.title = [NSString stringWithFormat:@"@%@", _status.user.screenName];
        if (![userInfoService checkMineStatus:_status]) {
            _deleteBarButtonItem.enabled = NO;
        }
        if (_status.favorited || [userInfoService checkMineStatus:_status]) {
            _favBarButtonItem.enabled = NO;
        }
        if (_status.spread || [userInfoService checkMineStatus:_status]) {
            _spreadButtonItem.enabled = NO;
        }
        _statusService = [[CRStatusService alloc] initWithStatus:_status callback:^(BOOL requestStatus) {
            if (requestStatus) {
                [weakSelf close];
            }
        }                                         deleteCallback:^(BOOL b) {
            if (b) {
                weakSelf.deleteCallback(b);
                [weakSelf close];
            }
        }];
    }
    [self textCounter:_textView];
    _textView.becomeFirstResponder;
}


- (IBAction)post {
    __weak CRStatusUpdateViewController *weakSelf = self;
    NSString *attach = _status == nil ? @"" : [NSString stringWithFormat:@"@%@ ", _status.user.screenName];

    [_statusService postWithMedia:[NSString stringWithFormat:@"%@%@", attach, _textView.text] image:_postImageView.image callback:^(BOOL status, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                weakSelf.textView.text = @"";
                [weakSelf textCounter:weakSelf.textView];
                weakSelf.postImageView.image = nil;
                weakSelf.postImageView.hidden = YES;
                if (weakSelf.status != nil) {
                    [weakSelf close];
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Crocus"
                                                                    message:@"投稿に失敗しました"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        });
    }];
}

- (IBAction)close {
    _textView.resignFirstResponder;
    [self close:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self textCounter:textView];
}

- (void)textCounter:(UITextView *)textView {
    NSInteger messageLength = textView.text.length;
    NSInteger screenNameLength = _status == nil ? 0 : _status.user.screenName.length;
    if (messageLength != 0) {
        _statusCountBarButtonItem.title = @(372 - messageLength - screenNameLength).stringValue;
    } else {
        _statusCountBarButtonItem.title = @(372 - screenNameLength).stringValue;
    }
}

- (IBAction)delete {
    [_statusService delete];
}

- (IBAction)spread {
    [_statusService spread];
}

- (IBAction)favourite {
    [_statusService favourite];
}

- (IBAction)userInfoOpen {
    _textView.resignFirstResponder;
    __weak CRStatusUpdateViewController *weakSelf = self;

    [CRProfileViewController show:_status.user callback:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.textView.becomeFirstResponder;
        });
    }];
}

- (IBAction)cameraOpen {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setDelegate:self];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        [self libraryOpen];
    }
}

- (IBAction)libraryOpen {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

static BOOL showStatusUpdateFlg;

+ (void)showStatus:(CRStatus *)status callBack:(void (^)(BOOL reload))callBack {
    if (showStatusUpdateFlg) {
        return;
    } else {
        showStatusUpdateFlg = YES;
    }
    CGRect rect = [UIScreen mainScreen].bounds;
    UIWindow *window = [[UIWindow alloc] initWithFrame:rect];
    window.alpha = 0;
    if (rect.size.height > 666) {
        window.rootViewController = [[CRStatusUpdateViewController alloc] initWithNibName:@"StatusUpdateView" bundle:nil];
    } else if (rect.size.height > 567) {
        window.rootViewController = [[CRStatusUpdateViewController alloc] initWithNibName:@"StatusUpdateView5" bundle:nil];
    } else {
        window.rootViewController = [[CRStatusUpdateViewController alloc] initWithNibName:@"StatusUpdateView4s" bundle:nil];
    }
    window.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
    window.transform = CGAffineTransformMakeScale(1.3, 1.3);
    window.transform = CGAffineTransformMakeTranslation(0, 0);
    window.windowLevel = UIWindowLevelNormal + 5;

    [window makeKeyAndVisible];

    CRStatusUpdateViewController *statusUpdateViewController = (CRStatusUpdateViewController *) window.rootViewController;
    statusUpdateViewController.callBack = callBack;
    statusUpdateViewController.status = status;

    objc_setAssociatedObject([UIApplication sharedApplication], &kStatusUpdateWindow, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [UIView transitionWithView:window duration:0.2 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        window.alpha = 1.0;
        window.transform = CGAffineTransformIdentity;
    }               completion:^(BOOL finished) {

    }];
}

+ (void)showStatus:(CRStatus *)status callBack:(void (^)(BOOL reload))callBack deleteCallback:(void (^)(BOOL deleted))deleteCallback {
    if (showStatusUpdateFlg) {
        return;
    } else {
        showStatusUpdateFlg = YES;
    }
    CGRect rect = [UIScreen mainScreen].bounds;
    UIWindow *window = [[UIWindow alloc] initWithFrame:rect];
    window.alpha = 0;
    if (rect.size.height > 666) {
        window.rootViewController = [[CRStatusUpdateViewController alloc] initWithNibName:@"StatusUpdateView" bundle:nil];
    } else if (rect.size.height > 567) {
        window.rootViewController = [[CRStatusUpdateViewController alloc] initWithNibName:@"StatusUpdateView5" bundle:nil];
    } else {
        window.rootViewController = [[CRStatusUpdateViewController alloc] initWithNibName:@"StatusUpdateView4s" bundle:nil];
    }
    window.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
    window.transform = CGAffineTransformMakeScale(1.3, 1.3);
    window.transform = CGAffineTransformMakeTranslation(0, 0);
    window.windowLevel = UIWindowLevelNormal + 5;

    [window makeKeyAndVisible];

    CRStatusUpdateViewController *statusUpdateViewController = (CRStatusUpdateViewController *) window.rootViewController;
    statusUpdateViewController.callBack = callBack;
    statusUpdateViewController.status = status;
    statusUpdateViewController.deleteCallback = deleteCallback;

    objc_setAssociatedObject([UIApplication sharedApplication], &kStatusUpdateWindow, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [UIView transitionWithView:window duration:0.2 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        window.alpha = 1.0;
        window.transform = CGAffineTransformIdentity;
    }               completion:^(BOOL finished) {

    }];
}

- (void)close:(BOOL)reload {
    if (showStatusUpdateFlg) {
        showStatusUpdateFlg = NO;
    }

    UIWindow *window = objc_getAssociatedObject([UIApplication sharedApplication], &kStatusUpdateWindow);
    __weak CRStatusUpdateViewController *weakSelf = self;

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

                        objc_setAssociatedObject([UIApplication sharedApplication], &kStatusUpdateWindow, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

                        UIWindow *nextWindow = [[UIApplication sharedApplication].delegate window];
                        [nextWindow makeKeyAndVisible];
                        [UIView setAnimationsEnabled:YES];
                        if (weakSelf.callBack)weakSelf.callBack(reload);
                    }];

}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    _postImageView.image = [UIImage rotateImage:image];
    _postImageView.hidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end