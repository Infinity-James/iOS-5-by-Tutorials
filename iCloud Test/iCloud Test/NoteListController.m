//
//  NoteListController.m
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#include "AppDelegate.h"
#include "ConflictVersionPicker.h"
#import "NoteController.h"
#import "NoteListController.h"

#define kNoteCellIdentifier		@"NoteListCell"
#define kUseiCloudKey			@"useiCloud"

@interface NoteListController ()
{
	NSMetadataQuery				*_query;
}

@end

@implementation NoteListController

#pragma mark - Setter & Getter Methods

/**
 *	called to set the icloud bool
 *
 *	@param	val					what to set the bool to
 */
- (void)setUseiCloud:(BOOL)useiCloud
{
	//	if this is not the same value
	if (_useiCloud != useiCloud)
	{
		//	set the bool
		_useiCloud				= useiCloud;
		
		//	save the bool to user defaults
		[[NSUserDefaults standardUserDefaults] setBool:_useiCloud forKey:kUseiCloudKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		//	if the user does not want to use icloud, we warn them first
		if (_useiCloud)
			[[[UIAlertView alloc] initWithTitle:@"Attention"
										message:@"This will delete notes from your iCloud account. Are you sure?"
									   delegate:self
							  cancelButtonTitle:@"No"
							  otherButtonTitles:@"I aint afraid", nil] show];
		
		//	otherwise we just start the migration
		else
			[self startMigration];
	}
}

#pragma mark - View Lifecycle

/**
 *	called after the controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	register the cell nib to be used later
	[self.tableView registerNib:[UINib nibWithNibName:kNoteCellIdentifier bundle:nil] forCellReuseIdentifier:kNoteCellIdentifier];
	
	//	initialise out notes array
	self.notes					= [[NSMutableArray alloc] init];
	
	//	get the user's settings
	self.useiCloud				= [[NSUserDefaults standardUserDefaults] boolForKey:kUseiCloudKey];
	
	//	allow editing in our table
	self.tableView.allowsSelectionDuringEditing	= YES;
	
	//	set our title
	self.title					= @"Notes";
	
	//	add the buttons to our view
	[self addButtons];
	
	//	register for notifications as to when app is active
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadNotes)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(noteHasChanged:)
												 name:UIDocumentStateChangedNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(loadNotes)
												 name:@"com.andbeyond.jamesvalaitis.noteReinstated"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(conflictResolved)
												 name:@"com.andbeyond.jamesvalaitis.conflictResolved"
											   object:nil];
}

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	@param	animated						whether the view needs to be added to the window with an animation
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//	when the view appears, make sure to show the toolbar
	[self.navigationController setToolbarHidden:NO];
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
	
	//	sort out the toolbar
	UIBarButtonItem *flexSpace1				= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				   target:nil
																				   action:NULL];
	
	UIBarButtonItem *iCloudSwitch			= [[UIBarButtonItem alloc]initWithCustomView:[self switchView]];
	
	UIBarButtonItem *flexSpace2				= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				   target:nil
																				   action:NULL];
	
	self.toolbarItems						= @[flexSpace1, iCloudSwitch, flexSpace2];
}

/**
 *	load the data retrieved by a query
 *
 *	@param	query						the query holding the data we would like to load
 */
- (void)loadData:(NSMetadataQuery *)query
{
	NSLog(@"Going to load data from query results: %@", query.results);
	
	//	clear out our notes array ready to reload them all
	[self.notes removeAllObjects];
	
	//	for every result in the query
	for (NSMetadataItem *result in query.results)
	{
		NSLog(@"Parsing results.");
		
		//	we then get the url required to build the note document
		NSURL *url						= [result valueForAttribute:NSMetadataItemURLKey];
		
		//	we build a note document with the url and keep a handle to ut
		Note *note						= [[Note alloc] initWithFileURL:url];
		
		//	we are now ready to open the note
		[note openWithCompletionHandler:^(BOOL success)
		{
			if (success)
			{
				NSLog(@"iCloud document has been successfully retrieved, built, and opened");
				
				//	upon successfully opening the note we add it to our array and reload the table
				[self.notes addObject:note];
				[self.tableView reloadData];
			}
			else
				NSLog(@"Failed to open a document from iCloud.");
		}];
	}
}

/**
 *	we have icloud access, so load the notes
 */
- (void)loadiCloudNotes
{
	//	initialise an nsmetadataquery object and keep a handle to it to keep it alive
	_query						= [[NSMetadataQuery alloc] init];
	
	//	define the search parameters of the query
	[_query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
	
	//	build a predicate and set it as the predicate of our query (using %@ wraps provided object in quotes)
	NSPredicate *predicate		= [NSPredicate predicateWithFormat:@"%K like 'Note_*'", NSMetadataItemFSNameKey];
	_query.predicate			= predicate;
	
	//	query is asynchronous, so we want to be notified upon completion
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(queryDidFinishGathering:)
												 name:NSMetadataQueryDidFinishGatheringNotification
											   object:_query];
	
	//	start the query
	[_query startQuery];
}

/**
 *	load the notes off of the local directory
 */
- (void)loadLocalNotes
{
	//	remove all the notes from our array
	[self.notes removeAllObjects];
	
	//	get the notes from the directory
	NSArray *localNotesURLs		= [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self localNotesURL]
																includingPropertiesForKeys:nil
																				   options:kNilOptions
																					 error:NULL];
	
	//	for each notes url, make a note and then reload the table
	for (NSURL *noteURL in localNotesURLs)
	{
		Note *note				= [[Note alloc] initWithFileURL:noteURL];
		[self.notes addObject:note];
		[self.tableView reloadData];
	}
}

