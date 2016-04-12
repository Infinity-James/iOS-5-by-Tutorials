//
//  DetailController.h
//  Artists
//
//  Created by James Valaitis on 20/11/2012.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CoolIndex		0
#define MehIndex		1

@class DetailController;

@protocol DetailControllerDelegate <NSObject>

- (void)detailController:(DetailController *)controller
  didPickButtonWithIndex:(NSInteger)buttonIndex;

@end

@class AnimatedView;

@interface DetailController : UIViewController

@property (nonatomic, weak) IBOutlet	AnimatedView					*animatedView;
@property (nonatomic, copy)				NSString						*artistName;
@property (nonatomic, weak)				id	<DetailControllerDelegate>	delegate;
@property (nonatomic, weak) IBOutlet	UINavigationBar					*navigationBar;

- (IBAction)coolAction;
- (IBAction)mehAction;

@end
