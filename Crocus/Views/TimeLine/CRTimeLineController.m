/*
 * Copyright (C) 2015 happy_ryo
 *      https://twitter.com/happy_ryo
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "CRTimeLineController.h"

@implementation UITableView (ScrollableToBottom)

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger sectionCount;
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sectionCount = [self.dataSource numberOfSectionsInTableView:self];
        if (sectionCount == 0) {
            return;
        }
    } else {
        sectionCount = 1;
    }

    NSInteger rowCount = [self.dataSource tableView:self numberOfRowsInSection:(sectionCount - 1)];
    if (rowCount == 0) {
        return;
    }

    NSIndexPath *lastRowPath = [NSIndexPath indexPathForRow:rowCount - 1
                                                  inSection:sectionCount - 1];

    [self scrollToRowAtIndexPath:lastRowPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

@end

@implementation CRTimeLineController {
    IBOutlet UIView *_baseView;
    IBOutlet UIButton *_controllerButton;
    IBOutlet UIButton *_postButton;
    IBOutlet UIButton *_rewindButton;
    IBOutlet UIButton *_fastForwardButton;
    UITableView *_tableView;
    BOOL _isOpened;
}


- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];

    if (self) {
        _tableView = tableView;
    }

    return self;
}

+ (instancetype)controllerWithTableView:(UITableView *)tableView {
    return [[self alloc] initWithTableView:tableView];
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

+ (instancetype)view {
    return [[[NSBundle mainBundle] loadNibNamed:@"TimeLineController" owner:nil options:0] firstObject];
}

- (IBAction)modeChange {
    if (_isOpened) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                _baseView.frame = CGRectMake(_baseView.frame.origin.x, _baseView.frame.origin.y + 200, 60, 60);
                CGRect baseRect = CGRectMake(0, 0, 60, 60);
                _controllerButton.frame = baseRect;
                _postButton.frame = baseRect;
                _fastForwardButton.frame = baseRect;
                _rewindButton.frame = baseRect;
//                _postButton.transform = CGAffineTransformIdentity;
//                _rewindButton.transform = CGAffineTransformIdentity;
//                _fastForwardButton.transform = CGAffineTransformIdentity;
            }                completion:^(BOOL finished) {
                if (finished) {
                    _isOpened = NO;
                }
            }];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat baseHeight = -50;
            [UIView animateWithDuration:0.5 animations:^{
                _baseView.frame = CGRectMake(_baseView.frame.origin.x, _baseView.frame.origin.y - 200, 60, 260);
                _controllerButton.frame = CGRectMake(0, 265-60, 60, 60);
                _postButton.frame = CGRectMake(0, 265 - 125, 60, 60);
                _rewindButton.frame = CGRectMake(0, 265 - 190, 60, 60);
                _fastForwardButton.frame = CGRectMake(0, 265 - 255, 60, 60);
//                _postButton.transform = CGAffineTransformMakeTranslation(0, baseHeight * 3);
//                _rewindButton.transform = CGAffineTransformMakeTranslation(0, baseHeight * 2);
//                _fastForwardButton.transform = CGAffineTransformMakeTranslation(0, baseHeight);
            }                completion:^(BOOL finished) {
                if (finished) {
                    _isOpened = YES;
                }
            }];
        });
    }
}

- (IBAction)statusUpdate {

}

- (IBAction)fastForward {
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)rewind {
    [_tableView scrollToBottomAnimated:YES];
}
@end