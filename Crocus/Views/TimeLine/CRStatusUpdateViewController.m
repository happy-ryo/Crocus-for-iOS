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

static const char kStatusUpdateWindow;

@implementation CRStatusUpdateViewController {
    IBOutlet UITextView *_textView;
    IBOutlet UIView *_textBackGroundView;
    IBOutlet UIImageView *_postImageView;
    IBOutlet UIView *_inputAccessory;
    IBOutlet UIBarButtonItem *_statusCountBarButtonItem;
    CRStatusService *_statusService;

    void (^_callBack)(BOOL reload);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _textView.inputAccessoryView = _inputAccessory;
    _textView.delegate = self;
    _statusService = [[CRStatusService alloc] init];
    [_textBackGroundView.layer setCornerRadius:5];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    _textView.becomeFirstResponder;
}

- (IBAction)post {
    __weak CRStatusUpdateViewController *weakSelf = self;

    [_statusService post:_textView.text callback:^(BOOL status, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                weakSelf.textView.text = @"";
                weakSelf.statusCountBarButtonItem.title = @"372";
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
    NSInteger messageLength = textView.text.length;
    if (messageLength != 0) {
        _statusCountBarButtonItem.title = @(372 - messageLength).stringValue;
    } else {
        _statusCountBarButtonItem.title = @"372";
    }
}

+ (void)show:(void (^)(BOOL reload))callBack {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.alpha = 0;
    window.rootViewController = [[CRStatusUpdateViewController alloc] initWithNibName:@"StatusUpdateView" bundle:nil];
    window.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
    window.transform = CGAffineTransformMakeScale(1.3, 1.3);
    window.transform = CGAffineTransformMakeTranslation(0, 0);
    window.windowLevel = UIWindowLevelNormal + 5;

    [window makeKeyAndVisible];

    CRStatusUpdateViewController *statusUpdateViewController = (CRStatusUpdateViewController *) window.rootViewController;
    statusUpdateViewController.callBack = callBack;

    objc_setAssociatedObject([UIApplication sharedApplication], &kStatusUpdateWindow, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [UIView transitionWithView:window duration:0.2 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        window.alpha = 1.0;
        window.transform = CGAffineTransformIdentity;
    }               completion:^(BOOL finished) {

    }];
}

- (void)close:(BOOL)reload {
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
                        weakSelf.callBack(reload);
                    }];

}


static BOOL needRevert;

- (void)keyboardWillShow:(NSNotification *)notification {
    needRevert = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (needRevert) [UIView setAnimationsEnabled:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    needRevert = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (needRevert) [UIView setAnimationsEnabled:YES];
}

@end