//
//  Note.h
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Note : NSObject <NSCoding>

@property (nonatomic, strong)	NSDate		*createdAt;
@property (nonatomic, strong)	NSDate		*updatedAt;
@property (nonatomic, strong)	NSString	*noteContent;
@property (nonatomic, strong)	NSString	*noteID;

@end
