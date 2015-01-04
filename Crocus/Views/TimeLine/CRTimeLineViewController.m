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


@implementation CRTimeLineViewController {
    CRTimeLineService *_timeLineService;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _timeLineService = [[CRTimeLineService alloc] initWithObserver:self];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineBaseCell" bundle:nil] forCellReuseIdentifier:@"baseCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TimeLineSpreadCell" bundle:nil] forCellReuseIdentifier:@"spreadCell"];
    [_timeLineService load];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTimeLine) forControlEvents:UIControlEventValueChanged];
}

- (void)refreshTimeLine {
    [_timeLineService update];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _timeLineService.statusCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CRStatus *status = [_timeLineService status:indexPath.row];
    CRTimeLineBaseCell *cell;
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
        [self.tableView reloadData];
    }
}

@end