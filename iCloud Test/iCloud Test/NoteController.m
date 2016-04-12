	//
//  ViewController.m
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#include "AppDelegate.h"
#import "NoteController.h"
#import "VersionPickerController.h"

#define kFileName					@"MyDocument.notez"

@interface NoteController ()
{
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
	
	//	register for note modified notifications
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReloaded:) name:@"noteModified" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(noteHasChanged:)
												 name:UIDocumentStateChangedNotification
											   object:nil];
	
	UIBarButtonItem *exportButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStylePlain target:self action:@selector(sendNoteURL)];
	
	self.navigationItem.rightBarButtonItem	= exportButtonItem;
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
	self.noteView.text			= self.note.noteContent;
	
	//	set the reinstated property
	self.isReinstated			= NO;
	
	//	check if this document has been deleted elsewhere
	if (self.note.documentState == UIDocumentStateSavingError)
	{
		self.reinstateButton	= [[UIBarButtonItem alloc] initWithTitle:@"Reinstate"
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(reinstateNote)];
		[self.navigationItem setRightBarButtonItem:self.reinstateButton];
	}
	
	self.undoButton.enabled			= self.note.undoManager.canUndo;
	self.redoButton.enabled			= self.note.undoManager.canRedo;
}

- (void)viewDidDisappear:(BOOL)animated
{
	[self saveNoteWithContent:self.noteView.text];
	
	[super viewDidDisappear:animated];
	
	if (self.isReinstated)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.andbeyond.jamesvalaitis.noteReinstated"
															object:self];
}

#pragma mark - Convenience Methods

/**
 *	generates and returns a url that can be used to retrieve the current note
 */
- (NSURL *)generateExportURL
{
	//	create a time interval equal to 3600 seconds (1 hour)
	NSTimeInterval	hourTimeOut		= 3600.0;
	NSDate *hourExpiration			= [NSDate dateWithTimeInterval:hourTimeOut sinceDate:[NSDate date]];
	
	//	use this hour expiration to generate a url which will expire in that time
	NSError *error;
	NSURL *url						= [[NSFileManager defaultManager] URLForPublishingUbiquitousItemAtURL:self.note.fileURL
																						   expirationDate:&hourExpiration
																									error:&error];
	if (error)
	{
		NSLog(@"Error: %@", error.localizedDescription);
		return nil;
	}
	else
		return url;
}

/**
 *	reloads the text view content, no questions asked
 */
- (void)reload
{
	NSLog(@"Reloading");
	//	updates text view according to data received
	self.noteView.text				= self.note.noteContent;
}

/**
 *	save the note
 */
- (void)saveNoteWithContent:(NSString *)newContent
{
	NSString *currentText			= self.note.noteContent;
	
	if (newContent != currentText)
	{
		[self.note.undoManager registerUndoWithTarget:self selector:@selector(saveNoteWithContent:) object:currentText];
		
		self.note.noteContent		= newContent;
		self.noteView.text			= self.note.noteContent;
	}
	
	self.undoButton.enabled			= self.note.undoManager.canUndo;
	self.redoButton.enabled			= self.note.undoManager.canRedo;
}

#pragma mark - Action & Selector Methods

/**
 *	called when a note object is modified to allow us to reload it
 *
 *	@param	notification		object encapsulating notification information
 */
- (void)dataReloaded:(NSNotification *)notification
{
	NSLog(@"Data Reloading");
	//	get the note that was sent with this notification
	self.note					= notification.object;
	//	set our text view to be the content of the note we retrieved
	self.noteView.text			= self.note.noteContent;
}

/**
 *	called when the note document has been changed in any way
 *
 *	@param	notification		object encapsulating notification information
 */
