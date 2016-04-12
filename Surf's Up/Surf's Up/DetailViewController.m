//
//  DetailViewController.m
//  Surf's Up
//
//  Created by Steven Baranski on 9/16/11.
//  Copyright 2011 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "DetailViewController.h"
#import "AboutController.h"
#import "AboutBackgroundView.h"

@implementation DetailViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_sand"]]];
	
	[rentSwitch setOnTintColor:[UIColor colorWithRed:0.0 green:175.0/255.0 blue:176.0/255.0 alpha:1.0]];
	
	UIBarButtonItem *aboutButton			= [[UIBarButtonItem alloc]  initWithTitle:@"About"
																	   style:UIBarButtonItemStyleDone
																	  target:self
																	  action:@selector(aboutTapped:)];
	
	[self.navigationItem setRightBarButtonItem:aboutButton animated:YES];
	
	// Initialize popover
    
    AboutController *aboutVC = [[AboutController alloc] initWithNibName:@"AboutView" bundle:nil];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		[self setAboutPopover:[[UIPopoverController alloc] initWithContentViewController:aboutVC]];
		[self.aboutPopover setDelegate:self];
		[self.aboutPopover setPopoverBackgroundViewClass:[AboutBackgroundView class]];
	}
    
}

#pragma mark - Private Methods

- (void)showAboutPopover
{
	if ([[self aboutPopover] isPopoverVisible] == NO)
    {
		[[self aboutPopover] presentPopoverFromBarButtonItem:self.lastTappedButton
									permittedArrowDirections:UIPopoverArrowDirectionAny
													animated:YES];
	}
	else
    {
		[[self aboutPopover] dismissPopoverAnimated:YES];
	}
}

#pragma mark - Action Methods

- (IBAction)aboutTapped:(id)sender
{
    [self setLastTappedButton:sender];
    [self showAboutPopover];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if ([self aboutPopover] != nil)
    {
		[[self aboutPopover] dismissPopoverAnimated:YES];
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.lastTappedButton != nil)
    {
		[self showAboutPopover];
	}
}

#pragma mark - UIPopoverViewControllerDelegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	self.lastTappedButton = nil;
}

@end
