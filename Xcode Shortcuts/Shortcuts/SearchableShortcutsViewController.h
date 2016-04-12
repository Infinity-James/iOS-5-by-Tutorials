//
//  SearchableShortcutsViewController.h
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

#import <UIKit/UIKit.h>

@interface SearchableShortcutsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate> {
    NSMutableDictionary * _shortcutsDict;
    NSMutableArray * _searchResults;
    NSString * _savedSearchTerm;
    NSMutableArray * _shortcuts;
}

@property (strong) NSMutableDictionary * shortcutsDict;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSMutableArray * searchResults;
@property (copy) NSString * savedSearchTerm;
@property (strong) NSMutableArray * shortcuts;

- (void)handleSearchForTerm:(NSString *)searchTerm;

@end
