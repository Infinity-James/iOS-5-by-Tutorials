//
//  ViewController.m
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Note.h"
#import "NoteController.h"

@interface NoteController ()
{
	BOOL						_isChanged;
	UIPopoverController			*_popover;
	UIButton					*_popoverButton;
}

@end

@implementation NoteController

#pragma mark - View Lifecycle

/**
 *	called after the controller's view has been loaded into memory
 */
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	set ourselves as the text view delegate
	[self.noteView setDelegate:self];
	
	//	set is changed
	_isChanged							= NO;
	
	//	add this controller as an observer of whether the document changes in anyway
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(noteHasChanged:)
												 name:UIDocumentStateChangedNotification
											   object:nil];
}

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	whether the view needs to be added to the window with an animation
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//	when the view appears, show the text view with our note's content
	if (self.note)
		self.noteView.text				= self.note.noteContent;
	
	//	register to when the app entered the background
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(saveNoteAsCurrent)
												 name:UIApplicationDidEnterBackgroundNotification
											   object:nil];
}

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	whether the view needs to be added to the window with an animation
 */
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self saveNote];
	
	//	remove ourselves as an obsrver of whether the app enter background
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

#pragma mark - Convenience Methods

/**
 *	reloads the text view content, no questions asked
 */
- (void)reload
{
	//	updates text view according to data received
	self.noteView.text				= self.note.noteContent;
}

/**
 *	save the note content
 */
- (void)saveNote
{
	if (_isChanged)
	{
		//	save to the text view to the note's contents
		self.note.noteContent			= self.noteView.text;
		
		//	post a notification that we changed the notes
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotesChangedNotification object:nil];
		
		NSLog(@"Just posted %@", kNotesChangedNotification);
		
		//	make sure we know it's already saved
		_isChanged							= NO;
	}
}

/**
 *	save the open note as the note currently being edited
 */
- (void)saveNoteAsCurrent
{
	[[NSUbiquitousKeyValueStore defaultStore] setString:self.note.noteID forKey:kCurrentNoteKey];
	[[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

#pragma mark - UISplitViewControllerDelegate Methods

/**
 *	called when the master view controller is about to be hidden
 *
 *	@param	svc					the split view controller that owns the specified view controller
 *	@param	aViewController		the view controller that is about to be hidden
 *	@param	barButtonItem		a bar button item that will present the view controller
 *	@param	pc					the pop over controller that will present the hidden view controller
 */
- (void)splitViewController:(UISplitViewController*)	svc
     willHideViewController:(UIViewController *)		aViewController
          withBarButtonItem:(UIBarButtonItem*)			barButtonItem
       forPopoverController:(UIPopoverController*)		pc
{
	//	if we have not yet created a pop over button
	if (!_popoverButton)
	{
		//	we create a custom button
		UIButton *popoverButton				= [UIButton buttonWithType:UIButtonTypeCustom];
		
		//	we set it's background colour
		UIColor *buttonColour				= [UIColor colorWithRed:158.0/255.0 green:99.0/255.0 blue:197.0/255.0 alpha:1.0];
		popoverButton.backgroundColor		= buttonColour;
		
		//	we set the title
		[popoverButton setTitle:@"Notes" forState:UIControlStateNormal];
		popoverButton.titleLabel.textColor	= [UIColor whiteColor];
		
		//	we give it rounded corners
		popoverButton.layer.cornerRadius	= 8;
		
		//	we add it to the main view
		[self.view addSubview:popoverButton];
		
		//	we add the targets, allowing it present the master controller
		[popoverButton addTarget:barButtonItem.target action:barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
		
		//	we keep a handle to it
		_popoverButton						= popoverButton;
	}
	
	//	ragerdless of whether it has been created or not, we set the frame a make it not hidden
	[_popoverButton setFrame:CGRectMake(64, 32, 64, 32)];
	[_popoverButton setHidden:NO];
	
	//	we keep a handle to the popover as well
	_popover								= pc;
}

/**
 *	called when the master view controller is about to be presented
 *
 *	@param	svc					the split view controller that owns the specified view controller
 *	@param	aViewController		the view controller that is about to be shown
 *	@param	barButtonItem		a bar button item that would present the view controller
 */
- (void)splitViewController: (UISplitViewController*)	svc
     willShowViewController:(UIViewController *)		aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)			barButtonItem
{
	//	this button is about to be invalidated, so we hide it
    [_popoverButton setHidden:YES];
	
	//	we nilify the popover handle as we no longer need it
    _popover							= nil;
}

/**
 *	called when the master view controller is about to be presented in a popover controller
 *
 *	@param	svc					the split view controller that owns the specified view controller
  *	@param	pc					the pop over controller that will present the hidden view controller
 *	@param	aViewController		the view controller that is about to be hidden
 */
- (void)splitViewController:(UISplitViewController*)	svc
		  popoverController:(UIPopoverController*)		pc
  willPresentViewController:(UIViewController *)		aViewController
{
	//	we only want one popover showing at any one time, so if there is another, we dismiss it
	if (_popover.isPopoverVisible)
        [_popover dismissPopoverAnimated:YES];
}

#pragma mark - UITextViewDelegate Methods

/**
 *	tells the delegate that the text or attributes in the specified text view were changed
 *
 *	@param	textView			text view containing the changes
 */
- (void)textViewDidChange:(UITextView *)textView
{
	//	if the text view changes, register the change
	_isChanged					= YES;
}

@end
