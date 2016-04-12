//
//  ShortcutsViewController.m
//  Shortcuts
//
//  Created by Ray Wenderlich on 9/23/11.
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

#import "ShortcutsViewController.h"
#import "Shortcut.h"
#import "ShortcutsDatabase.h"

@implementation ShortcutsViewController
@synthesize shortcuts = _shortcuts;
@synthesize imageView = _imageView;
@synthesize tableView = _tableView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageView.image = [[UIImage imageNamed:@"tv_stretch"] resizableImageWithCapInsets:UIEdgeInsetsMake(53, 12, 53, 12)];
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(handleBack:)];
}

- (void) handleBack:(id)sender
{
    [[ShortcutsDatabase sharedDatabase] playClick];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[ShortcutsDatabase sharedDatabase] playClick];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _shortcuts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
        //cell.textLabel.textColor = [UIColor colorWithRed:63.0/255.0 green:75.0/255.0 blue:77.0/255.0 alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Courier" size:18.0];
        cell.detailTextLabel.minimumScaleFactor = 0.6;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    Shortcut * shortcut = [_shortcuts objectAtIndex:indexPath.row];
    cell.textLabel.text = shortcut.keystroke;
    cell.detailTextLabel.text = shortcut.action;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Shortcut * shortcut = [_shortcuts objectAtIndex:indexPath.row];
    [[ShortcutsDatabase sharedDatabase] addFavorite:shortcut];
}

@end