/**
 *	returns the url of the directory where local notes are stored
 */
- (NSURL *)localNotesURL
{
	//	return url pointing to document directory in app sandbox
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 *	starts the migration between local and ubiquitous directories
 */
- (void)startMigration
{	
	////	instantiate queue and an operation to it that will run in the background
	NSOperationQueue *iCloudQueue		= [NSOperationQueue new];
	NSInvocationOperation *operation	= [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(setNotesUbiquity)
																			  object:nil];
	[iCloudQueue addOperation:operation];
}

/**
 *	builds and returns a view for a switch
 */
- (UIView *)switchView
{	//	create a view to hold the switch, then create the switch
	UIView *switchView			= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 32)];
	self.iCloudSwitch			= [[UISwitch alloc] initWithFrame:CGRectMake(40, 4, 80, 26)];
	
	//	make the switch reflect our property
	self.iCloudSwitch.on			= self.useiCloud;
	
	//	when the switch is used, we want to be made aware
	[self.iCloudSwitch addTarget:self action:@selector(toggleiCloud:) forControlEvents:UIControlEventValueChanged];
	
	//	attach the views
	[switchView addSubview:self.iCloudSwitch];
	
	return switchView;
}

/**
 *	returns url of icloud directory, used by daemon to sync with remote location
 */
