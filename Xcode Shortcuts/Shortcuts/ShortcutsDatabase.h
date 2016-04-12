//
//  ShortcutsDatabase.h
//  Shortcuts
//
//  Created by Ray Wenderlich on 9/21/11.
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

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class Shortcut;
@class UserData;

@interface ShortcutsDatabase : NSObject {
    NSMutableDictionary * _shortcutsByMenu;
    NSMutableDictionary * _shortcutsByKey;
    NSArray * _menusArray;
    UserData * _userData;
    SystemSoundID _clickSound;
    SystemSoundID _paperSound;
    SystemSoundID _rustleSound;
}

@property (strong) NSMutableDictionary * shortcutsByMenu;
@property (strong) NSMutableDictionary * shortcutsByKey;
@property (strong) NSArray * menusArray;
@property (strong) UserData * userData;

+ (ShortcutsDatabase *) sharedDatabase;
- (BOOL)addFavorite:(Shortcut *)favorite;
- (void)removeFavorite:(Shortcut *)favorite;
- (void)setFavoritesFontSize:(float)fontSize;
- (void)playClick;
- (void)playPaper;
- (void)playRustle;

@end
