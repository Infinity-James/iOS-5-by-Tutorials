//
//  BeerAdvisorController.m
//  Beer Advisor
//
//  Created by James Valaitis on 09/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Annotation.h"
#import "BeerAdvisorController.h"

@interface BeerAdvisorController()
{
	BOOL						_updated;
}

@end

@implementation BeerAdvisorController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_updated					= NO;
	
	//	start updating the location
	_manager					= [[CLLocationManager alloc] init];
	[_manager setDelegate:self];
	[_manager startUpdatingLocation];
	
	//	start monitoring for regions
	[self monitorRegions];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[_manager stopUpdatingLocation];
	
	for (CLRegion *region in _manager.monitoredRegions)
		[_manager stopMonitoringForRegion:region];
}

#pragma mark - Convenience Methods

- (void)forwardGeocodeWithAddress:(NSString *)address
{
	//	inform user of what we are now doing
	_locationLabel.text			= @"Geocoding Coordinate...";
	
	//	create our geocoder object
	CLGeocoder *forwardGeocoder	= [[CLGeocoder alloc] init];
	
	//	use the geocoder to geocode our address
	[forwardGeocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error)
	{
		//	if we found no location for this address string, or there was an error, we do not continue
		if (placemarks.count == 0 || error)	{NSLog(@"Error Geocoding Address: %@", error);	return;}
		
		//	we get the first place mark in the array
		CLPlacemark *firstMark	= (CLPlacemark *)[placemarks objectAtIndex:0];
		
		//	we get the coordinates for this placemark
		double latitude			= firstMark.location.coordinate.latitude;
		double longitude		= firstMark.location.coordinate.longitude;
		
		//	we then display the coordinates to the user
		_locationLabel.text		= [NSString stringWithFormat:@"Coordinates:\nLatitude: %0.3f, Longitude: %0.3f", latitude, longitude];
		
		//	show this adress on the map view
		[self updateMapView:firstMark.location.coordinate];
	}];
}

- (void)monitorRegions
{
	//	create the coordinates of the centre of kreuzberg
	CLLocationCoordinate2D kreuzbergCentre;
	kreuzbergCentre.latitude	= 52.497727;
	kreuzbergCentre.longitude	= 13.431129;
	
	//	set up a region of kreuzberg to monitor for
	CLRegion *kreuzBerg			= [[CLRegion alloc] initCircularRegionWithCenter:kreuzbergCentre radius:1000 identifier:@"Kreuzberg"];
	
	//	start monitoring if the user enters that region
	[_manager startMonitoringForRegion:kreuzBerg];
}

- (void)reverseGeocodeWithLocation:(CLLocation *)location
{
	//	inform user of what we are now doing
	_addressLabel.text			= @"Reverse Geocoding Coordinate...";
	
	//	a clgeocoder object can be used once
	CLGeocoder *reverseGeocoder	= [[CLGeocoder alloc] init];
	
	//	make reverse geocoding call to apple's servers
	[reverseGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
	{
		//	if there was an error we do not continue
		if (error)				{NSLog(@"Error Reverse Geocoding Address: %@", error);	return;}
		
		//	we get the first placemark that we reverse geocoded
		CLPlacemark *firstMark	= [placemarks objectAtIndex:0];
		
		//	we get the address for this place mark and structure it to allow for easy presentation
		NSArray *addressLines	= [firstMark.addressDictionary objectForKey:@"FormattedAddressLines"];
		NSString *firstAddress	= [addressLines componentsJoinedByString:@"\n"];
		
		//	we show the address to the user
		_addressLabel.text		= [NSString stringWithFormat:@"Reverse Geocoded Address: \n%@", firstAddress];
		
		//	we now forward geocode the address we have to get the coordinates
		[self forwardGeocodeWithAddress:firstAddress];
	}];
}

- (void)updateMapView:(CLLocationCoordinate2D)coordinate
{
	//	create a new annotation and add it to the map
	[_mapView addAnnotation:(id)[[Annotation alloc] initWithCoordinate:coordinate]];
	
	//	build a region around the coordinate
	MKCoordinateRegion viewRegion		= MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
	MKCoordinateRegion adjustedRegion	= [_mapView regionThatFits:viewRegion];
	
	//	set the region to the map
	[_mapView setRegion:adjustedRegion animated:YES];
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager
		 didEnterRegion:(CLRegion *)region
{
	[[[UIAlertView alloc] initWithTitle:region.identifier
								message:@"An especially awesome place for beer."
							   delegate:nil
					  cancelButtonTitle:@"Nice"
					  otherButtonTitles:nil] show];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
	//	get the current location and the previous location
	CLLocation *newLocation		= [locations objectAtIndex:0];
	CLLocation *oldLocation		= newLocation;
	
	if (locations.count > 1)
		oldLocation				= [locations objectAtIndex:1];
	
	//	if the current location and the previous location are different we will reverse geocode the location
	if (newLocation.coordinate.latitude != oldLocation.coordinate.latitude || !_updated)
	{
		[self reverseGeocodeWithLocation:newLocation];
		_updated				= YES;
	}
}

@end
