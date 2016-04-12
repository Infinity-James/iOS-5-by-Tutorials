//
//  DetailController.m
//  Ratings
//
//  Created by James Valaitis on 22/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "DetailController.h"

@implementation DetailController
{
	UIPopoverController *_masterPopoverController;
	UIPopoverController *_menuPopoverController;
}

#pragma mark Autorotation

/**
 *	returns whether the view controller’s contents should auto rotate
 */
- (BOOL)shouldAutorotate
{
	return YES;
}

/**
 *	returns all of the interface orientations that the view controller supports
 */
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

/**
 *	sent to the view controller before performing a one-step user interface rotation
 *
 *	@param	toInterfaceOrientation	new orientation for the user interface
 *	@param	duration				duration of the pending rotation, measured in seconds
 */
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
										 duration:(NSTimeInterval)duration
{
	if (_menuPopoverController && _menuPopoverController.popoverVisible)
	{
		[_menuPopoverController dismissPopoverAnimated:YES];
		_menuPopoverController		= nil;
	}
}

#pragma mark - Segue Methods

/**
 *	notifies view controller that segue is about to be performed
 *
 *	@param	segue				segue object containing information about the view controllers involved in the segue
 *	@param	sender				object that initiated the segue
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue
				 sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ShowPopover"])
	{
		if (_menuPopoverController && _menuPopoverController.popoverVisible)
			[_menuPopoverController dismissPopoverAnimated:NO];
		
		_menuPopoverController	= ((UIStoryboardPopoverSegue *)segue).popoverController;
		[_menuPopoverController setDelegate:self];
	}
}

#pragma mark - UIPopoverControllerDelegate Methods

/**
 *	tells the delegate that the popover was dismissed
 *
 *	@param	popoverController	popover controller that was dismissed
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[_menuPopoverController setDelegate:nil];
	_menuPopoverController		= nil;
}

#pragma mark - UISplitViewControllerDelegate Methods

/**
 *	called when the master view controller is about to be presented in a popover controller
 *
 *	@param	splitViewController	the split view controller that owns the specified view controller
 *	@param	popoverController	the pop over controller that will present the hidden view controller
 *	@param	aViewController		the view controller that is about to be hidden
 */
- (void)splitViewController:(UISplitViewController *)splitViewController
		  popoverController:(UIPopoverController *)popoverController
  willPresentViewController:(UIViewController *)aViewController
{
	
}

/**
 *	called when the master view controller is about to be hidden
 *
 *	@param	splitViewController	the split view controller that owns the specified view controller
 *	@param	aViewController		the view controller that is about to be hidden
 *	@param	barButtonItem		a bar button item that will present the view controller
 *	@param	popoverController	the pop over controller that will present the hidden view controller
 */
- (void)splitViewController:(UISplitViewController*)splitViewController
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem*)barButtonItem
       forPopoverController:(UIPopoverController*)popoverController
{
	barButtonItem.title			= @"Master";
	NSMutableArray *items		= self.toolbar.items.mutableCopy;
	[items insertObject:barButtonItem atIndex:0];
	[self.toolbar setItems:items animated:YES];
	_masterPopoverController		= popoverController;
}

/**
 *	called when the master view controller is about to be presented
 *
 *	@param	splitViewController	the split view controller that owns the specified view controller
 *	@param	aViewController		the view controller that is about to be shown
 *	@param	barButtonItem		a bar button item that would present the view controller
 */
- (void)splitViewController: (UISplitViewController*)splitViewController
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	NSMutableArray *items		= self.toolbar.items.mutableCopy;
	[items removeObject:barButtonItem];
	[self.toolbar setItems:items animated:YES];
}

@end
