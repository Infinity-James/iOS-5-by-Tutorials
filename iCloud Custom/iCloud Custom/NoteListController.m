//
//  ViewController.m
//  iCloud Custom
//
//  Created by James Valaitis on 15/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NoteController.h"
#import "NoteListController.h"

#define kFileName							@"notes.notez"
#define kNoteCellIdentifier					@"NoteListCell"

@interface NoteListController ()
{
	NSMetadataQuery		*_query;
}

@end

@implementation NoteListController

#pragma mark - View Lifecycle

/**
 *	called after the controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	register the cell nib to be used later
	[self.tableView registerNib:[UINib nibWithNibName:kNoteCellIdentifier bundle:nil] forCellReuseIdentifier:kNoteCellIdentifier];
	
	//	add the buttons to our view
	[self addButtons];
	
	//	register for notifications
	[self registerForNotifications];
}

#pragma mark - Action & Selector Methods

/**
 *	create and add a new note to our notes array
 */
- (void)addNote
{
	Note *note								= [[Note alloc] init];
	note.noteContent						= @"Test.";
	[self.notesDocument addNote:note];
}

/**
 *	load notes from icloud
 */
- (void)loadNotes
{
	//	get the first ubiquity container for this app as a file path
	NSURL *ubiquityContainer	= [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
	
	//	if we have the icloud access, we'll load the document
	if (ubiquityContainer)
	{
		NSLog(@"iCloud access at %@", ubiquityContainer);
		[self loadiCloudNotes];
	}
	
	//	or if the user wants to use icloud, but there was a problem
	else
		NSLog(@"No iCloud access.");
}

/**
 *	called when the note document has been changed in any way
 *
 *	@param	notification		object encapsulating notification information
 */
- (void)noteHasChanged:(NSNotification *)notification
{
	NotesDocument *notesDocument	= notification.object;
	
	//	if the a note has been deleted on another device, just reload the table with the new document
	if (notesDocument.documentState == UIDocumentStateSavingError)
		[self.tableView reloadData];
}

/**
 *	called when the notes have been loaded
 *
 *	@param	notification		object encapsulating notification information
 */
- (void)notesLoaded:(NSNotification *)notification
{
	//	gets the loaded notes document and reloads table data
	self.notesDocument			= notification.object;
	[self.tableView reloadData];
	
	//	get a handle to the store and register for key value store changes we didn't make
	NSUbiquitousKeyValueStore *store	= [NSUbiquitousKeyValueStore defaultStore];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateCurrentNoteIfNeeded:)
												 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
											   object:store];
	[store synchronize];
}

/**
 *	called when the query has completed
 *
 *	@param	notification				the notification object sent with this message
 */
- (void)queryDidFinishGathering:(NSNotification *)notification
{
	NSLog(@"Query finished gathering.");
	
	//	get the query that has finished gathering
	NSMetadataQuery *query		= notification.object;
	
	//	stop the query and the live updates it will send us, or it will run forever
	[query disableUpdates];
	[query stopQuery];
	
	//	load the data from the query
	[self loadData:query];
	
	//	remove ourself as an observer to ignore further notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSMetadataQueryDidFinishGatheringNotification
												  object:query];
	
	//	nilify handle so, once out of scope, the query is destroyed
	_query							= nil;
}

/**
 *	present the currently being edited note
 *
 *	@param	notification				the notification object sent with this message
 */	
- (void)updateCurrentNoteIfNeeded:(NSNotification *)notification
{
	NSString *currentNoteID			= [[NSUbiquitousKeyValueStore defaultStore] stringForKey:kCurrentNoteKey];
	
	Note *note						= [self.notesDocument noteByID:currentNoteID];
	
	[self changeNoteController:note];
}

#pragma mark - Convenience Methods

/**
 *	add the buttons to our view
 */
- (void)addButtons
{
	//	set the title of this view controller
	self.title								= @"Notes";
	
	UIView* toolbar							= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 94,
													self.navigationController.navigationBar.frame.size.height)];
	
	NSLog(@"Toolbar frame: Width = %f Height = %f", toolbar.frame.size.width, toolbar.frame.size.height);
	
	// create an array for the buttons
	NSMutableArray *buttons					= [[NSMutableArray alloc] initWithCapacity:5];
	
	//	creates a button allowing the user to create notes
	UIButton *addNote						= [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 44, 32) ];
	[addNote setTitle:@"Add" forState:UIControlStateNormal];
	[addNote setBackgroundColor:[UIColor blackColor]];
	addNote.layer.cornerRadius				= 8;
	[addNote addTarget:self action:@selector(addNote) forControlEvents:UIControlEventTouchUpInside];
											   
	
	//	creates a refresh button
	UIButton *refreshItem					= [[UIButton alloc] initWithFrame:CGRectMake(46, 6, 44, 32) ];
	[refreshItem setTitle:@"R" forState:UIControlStateNormal];
	[refreshItem setBackgroundColor:[UIColor blackColor]];
	refreshItem.layer.cornerRadius			= 8;
	[refreshItem addTarget:self action:@selector(loadNotes) forControlEvents:UIControlEventTouchUpInside];
	
	//	add buttons to custom tool bar
	[buttons addObjectsFromArray:@[addNote, refreshItem]];
	
	for (UIButton *button in buttons)
		[toolbar addSubview:button];
	
	//	put the buttons on the bar
	self.navigationItem.leftBarButtonItem	= [[UIBarButtonItem alloc] initWithCustomView:toolbar];
	self.navigationItem.rightBarButtonItem	= self.editButtonItem;
}

/**
 *	transition to a note controller with the passed in note
 *
 *	@param	note						note to present in a note controller
 */
