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

@implementation UITableView (UITableViewAddition)

- (void)reloadDataAndWait:(void (^)(void))waitBlock {
    [self reloadData];
    if (waitBlock) {
        waitBlock();
    }
}

@end

@implementation CRTimeLineViewController {
    CRTimeLineService *_timeLineService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak CRTimeLineViewController *weakSelf = self;

    _timeLineService = [[CRTimeLineService alloc] initWithLoaded:^(NSArray *array, BOOL b) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.refreshControl endRefreshing];
            if (b) {
                if (_timeLineService.statusCount == 20) {
//                    NSLog(@"fuga");
                    [weakSelf.tableView reloadData];
                } else {
                    NSMutableArray *indexPaths = @[].mutableCopy;
                    for (NSUInteger i = 0; array.count > i; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    NSArray *visibleRows = weakSelf.tableView.indexPathsForVisibleRows;
                    NSIndexPath *visibleRowIndexPath = visibleRows[visibleRows.count - 2];
                    NSLog(@"%i", visibleRowIndexPath.row);
                    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:visibleRowIndexPath.row + indexPaths.count inSection:0];
                    NSLog(@"%i", scrollIndexPath.row);
                    [weakSelf.tableView reloadDataAndWait:^{
                        if (visibleRowIndexPath.row) {
                            dispatch_after((dispatch_time_t) 0.3, dispatch_get_main_queue(), ^{
                                [weakSelf.tableView scrollToRowAtIndexPath:visibleRowIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];

                            });
                        }
                    }];

                }
            } else {
                [weakSelf.tableView reloadData];
            }
        });
    }];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineBaseCell" bundle:nil] forCellReuseIdentifier:@"baseCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineSpreadCell" bundle:nil] forCellReuseIdentifier:@"spreadCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadingCell" bundle:nil] forCellReuseIdentifier:@"loadingCell"];
    CROAuth *auth = [[CROAuth alloc] init];
    if (auth.authorized) {
        [_timeLineService load];
    } else {
        [auth authorizeWebView:^(BOOL result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_timeLineService load];
            });
        }];
    }

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTimeLine) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTimeLine {
    [_timeLineService update];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_timeLineService.statusCount > 0) {
        return _timeLineService.statusCount + 1;
    } else {
        return _timeLineService.statusCount;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_timeLineService.statusCount == indexPath.row) {
        [_timeLineService performSelector:@selector(historyLoad) withObject:nil afterDelay:0.5];
        CRLoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
        [cell startAnimating];
        return cell;
    }
    CRTimeLineBaseCell *cell;
    CRStatus *status = [_timeLineService status:indexPath.row];
    if (status.spreadStatus != nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"spreadCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"baseCell"];
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

- (void)dealloc {
    [_timeLineService removeObserver:self];
}

@end