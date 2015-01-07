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

@interface CRTimeLineViewController ()
@property(nonatomic, strong) CRTimeLineService *timeLineService;
@end

@implementation CRTimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak CRTimeLineViewController *weakSelf = self;

    self.timeLineService = [[CRTimeLineService alloc] initWithLoaded:^(NSArray *array, BOOL b) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.refreshControl endRefreshing];
            if (b) {
                if (weakSelf.timeLineService.statusCount == 20) {
                    [weakSelf.tableView reloadData];
                } else {
                    NSMutableArray *indexPaths = @[].mutableCopy;
                    for (NSUInteger i = (weakSelf.timeLineService.statusCount - array.count); weakSelf.timeLineService.statusCount > i; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                }
            } else {
                if (array.count == 20) {
                    [weakSelf.tableView reloadData];
                } else {
                    NSMutableArray *indexPaths = @[].mutableCopy;
                    for (NSUInteger i = 0; array.count > i; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    [UIView setAnimationsEnabled:NO];
                    [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPaths.count inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    [UIView setAnimationsEnabled:YES];
                    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (NSEC_PER_SEC*1.5));
                    dispatch_after(start, dispatch_get_main_queue(), ^{
                        [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
                    });
                }
            }
        });
    }];

    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineBaseCell" bundle:nil] forCellReuseIdentifier:@"baseCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineImageCell" bundle:nil] forCellReuseIdentifier:@"imageCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineSpreadCell" bundle:nil] forCellReuseIdentifier:@"spreadCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineImageSpreadCell" bundle:nil] forCellReuseIdentifier:@"spreadImageCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"loadingCell"];

    CROAuth *auth = [[CROAuth alloc] init];
    if (auth.authorized) {
        [self.timeLineService load];
    } else {
        [auth authorizeWebView:^(BOOL result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.timeLineService load];
            });
        }];
    }

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTimeLine) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTimeLine {
    [self.timeLineService update];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.timeLineService.statusCount > 0) {
        return self.timeLineService.statusCount + 1;
    } else {
        return self.timeLineService.statusCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.timeLineService.statusCount == indexPath.row) {
        [self.timeLineService performSelector:@selector(historyLoad) withObject:nil afterDelay:0.5];
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
    } else {
        if (status.isExistImage) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"baseCell"];
        }
    }
    [cell loadCRStatus:status];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

@end