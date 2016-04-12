//
//  SurfsUpAppDelegate.m
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

#import "SurfsUpAppDelegate.h"
#import "DetailViewController.h"
#import "NavDetailController.h"
#import "PlaceholderViewController.h"
#import "SurfsUpViewController.h"

@implementation SurfsUpAppDelegate

@synthesize window				= _window;
@synthesize splitController		= _splitController;
@synthesize tabController		= _tabController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    
    SurfsUpViewController *surfController		= [[SurfsUpViewController alloc] initWithStyle:UITableViewStylePlain];
	
    surfController.title						= @"Surf's Up";
	
	[[surfController navigationItem] setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]]];
	
    UINavigationController *navController		= [[UINavigationController alloc] initWithRootViewController:surfController];
	
	[self customiseAppearance];
	
	DetailViewController *detailController;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		detailController	= [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
	else
		detailController	= [[DetailViewController alloc] initWithNibName:@"DetailView_iPad" bundle:nil];
	
	[detailController setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated tag:100]];
	
	PlaceholderViewController *placeholder1	= [[PlaceholderViewController alloc] initWithNibName:@"PlaceholderView" bundle:nil];
	[placeholder1 setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:101]];
	
	PlaceholderViewController *placeholder2 = [[PlaceholderViewController alloc] initWithNibName:@"PlaceholderView" bundle:nil];
	[placeholder2 setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:102]];
	
	self.tabController						= [[UITabBarController alloc] init];
	self.tabController.viewControllers		= @[detailController, placeholder1, placeholder2];
	
	surfController.detailController			= detailController;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		self.window.rootViewController			= navController;
	else
	{
		self.detailNavController				= [[NavDetailController alloc] initWithRootViewController:detailController];
		[self.detailNavController setDetailController:detailController];
		self.splitController					= [[UISplitViewController alloc] init];
		self.splitController.delegate			= self.detailNavController;
		self.splitController.viewControllers	= @[navController, self.detailNavController];
		self.window.rootViewController			= self.splitController;
	}
	
    [[self window] makeKeyAndVisible];
    
    return YES;
}

- (void)customiseAppearance
{
	//	create resizable image
	UIImage *gradientImage44			= [[UIImage imageNamed:@"gradient_44"]
										   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	UIImage *gradientImage32			= [[UIImage imageNamed:@"gradient_32"]
										   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	
	//	set background image for all navigation bars
	[[UINavigationBar appearance] setBackgroundImage:gradientImage44 forBarMetrics:UIBarMetricsDefault];
	[[UINavigationBar appearance] setBackgroundImage:gradientImage32 forBarMetrics:UIBarMetricsLandscapePhone];
	
	//	customise title text for all navigation bars
	[[UINavigationBar appearance] setTitleTextAttributes:
	 [NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0],	UITextAttributeTextColor,
												 [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],	UITextAttributeTextShadowColor,
												 [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],			UITextAttributeTextShadowOffset,
												 [UIFont fontWithName:@"Arial-Bold" size:0.0],				UITextAttributeFont, nil]];
	
	//	create resizable buttons
	UIImage *button30					= [[UIImage imageNamed:@"barbutton_30"]
										   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
	UIImage *button24					= [[UIImage imageNamed:@"barbutton_24"]
										   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
	
	//	set background image for barbutton items
	[[UIBarButtonItem appearance] setBackgroundImage:button30 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearance] setBackgroundImage:button24 forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
	
	//	customise text for bar button items
	[[UIBarButtonItem appearance] setTitleTextAttributes:
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  [UIColor colorWithRed:205.0/255.0 green:142.0/255.0 blue:93.0/255.0 alpha:1.0],	UITextAttributeTextColor,
	  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],							UITextAttributeTextShadowColor,
	  [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],									UITextAttributeTextShadowOffset,
	  [UIFont fontWithName:@"AmericanTypeWriter" size:0.0],								UITextAttributeFont, nil]
	  forState:																			UIControlStateNormal];
	
	//	create resizable back buttons
	UIImage *buttonBack30				= [[UIImage imageNamed:@"button_back_textured_30"]
										   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
	UIImage *buttonBack24				= [[UIImage imageNamed:@"button_back_textured_24"]
										   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 5)];

	//	set background image for back buttons
	[[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack30 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack24
													  forState:UIControlStateNormal
													barMetrics:UIBarMetricsLandscapePhone];
	
	//	create resizeable tab bar background image and set the background and selection indicator
	UIImage *tabBackground				= [[UIImage imageNamed:@"tab_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	[[UITabBar appearance] setBackgroundImage:tabBackground];
	[[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tab_select_indicator"]];
	
	//	customising the uislider
	UIImage *minImage					= [[UIImage imageNamed:@"slider_minimum"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
	UIImage *maxImage					= [[UIImage imageNamed:@"slider_maximum"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
	UIImage *thumbImage					= [UIImage imageNamed:@"thumb"];
	
	[[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
	[[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
	[[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
	
	//	selection customisation
	UIImage *segmentSelected			= [[UIImage imageNamed:@"segcontrol_sel"]
										   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
	UIImage *segmentUnselected			= [[UIImage imageNamed:@"segcontrol_uns"]
										   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
	UIImage *segmentSelectedUnselected	= [UIImage imageNamed:@"segcontrol_sel-uns"];
	UIImage *segmentUnselectedSelected	= [UIImage imageNamed:@"segcontrol_uns-sel"];
	UIImage *segUnselectedUnselected	= [UIImage imageNamed:@"segcontrol_uns-uns"];
	
	[[UISegmentedControl appearance] setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UISegmentedControl appearance] setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
	[[UISegmentedControl appearance] setDividerImage:segUnselectedUnselected
								 forLeftSegmentState:UIControlStateNormal
								   rightSegmentState:UIControlStateNormal
										  barMetrics:UIBarMetricsDefault];
	[[UISegmentedControl appearance] setDividerImage:segmentSelectedUnselected
								 forLeftSegmentState:UIControlStateSelected
								   rightSegmentState:UIControlStateNormal
										  barMetrics:UIBarMetricsDefault];
	[[UISegmentedControl appearance] setDividerImage:segmentUnselectedSelected
								 forLeftSegmentState:UIControlStateNormal
								   rightSegmentState:UIControlStateSelected
										  barMetrics:UIBarMetricsDefault];
	[[UISegmentedControl appearance] setDividerImage:segUnselectedUnselected
								 forLeftSegmentState:UIControlStateNormal
								   rightSegmentState:UIControlStateNormal
										  barMetrics:UIBarMetricsDefault];
	
}

@end
