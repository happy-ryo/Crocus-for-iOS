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
#import "CRTimeLineViewController.h"
#import "CRTimeLineService.h"
#import "CRTimeLineBaseCell.h"
#import "CRStatus.h"
#import "CRLoadingCell.h"
#import "CROAuth.h"
#import "CRUserInfoService.h"
#import "CRTimeLineController.h"
#import "CRStatusDetailViewController.h"
#import "CRStatusUpdateViewController.h"
#import "CRUser.h"
#import "CRProfileViewController.h"
#import "MBProgressHUD.h"
#import "Parse.h"

@interface CRTimeLineViewController ()
@property(nonatomic, strong) CRUserInfoService *userInfoService;
@property(nonatomic, strong) NSTimer *repeats;
@end

@implementation CRTimeLineViewController {
    CRTimeLineController *_timeLineController;
    BOOL _adBlocking;
    NSInteger _adProbability;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak CRTimeLineViewController *weakSelf = self;
    _adProbability = 95;

    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineBaseCell" bundle:nil] forCellReuseIdentifier:@"baseCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineImageCell" bundle:nil] forCellReuseIdentifier:@"imageCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineReplyBaseCell" bundle:nil] forCellReuseIdentifier:@"replyBaseCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineReplyImageCell" bundle:nil] forCellReuseIdentifier:@"replyImageCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineSpreadCell" bundle:nil] forCellReuseIdentifier:@"spreadCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineImageSpreadCell" bundle:nil] forCellReuseIdentifier:@"spreadImageCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AdsTimeLineBaseCell" bundle:nil] forCellReuseIdentifier:@"adsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"loadingCell"];

    CROAuth *auth = [[CROAuth alloc] init];
    if (auth.authorized) {
        [self createTimeLineService];
        [self.timeLineService load];
        self.repeats = [self refreshTimer:4];
        [self timerFire];
    } else {
        [auth authorizeWebView:^(BOOL result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf createTimeLineService];
                [weakSelf.timeLineService load];
                weakSelf.repeats = [weakSelf refreshTimer:4];
                [weakSelf timerFire];
            });
        }];
    }

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTimeLine) forControlEvents:UIControlEventValueChanged];
    _timeLineController = [CRTimeLineController view];
    [_timeLineController install:self.navigationController.view targetTableView:self.tableView];
    _timeLineController.reload = ^{
        [weakSelf refreshTimeLine];
    };

    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selected:)];
    [self.tableView addGestureRecognizer:longPressGestureRecognizer];

    [self loadNavigationItem];

}

- (void)loadNavigationItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStyleBordered target:self action:@selector(cleanReload)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor lightGrayColor];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStyleBordered target:self action:@selector(openConfig)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
}

- (void)openConfig {
    [self performSegueWithIdentifier:@"config" sender:nil];
}

- (void)cleanReload {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    __weak CRTimeLineViewController *weakSelf = self;
    self.tableView.scrollEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2), dispatch_get_main_queue(), ^{
        [weakSelf.timeLineService reset:weakSelf.tableView];
        weakSelf.tableView.scrollEnabled = YES;
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    });
}

- (void)selected:(UILongPressGestureRecognizer *)selected {
    BOOL timeLineControllerOpen = NO;
    if (_timeLineController.isOpened) {
        timeLineControllerOpen = YES;
        [_timeLineController closeController];
    }
    __weak CRTimeLineViewController *weakSelf = self;

    CGPoint p = [selected locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    CRStatus *targetStatus = [self.timeLineService status:indexPath.row];
    [CRStatusUpdateViewController showStatus:targetStatus callBack:^(BOOL reload) {
        if (reload && timeLineControllerOpen) {
            [weakSelf.timeLineController openController];
        }
    }                         deleteCallback:^(BOOL deleted) {
        if (deleted) {
            [weakSelf.timeLineService removeStatus:targetStatus];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (void)timerFire {
    __weak CRTimeLineViewController *weakSelf = self;
    if (!weakSelf.repeats.isValid) {
        [self.repeats fire];
    }
}

- (NSTimer *)refreshTimer:(NSUInteger)timer {
    if (timer > 60) {
        timer = 60;
    }
    __weak CRTimeLineViewController *weakSelf = self;
    if (weakSelf.repeats.isValid) {
        [weakSelf.repeats invalidate];
    }
    return [NSTimer scheduledTimerWithTimeInterval:timer
                                            target:weakSelf
                                          selector:@selector(refreshTimeLine)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak CRTimeLineViewController *weakSelf = self;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    PFQuery *query = [PFQuery queryWithClassName:@"Advertising"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            weakSelf.adProbability = [object[@"probability"] integerValue];
        }
    }];

    [self startTimer];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.userInfoService = [[CRUserInfoService alloc] init];
    [self.userInfoService loadUserInfo];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopTimer];
}

- (void)createTimeLineService {
    __weak CRTimeLineViewController *weakSelf = self;

    self.timeLineService = [[CRTimeLineService alloc] initWithLoaded:^(NSArray *array, BOOL b) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadSection:array history:b];
        });
    }];
}

