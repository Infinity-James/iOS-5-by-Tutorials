//
//  RootController.h
//  PhotoAlbum
//
//  Created by James Valaitis on 30/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

// ----------------------------------------------------------------------------------------------------------------
//											Root Controller Public Interface
// ----------------------------------------------------------------------------------------------------------------

@interface RootController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong)	UIPageViewController	*pageViewController;
@property (nonatomic, strong)	NSArray					*picturesArray;

@end
