//
//  TagPickerController.m
//  iCloud Core Data
//
//  Created by James Valaitis on 20/11/2012.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.
//

#import "TagPickerController.h"

@interface TagPickerController ()

@end

@implementation TagPickerController

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
	NSEntityDescription *entity		= [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:self.note.managedObjectContext];
	fetchRequest.entity				= entity;
	
	//	specify how results should be sorted
	NSSortDescriptor *sortDescriptor= [[NSSortDescriptor alloc] initWithKey:@"tagContent" ascending:NO];
	NSArray *sortDescriptors		= [NSArray arrayWithObject:sortDescriptor];
	fetchRequest.sortDescriptors	= sortDescriptors;
	
	//	initialise a fetched results controller with the request and context
	_fetchedResultsController		= [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																	 managedObjectContext:self.note.managedObjectContext
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
	
	//	initialise our picked tags array and ser our title
	self.pickedTags					= [[NSMutableSet alloc] init];
	self.title						= @"Tag Your Note";
	
	//	retireve tags
	NSError *error;
	if (![self.fetchedResultsController performFetch:&error])
	{
		NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
		abort();
	}
	
	//	if there are no tags we create some
	if (self.fetchedResultsController.fetchedObjects.count == 0)
	{
		for (int i = 0; i < 5; i++)
		{
			Tag *tag				= [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
																	inManagedObjectContext:self.note.managedObjectContext];
			tag.tagContent			= [NSString stringWithFormat:@"Tag %i", i];
		}
		
		//	save any new tags we have just created
		if (![self.note.managedObjectContext save:&error])
		{
			NSLog(@"Unresolved error: %@, %@", error, error.userInfo);
			abort();
		}
		
		//	now retrieve the tags again
		NSLog(@"New tags have been created.");
		[self.fetchedResultsController performFetch:&error];
	}
	
	//	each tag for this note should be in the picked tags array
	for (Tag *tag in self.note.tags)
		[self.pickedTags addObject:tag];
}

/**
 *	notifies the view controller that its view is about to be removed from the view hierarchy
 *
 *	@param	animated				whether the view needs to be removed from the window with an animation
 */
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	//	save the note with it's tags as well as the tags themselves
	self.note.tags					= self.pickedTags;
	NSError *error;
	if (![self.note.managedObjectContext save:&error])
	{
		NSLog(@"Core Data error: %@, %@", error, error.userInfo);
		abort();
	}
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
	CellIdentifier				= @"TagCell";
	
	NSManagedObject *managedObject;
	managedObject				= [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	UITableViewCell *cell		= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell)
		cell					= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
	cell.accessoryType			= UITableViewCellAccessoryNone;
	
	Tag *tag					= (Tag *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	if ([self.pickedTags containsObject:tag])
		cell.accessoryType		= UITableViewCellAccessoryCheckmark;

	cell.textLabel.text			= tag.tagContent;
	
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
	//	get the relevant cell and tag
	Tag *tag					= (Tag *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	UITableViewCell *cell		= [self.tableView cellForRowAtIndexPath:indexPath];
	
	//	deselect this cell
	[cell setSelected:NO animated:YES];
	
	//	if this tag has been picked, we unpick it
	if ([self.pickedTags containsObject:tag])
		cell.accessoryType		= UITableViewCellAccessoryNone;
	//	and if it hasn't, we pick it
	else
	{
		[self.pickedTags addObject:tag];
		cell.accessoryType		= UITableViewCellAccessoryCheckmark;
	}
}

@end
