//
//  AnimatedView.h
//  Artists
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AnimatedViewBlock)(CGContextRef context, CGRect rect,
									CFTimeInterval totalTime, CFTimeInterval deltaTime);

@interface AnimatedView : UIView

@property (nonatomic, copy)	AnimatedViewBlock	block;

- (void)	stopAnimation;

@end
