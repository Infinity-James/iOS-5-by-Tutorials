//
//  NotesDocument.m
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "NotesDocument.h"

// ----------------------------------------------------------------------------------------------------------------
//											Notes Document Implementation
// ----------------------------------------------------------------------------------------------------------------

@implementation NotesDocument

static NSString *const EntriesKey		= @"entries";
static NSString *const EntriesWrapperKey= @"notes.dat";

#pragma mark - Lifecycle

/**
 *	initialises an object with a unique file url
 */
- (id)initWithFileURL:(NSURL *)url
{
	if (self = [super initWithFileURL:url])
	{
		self.entries					= [[NSMutableArray alloc] init];
		
		//	we want to be notified when a note has changed
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(noteChanged)
													 name:@"com.andbeyond.noteChanged"
												   object:nil];
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

#pragma mark - Selector Methods

/**
 *	called when a note had changed
 */
- (void)noteChanged
{
	//	save the notes
	[self saveToURL:[self fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success)
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
	[archiver encodeObject:self.entries forKey:EntriesKey];
	//	finish with the archiver
	[archiver finishEncoding];
	
	//	initialise a file wrapper with the contents of our data
	NSFileWrapper *entriesWrapper		= [[NSFileWrapper alloc] initRegularFileWithContents:data];
	//	store the wrapper in our wrappers dictionary
	[wrappers setObject:entriesWrapper forKey:EntriesWrapperKey];
	
	//	create root wrapper and initialise with all created wrappers
	NSFileWrapper *result				= [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
	
	NSLog(@"contentsForType called.");
	
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
	NSFileWrapper *entriesWrapper		= [childrenWrappers objectForKey:EntriesWrapperKey];
	
	//	build a data buffer from the wrapper
	NSData *data						= [entriesWrapper regularFileContents];
	//	initialise an unarchiver with our data buffer and decode the object using our key
	NSKeyedUnarchiver *unarchiver		= [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	self.entries						= [unarchiver decodeObjectForKey:EntriesKey];
	
	//	post a notification that we loaded the notes
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.andbeyond.notesLoaded" object:self];
	
	return YES;
}































































@end
