//
//  FavoritesViewController.m
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

#import "FavoritesViewController.h"
#import "ShortcutsDatabase.h"
#import "Shortcut.h"
#import "UserData.h"

#define MARGIN 10

@implementation FavoritesViewController
@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;

#pragma mark - View lifecycle

- (void)addLabelForFavorite:(Shortcut *)favorite {
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont fontWithName:@"Courier" size:_fontSize];
    label.backgroundColor = [UIColor grayColor];
    label.textColor = [UIColor whiteColor];
    label.text = favorite.description;
    label.userInteractionEnabled = YES;
    [label sizeToFit];
    [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)]];
    [_labels addObject:label];            
    [_scrollView addSubview:label];
}

- (void)refreshLabels {
    for (int i = _labels.count - 1; i >= 0; --i) {
        UILabel * label = [_labels objectAtIndex:i];
        [label removeFromSuperview];        
        [_labels removeObjectAtIndex:i];
    }
    
    NSMutableArray * favorites = [ShortcutsDatabase sharedDatabase].userData.favorites;
    for (int i = 0; i < favorites.count; ++i) {        
        Shortcut * favorite = [favorites objectAtIndex:i];
        [self addLabelForFavorite:favorite];
    }
    
}

- (void)refreshLayout {        
    
    float curX = 0 + MARGIN;
    float curY = 0 + MARGIN;
    float maxY = 0;
    
    for (UILabel * label in _labels) {
        
        if (curX + label.frame.size.width > self.view.bounds.size.width) {
            curX = 0 + MARGIN;
            curY = maxY + MARGIN;
            maxY = curY;
        }
        
        CGRect frame = label.frame;
        frame.origin.x = curX;
        frame.origin.y = curY;
        label.frame = frame;
        
        curX += frame.size.width + MARGIN;
        maxY = MAX(maxY, curY + frame.size.height);        
        
    }
    
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, maxY + MARGIN);
    
}

- (void)viewWillAppear:(BOOL)animated {
    _fontSize = [ShortcutsDatabase sharedDatabase].userData.favoritesFontSize;
    [self refreshLabels];
    [self refreshLayout];
}

- (void)favoriteAdded:(NSNotification *)notification {    
    [self addLabelForFavorite:notification.object];
    [UIView animateWithDuration:0.25 animations:^{
        [self refreshLayout];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView animateWithDuration:0.25 animations:^{
        [self refreshLayout];
    }];
}

- (void)labelTapped:(UITapGestureRecognizer *)recognizer {
    [[ShortcutsDatabase sharedDatabase] playRustle];
    
    UILabel * label = (UILabel *) recognizer.view;
    [UIView animateWithDuration:0.25 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
        int i = [_labels indexOfObject:label];
        [[ShortcutsDatabase sharedDatabase].userData.favorites removeObjectAtIndex:i];
        [_labels removeObjectAtIndex:i];
        [UIView animateWithDuration:0.25 animations:^{
            [self refreshLayout];
        }];
    }];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _labels = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoriteAdded:) name:@"AddFavorite" object:nil];
    _imageView.image = [[UIImage imageNamed:@"border_stretch"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
}

- (void)viewDidUnload
{
    _labels = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setImageView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
