//
//  Annotation.h
//  Beer Advisor
//
//  Created by James Valaitis on 09/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject <MKAnnotation>

@property (nonatomic, readonly)	CLLocationCoordinate2D		coordinate;

- (id)	initWithCoordinate:		(CLLocationCoordinate2D)	coordinate;

@end