- (void)noteHasChanged:(NSNotification *)notification
{
	//	if the a note has been deleted on another device, just reload the table with the new document
	if (self.note.documentState == UIDocumentStateSavingError)
	{
		self.title				= @"Limbo Note";
		self.reinstateButton	= [[UIBarButtonItem alloc] initWithTitle:@"Reinstate" style:UIBarButtonItemStylePlain target:self action:@selector(reinstateNote)];
		[self.navigationItem setRightBarButtonItem:self.reinstateButton];
	}
	
	//	whilst in this state, the document really shouldn't be edited or saved
	if (self.note.documentState == UIDocumentStateEditingDisabled)
	{
		[self.navigationItem.leftBarButtonItem setEnabled:NO];
		NSLog(@"Document state is UIDocumentStateEditingDisabled");
	}
	
	//	everything's fine man
	if (self.note.documentState == UIDocumentStateNormal)
	{
		[self.navigationItem.leftBarButtonItem setEnabled:YES];
		NSLog(@"Old content is %@", self.noteView.text);
		NSLog(@"New content is %@", self.note.noteContent);
		
		if (![self.noteView.text isEqualToString:self.note.noteContent])
		{
			UIBarButtonItem *resolveButton;
			resolveButton		= [[UIBarButtonItem alloc] initWithTitle:@"Resolve"
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(resolveNote)];
			
			[self.navigationItem setRightBarButtonItem:resolveButton];
		}
	}
}

/**
 *	redo any changes done to the text
 */
- (IBAction)performRedo:(id)sender
{
	//if (self.note.undoManager.canRedo)
	//	[self.note.undoManager redo];
}

/**
 *	undo any changes done to the text
 */
- (IBAction)performUndo:(id)sender
{
	//if (self.note.undoManager.canUndo)
	//	[self.note.undoManager undo];
}

/**
 *	reinstates note and resaves if it has been deleted
 */
- (void)reinstateNote
{
	//	generate filename for note
	NSDateFormatter *formatter	= [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMdd_hhmmss"];
	NSString *fileName			= [NSString stringWithFormat:@"Note_%@", [formatter stringFromDate:[NSDate date]]];
	
	NSURL *ubiquitousPackage	= [[[[NSFileManager defaultManager]
									 URLForUbiquityContainerIdentifier:nil]
									 URLByAppendingPathComponent:@"Documents"]
								     URLByAppendingPathComponent:fileName];
	
	//	create a new note and save it
	Note *note					= [[Note alloc] initWithFileURL:ubiquitousPackage];
	note.noteContent			= self.noteView.text;
	self.reinstateButton.enabled= NO;
	
	[note saveToURL:note.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
	{
		if (success)
		{
			self.note			= note;
			self.isReinstated	= YES;
			[self.navigationItem setRightBarButtonItem:nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.andbeyond.jamesvalaitis.noteReinstated" object:self];
		}
		else
			[self.reinstateButton setEnabled:YES];
	}];
}

/**
 *	allow user to choose a note version
 */
- (void)resolveNote
{
	VersionPickerController *versionPicker;
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
		versionPicker				= [[VersionPickerController alloc] initWithNibName:@"VersionPickerView_iPad" bundle:nil];
	else
		versionPicker				= [[VersionPickerController alloc] initWithNibName:@"VersionPickerView_iPhone" bundle:nil];
	
	versionPicker.newerNoteContent	= self.note.noteContent;
	versionPicker.oldNoteContent	= self.noteView.text;
	versionPicker.note				= self.note;
	
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		AppDelegate *delegate	= [UIApplication sharedApplication].delegate;
		[delegate.detailNavController pushViewController:versionPicker animated:YES];
	}
	else
		[self.navigationController pushViewController:versionPicker animated:YES];
}

/**
 *	sends the url of a note
 */
- (void)sendNoteURL
{
	//	generate the export url for the note
	NSURL *url						= [self generateExportURL];
	
	//	instantiate a mail composing view controller
	MFMailComposeViewController *mailComposer;
	mailComposer					= [[MFMailComposeViewController alloc] init];
	mailComposer.mailComposeDelegate= self;
	
	//	set the properties of the mail composer
	[mailComposer setModalPresentationStyle:UIModalPresentationFormSheet];
	[mailComposer setSubject:@"Download My Note"];
	[mailComposer setMessageBody:
	 [NSString stringWithFormat:@"The note can be downloaded at the following URL:\n\n%@\n\nIt will expire in one hour.", url]
						  isHTML:NO];
	
	//	present the view controller
	[self presentViewController:mailComposer animated:YES completion:NULL];
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
	//	save the inputted text into our note object and update the change to initiate a save
	//	self.note.noteContent		= textView.text;
	//	[self.note updateChangeCount:UIDocumentChangeDone];
}

@end
