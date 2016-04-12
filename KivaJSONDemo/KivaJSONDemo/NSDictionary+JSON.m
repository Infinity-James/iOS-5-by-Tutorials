//
//  NSDictionary+JSON.m
//  KivaJSONDemo
//
//  Created by James Valaitis on 08/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

/**
 *	creates a json nsdictionary using a passed in url
 *
 *	@param	url				the web address from which to get the json data
 */
+ (NSDictionary *)dictionaryWithContentsOfJSONURLString:(NSString *)url
{
	NSData *data			= [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	
	__autoreleasing NSError *error;
	
	NSDictionary *result	= [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
	
	if (error)				return nil;
	
	return result;
}

/**
 *	convenience method for returning a dictionary as json data
 */
- (NSData *)toJSON
{
	NSError *error;
	
	NSData *result			= [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
	
	if (error)				return nil;
	
	return result;
}

@end