- (void)reloadSection:(NSArray *)array history:(BOOL)flag {
    __weak CRTimeLineViewController *weakSelf = self;

    [weakSelf.refreshControl endRefreshing];
    if (array.count == 0) {
        weakSelf.repeats = [weakSelf refreshTimer:(NSUInteger) (weakSelf.repeats.timeInterval + 1)];
        return;
    } else if (flag) {
        if (weakSelf.timeLineService.statusCount == 20) {
            [weakSelf.tableView reloadData];
        } else {
            NSMutableArray *indexPaths = @[].mutableCopy;
            for (NSUInteger i = (weakSelf.timeLineService.statusCount - array.count); weakSelf.timeLineService.statusCount > i; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            if (_timeLineService.statusCount < 20) {
                [weakSelf.tableView reloadData];
            } else {
                [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
            }
        }
    } else {
        if (array.count == 20) {
            [weakSelf.tableView reloadData];
        } else {
            if (weakSelf.repeats.timeInterval > 4) {
                weakSelf.repeats = [weakSelf refreshTimer:4];
            }
            NSMutableArray *indexPaths = @[].mutableCopy;
            for (NSUInteger i = 0; array.count > i; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [UIView setAnimationsEnabled:NO];
            [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            NSIndexPath *indexPath = weakSelf.tableView.indexPathsForVisibleRows[0];
            if (indexPath.row < array.count + 3) {
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPaths.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                [UIView setAnimationsEnabled:YES];
                dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (NSEC_PER_SEC * 1.7));
                dispatch_after(start, dispatch_get_main_queue(), ^{
                    [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
                });
            } else {
                [UIView setAnimationsEnabled:YES];
            }
        }
    }
}

- (void)refreshTimeLine {
    NSIndexPath *indexPath;
    if (self.tableView.indexPathsForVisibleRows.count == 0) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else {
        indexPath = self.tableView.indexPathsForVisibleRows[0];
    }
    if (indexPath.row == 0) {
        [self.timeLineService update];
    } else {
        [self.refreshControl endRefreshing];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.timeLineService.statusCount >= 20) {
        return self.timeLineService.statusCount + 1;
    } else {
        return self.timeLineService.statusCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.timeLineService.statusCount == indexPath.row + 8) {
//        [self.timeLineService performSelector:@selector(historyLoad) withObject:nil afterDelay:0.1];
        [self.timeLineService historyLoad];
    }
    if (self.timeLineService.statusCount == indexPath.row) {
        CRLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
        [cell startAnimating];
        return cell;
    }
    CRTimeLineBaseCell *cell;
    CRStatus *status = [self.timeLineService status:indexPath.row];
    if (status.isSpreadStatus) {
        if (status.isExistImageSpread) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"spreadImageCell"];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"spreadCell"];
        }
    } else if ([self.userInfoService replyCheck:status]) {
        if (status.isExistImage) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"replyImageCell"];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"replyBaseCell"];
        }
    } else {
        if (status.isExistImage) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
        } else {
            int rand = arc4random() % 100 + 1;
            if (rand > _adProbability && !_adBlocking) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"adsCell"];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"baseCell"];
            }
        }
    }
    [cell loadCRStatus:status];
    [cell.iconButton addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CRStatus *status = [_timeLineService status:indexPath.row];
    [CRStatusDetailViewController show:status];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"newerStatuses"]) {
        [self.refreshControl endRefreshing];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight;
    if (indexPath.row == self.timeLineService.statusCount) {
        return 60.f;
    }
    CRStatus *status = [self.timeLineService status:indexPath.row];
    if (status.isSpreadStatus) {
        if (status.isExistImageSpread) {
            cellHeight = 230;
        } else {
            cellHeight = 140;
        }
    } else {
        if (status.isExistImage) {
            cellHeight = 180;
        } else {
            cellHeight = 60;
        }
    }
    return cellHeight;
}


- (void)dealloc {
    [self.timeLineService removeObserver:self];
}

- (void)handleTouchImage:(UIImageView *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    CRStatus *status = [_timeLineService status:indexPath.row];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    CRStatus *status = [_timeLineService status:indexPath.row];
    [CRProfileViewController show:status.user];
}

- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    return indexPath;
}

- (void)startTimer {
    CROAuth *auth = [[CROAuth alloc] init];
    if (auth.authorized) {
        self.repeats = [self refreshTimer:4];
        [self timerFire];
    }
}

- (void)stopTimer {
    [self.repeats invalidate];
    self.repeats = nil;
}
@end