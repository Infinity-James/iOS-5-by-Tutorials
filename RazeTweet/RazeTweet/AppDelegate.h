//
//  AppDelegate.h
//  RazeTweet
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong)	ACAccount			*userAccount;
@property (nonatomic, strong)	ACAccountStore		*accountStore;
@property (nonatomic, strong)	NSMutableDictionary	*profileImages;
@property (nonatomic, strong)	UIWindow			*window;

@end
