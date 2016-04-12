//
//  SMMasterViewController.m
//  dox
//
//  Created by cesarerocchi Rocchi on 10/11/11.
//  Copyright (c) 2011 studiomagnolia.com. All rights reserved.
//

#import "NoteController.h"
#import "NoteListController.h"

@implementation NoteListController

#pragma mark - Setter & Getter Methods

/**
 *	returns the fetched results controller
 */
- (NSFetchedResultsController *)fetchedResultsController
{
	//	if the fetched results controller is initialised, return it
	if (_fetchedResultsController)
		return _fetchedResultsController;
	
	//	if it is not yet initialised, we do so, starting by creating a request for it
	NSFetchRequest *fetchRequest	= [[NSFetchRequest alloc] init];
	
	//	then create an entity description for the entity to be fetched and assign it to the request
	NSEntityDescription *entity		= [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
	fetchRequest.entity				= entity;
	
	//	specify how results should be sorted
	NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"noteTitle" ascending:NO];
	NSArray *sortDescriptors		= [NSArray arrayWithObject:sortDescriptor];
	fetchRequest.sortDescriptors	= sortDescriptors;
	
	//	initialise a fetched results controller with the request and context
	_fetchedResultsController		= [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		  managedObjectContext:self.managedObjectContext
																			sectionNameKeyPath:nil
																					 cacheName:@"Master"];
	[_fetchedResultsController setDelegate:self];
	
	//	now perform a fetch request and retrieve the data
	NSError *error;
	if (![_fetchedResultsController performFetch:&error])
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
	
	return _fetchedResultsController;
}

#pragma mark - View Lifecycle

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	add a bar button item for adding notes
	UIBarButtonItem *addNote		= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																					target:self
																					action:@selector(addNote)];
	[self.navigationItem setRightBarButtonItem:addNote animated:NO];
	
	//	register to be made aware of when the persistent store coordinator has been added
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotes) name:FetchNotesNotification object:nil];
}

#pragma mark - Action & Selector Methods

/**
 *	called to add a note to the model
 */
- (void)addNote
{
	//	get a new instance of the note entity
	Note *note						= [NSEntityDescription insertNewObjectForEntityForName:@"Note"
																	inManagedObjectContext:self.managedObjectContext];
	
	//	use the date and time to create a unique title for the note
	NSDateFormatter *formatter		= [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMdd_hhmmss"];
	note.noteTitle					= [NSString stringWithFormat:@"Note_%@", [formatter stringFromDate:[NSDate date]]];
	note.noteContent				= @"New Note Content.";
	
	
	//	save the context with this new note asynchronously
	[self.managedObjectContext performBlockAndWait:
	^{
		NSError *error;
		if (![self.managedObjectContext save:&error])
		{
			NSLog(@"Core Data error: %@, %@", error, error.userInfo);
			abort();
		}
	}];
}

/**
 *	reloads data in the table view
 */
- (void)reloadNotes
{
	//	fetch the new updated notes
	NSLog(@"Refetching notes.");
	NSError *error;
	if (![self.fetchedResultsController performFetch:&error])
	{
		NSLog(@"Core Data error: %@, %@", error, error.userInfo);
		abort();
	}
	
	//	reload the table view with the notes
	NSLog(@"Reloading %i notes.", self.fetchedResultsController.fetchedObjects.count);
	[self.tableView reloadData];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

/**
 *	called when the data model has been changed and the fetched results controller has finished processing it
 *
 *	@param	controller				the fetched results controller that sent the message
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	NSLog(@"Something has changed within the fetched results controller.");
	[self.tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

/**
 *	as the data source, we must define how many sections we want the table view to have
 *
 *	@param	tableView				the table view for which are defining the sections number
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
	static NSString *CellIdentifier;
	CellIdentifier				= @"NoteCell";
	
	NSManagedObject *managedObject;
	managedObject				= [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	UITableViewCell *cell		= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell)
	{
		cell					= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
			cell.accessoryType	= UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text			= [managedObject valueForKey:@"noteTitle"];
	
	return cell;
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
	id <NSFetchedResultsSectionInfo> sectionInfo;
	sectionInfo					= [self.fetchedResultsController.sections objectAtIndex:section];
	return [sectionInfo numberOfObjects];
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
	Note *note					= (Note *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		[self setDetailViewController:[[NoteController alloc] initWithNibName:@"NoteView_iPhone" bundle:nil]];
	else
		[self setDetailViewController:[[NoteController alloc] initWithNibName:@"NoteView_iPad" bundle:nil]];

	[self.detailViewController setCurrentNote:note];
	[self.navigationController pushViewController:self.detailViewController animated:YES];
}





























































@end
