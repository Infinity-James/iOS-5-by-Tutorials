//
//  CustomSegue.m
//  Ratings
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CustomSegue.h"

@implementation CustomSegue

#pragma mark - UIStoryBoardSegue Methods

/**
 *	performs visual transition for segue
 */
- (void)perform
{
	UIViewController *source			= self.sourceViewController;
	UIViewController *destination		= self.destinationViewController;
	
	//	create uiimage with contents of destimation
	UIGraphicsBeginImageContext(destination.view.bounds.size);
	[destination.view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *destinationImage			= UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//	add image as subview of tab bar controller
	UIImageView *destinationImageView	= [[UIImageView alloc] initWithImage:destinationImage];
	[source.parentViewController.view addSubview:destinationImageView];
	
	//	scale image down and rotate 180 degrees so it is upside down
	CGAffineTransform scaleTransform	= CGAffineTransformMakeScale(0.1, 0.1);
	CGAffineTransform rotateTransform	= CGAffineTransformMakeRotation(M_PI);
	destinationImageView.transform		= CGAffineTransformConcat(scaleTransform, rotateTransform);
	
	//	move image outside visible area
	CGPoint oldCentre					= destinationImageView.center;
	CGPoint newCentre					= CGPointMake(oldCentre.x = destinationImageView.bounds.size.width, oldCentre.y);
	destinationImageView.center			= newCentre;
	
	//	start animation
	[UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationTransitionFlipFromRight animations:
	^{
		destinationImageView.transform	= CGAffineTransformIdentity;
		destinationImageView.center		= oldCentre;
	}
	completion:^(BOOL finished)
	{
		//	properly present new screen
		[source presentViewController:destination animated:NO completion:
		^{
			//	remove image as we no longer need it
			[destinationImageView removeFromSuperview];
		}];
	}];
}

@end
