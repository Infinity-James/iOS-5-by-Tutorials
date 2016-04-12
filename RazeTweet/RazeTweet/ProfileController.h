//
//  ProfileController.h
//  RazeTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileController : UIViewController

@property (nonatomic, weak) IBOutlet	UILabel	*descriptionLabel;
@property (nonatomic, weak) IBOutlet	UILabel	*favouritesLabel;
@property (nonatomic, weak) IBOutlet	UILabel	*followersLabel;
@property (nonatomic, weak) IBOutlet	UILabel	*followingLabel;
@property (nonatomic, weak) IBOutlet	UILabel	*tweetsLabel;
@property (nonatomic, weak) IBOutlet	UILabel	*usernameLabel;

@end
