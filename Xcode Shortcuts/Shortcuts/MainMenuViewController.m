//
//  MainMenuViewController.m
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

#import "MainMenuViewController.h"
#import "DictionaryViewController.h"
#import "SearchableShortcutsViewController.h"
#import "ShortcutsDatabase.h"
#import "FavoritesViewController.h"
#import "SettingsViewController.h"
#import "ShortcutsDatabase.h"

typedef enum {
    kRowMenus = 0,
    kRowKeys,
    kRowAll,
    kRowFavorites,
    kRowSettings,
    kNumRows
} RowTypes;

@implementation MainMenuViewController
@synthesize tableView = _tableView;
@synthesize imageView = _imageView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageView.image = [[UIImage imageNamed:@"tv_stretch"] resizableImageWithCapInsets:UIEdgeInsetsMake(53, 12, 53, 12)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_mainmenu"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = imageView;
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
    [self setTableView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{    
    [_tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return kNumRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont fontWithName:@"Courier" size:18.0];
    }
    
    switch (indexPath.row) {
        case kRowKeys:
            cell.textLabel.text = @"Shortcuts by Key";
            break;
        case kRowMenus:
            cell.textLabel.text = @"Shortcuts by Menu";
            break;
        case kRowAll:
            cell.textLabel.text = @"All Shortcuts";
            break;
        case kRowFavorites:
            cell.textLabel.text = @"Favorites";
            break;
        case kRowSettings:
            cell.textLabel.text = @"Settings";
            break;
        default:
            break;
    }    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[ShortcutsDatabase sharedDatabase] playClick];
    switch (indexPath.row) {
        case kRowMenus: 
            if (_menusViewController == nil) {
                _menusViewController = [[DictionaryViewController alloc] initWithNibName:nil bundle:nil];
                _menusViewController.navigationItem.title = @"Menus";
                _menusViewController.dict =  [ShortcutsDatabase sharedDatabase].shortcutsByMenu;
            }
            [self.navigationController pushViewController:_menusViewController animated:YES];
            break;            
        case kRowKeys:
            if (_keysViewController == nil) {
                _keysViewController = [[DictionaryViewController alloc] initWithNibName:nil bundle:nil];
                _keysViewController.navigationItem.title = @"Keys";
                _keysViewController.dict =  [ShortcutsDatabase sharedDatabase].shortcutsByKey;
            }
            [self.navigationController pushViewController:_keysViewController animated:YES];
            break;            
        case kRowAll:
            if (_allViewController == nil) {
                _allViewController = [[SearchableShortcutsViewController alloc] initWithNibName:nil bundle:nil];
                _allViewController.navigationItem.title = @"All Shortcuts";
                _allViewController.shortcutsDict = [ShortcutsDatabase sharedDatabase].shortcutsByKey;    
            }
            [self.navigationController pushViewController:_allViewController animated:YES];
            break;
        case kRowFavorites:
            if (_favoritesViewController == nil) {
                _favoritesViewController = [[FavoritesViewController alloc] initWithNibName:nil bundle:nil];
                _favoritesViewController.navigationItem.title = @"Favorites";
            }
            [self.navigationController pushViewController:_favoritesViewController animated:YES];
            break;
        case kRowSettings:
            if (_settingsViewController == nil) {
                _settingsViewController = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
                _settingsViewController.navigationItem.title = @"Settings";
            }
            [self.navigationController pushViewController:_settingsViewController animated:YES];
            break;
        default:
            break;
    } 
}

@end
