//
//  NoteListController.m
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "NoteListController.h"

#define kFileName					@"notes.dox"

// ----------------------------------------------------------------------------------------------------------------
//									Note List Controller Private Interface
// ----------------------------------------------------------------------------------------------------------------

@interface NoteListController ()

@end

// ----------------------------------------------------------------------------------------------------------------
//									Note List Controller Implementation
// ----------------------------------------------------------------------------------------------------------------

@implementation NoteListController

#pragma mark - View Lifecycle

/**
 *	message received when there is low memory
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *	called when controller's view is loaded into memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//	set the table view data source to be ourselves
	[self.tableView setDataSource:self];
	//	same for the table view delegate
	[self.tableView setDelegate:self];
	
	//	add the buttons to our view
	[self addButtons];
	
	//	register for notification
	[self registerForNotifications];
}

#pragma mark - Helper Methods

/**
 *	adds buttons to our view
 */
- (void)addButtons
{
	//	create an add button which calls the add note method
	UIBarButtonItem *addNoteItem	= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																					target:self
																					action:@selector(addNote:)];
	
	//	set the add note button to be the right bar button item
	[self.navigationItem setRightBarButtonItem:addNoteItem];
}

/**
 *	if the document exists we open it
 *
 *	@param	query					the query holding the daya
 */
- (void)loadData:(NSMetadataQuery *)query
{
	//	if the query has a result (our document)
	if (query.resultCount == 1)
	{
		//	get the result from the query
		NSMetadataItem *item		= [query resultAtIndex:0];
		//	get the file path of the result
		NSURL *url					= [item valueForAttribute:NSMetadataItemURLKey];
		
		//	initialise a notes document object with file path of the document we found
		NotesDocument *document		= [[NotesDocument alloc] initWithFileURL:url];
		
		//	keep a pointer to the document
		self.document				= document;
		
		[document openWithCompletionHandler:^(BOOL success)
		{
			//	if there was a document
			if (success)
			{
				NSLog(@"The document was successfully loaded from iCloud.");
				//	reload the table with our new data
				[self.tableView reloadData];
			}
			else
				NSLog(@"Failed to open document.");
		}];
	}
	//	otherwise there is no such document, and we must create it
	else
	{
		//	grab the default uniquity container
		NSURL *ubiquityContainer	= [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
		//	create the file path to create the document
		NSURL *ubiquitousPackage	= [[ubiquityContainer URLByAppendingPathComponent:@"Documents"]
														  URLByAppendingPathComponent:kFileName];
		
		//	initialise the document with the file path we created
		NotesDocument *document		= [[NotesDocument alloc] initWithFileURL:ubiquitousPackage];
		//	keep a pointer to the document
		self.document				= document;
		
		NSLog(@"loadData called.");
		//	save the document
		[document saveToURL:[document fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
		{
			NSLog(@"New document saved to iCloud.");
			//	now that it's created, we open it
			[document openWithCompletionHandler:^(BOOL success)
			{
				NSLog(@"Newly created document now opened from iCloud.");
			}];
		}];
	}
}

/**
 *	registers for notifications for this class
 */
- (void)registerForNotifications
{
	NSNotificationCenter *centre	= [NSNotificationCenter defaultCenter];
	
	//	register so notes are reloaded whenever our app becomes active
	[centre addObserver:self selector:@selector(loadNotes) name:UIApplicationDidBecomeActiveNotification object:nil];
	//	register to know when notes have been successfully loaded
	[centre addObserver:self selector:@selector(notesLoaded:) name:@"com.andbeyond.notesLoaded" object:nil];
}

#pragma mark - Selector Methods

/**
 *	called when user wants to add a new note
 *
 *	@param	sender					caller of this method
 */
- (void)addNote:(id)sender
{
	//	instantiate new note, give it some default content, then add it to our notes document
	Note *note						= [[Note alloc] init];
	note.noteContent				= @"Test";
	[self.document addNote:note];
}

/**
 *	handles the loading of notes
 */
- (void)loadNotes
{
	//	grab the default uniquity container
	NSURL *ubiquity					= [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
	
	if (ubiquity)
	{
		//	instantiate a metadata query
		NSMetadataQuery *query		= [[NSMetadataQuery alloc] init];
		
		//	keep a handle to the query to keep it alive
		_query						= query;
		
		//	search within the document directories of the app's icloud directories
		[query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
		
		//	predicate based on whether the name as seen in the file system is equal to the name of our document
		NSPredicate *predicate		= [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, kFileName];
		
		//	set the predicate for the query
		[query setPredicate:predicate];
		
		//	register to be notified when query has finished
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(queryDidFinishGathering:)
													 name:NSMetadataQueryDidFinishGatheringNotification
												   object:query];
		
		[query startQuery];
	}
}

/**
 *	callback for when query finished gathering data
 *
 *	@param	notification			a notification object sent to this method
 */
- (void)queryDidFinishGathering:(NSNotification *)notification
{
	//	get a handle to the query
	NSMetadataQuery *query			= notification.object;
	//	disable query updates (or they'd go indefinitely until the app closes)
	[query disableUpdates];
	//	completely halt query
	[query stopQuery];
	
	//	load data of the query
	[self loadData:query];
	
	//	remove ourselves as an observer of query updates
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
	
	//	destroy last pointer toe the query object, removing it from memory
	_query							= nil;
}

/**
 *	method triggered when notes successfully loaded
 *
 *	@param	notification			a notification object sent to this method
 */
- (void)notesLoaded:(NSNotification *)notification
{
	//	grab the notes document
	self.document					= notification.object;
	//	reload the table view now that the notes have been loaded
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

@end