- (void)changeNoteController:(Note *)note
{
	NoteController *detail;
	
	//	if this is an ipad grab the detail note controller and show the note on it
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		
		detail					= [self.splitViewController.viewControllers lastObject];
		[detail saveNote];
		detail.note				= note;
		[detail reload];
	}
	
	//	if on iphone use navigation controller to show note
	else
	{
		detail					= [[NoteController alloc] initWithNibName:@"NoteView_iPhone" bundle:nil];
		detail.note				= note;
		[self.navigationController pushViewController:detail animated:YES];
	}
}

/**
 *	load the data retrieved by a query
 *
 *	@param	query						the query holding the data we would like to load
 */
- (void)loadData:(NSMetadataQuery *)query
{
	NSLog(@"Going to load data from query results: %@", query.results);
	
	//	checks to see if there was a result
	BOOL	results						= NO;
	
	//	for every result in the query
	for (NSMetadataItem *result in query.results)
	{
		NSLog(@"Parsing results.");
		
		//	we then get the url required to build the note document
		NSURL *url						= [result valueForAttribute:NSMetadataItemURLKey];
		
		//	we build a note document with the url and keep a handle to it
		NotesDocument *notesDocument	= [[NotesDocument alloc] initWithFileURL:url];
		self.notesDocument				= notesDocument;
		
		//	we are now ready to open the note
		[notesDocument openWithCompletionHandler:^(BOOL success)
		 {
			 if (success)
			 {
				 NSLog(@"iCloud document has been successfully retrieved, built, and opened");
				 
				 [self.tableView reloadData];
			 }
			 else
				 NSLog(@"Failed to open a document from iCloud.");
		 }];
		
		results							= YES;
	}
	
	//	if there no result in the query we create one
	if (!results)
	{
		NotesDocument *notesDocument	= [[NotesDocument alloc] initWithFileURL:[[self ubiquitousNotesURL]
																				  URLByAppendingPathComponent:kFileName]];
		
		//	keep a handle to the new notes document
		self.notesDocument				= notesDocument;
		
		//	we then save it
		[notesDocument saveToURL:notesDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
		{
			//	if everything went according to plan
			if (success)
			{
				NSLog(@"New document created and saved to iCloud.");
				
				//	open the document
				[notesDocument openWithCompletionHandler:^(BOOL success)
				{
					NSLog(@"The new document has been opened.");
				}];
			}
		}];
	}
}

/**
 *	we have icloud access, so load the notes
 */
- (void)loadiCloudNotes
{
	//	initialise an nsmetadataquery object and keep a handle to it to keep it alive
	NSMetadataQuery *query		= [[NSMetadataQuery alloc] init];
	_query						= query;
	
	//	define the search parameters of the query
	[query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
	
	//	build a predicate and set it as the predicate of our query (using %@ wraps provided object in quotes)
	NSPredicate *predicate		= [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, kFileName];
	query.predicate			= predicate;
	
	//	query is asynchronous, so we want to be notified upon completion
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(queryDidFinishGathering:)
												 name:NSMetadataQueryDidFinishGatheringNotification
											   object:query];
	
	//	start the query
	[query startQuery];
}

/**
 *	register for all the notifications this class wants to observe
 */
- (void)registerForNotifications
{
	//	register to load the notes every time this app is made active
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadNotes)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
	
	//	register to be made aware everytime the notes have been loaded
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(notesLoaded:)
												 name:@"com.andbeyond.jamesvalaitis.notesLoaded"
											   object:nil];
	
	//	notified whenever document has been changed in any way
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(noteHasChanged:)
												 name:UIDocumentStateChangedNotification
											   object:nil];
}

/**
 *	returns url of icloud directory, used by daemon to sync with remote location
 */
- (NSURL *)ubiquitousNotesURL
{
	//	retrieve and return local icloud directory
	return [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
}

#pragma mark - UITableViewDataSource Methods

/**
 *	as the data source, we must define how many sections we want the table view to have
 *
 *	@param	tableView			the table view for which are defining the sections number
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

/**
 *	create and return the cells for each row of the table view
 *
 *	@param	tableView			the table view for which we are creating cells
 *	@param	indexPath			the index path of the row we are creating a cell for
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//	style of cell already defined in nib file, so just dequeue it
	UITableViewCell *cell		= [tableView dequeueReusableCellWithIdentifier:kNoteCellIdentifier forIndexPath:indexPath];
	
	//	get the note relevant to this row and use it's file name as the name for text label
	Note *note					= [self.notesDocument entryAtIndex:indexPath.row];
	cell.textLabel.text			= note.noteID;
	
	//	return our cell now
	return cell;
}

/**
 *	called to commit the insertion or deletion of a specified row in the receiver
 *
 *	@param	tableView			table view object requesting the insertion or deletion
 *	@param	editingStyle		cell editing style corresponding to a insertion or deletion
 *	@param	indexPath			index path of row requesting editing
 */
- (void) tableView:(UITableView *)				tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)				indexPath
{
	//	deletes the note at this particular index
	[self.notesDocument deleteNoteAtIndex:indexPath.row];
	
	//	removes note from table
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

/**
 *	define how many rows for each section there are in this table view
 *
 *	@param	tableView			the table view for which we are creating cells
 *	@param	section				the particular section for which we must define the rows
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return	self.notesDocument.entries.count;
}

#pragma mark - UITableViewDelegate Methods

/**
 *	handle the fact that a cell was just selected
 *
 *	@param	tableView			the table view containing selected cell
 *	@param	indexPath			the index path of the cell that was selected
 */
- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Note *note					= [self.notesDocument entryAtIndex:indexPath.row];
	
	[self changeNoteController:note];
}

/**
 *	return the editing style of a row at a particular location in a table view
 *
 *	@param	tableView			table view object requesting information
 *	@param	indexPath			index object defining row in table view
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
		   editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}


@end
