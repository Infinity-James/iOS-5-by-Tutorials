//
//  NotesDocument.m
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "NotesDocument.h"

#define kEntriesKey						@"entries"
#define kEntriesWrapperKey				@"notes.dat"

// ----------------------------------------------------------------------------------------------------------------
//											Notes Document Implementation
// ----------------------------------------------------------------------------------------------------------------

@implementation NotesDocument

#pragma mark - Initialisation

/**
 *
 */
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotesChangedNotification object:nil];
}

/**
 *	initialises an object with a unique file url
 *
 *	@param	url							the url to set as the file url
 */
- (id)initWithFileURL:(NSURL *)url
{
	if (self = [super initWithFileURL:url])
	{
		self.entries					= [[NSMutableArray alloc] init];
		
		//	we want to be notified when a note has changed
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteChanged:)
													 name:kNotesChangedNotification
												   object:nil];
		
		NSLog(@"Just registered for %@", kNotesChangedNotification);
	}
	
	return self;
}

#pragma mark - Helper Methods

/**
 *	adds a note instance to the array and saves the document
 *
 *	@param	note						note to add
 */
- (void)addNote:(Note *)note
{
	//	add the note
	[self.entries addObject:note];
	
	//	save the note
	[self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
	{
		if (success)
		{
			NSLog(@"Note added and document saved.");
			
			//	if it saved successfully, open it
			[self openWithCompletionHandler:^(BOOL success)
			{
				NSLog(@"New note opened.");
			}];
		}
	}];
}

/**
 *	public method to return the count of the array
 */
- (NSInteger)count
{
	//	just return the entries count
	return self.entries.count;
}

/**
 *	removes a note at an index
 *
 *	@param	index						index of note to remove
 */
- (void)deleteNoteAtIndex:(NSInteger)index
{
	[self.entries removeObjectAtIndex:index];
	
	//	save the lack of note
	[self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
	 {
		 if (success)
		 {
			 NSLog(@"Note removed and document saved.");
			 
			 //	if it saved successfully, open it
			 [self openWithCompletionHandler:^(BOOL success)
			  {
				  NSLog(@"Notes document opened.");
			  }];
		 }
	 }];
}

/**
 *	public method that returns an entry at a given index in the array
 *
 *	@param	index						the index we want the entry for
 */
- (Note *)entryAtIndex:(NSUInteger)index
{
	//	if the index is within the number of entries, return the correct entry
	if (index < self.entries.count)
		return [self.entries objectAtIndex:index];
	
	//	otherwise return nil because it is an invalid index
	else
		return nil;
}

/**
 *	returns a note based on a given id
 *
 *	@param	noteID						id of the note to return
 */
- (Note *)noteByID:(NSString *)noteID
{
	Note *result;
	
	//	for each note in the notea array check if it has the right id, if it does save and return it
	for (Note *note in self.entries)
		if ([note.noteID isEqualToString:noteID])
			result						= note;
	
	return result;
}

#pragma mark - Action & Selector Methods

/**
 *	called when a note has changed
 */
- (void)noteChanged:(NSNotification *)notification
{
	//	save the notes
	[self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
	{
		if (success)
			NSLog(@"Note updated.");
	}];
}

#pragma mark - UIDocument Methods

/**
 *	builds and generates our fie wrapper and returns the document to be saved
 *	
 *	@param	typeName					the file type of the document
 *	@param	outError					an error to set if something goes wrong
 */
- (id)contentsForType:(NSString *)					typeName
				error:(NSError *__autoreleasing *)	outError
{
	//	create an empty dictionary
	NSMutableDictionary *wrappers		= [NSMutableDictionary dictionary];
	//	create an empty data object
	NSMutableData *data					= [NSMutableData data];
	//	create an archiver initialised for encoding an archive into the given data object
	NSKeyedArchiver *archiver			= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	
	//	encode the array into the data
	[archiver encodeObject:self.entries forKey:kEntriesKey];
	//	finish with the archiver
	[archiver finishEncoding];
	
	//	initialise a file wrapper with the contents of our data
	NSFileWrapper *entriesWrapper		= [[NSFileWrapper alloc] initRegularFileWithContents:data];
	//	store the wrapper in our wrappers dictionary
	[wrappers setObject:entriesWrapper forKey:kEntriesWrapperKey];
	
	//	create root wrapper and initialise with all created wrappers
	NSFileWrapper *result				= [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
	
	return result;
}

/**
 *	called to load document data into application model
 *
 *	@param	contents					object encapsulating the data to load
 *	@param	typeName					type of document to load
 *	@param	outError					we set this error if soemthing goes wrong
 */
- (BOOL)loadFromContents:(id)							contents
				  ofType:(NSString *)					typeName
				   error:(NSError *__autoreleasing *)	outError
{
	//	unfold main wrapper in a dictionary
	NSFileWrapper *wrapper				= (NSFileWrapper *)contents;
	NSDictionary *childrenWrappers		= [wrapper fileWrappers];
	
	//	retrieve the wrapper of notes using our key
	NSFileWrapper *entriesWrapper		= [childrenWrappers objectForKey:kEntriesWrapperKey];
	
	//	build a data buffer from the wrapper
	NSData *data						= [entriesWrapper regularFileContents];
	//	initialise an unarchiver with our data buffer and decode the object using our key
	NSKeyedUnarchiver *unarchiver		= [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	self.entries						= [unarchiver decodeObjectForKey:kEntriesKey];
	
	//	post a notification that we loaded the notes
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotesLoadedNotification object:self];
	
	return YES;
}

@end
