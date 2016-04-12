//
//  Note.m
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "Note.h"

@implementation Note

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
 */
- (id)init
{
	if (self = [super init])
	{
		//	get the date and time thid note was created and use it to create a unique id
		NSDateFormatter *formatter	= [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyyMMdd_hhmmss"];
		self.createdAt				= [NSDate date];
		self.noteID					= [NSString stringWithFormat:@"Note_%@", [formatter stringFromDate:self.createdAt]];
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
 *	allows the decoding of object when intialising
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
