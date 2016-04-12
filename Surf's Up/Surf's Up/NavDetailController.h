//
//  NavDetailController.h
//  Surf's Up
//
//  Created by James Valaitis on 25/10/2012.
//  Copyright (c) 2012 komorka technology, llc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface NavDetailController : UINavigationController <UISplitViewControllerDelegate>

@property (nonatomic, strong)	DetailViewController	*detailController;

@end
