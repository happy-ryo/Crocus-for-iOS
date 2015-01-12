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
#import "UIImage+rotation.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _textView.becomeFirstResponder;
}

- (IBAction)post {
    __weak CRStatusUpdateViewController *weakSelf = self;

    [_statusService postWithMedia:_textView.text image:_postImageView.image callback:^(BOOL status, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                weakSelf.textView.text = @"";
                weakSelf.statusCountBarButtonItem.title = @"372";
                weakSelf.postImageView.image = nil;
                weakSelf.postImageView.hidden = YES;
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

+ (void)show:(void (^)(BOOL reload))callBack {
    CGRect rect = [UIScreen mainScreen].bounds;
    UIWindow *window = [[UIWindow alloc] initWithFrame:rect];
    window.alpha = 0;
    if (rect.size.height > 568) {
        window.rootViewController = [[CRStatusUpdateViewController alloc] initWithNibName:@"StatusUpdateView" bundle:nil];
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
                        [UIView setAnimationsEnabled:YES];
                        weakSelf.callBack(reload);
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