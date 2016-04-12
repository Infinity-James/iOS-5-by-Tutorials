//
//  Player.h
//  Ratings
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (nonatomic, copy)		NSString	*name;
@property (nonatomic, copy)		NSString	*game;
@property (nonatomic, assign)	int			rating;

@end
