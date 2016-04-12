//
//  Annotation.m
//  Beer Advisor
//
//  Created by James Valaitis on 09/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

#pragma mark - Initialisation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
	if (self = [super init])
		_coordinate			= coordinate;
	
	return self;
}

@end
