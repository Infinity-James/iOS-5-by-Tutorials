//
//  ViewController.m
//  Draw With Fire
//
//  Created by James Valaitis on 08/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_fireView setEmitterPositionFromTouch:[touches anyObject]];
	[_fireView setIsEmitting:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_fireView setIsEmitting:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_fireView setIsEmitting:NO];
}

- (void)touchesMoved:(NSSet *)touches
		   withEvent:(UIEvent *)event
{
	[_fireView setEmitterPositionFromTouch:[touches anyObject]];
}

@end
