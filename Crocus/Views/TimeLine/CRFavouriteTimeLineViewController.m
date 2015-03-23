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
#import "CRFavouriteTimeLineViewController.h"
#import "CRHomeTimeLineService.h"
#import "CRFavoriteTimeLineService.h"


@implementation CRFavouriteTimeLineViewController {

}

- (void)createTimeLineService {
    __weak CRTimeLineViewController *weakSelf = self;

    self.timeLineService = [[CRFavoriteTimeLineService alloc] initWithLoaded:^(NSArray *array, BOOL b) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadSection:array history:b];
        });
    }];
}

- (void)loadNavigationItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStyleBordered target:self action:@selector(cleanReload)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor lightGrayColor];
}
@end