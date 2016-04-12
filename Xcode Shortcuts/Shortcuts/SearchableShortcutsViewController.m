//
//  SearchableShortcutsViewController.m
//  Shortcuts
//
//  Created by Ray Wenderlich on 9/24/11.
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

#import "SearchableShortcutsViewController.h"
#import "Shortcut.h"
#import "ShortcutsDatabase.h"

@implementation SearchableShortcutsViewController
@synthesize shortcutsDict = _shortcutsDict;
@synthesize imageView = _imageView;
@synthesize tableView = _tableView;
@synthesize searchResults = _searchResults;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize shortcuts = _shortcuts;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageView.image = [[UIImage imageNamed:@"tv_stretch"] resizableImageWithCapInsets:UIEdgeInsetsMake(53, 12, 53, 12)];
    if (self.savedSearchTerm) {
        self.searchDisplayController.searchBar.text = self.savedSearchTerm;
    }
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

- (void)viewWillAppear:(BOOL)animated {
    self.shortcuts = [NSMutableArray array];
    [_shortcutsDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        for (Shortcut * shortcut in (NSArray *) obj) {
            [_shortcuts addObject:shortcut];
        }
    }];
    [_shortcuts sortUsingSelector:@selector(compare:)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[ShortcutsDatabase sharedDatabase] playClick];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    self.savedSearchTerm = self.searchDisplayController.searchBar.text;
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _searchResults.count;
    } else {
        return _shortcuts.count;
    }    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Courier" size:14.0];
        cell.textLabel.textColor = [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0];
        cell.textLabel.minimumScaleFactor = 0.7;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;  
        cell.detailTextLabel.font = [UIFont fontWithName:@"Courier" size:18.0];
        cell.detailTextLabel.minimumScaleFactor = 0.6;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;        
    }

    Shortcut * shortcut;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        shortcut = [_searchResults objectAtIndex:indexPath.row];
    } else {
        shortcut = [_shortcuts objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = shortcut.keystroke;
    cell.detailTextLabel.text = shortcut.action;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    Shortcut * shortcut;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        shortcut = [_searchResults objectAtIndex:indexPath.row];
    } else {
        shortcut = [_shortcuts objectAtIndex:indexPath.row];
    }
    [[ShortcutsDatabase sharedDatabase] addFavorite:shortcut];
}

#pragma mark - Search

- (void)handleSearchForTerm:(NSString *)searchTerm {
    self.savedSearchTerm = searchTerm;
        
    if (self.searchResults == nil) {
        self.searchResults = [NSMutableArray array];        
    }
    
    [_searchResults removeAllObjects];
    if (searchTerm.length != 0) {
        for (Shortcut * shortcut in _shortcuts) {
            if ([shortcut.action rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [_searchResults addObject:shortcut];
            }
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self handleSearchForTerm:searchString];    
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self setSavedSearchTerm:nil];	
    [self.tableView reloadData];
}

@end
