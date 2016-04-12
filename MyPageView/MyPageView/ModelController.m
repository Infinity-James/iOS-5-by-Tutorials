//
//  ModelController.m
//  MyPageView
//
//  Created by James Valaitis on 29/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "ModelController.h"
#import "DataViewController.h"

@interface ModelController()

@property (readonly, strong, nonatomic)	NSArray		*pageData;

@end

@implementation ModelController

#pragma mark - View Lifecycle

/**
 *	initialised a new object of this class
 */
- (id)init
{
    self = [super init];
    if (self)
	{
		//	create data model with a collection of month name	
		NSDateFormatter *dateFormatter		= [[NSDateFormatter alloc] init];
		_pageData							= [[dateFormatter monthSymbols] copy];
    }
    return self;
}

/**
 *	returns a view controller for a given index (usefull in initial config op app and implementation od data source methods)
 *
 *	@param	index							the index for which to return a view controller
 *	@param	storyboard						the storyboard containing the indentifier of the view controller in instantiate
 */
- (DataViewController *)viewControllerAtIndex:(NSUInteger)		index
								   storyboard:(UIStoryboard *)	storyboard
{   
    //	if the index is outside the realms of the view controllers we know of, return nil
    if (([self.pageData count] == 0) || (index >= [self.pageData count]))
        return nil;
    
    //	otherwise we create a view controller using the storyboard identifier
    DataViewController *dataViewController	= [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
	
	//	we give it the correct month name
    dataViewController.dataObject			= self.pageData[index];
	
	//	then we return the fully created view controller
    return dataViewController;
}

/**
 *	returns the index of a given view controller
 *
 *	@param	viewController					the view controller for which to find an index
 */
- (NSUInteger)indexOfViewController:(DataViewController *)viewController
{
	//	for simplicity we use the array of static data to determine the index of a view controller
    return [self.pageData indexOfObject:viewController.dataObject];
}

#pragma mark - PageViewControllerDataSource Methods

/**
 *	returns a view controller before the given view controller
 *
 *	@param	pageViewController				the page view controller
 *	@param	viewController					the view controller that the user has navigated away from
 */
- (UIViewController *)pageViewController:(UIPageViewController *)	pageViewController
	  viewControllerBeforeViewController:(UIViewController *)		viewController
{
	//	get index of given view controller
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
	
	//	if the index is outside the realms of the view controllers we know of, return nil
    if ((index == 0) || (index == NSNotFound)) 
        return nil;
    
	//	decrement the index to get a correct index of the previous view controller
    index--;
	
	//	return the previous view controller
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
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
	//	get index of given view controller
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
	
	//	if the index is outside the realms of the view controllers we know of, return nil
    if (index == NSNotFound) 
        return nil;
    
	//	increment the index to get a correct index of the next view controller
    index++;
	
	//	if the index is now just outside of the maximum view controllers, return nil
    if (index == [self.pageData count])
        return nil;

	//	return an instance of the next view controller
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
