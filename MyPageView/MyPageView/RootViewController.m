//
//  RootViewController.m
//  MyPageView
//
//  Created by James Valaitis on 29/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "RootViewController.h"
#import "ModelController.h"
#import "DataViewController.h"

@interface RootViewController ()

@property (readonly, strong, nonatomic) ModelController *modelController;

@end

@implementation RootViewController

@synthesize modelController = _modelController;

#pragma mark - Setter & Getter Methods

/**
 *	the getter for our model controller
 */
- (ModelController *)modelController
{
	//	lazy instantiation of the model controller
    if (!_modelController)
        _modelController = [[ModelController alloc] init];
    
    return _modelController;
}

#pragma mark - View Lifecycle

/**
 *	called after our view has been loaded into memory
 */
- (void)viewDidLoad
{
	//	as usual call the super class' viewdidload method
    [super viewDidLoad];

	self.pageViewController						= [[UIPageViewController alloc]
										   initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
											 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
														   options:nil];
	
	//	set ourselves as page view controller delegate
	self.pageViewController.delegate			= self;

	//	get the first view controller
	DataViewController *startingViewController	= [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
	
	//	create an array of the view controller to display (just the first one)
	NSArray *viewControllers					= @[startingViewController];
	
	//	set the view controllers to display using our array
	[self.pageViewController setViewControllers:viewControllers
									  direction:UIPageViewControllerNavigationDirectionForward
									   animated:NO
									 completion:NULL];

	//	set the model controller to be the data source of the oage view controller
	self.pageViewController.dataSource			= self.modelController;

	//	add the oage view controller as a child of this view controller
	[self addChildViewController:self.pageViewController];
	
	//	then add it to our view
	[self.view addSubview:self.pageViewController.view];

	//	we need to set the frame of the view controller to be within our bounds
	CGRect pageViewRect							= self.view.bounds;
	
	//	if this is an ipad we will make it slightly smaller than our bounds
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	    pageViewRect							= CGRectInset(pageViewRect, 40.0, 40.0);
	
	//	we then explicitly set the page view controller's frame
	self.pageViewController.view.frame			= pageViewRect;

	//	we make sure to call this method because we have added it and moved it to our view
	[self.pageViewController didMoveToParentViewController:self];

	//	adopt the gesture recognisers from the page view controller to allow for easier navigation of the book
	self.view.gestureRecognizers				= self.pageViewController.gestureRecognizers;
}

/**
 *	received when app issues a memory warning, we should do clean up here
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIPageViewControllerDelegate Methods

/**
 *	return the correct spine location for a given orientation
 *
 *	@param	pageViewController					the page view controller
 *	@param	orientation							the new orientation of the device
 */
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController
				   spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	//	portrait or iphone, only display one page (and set doublesided to no)
	if (UIInterfaceOrientationIsPortrait(orientation) ||
		([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone))
	{
		//	get handle to first controller
	    UIViewController *currentViewController		= self.pageViewController.viewControllers[0];
		
		//	put it in out array
	    NSArray *viewControllers					= @[currentViewController];
		
		//	set the view controller
	    [self.pageViewController setViewControllers:viewControllers
										  direction:UIPageViewControllerNavigationDirectionForward
										   animated:YES
										 completion:NULL];
	    
		//	make sure to clarify this is not a double sided book
	    self.pageViewController.doubleSided			= NO;
		
		//	return the fact that we want spine on left side
	    return UIPageViewControllerSpineLocationMin;
	}

	//	landscape on ipad means we wants spine in centre and displaying two view controllers
	
	//	first grab first view controller
	DataViewController *currentViewController		= self.pageViewController.viewControllers[0];
	
	//	get empty array
	NSArray *viewControllers = nil;

	//	calculate whether there are even number of view controllers
	NSUInteger indexOfCurrentViewController			= [self.modelController indexOfViewController:currentViewController];
	
	//	if it is even...
	if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0)
	{
		//	grab the next view controller
	    UIViewController *nextViewController		= [self.modelController
													   pageViewController:self.pageViewController
										viewControllerAfterViewController:currentViewController];
		
		//	put both in the array of view controllers to display
	    viewControllers = @[currentViewController, nextViewController];
	}
	
	//	if it's odd...
	else
	{
		//	grab the last view controller
	    UIViewController *previousViewController	= [self.modelController pageViewController:self.pageViewController
														    viewControllerBeforeViewController:currentViewController];
		
		//	and put both in array of view controller to be displayed
	    viewControllers = @[previousViewController, currentViewController];
	}
	
	//	display both view controller in an animated fashion
	[self.pageViewController setViewControllers:viewControllers
									  direction:UIPageViewControllerNavigationDirectionForward
									   animated:YES
									 completion:NULL];


	//	return the fact that we want the spine down the middle
	return UIPageViewControllerSpineLocationMid;
}

@end
