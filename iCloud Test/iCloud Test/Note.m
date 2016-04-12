//
//  Note.m
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "Note.h"

@implementation Note

#pragma mark - Setter & Getter Methods

- (void)setNoteContent:(NSString *)noteContent
{
	if (_noteContent != noteContent)
	{
		NSLog(@"Changing Note Content from %@ to %@", _noteContent, noteContent);
		_noteContent			= noteContent;
	}
}

#pragma mark - UIDocument Methods

/**
 *	overriden to return document data to be saved
 *
 *	@param	typeName			type of document; a uti based on extension of fileurl property
 *	@param	outError			if an error occurs loading the document, this error can be set to indicate why
 */
- (id)contentsForType:(NSString *)					typeName
				error:(NSError *__autoreleasing *)	outError
{
	//	we do not want to send an empty document to be saved, so we create default content
	if (self.noteContent.length == 0)
		self.noteContent		= @"Get typing.";
	
	//	return the content as data
	return [NSData dataWithBytes:self.noteContent.UTF8String length:self.noteContent.length];
}

/**
 *	overriden to load the document data into the application data model
 *
 *	@param	contents			an object encapsulating the document data to load
 *	@param	typeName			type of document; a uti based on extension of fileurl property
 *	@param	outError			if an error occurs loading the document, this error can be set to indicate why
 */
- (BOOL)loadFromContents:(id)							contents
				  ofType:(NSString *)					typeName
				   error:(NSError *__autoreleasing *)	outError
{
	//	if there is already some data, we initialise this document's contents with it
	if ([contents length] > 0)
		self.noteContent		= [[NSString alloc] initWithBytes:[contents bytes]
														   length:[contents length]
														 encoding:NSUTF8StringEncoding];
	//	if there is not yet data, we create some default data
	else
		self.noteContent		= @"Get typing.";
	
	//	notify all observers that this note has been modified
	[[NSNotificationCenter defaultCenter] postNotificationName:@"noteModified" object:self];
	
	//	indicate that this method executed successfully
	return YES;
}

@end
