//
//  DetailController.m
//  Artists
//
//  Created by James Valaitis on 20/11/2012.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AnimatedView.h"
#import "DetailController.h"
#import "GradientFactory.h"

@interface DetailController ()

@end

@implementation DetailController

#pragma mark - Initialisation

/**
 *	deallocates the memory occupied by the receiver
 */
- (void)dealloc
{
	NSLog(@"Deallocating detail controller.");
	[self.animatedView stopAnimation];
}

#pragma mark - View Lifecycle

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];	
	self.navigationBar.topItem.title	= self.artistName;
	
	[self setupAnimatedView];
}

#pragma mark - Action & Selector Methods

- (IBAction)coolAction
{
	UIGraphicsBeginImageContext(self.animatedView.bounds.size);
	[self.animatedView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image						= UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	NSData *data						= UIImagePNGRepresentation(image);
	if (data)
	{
		NSString *filename				= [[self documentsDirectory] stringByAppendingPathComponent:@"Cool.png"];
		
		NSError *error;
		if (![data writeToFile:filename options:NSDataWritingAtomic error:&error])
			NSLog(@"Whilst writing to file: %@ there was an error: %@", filename, error);
	}
	
	[self.delegate detailController:self didPickButtonWithIndex:CoolIndex];
}

- (IBAction)mehAction
{
	[self.delegate detailController:self didPickButtonWithIndex:MehIndex];
}

#pragma mark - Helper Methods

/**
 *	returns the documents directory
 */
- (NSString *)documentsDirectory
{
	NSArray *paths						= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	return paths.lastObject;
}

/**
 *	sets up our animated view
 */
- (void)setupAnimatedView
{
	UIFont *font						= [UIFont boldSystemFontOfSize:24.0f];
	CGSize textSize						= [self.artistName sizeWithFont:font];
	
	float components[9];
	NSUInteger length					= self.artistName.length;
	NSString *lowercase					= self.artistName.lowercaseString;
	
	//	loop through lowercase name of artist, and make each character a value between 0.0f and 1.0f to be used as colours
	for (int i = 0; i < 9; ++i)
	{
		unichar character				= [lowercase characterAtIndex:i % length];
		components[i]					= ((character * (10 - i)) & 0xFF) / 255.0f;
	}
	
	UIColor *colour1					= [UIColor colorWithRed:components[0] green:components[3] blue:components[6] alpha:1.0f];
	UIColor *colour2					= [UIColor colorWithRed:components[1] green:components[4] blue:components[7] alpha:1.0f];
	UIColor *colour3					= [UIColor colorWithRed:components[2] green:components[5] blue:components[8] alpha:1.0f];
	
	__weak DetailController *weakSelf	= self;
	
	self.animatedView.block				= ^(CGContextRef context, CGRect rect, CFTimeInterval totalTime, CFTimeInterval deltaTime)
										{
											DetailController *strongSelf	= weakSelf;
											
											if (strongSelf)
											{
												NSLog(@"Total Timer: %f\nDelta Time: %f", totalTime, deltaTime);
												
												CGPoint startPoint			= CGPointMake(0.0, 0.0);
												CGPoint endPoint			= CGPointMake(0.0, rect.size.height);
												CGFloat midpoint			= 0.5f + (sinf(totalTime)) / 2.0f;
												
												CGGradientRef gradient		= [[GradientFactory sharedInstance]
																			   newGradientWithColour1:colour1
																							  colour2:colour2
																							  colour3:colour3
																						  andMidpoint:midpoint];
												
												CGContextDrawLinearGradient(context, gradient, startPoint, endPoint,
																			kCGGradientDrawsBeforeStartLocation |
																			kCGGradientDrawsAfterEndLocation);
												
												CGGradientRelease(gradient);
												
												CGPoint textPoint			= CGPointMake((rect.size.width - textSize.width) / 2,
																						  (rect.size.height - textSize.height) / 2);
												[strongSelf.artistName drawAtPoint:textPoint withFont:font];
											}
										};
}

@end
