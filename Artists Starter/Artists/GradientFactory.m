//
//  GradientFactory.m
//  Artists
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "GradientFactory.h"

@implementation GradientFactory

#pragma mark - Singleton Methods

/**
 *	returns a share singleton instance to be used across the entire app
 */
+ (id)sharedInstance
{
	static GradientFactory *sharedInstance;
	static dispatch_once_t once;
	
	dispatch_once(&once,
	^{
		sharedInstance			= [[GradientFactory alloc] init];
	});
	
	return sharedInstance;
}

#pragma mark - Initialisation

/**
 *	creates a new gradient with the given colours and midpoint
 */
- (CGGradientRef)newGradientWithColour1:(UIColor *)	colour1
								colour2:(UIColor *)	colour2
								colour3:(UIColor *)	colour3
							andMidpoint:(CGFloat)	midpoint
{
	NSArray *colours			= [NSArray arrayWithObjects:(id)colour1.CGColor, (id)colour2.CGColor, (id)colour3.CGColor, nil];
	
	const CGFloat locations[3]	= { 0.0f, midpoint, 1.0f};
	
	CGColorSpaceRef colourSpace	= CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient		= CGGradientCreateWithColors(colourSpace, (__bridge CFArrayRef)colours, locations);
	CGColorSpaceRelease(colourSpace);
	
	return gradient;
}

@end
