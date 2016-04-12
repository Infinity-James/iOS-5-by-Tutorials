//
//  ViewController.h
//  Game Center Demo
//
//  Created by James Valaitis on 09/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainController : UIViewController
{
	IBOutlet UIImageView	*_photoView;
	IBOutlet UILabel		*_nameLabel;
}

- (IBAction)doAnAchievement;

@end
