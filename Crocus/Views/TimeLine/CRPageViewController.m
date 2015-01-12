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
#import "CRPageViewController.h"


@implementation CRPageViewController {
    UIPageViewController *_pageViewController;
    NSArray *_pageViews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    _pageViews = @[
            [self.storyboard instantiateViewControllerWithIdentifier:@"home"],
            [self.storyboard instantiateViewControllerWithIdentifier:@"ptl"],
            [self.storyboard instantiateViewControllerWithIdentifier:@"mention"]
    ];
    [self.pageViewController setViewControllers:@[_pageViews[1]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:^(BOOL finished) {

                                     }];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [_pageViews indexOfObject:viewController];
    if (index == 1) {
        return _pageViews[0];
    } else if (index == 0) {
        return _pageViews[2];
    } else {
        return _pageViews[1];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [_pageViews indexOfObject:viewController];
    if (index == 1) {
        return _pageViews[2];
    } else if (index == 0) {
        return _pageViews[1];
    } else {
        return _pageViews[0];
    }
}


@end