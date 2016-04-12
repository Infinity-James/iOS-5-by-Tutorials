//
//  TweetController.h
//  RazeTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetController : UIViewController

@property (nonatomic, weak) IBOutlet	UILabel		*attachedLabel;
@property (nonatomic, weak) IBOutlet	UITextField	*statusTextField;
@property (nonatomic, weak) IBOutlet	UILabel		*successLabel;

- (IBAction)attachTapped;
- (IBAction)tweetTapped;

@end
