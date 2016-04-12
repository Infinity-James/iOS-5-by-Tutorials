//
//  NavDetailController.m
//  Surf's Up
//
//  Created by James Valaitis on 25/10/2012.
//  Copyright (c) 2012 komorka technology, llc. All rights reserved.
//

#import "NavDetailController.h"
#import "DetailViewController.h"

@interface NavDetailController ()

@end

@implementation NavDetailController

#pragma mark - UISplitViewControllerDelegate Methods

- (void)splitViewController:(UISplitViewController*)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem*)barButtonItem
       forPopoverController:(UIPopoverController*)pc
{
    barButtonItem.title = @"Surf Trips";
    [self.detailController.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.detailController.detailPopover	= pc;
}

- (void)splitViewController: (UISplitViewController*)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.detailController.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.detailController.detailPopover = nil;
}

- (void)splitViewController:(UISplitViewController*)svc
		  popoverController:(UIPopoverController*)pc
  willPresentViewController:(UIViewController *)aViewController
{
	if (self.detailController.aboutPopover.isPopoverVisible)
    {
        [self.detailController.aboutPopover dismissPopoverAnimated:YES];
    }
}

@end
