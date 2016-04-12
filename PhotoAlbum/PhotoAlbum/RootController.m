//
//  RootController.m
//  PhotoAlbum
//
//  Created by James Valaitis on 30/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "RootController.h"
#import "AlbumPageController.h"

// ----------------------------------------------------------------------------------------------------------------
//											Root Controller Private Interface
// ----------------------------------------------------------------------------------------------------------------

@interface RootController ()

@end

// ----------------------------------------------------------------------------------------------------------------
//											Root Controller Implementation
// ----------------------------------------------------------------------------------------------------------------

@implementation RootController

#pragma mark - View Lifecycle

/**
 *	we get this message when the app has received a memory warning
 */
- (void)didReceiveMemoryWarning
{
	self.picturesArray					= nil;
}

/**
 *	called when view is loaded into memory
 */
- (void)viewDidLoad
{
	//	as usual, we call the super class viewdidload method
	[super viewDidLoad];
	
	//	fill our pictures array
	[self setUpPicturesArray];
	
	//	sets up the page view controller and all of it's controllers
	[self setUpPageViewController];
	
	//	makes page view controller our child
	[self adoptPageViewController];
}

#pragma mark - Convenience Methods

/**
 *	moves the page view controller to our view to make it visible
 */
- (void)adoptPageViewController
{
	//	add the page view controller as a child view controller
	[self addChildViewController:self.pageViewController];
	
	//	add the page view controller to our view
	[self.view addSubview:self.pageViewController.view];
	
	//	we then explicitly set the page view controller's frame
	self.pageViewController.view.frame	= self.view.bounds;
	
	//	we call this method after we've adopted the view into our view
	[self.pageViewController didMoveToParentViewController:self];
}

/**
 *	gives the first page some pictures
 *
 *	@param	albumPageController			the page controller which requires pages
 */
- (void)setUpFirstPage:(AlbumPageController *)albumPageController
{
	NSRange picturesRange;
	
	if (self.picturesArray.count > 0)
	{
		NSInteger picturesPerPage;
		
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
			picturesPerPage				= 4;
		else
			picturesPerPage				= 2;
		
		
		picturesRange.location			= 0;
		
		if (self.picturesArray.count >= picturesPerPage)
			picturesRange.length		= picturesPerPage;

		else
			picturesRange.length		= self.picturesArray.count;
	}
	
	albumPageController.picturesArray	= [self.picturesArray subarrayWithRange:picturesRange];
}

/**
 *	simply initialises our page view controller, and sorts out it's controllers
 */
- (void)setUpPageViewController
{
	//	clarify that we want out spine on the left side
	NSDictionary *pageViewOptions		= [NSDictionary dictionaryWithObjectsAndKeys:
										   UIPageViewControllerOptionSpineLocationKey,
										   [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin], nil];
	
	//	initialise page view controller as a horizontal controller with page curl and the options defined above
	self.pageViewController				= [[UIPageViewController alloc]
										   initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
										   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
										   options:pageViewOptions];
	
	//	set ourselves as data source and delegate of page view controller
	[self.pageViewController setDataSource:self];
	[self.pageViewController setDelegate:self];
	
	//	initialise the album view controller with the view we created
	AlbumPageController *albumPageController;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		albumPageController				= [[AlbumPageController alloc] initWithNibName:@"AlbumPageView_iPhone" bundle:nil];
	else
		albumPageController				= [[AlbumPageController alloc] initWithNibName:@"AlbumPageView_iPad" bundle:nil];
	
	//	set the page up with pictures
	[self setUpFirstPage:albumPageController];
	
	//	set index of first page to 0
	albumPageController.index			= 0;
	
	//	set the page view controllers' view controllers
	[self.pageViewController setViewControllers:[NSArray arrayWithObject:albumPageController]
									  direction:UIPageViewControllerNavigationDirectionForward
									   animated:NO
									 completion:NULL];
	
	//	adopt the gesture recognisers from the page view controller to allow for easier navigation of the book
	self.view.gestureRecognizers				= self.pageViewController.gestureRecognizers;
}

