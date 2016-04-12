//
//  Note.m
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "Note.h"

// ----------------------------------------------------------------------------------------------------------------
//											Note Implementation
// ----------------------------------------------------------------------------------------------------------------

@implementation Note

#pragma mark - Lifecycle

/**
 *	a standard initialiser method
 */
- (id)init
{
	if (self = [super init])
	{
		//	initialise a date formatter
		NSDateFormatter *formatter		= [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyyMMdd_hhmmss"];
		//	set the unique id to be the creation time
		self.noteID						= [NSString stringWithFormat:@"Note_%@", [formatter stringFromDate:[NSDate date]]];
	}
	
	return self;
}

#pragma mark - NSCoding Methods

/**
 *	allows the encoding of objects when saving
 *
 *	@param	aCoder						the object used to encode our properties
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	//	for each object, encode the properties with a key for each
	[aCoder encodeObject:self.noteID forKey:@"noteID"];
	[aCoder encodeObject:self.noteContent forKey:@"noteContent"];
	[aCoder encodeObject:self.createdAt forKey:@"createdAt"];
	[aCoder encodeObject:self.updatedAt forKey:@"updatedAt"];
}

/**
 *	allows the decoding of object when saving
 *
 *	@param	aDecoder					the object used to decode our proerties
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		//	for each object, decode the properties using our keys
		self.noteID						= [aDecoder decodeObjectForKey:@"noteID"];
		self.noteContent				= [aDecoder decodeObjectForKey:@"noteContent"];
		self.createdAt					= [aDecoder decodeObjectForKey:@"createdAt"];
		self.updatedAt					= [aDecoder decodeObjectForKey:@"updatedAt"];
	}
	
	return self;
}

@end
