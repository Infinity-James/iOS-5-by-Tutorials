//
//  AppDelegate.h
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoteController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic)	UIWindow				*window;
@property (strong, nonatomic)	UINavigationController	*detailNavController;
@property (strong, nonatomic)	NoteController			*noteController;

@end