/**
 *	stores our picture names in an array
 */
- (void)setUpPicturesArray
{
	//	grab the dictionary from the plist in our main bundle
	NSDictionary *picturesDictionary	= [NSDictionary dictionaryWithContentsOfFile:
										   [[NSBundle mainBundle] pathForResource:@"Photos" ofType:@"plist"]];
	
	//	get the array from within the dictionary
	self.picturesArray					= [picturesDictionary objectForKey:@"PhotosArray"];
}

#pragma mark - UIPageViewControllerDataSource Methods

/**
 *	returns a view controller before the given view controller
 *
 *	@param	pageViewController				the page view controller
 *	@param	viewController					the view controller that the user has navigated away from
 */
- (UIViewController *)pageViewController:(UIPageViewController *)	pageViewController
	  viewControllerBeforeViewController:(UIViewController *)		viewController
{
	//	initialise the album view controller with the view we created
	AlbumPageController *currentPage	= (AlbumPageController *)viewController;
	
	//	if the page we are on at the moment is the first page, then there is no previous controller
	if (currentPage.index == 0)
		return nil;
	
	//	create the view controller to return
	AlbumPageController *previousPage;
	
	//	depending on whether we're on iphone or ipad, load correct view
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		previousPage					= [[AlbumPageController alloc] initWithNibName:@"AlbumPageView_iPhone" bundle:nil];
	else
		previousPage					= [[AlbumPageController alloc] initWithNibName:@"AlbumPageView_iPad" bundle:nil];
	
	previousPage.index					= currentPage.index - 1;
	
	//	we'll use this as the range within the array of the pictures we need
	NSRange picturesRange;
	
	//	if on an ipad...
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		//	the starting index will be the page index * 4 because we show 4 pictures per page
		NSUInteger startingIndex		= previousPage.index * 4;
		
		//	set the range accordingly, adhering to the 4 pictures per page
		picturesRange.location			= startingIndex;
		picturesRange.length			= 4;
		
		//	however, if there are not 4 pictures left, just get however many are left
		if ((picturesRange.location + picturesRange.length) >= self.picturesArray.count)
			picturesRange.length		= self.picturesArray.count - picturesRange.location - 1;
	}
	//	if we're on an iphone...
	else
	{
		//	the starting index will be the page index * 2 because we show 2 pictures per page
		NSUInteger startingIndex		= previousPage.index * 2;
		
		//	set the range accordingly, adhering to the 2 pictures per page
		picturesRange.location			= startingIndex;
		picturesRange.length			= 2;
		
		//	however, if there are not 2 pictures left, just get however many are left
		if ((picturesRange.location + picturesRange.length) >= self.picturesArray.count)
			picturesRange.length		= self.picturesArray.count - picturesRange.location - 1;
	}
	
	//	pass the picture names we aquired into the page's array
	previousPage.picturesArray			= [self.picturesArray subarrayWithRange:picturesRange];
	
	return previousPage;
}

/**
 *	returns a view controller after the given view controller
 *
 *	@param	pageViewController				the page view controller
 *	@param	viewController					the view controller that the user has navigated away from
 */
