//
//  BeerAdvisorController.h
//  Beer Advisor
//
//  Created by James Valaitis on 09/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface BeerAdvisorController : UIViewController <CLLocationManagerDelegate>
{
	CLLocationManager			*_manager;
	IBOutlet MKMapView			*_mapView;
	IBOutlet UILabel			*_addressLabel;
	IBOutlet UILabel			*_locationLabel;
}

@end
