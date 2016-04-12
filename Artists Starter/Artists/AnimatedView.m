//
//  AnimatedView.m
//  Artists
//
//  Created by James Valaitis on 21/11/2012.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "AnimatedView.h"

@implementation AnimatedView
{
	NSTimer						*_timer;
	CFTimeInterval				_startTime;
	CFTimeInterval				_lastTime;
}

#pragma mark - Initialisation

/**
 *	deallocates the memory occupied by the receiver
 */
- (void)dealloc
{
	NSLog(@"Deallocating animated view.");
}

/**
 *	allows the decoding of object when initialising
 *
 *	@param	aDecoder			the object used to decode our properties
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		_timer					= [NSTimer scheduledTimerWithTimeInterval:0.1
															   target:self
															 selector:@selector(handleTimer:)
															 userInfo:nil
															  repeats:YES];
		
		_startTime				= _lastTime	= CACurrentMediaTime();
	}
	
	return self;
}

#pragma mark - Action & Selector Methods

/**
 *	we want to draw ourselves every time the timer is fired
 */
- (void)handleTimer:(NSTimer *)timer
{
	[self setNeedsDisplay];
}

#pragma mark - Helper Methods

/**
 *	called to clear memory
 */
- (void)stopAnimation
{
	//	rid this view of the timer as it holds a strong pointer to us
	[_timer invalidate], _timer	= nil;
}

#pragma mark - UIView Methods

/**
 *	draws the receiver’s image within the passed-in rectangle
 *
 *	@param	rect				portion of the view’s bounds that needs to be updated
 */
- (void)drawRect:(CGRect)rect
{
	CFTimeInterval now			= CACurrentMediaTime();
	CFTimeInterval totalTime	= now - _startTime;
	CFTimeInterval deltaTime	= now - _lastTime;
	_lastTime					= now;
	
	if (self.block)
		self.block(UIGraphicsGetCurrentContext(), rect, totalTime, deltaTime);
}

@end