- (NSURL *)ubiquitousNotesURL
{
	//	retrieve and return local icloud directory
	return [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
}

#pragma mark - Action & Selector Methods

/**
 *	create and add a new note to our notes array
 */
- (void)addNote
{
	//	get today's date and the time
	NSDateFormatter *formatter	= [[NSDateFormatter alloc] init];
	formatter.dateFormat		= @"yyyyMMdd_hhmmss";
	
	//	we want the file name to be unique, so we use the date and time in a formater we just created
	NSString *fileName			= [NSString stringWithFormat:@"Note_%@", [formatter stringFromDate:[NSDate date]]];
	
	//	get the correct directory based on whether the user wants icloud or not
	NSURL *baseURL				= [self localNotesURL];
	if (self.useiCloud)
		baseURL					= [self ubiquitousNotesURL];
	
	NSURL *notesURL				= [baseURL URLByAppendingPathComponent:fileName];
	
	//	initialise an instance of our document in the directory and keep a handle to the note
	Note *note					= [[Note alloc] initWithFileURL:notesURL];
	
	//	save the note in the directory
	[note saveToURL:note.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
	{
		//	if the document was successfully created / saved, we add it our notes array and reload the table
		if (success)
		{
			[self.notes addObject:note];
			[self.tableView reloadData];
		}
		//	otherwise, if we failed...
		else
			NSLog(@"Failed to save, and subsequently open an iCloud document.");
	}];
}

/**
 *	called when conflicts in a document have been resolved
 */
- (void)conflictResolved
{
	[self.tableView reloadData];
}

/**
 *	load notes from icloud
 */
- (void)loadNotes
{
	//	get the first ubiquity container for this app as a file path
	NSURL *ubiquityContainer	= [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
	
	//	if we have the icloud access, we'll load the document
	if (ubiquityContainer && self.useiCloud)
	{
		NSLog(@"iCloud access at %@", ubiquityContainer);
		[self loadiCloudNotes];
	}
	
	//	or if the user wants to use icloud, but there was a problem
	else if (self.useiCloud)
		NSLog(@"No iCloud access.");
	
	//	otherwise if the use just wants to load local notes
	else
		[self loadLocalNotes];
}

/**
 *	called when the note document has been changed in any way
 *
 *	@param	notification		object encapsulating notification information
 */
- (void)noteHasChanged:(NSNotification *)notification
{
	Note *note					= notification.object;
	
	//	if the a note has been deleted on another device, just reload the table with the new document
	if (note.documentState == UIDocumentStateSavingError)
		[self.tableView reloadData];
	else
		[self.tableView reloadData];
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
 *
 */
- (void)setNotesUbiquity
{
	//	get the base url according to the user's setting
	NSURL *baseURL				= [self localNotesURL];
	if (self.useiCloud)
		baseURL					= [self ubiquitousNotesURL];
	
	//	for each note currently in the url, move it over to the other directory
	for (Note *note in self.notes)
	{
		NSURL *destinationURL	= [baseURL URLByAppendingPathComponent:note.fileURL.lastPathComponent];
		
		NSLog(@"Note Original URL: %@", note.fileURL);
		NSLog(@"Note Destination URL: %@", destinationURL);
		
		[[NSFileManager defaultManager] setUbiquitous:self.useiCloud itemAtURL:note.fileURL destinationURL:destinationURL error:NULL];
	}
	
	//	we are running in another thread, so now it's over execute a method on the main thread
	[self performSelectorOnMainThread:@selector(ubiquityIsSet) withObject:nil waitUntilDone:YES];
}

/**
 *	called when the use icloud switch is toggled
 */
- (void)toggleiCloud:(UISwitch *)iCloudSwitch
{
	self.useiCloud				= iCloudSwitch.isOn;
}

/**
 *	called once the notes have been moved over to either side
 */
- (void)ubiquityIsSet
{
	NSLog(@"Are notes ubiquitous? %i", self.useiCloud);
}

#pragma mark - UIAlertViewDelegate Methods

- (void)   alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		[self.iCloudSwitch setOn:YES animated:YES];
		self.useiCloud			= YES;
	}
	
	else
		[self startMigration];
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
	Note *note					= [self.notes objectAtIndex:indexPath.row];
	cell.textLabel.text			= note.fileURL.lastPathComponent;
	
	//	make it obvious if a note is in conflict
	if (note.documentState == UIDocumentStateInConflict)
	{
		cell.textLabel.textColor= [UIColor redColor];
		
		NSArray *conflicts		= [NSFileVersion unresolvedConflictVersionsOfItemAtURL:note.fileURL];
		
		for (NSFileVersion *version in conflicts)
		{
			NSLog(@"--------------------------------");
			NSLog(@"Name: %@", version.localizedName);
			NSLog(@"Date: %@", version.modificationDate);
			NSLog(@"Device: %@", version.localizedNameOfSavingComputer);
			NSLog(@"URL: %@", version.URL);
			NSLog(@"--------------------------------");
		}
	}
	else
		cell.textLabel.textColor= [UIColor blackColor];
	
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
	//	get the note we want to delete
	Note *note					= [self.notes objectAtIndex:indexPath.row];
	NSError *error;
	
	//	remove it from it's directory
	[[NSFileManager defaultManager] removeItemAtURL:note.fileURL error:&error];
	
	//	remove it from the notes array
	[self.notes removeObjectAtIndex:indexPath.row];
	
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
	return	self.notes.count;
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
	Note *note					= [self.notes objectAtIndex:indexPath.row];
	
	if (note.documentState == UIDocumentStateInConflict)
	{
		ConflictVersionPicker *picker;
		
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		{
			picker				= [[ConflictVersionPicker alloc] initWithNibName:@"ConflictVersionPicker_iPad" bundle:nil];
		}
		
		else
		{
			picker				= [[ConflictVersionPicker alloc] initWithNibName:@"ConflictVersionPicker_iPhone" bundle:nil];
		}
		
		picker.note				= note;
		
		NSArray *conflicts		= [NSFileVersion unresolvedConflictVersionsOfItemAtURL:note.fileURL];
		
		for (NSFileVersion *version in conflicts)
		{
			Note *otherDeviceNote	= [[Note alloc] initWithFileURL:version.URL];
			
			[otherDeviceNote openWithCompletionHandler:^(BOOL success)
			{
				if (success)
				{
					picker.thisDeviceNoteContent	= note.noteContent;
					picker.otherDeviceNoteContent	= otherDeviceNote.noteContent;
					
					if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
					{
						AppDelegate *delegate	= [UIApplication sharedApplication].delegate;
						[delegate.detailNavController pushViewController:picker animated:YES];
					}
					
					else
					{
						[self.navigationController pushViewController:picker animated:YES];
					}
					
				}
			}];
		}
		
		return;
	}
	
	
	
	
	NoteController *detail;
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		AppDelegate *delegate	= [UIApplication sharedApplication].delegate;
		detail					= delegate.noteController;
		detail.note				= note;
		[detail reload];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
	{
		detail					= [[NoteController alloc] initWithNibName:@"NoteView_iPhone" bundle:nil];
		detail.note				= note;
		[self.navigationController pushViewController:detail animated:YES];
	}
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
