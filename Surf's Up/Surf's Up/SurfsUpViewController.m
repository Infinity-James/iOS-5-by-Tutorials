//
//  SurfsUpViewController.m
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

#import "SurfsUpViewController.h"
#import "SurfsUpAppDelegate.h"
#import "CustomCell.h"
#import "DetailViewController.h"
#import "PlaceholderViewController.h"

NSString	*const	TopCellIdentifier		= @"TopRow";
NSString	*const	MiddleCellIdentifier	= @"MiddleRow";
NSString	*const	BottomCellIdentifier	= @"BottomRow";
NSString	*const	SingleCellIdentifier	= @"SingleRow";

@implementation SurfsUpViewController

- (SurfsUpAppDelegate *)sharedAppDelegate;
{
    return (SurfsUpAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Private behavior and "Model" methods

- (NSString *)tripNameForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            return @"Kuta, Bali";
            break;
        case 1:
            return @"Lagos, Portugal";
            break;
        case 2:
            return @"Waikiki, Hawaii";
            break;
    }
    return @"-";
}

- (UIImage *)tripPhotoForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            return [UIImage imageNamed:@"surf1.png"];
            break;
        case 1:
            return [UIImage imageNamed:@"surf2.png"];
            break;
        case 2:
            return [UIImage imageNamed:@"surf3.png"];
            break;
    }
    return nil;
}

#pragma mark - View lifecycle

- (void)registerNibs
{
	NSBundle *classBundle		= [NSBundle bundleForClass:[CustomCell class]];
	
	UINib *topNib				= [UINib nibWithNibName:TopCellIdentifier bundle:classBundle];
	UINib *middleNib			= [UINib nibWithNibName:MiddleCellIdentifier bundle:classBundle];
	UINib *bottomNib			= [UINib nibWithNibName:BottomCellIdentifier bundle:classBundle];
	UINib *singleNib			= [UINib nibWithNibName:SingleCellIdentifier bundle:classBundle];
	
	[self.tableView registerNib:topNib forCellReuseIdentifier:TopCellIdentifier];
	[self.tableView registerNib:middleNib forCellReuseIdentifier:MiddleCellIdentifier];
	[self.tableView registerNib:bottomNib forCellReuseIdentifier:BottomCellIdentifier];
	[self.tableView registerNib:singleNib forCellReuseIdentifier:SingleCellIdentifier];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self registerNibs];
	
	[self.tableView setDataSource:self];
	[self.tableView setDelegate:self];
	
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"table_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 192, 0)]]];
	
	NSIndexPath *initialPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:initialPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [[self detailController] setTitle:[self tripNameForRowAtIndexPath:initialPath]];
}

- (NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//	number of rows in the table view (we only have 1 section)
	NSInteger rowCount			= [self tableView:self.tableView numberOfRowsInSection:0];
	//	the row index we have to determine the reuse identifier for
	NSInteger rowIndex			= indexPath.row;
	
	if (rowCount == 1)
		return SingleCellIdentifier;
	else if (rowIndex == 0)
		return TopCellIdentifier;
	else if (rowIndex == (rowCount - 1))
		return BottomCellIdentifier;
	else
		return MiddleCellIdentifier;
}

- (UIImage *)backgroundImageForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuseID			= [self reuseIdentifierForRowAtIndexPath:indexPath];
	
	if ([reuseID isEqualToString:SingleCellIdentifier])
		return [[UIImage imageNamed:@"cell_single"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 43.0, 0.0, 64.0)];
	else if ([reuseID isEqualToString:TopCellIdentifier])
		return [[UIImage imageNamed:@"cell_top"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 43.0, 0.0, 64.0)];
	else if ([reuseID isEqualToString:BottomCellIdentifier])
		return [[UIImage imageNamed:@"cell_bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 34.0, 0.0, 35.0)];
	else
		return [[UIImage imageNamed:@"cell_middle"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 30.0)];
}

- (UIImage *)selectedBackgroundImageForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuseID			= [self reuseIdentifierForRowAtIndexPath:indexPath];
	
	if ([reuseID isEqualToString:SingleCellIdentifier])
		return [[UIImage imageNamed:@"cell_single_sel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 43.0, 0.0, 64.0)];
	else if ([reuseID isEqualToString:TopCellIdentifier])
		return [[UIImage imageNamed:@"cell_top_sel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 43.0, 0.0, 64.0)];
	else if ([reuseID isEqualToString:BottomCellIdentifier])
		return [[UIImage imageNamed:@"cell_bottom_sel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 34.0, 0.0, 35.0)];
	else
		return [[UIImage imageNamed:@"cell_middle_sel"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 30.0, 0.0, 30.0)];
}

- (void)configureCell:(CustomCell *)cell
	forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[cell.tripPhoto setImage:[self tripPhotoForRowAtIndexPath:indexPath]];
	[cell.tripName setText:[self tripNameForRowAtIndexPath:indexPath]];
	
	CGRect cellRect						= cell.frame;
	
	UIImageView *backgroundView			= [[UIImageView alloc] initWithFrame:cellRect];
	UIImageView *selectedBackgroundView	= [[UIImageView alloc] initWithFrame:cellRect];
	backgroundView.image				= [self backgroundImageForRowAtIndexPath:indexPath];
	selectedBackgroundView.image		= [self selectedBackgroundImageForRowAtIndexPath:indexPath];
	[cell setBackgroundView:backgroundView];
	[cell setSelectedBackgroundView:selectedBackgroundView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self reuseIdentifierForRowAtIndexPath:indexPath];
	
	NSLog(@"Cell Identifier: %@", CellIdentifier);
	
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	[self configureCell:(CustomCell *)cell forRowAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[[self navigationController] pushViewController:[self sharedAppDelegate].tabController animated:YES];
	}
	else
		self.detailController.navigationItem.title	= [self tripNameForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:[self tableView] cellForRowAtIndexPath:indexPath];
    return [cell frame].size.height;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
