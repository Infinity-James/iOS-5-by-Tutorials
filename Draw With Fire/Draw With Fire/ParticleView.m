//
//  ParticleView.m
//  Draw With Fire
//
//  Created by James Valaitis on 08/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ParticleView.h"

@implementation ParticleView
{
	//	holds our caemitterlayer
	CAEmitterLayer					*_fireEmitter;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib
{
	//	store this view's layer as a caemitterlayer
	_fireEmitter					= (CAEmitterLayer *)self.layer;
	
	//	configure the emitter layer
	_fireEmitter.emitterPosition	= CGPointMake(50, 50);
	_fireEmitter.emitterSize		= CGSizeMake(10, 10);
	//	additive means that overlapping particles increase the colour intensity
	_fireEmitter.renderMode			= kCAEmitterLayerAdditive;
	
	//	configure a source of particles to emit in our layer
	CAEmitterCell *fire				= [CAEmitterCell emitterCell];
	//	number of emitted cells per second
	fire.birthRate					= 0;
	//	number of seconds before a particle should disappear
	fire.lifetime					= 3.0;
	//	gives a particle a random lifetime between lifetime - range to lifetime + range
	fire.lifetimeRange				= 0.5;
	//	 the colour tint to apply to the particles (orange in this case)
	fire.color						= [UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1].CGColor;
	//	contents to use for the cell, we're using our image
	fire.contents					= (id)[UIImage imageNamed:@"Particles_fire.png"].CGImage;
	//	the particles velocity in points per second
	fire.velocity					= 10;
	//	range by which velocity should vary
	fire.velocityRange				= 20;
	//	angle in radians in which the cell will emit
	fire.emissionRange				= M_PI_2;
	//	rate of change per second at which particles change scale
	fire.scaleSpeed					= 0.3;
	//	sets rotation speed of each particle
	fire.spin						= 0.5;
	//	a name to allow us to look the cell up later
	fire.name						= @"fire";
	
	//	add the cell to our layer
	_fireEmitter.emitterCells		= @[fire];
}

/**
 *	returns class used to create the layer for instances of this class
 */
+ (Class)layerClass
{
	//	configure the view to have an emitter layer
	return [CAEmitterLayer class];
}

#pragma mark - Convenience Methods

/**
 *	moves the layer's emitter position to where the touch is
 *
 *	@param	touch					the touch which we will position the emitter according to
 */
- (void)setEmitterPositionFromTouch:(UITouch *)touch
{
	//	change the emitter's position
	_fireEmitter.emitterPosition	= [touch locationInView:self];
}

/**
 *	turn off and on the emitting of particles
 */
- (void)setIsEmitting:(BOOL)isEmitting
{
	[_fireEmitter setValue:[NSNumber numberWithInt:isEmitting?200:0] forKeyPath:@"emitterCells.fire.birthRate"];
}

@end
