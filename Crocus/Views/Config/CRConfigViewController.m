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
#import "CRConfigViewController.h"
#import "Parse.h"
#import "CRUserInfoService.h"
#import "MBProgressHUD.h"
#import "CRUser.h"

@implementation CRConfigViewController {
    IBOutlet UISwitch *_protectSwitch;
    IBOutlet UITextField *_timerSecTextField;
    CRUserInfoService *_userInfoService;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Config";
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor lightGrayColor];

    [_protectSwitch removeTarget:self action:@selector(protect:) forControlEvents:UIControlEventValueChanged];

    _userInfoService = [[CRUserInfoService alloc] init];
    [_userInfoService loadUserInfo];
    if (_userInfoService.isExistUserInfo) {
        CRUser *crUser = _userInfoService.getUser;
        _protectSwitch.on = crUser.userProtected;
        if (crUser.timerSec != nil) {
            _timerSecTextField.text = crUser.timerSec;
        }
    }

    [_protectSwitch addTarget:self action:@selector(protect:) forControlEvents:UIControlEventValueChanged];
    _timerSecTextField.delegate = self;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [PFPurchase buyProduct:@"info.happyryo.crocus.adblocking" block:^(NSError *error) {
            if (!error) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:YES forKey:@"adblocking"];
                [userDefaults synchronize];
            }
        }];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self checkDelete];
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        [self checkAllDelete];
    }
}

- (void)checkAllDelete {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Crocus" message:@"すべてのささやきを出来る限り消しますか？" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }]];

    __weak CRConfigViewController *weakSelf = self;

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Crocus" message:@"まじで？" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"やめとくわ" style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"過去と決別する" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                CRUserInfoService *userInfoService = [[CRUserInfoService alloc] init];
                [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                [userInfoService deleteAllStatuses:^(NSUInteger count) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                        UIAlertController *uiAlertController = [UIAlertController alertControllerWithTitle:@"Crocus" message:@"出来るだけ消しました。" preferredStyle:UIAlertControllerStyleAlert];
                        [uiAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        }]];
                        [weakSelf presentViewController:uiAlertController animated:YES completion:nil];
                    });
                }];
            }]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        });
    }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)checkDelete {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Crocus" message:@"本日中のささやきを出来る限り消しますか？" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }]];

    __weak CRConfigViewController *weakSelf = self;

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        CRUserInfoService *userInfoService = [[CRUserInfoService alloc] init];
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        [userInfoService deleteTodayStatuses:^(NSUInteger count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                UIAlertController *uiAlertController = [UIAlertController alertControllerWithTitle:@"Crocus" message:@"出来るだけ消しました。" preferredStyle:UIAlertControllerStyleAlert];
                [uiAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }]];
                [weakSelf presentViewController:uiAlertController animated:YES completion:nil];
            });
        }];
    }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"adblocking"]) {
        count = 1;
    } else {
        count = 2;
    }
    return count;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    textField.resignFirstResponder;
    return YES;
}


- (IBAction)protect:(UISwitch *)sender {
    [_userInfoService protect:sender.isOn updateFinish:^(BOOL result) {
        if (result == NO) {
            sender.on = !sender.on;
        }
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [_userInfoService timer:textField.text updateFinish:^(BOOL result) {
        if (result == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Crocus" message:@"入力した値、ネットワークの接続状況を確認して下さい" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            });
        }
    }];
}

@end