- (UIViewController *)pageViewController:(UIPageViewController *)	pageViewController
	   viewControllerAfterViewController:(UIViewController *)		viewController
{
	//	initialise the album view controller with the view we created
	AlbumPageController *currentPage	= (AlbumPageController *)viewController;
	
	//	keep a track of how many pages we should be showing
	NSUInteger pagesCount;
	
	//	if on the ipad...
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		//	the number of pages will be a quarter of the number of images (because we show 4 images per page)
		pagesCount						= (NSUInteger)ceilf(self.picturesArray.count * 0.25);
	
	//	but if we're on the iphone...
	else
		//	the number of pages will be half number of images (showing 2 images per page)
		pagesCount						= (NSUInteger)ceilf(self.picturesArray.count * 0.5);
	
	pagesCount--;
	
	//	if we are on the last page, return nil
	if (currentPage.index == pagesCount)
		return nil;
	
	AlbumPageController *nextPage;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		nextPage						= [[AlbumPageController alloc] initWithNibName:@"AlbumPageView_iPhone" bundle:nil];
	else
		nextPage						= [[AlbumPageController alloc] initWithNibName:@"AlbumPageView_iPad" bundle:nil];
	
	nextPage.index						= currentPage.index + 1;
	
	//	we'll use this as the range within the array of the pictures we need
	NSRange picturesRange;
	
	//	if on an ipad...
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		//	the starting index will be the page index * 4 because we show 4 pictures per page
		NSUInteger startingIndex		= nextPage.index * 4;
		
		//	set the range accordingly, adhering to the 4 pictures per page
		picturesRange.location			= startingIndex;
		picturesRange.length			= 4;
		
		//	however, if there are not 4 pictures left, just get however many are left
		if ((picturesRange.location + picturesRange.length) >= self.picturesArray.count)
			picturesRange.length		= self.picturesArray.count - picturesRange.location - 1;
	}
	//	if we're on an iphone...
	else
	{
		//	the starting index will be the page index * 2 because we show 2 pictures per page
		NSUInteger startingIndex		= nextPage.index * 2;
		
		//	set the range accordingly, adhering to the 2 pictures per page
		picturesRange.location			= startingIndex;
		picturesRange.length			= 2;
		
		//	however, if there are not 2 pictures left, just get however many are left
		if ((picturesRange.location + picturesRange.length) >= self.picturesArray.count)
			picturesRange.length		= self.picturesArray.count - picturesRange.location - 1;
	}
	
	//	pass the picture names we aquired into the page's array
	nextPage.picturesArray			= [self.picturesArray subarrayWithRange:picturesRange];
	
	return nextPage;
}

#pragma mark - UIPageViewControllerDelegate Methods

/**
 *	return the correct spine location for a given orientation
 *
 *	@param	pageViewController			the page view controller
 *	@param	orientation					the new orientation of the device
 */
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController
				   spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	//	initialise an album page controller for the page we are on
	AlbumPageController *currentPage	= [self.pageViewController.viewControllers objectAtIndex:0];
	
	//	if the device is an ipad in landscape
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape(orientation))
	{
		//	initialise an album page controller for the page we are on
		AlbumPageController *currentPage	= [self.pageViewController.viewControllers objectAtIndex:0];
		
		//	create an array of 'to be displayed' view controllers
		NSArray *viewControllers			= @[];
		
		//	get the index of where the current page is
		NSUInteger indexOfCurrentPage		= currentPage.index;
		
		//	use the index to work out what other page to display
		if (indexOfCurrentPage == 0 || indexOfCurrentPage % 2 == 0)
		{
			//	it's even, so get the next page
			UIViewController *nextPage		= [self pageViewController:self.pageViewController
									 viewControllerAfterViewController:currentPage];
			
			//	set the array of view controllers to display with our pages
			viewControllers					= @[currentPage, nextPage];
		}
		
		//	otherwise it's an odd numbered page, so we must display the previous page along with it
		else
		{
			//	get the previous page
			UIViewController *previousPage	= [self pageViewController:self.pageViewController
								    viewControllerBeforeViewController:currentPage];
			
			//	set the array with the pages we want to display
			viewControllers					= @[previousPage, currentPage];
		}
		
		//	set the page view controllers' view controllers
		[self.pageViewController setViewControllers:viewControllers
										  direction:UIPageViewControllerNavigationDirectionForward
										   animated:YES
										 completion:NULL];
		
		return UIPageViewControllerSpineLocationMid;
	}
	
	//	if we aren't showing two pages, don't make it double sided
	self.pageViewController.doubleSided		= NO;

	//	create an array of 'to be displayed' view controllers
	NSArray *viewControllers				= @[currentPage];
	
	//	set the page view controllers' view controllers
	[self.pageViewController setViewControllers:viewControllers
									  direction:UIPageViewControllerNavigationDirectionForward
									   animated:YES
									 completion:NULL];
	
	
	return UIPageViewControllerSpineLocationMin;
}































































@end
