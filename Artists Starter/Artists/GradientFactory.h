//
//  GradientFactory.h
//  Artists
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GradientFactory : NSObject

+ (id)				sharedInstance;

- (CGGradientRef)	newGradientWithColour1:(UIColor *)	colour1
								   colour2:(UIColor *)	colour2
								   colour3:(UIColor *)	colour3
							   andMidpoint:(CGFloat)	midpoint;

@end
