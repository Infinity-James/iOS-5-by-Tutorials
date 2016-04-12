//
//  AboutBackgroundView.m
//  Surf's Up
//
//  Created by James Valaitis on 25/10/2012.
//  Copyright (c) 2012 komorka technology, llc. All rights reserved.
//

#import "AboutBackgroundView.h"

@implementation AboutBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    UIEdgeInsets popoverInsets			= UIEdgeInsetsMake(68.0f, 16.0f, 16.0f, 34.0f);
	UIImage *popover					= [[UIImage imageNamed:@"popover_stretchable"] resizableImageWithCapInsets:popoverInsets];
	
	[popover drawInRect:rect];
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
	
}

- (UIPopoverArrowDirection)arrowDirection
{
	return UIPopoverArrowDirectionUp;
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
	
}

- (CGFloat)arrowOffset
{
	return 0.0f;
}

+ (CGFloat)arrowBase
{
	return 26.0f;
}

+ (CGFloat)arrowHeight
{
	return 16.0f;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(40.0f, 6.0f, 8.0f, 7.0f);
}


@end
