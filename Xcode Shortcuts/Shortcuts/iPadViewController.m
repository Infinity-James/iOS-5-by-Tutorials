//
//  iPadViewController.m
//  Shortcuts
//
//  Created by James Valaitis on 08/11/2012.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import "DictionaryViewController.h"
#import "FavoritesViewController.h"
#import "iPadViewController.h"
#import "SearchableShortcutsViewController.h"
#import "SettingsViewController.h"
#import "ShortcutsDatabase.h"

@interface iPadViewController ()

@end

@implementation iPadViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.backgroundImageView.image	= [[UIImage imageNamed:@"bg_200"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	
	[self initialiseViewControllers];
}

#pragma mark - Convenience Methods

- (void)initialiseViewControllers
{
	//	sort out the shortcuts by key view controller
	_keysViewController				= [[DictionaryViewController alloc] initWithNibName:nil bundle:nil];
	[_keysViewController.navigationItem setTitle:@"Shortcuts By Key"];
	_keysViewController.dict		= [ShortcutsDatabase sharedDatabase].shortcutsByKey;
	
	//	sort out shortcuts by menu view controller
	_menusViewController			= [[DictionaryViewController alloc] initWithNibName:nil bundle:nil];
	[_menusViewController.navigationItem setTitle:@"Shortcuts By Menu"];
	_menusViewController.dict		= [ShortcutsDatabase sharedDatabase].shortcutsByMenu;
	_menusViewController.keys		= [ShortcutsDatabase sharedDatabase].menusArray;
	
	//	sort out favourites view controller
	_favouritesViewController		= [[FavoritesViewController alloc] initWithNibName:nil bundle:nil];
	
	//	sort out searching view controller
	_allShortcutsViewController		= [[SearchableShortcutsViewController alloc] initWithNibName:nil bundle:nil];
	[_allShortcutsViewController.navigationItem setTitle:@"All Shortcuts"];
	_allShortcutsViewController.shortcutsDict	= [ShortcutsDatabase sharedDatabase].shortcutsByKey;
	
	//	sort out settings view controller
	_settingsViewController			= [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
	
	//	add the views to their respective navigation controller
	_allNavigationController		= [[UINavigationController alloc] initWithRootViewController:_allShortcutsViewController];
	_keysNavigationController		= [[UINavigationController alloc] initWithRootViewController:_keysViewController];
	_menusNavigationController		= [[UINavigationController alloc] initWithRootViewController:_menusViewController];
	
	//	set the frames of each view
	_allNavigationController.view.frame				= self.rightView.bounds;
	_keysNavigationController.view.frame			= self.middleView.bounds;
	_menusNavigationController.view.frame			= self.leftView.bounds;
	_favouritesViewController.view.frame			= self.bottomView.bounds;
	_settingsViewController.view.frame				= self.bottomView.bounds;
	
	//	add each view to the main view
	[self.leftView addSubview:_menusNavigationController.view];
	[self.middleView addSubview:_keysNavigationController.view];
	[self.rightView addSubview:_allNavigationController.view];
	[self.bottomView addSubview:_favouritesViewController.view];
	
	//	add the view controllers as our children to make this work smoothly
	[self addChildViewController:_favouritesViewController];
	[_favouritesViewController didMoveToParentViewController:self];
	[self addChildViewController:_keysNavigationController];
	[_keysNavigationController didMoveToParentViewController:self];
	[self addChildViewController:_menusNavigationController];
	[_menusNavigationController didMoveToParentViewController:self];
}

#pragma mark - Action & Selector Methods

- (IBAction)favouritesButtonTapped
{
	[[ShortcutsDatabase sharedDatabase] playClick];
	
	[self addChildViewController:_favouritesViewController];
			
	[self transitionFromViewController:_settingsViewController
					  toViewController:_favouritesViewController
							  duration:0.5
							   options:UIViewAnimationOptionTransitionFlipFromBottom
							animations:^{
											[_settingsViewController.view removeFromSuperview];
											_favouritesViewController.view.frame	= self.bottomView.bounds;
											[self.bottomView addSubview:_favouritesViewController.view];
										}
							completion:^(BOOL finished)
										{
											[_favouritesViewController didMoveToParentViewController:self];
											[_settingsViewController removeFromParentViewController];
										}];
}

- (IBAction)settingsButtonTapped
{
	[[ShortcutsDatabase sharedDatabase] playClick];
	
	[self addChildViewController:_settingsViewController];
	
	[self transitionFromViewController:_favouritesViewController
					  toViewController:_settingsViewController
							  duration:0.5
							   options:UIViewAnimationOptionTransitionFlipFromBottom
							animations:^{
											[_favouritesViewController.view removeFromSuperview];
											_settingsViewController.view.frame	= self.bottomView.bounds;
											[self.bottomView addSubview:_settingsViewController.view];
										}
							completion:^(BOOL finished)
										{
											[_settingsViewController didMoveToParentViewController:self];
											[_favouritesViewController removeFromParentViewController];
										}];
}









































































@end
