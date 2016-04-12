//
//  SMNoteViewController.m
//  dox
//
//  Created by cesarerocchi Rocchi on 10/11/11.
//  Copyright (c) 2011 studiomagnolia.com. All rights reserved.
//

#import "NoteController.h"
#import "Tag.h"
#import "TagPickerController.h"

@implementation NoteController

#pragma mark - View Lifecycle

/**
 *	called once this controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	set ourselves as the text view delegate
	[self.noteContentView setDelegate:self];
	
	//	note the fact that the text has obviously not yet changed
	self.isChanged							= NO;
	
	//	if the tags label is tapped, we allow the user to add tags
	self.tagsLabel.userInteractionEnabled	= YES;
	UITapGestureRecognizer *tapGesture		= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagsTapped)];
	[self.tagsLabel addGestureRecognizer:tapGesture];
}

/**
*	notifies the view controller that its view is about to be added to a view hierarchy
*
*	@param	animated						whether the view needs to be added to the window with an animation
*/
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//	if there is a note associated with this controller
	if (self.currentNote)
	{
		//	set the text view of this controller to display the content of the note
		self.noteContentView.text			= self.currentNote.noteContent;
		self.title							= self.currentNote.noteTitle;
		
		//	get the notes tags and iterate through all of them to get the name of each tag
		NSArray *tagsArray					= self.currentNote.tags.allObjects;
		NSMutableArray *tagNames			= [NSMutableArray arrayWithCapacity:tagsArray.count];
		for (Tag *tag in tagsArray)
			[tagNames addObject:tag.tagContent];
		
		//	concatenate all of the tag names to display in the label
		NSString *tagsString				= [tagNames componentsJoinedByString:@", "];
		self.tagsLabel.text					= tagsString;
		[self.noteContentView becomeFirstResponder];
	}
}

/**
 *	notifies the view controller that its view is about to be removed from the view hierarchy
 *
 *	@param	animated						whether the view needs to be removed from the window with an animation
 */
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	//	save the note with it's new content
	self.currentNote.noteContent			= self.noteContentView.text;
	NSError *error;
	if (![self.currentNote.managedObjectContext save:&error])
	{
		NSLog(@"Core Data error: %@, %@", error, error.userInfo);
		abort();
	}
}

#pragma mark - Action & Selector Methods

/**
 *	called when the tags label has been tapped
 */
- (void)tagsTapped
{
	//	initialise the tag picker controller according to the device
	TagPickerController *tagPicker;
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		tagPicker							= [[TagPickerController alloc] initWithNibName:@"TagPickerView_iPhone" bundle:nil];
	else
		tagPicker							= [[TagPickerController alloc] initWithNibName:@"TagPickerView_iPad" bundle:nil];
	
	//	set the note of the tag picker and push it to the navigation stack
	tagPicker.note							= self.currentNote;
	[self.navigationController pushViewController:tagPicker animated:YES];
}




































@end
