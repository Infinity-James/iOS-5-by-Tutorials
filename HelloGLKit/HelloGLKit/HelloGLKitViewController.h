//
//  HelloGLKitViewController.h
//  HelloGLKit
//
//  Created by James Valaitis on 22/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface HelloGLKitViewController : GLKViewController

- (IBAction)diffuseChanged:		(UISlider *)sender;
- (IBAction)ambientChanged:		(UISlider *)sender;
- (IBAction)specularChanged:	(UISlider *)sender;
- (IBAction)shininessChanged:	(UISlider *)sender;
- (IBAction)cutoffChanged:		(UISlider *)sender;
- (IBAction)exponentChanged:	(UISlider *)sender;
- (IBAction)constantChanged:	(UISlider *)sender;
- (IBAction)linearChanged:		(UISlider *)sender;
- (IBAction)quadraticChanged:	(UISlider *)sender;

@end
