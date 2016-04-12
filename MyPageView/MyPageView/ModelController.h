//
//  ModelController.h
//  MyPageView
//
//  Created by James Valaitis on 29/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:	(NSUInteger)			index
								   storyboard:	(UIStoryboard *)		storyboard;

- (NSUInteger)			indexOfViewController:	(DataViewController *)	viewController;

@end
