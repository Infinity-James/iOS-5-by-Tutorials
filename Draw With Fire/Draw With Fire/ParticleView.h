//
//  ParticleView.h
//  Draw With Fire
//
//  Created by James Valaitis on 08/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParticleView : UIView

- (void)setEmitterPositionFromTouch:(UITouch *)	touch;
- (void)setIsEmitting:				(BOOL)		isEmitting;

@end
