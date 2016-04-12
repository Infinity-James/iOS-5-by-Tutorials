//
//  ShortcutsDatabase.m
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

#import "ShortcutsDatabase.h"
#import "Shortcut.h"
#import "UserData.h"

@implementation ShortcutsDatabase
@synthesize shortcutsByMenu = _shortcutsByMenu;
@synthesize shortcutsByKey = _shortcutsByKey;
@synthesize userData = _userData;
@synthesize menusArray = _menusArray;

static ShortcutsDatabase * g_database;

+ (ShortcutsDatabase *) sharedDatabase {
    if (!g_database) {
        g_database = [[ShortcutsDatabase alloc] init];        
    }
    return g_database;
}

- (void)loadShortcuts {
    
    // Read Shortcuts.plist
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Shortcuts" ofType:@"plist"];
    NSDictionary * plistAsDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSAssert(plistAsDict != nil, @"Couldn't load Shortcuts.plist!");
    
    // Parse root keys
    self.menusArray = [plistAsDict objectForKey:@"Menus"];
    NSAssert(_menusArray != nil, @"Couldn't load Menus entry!");    
    NSArray * keysArray = [plistAsDict objectForKey:@"Keys"];
    NSAssert(keysArray != nil, @"Couldn't load Keys entry!");
    
    // Create shortcutsByMenu
    _shortcutsByMenu = [NSMutableDictionary dictionary];
    for (NSString * menuName in _menusArray) {        
        NSMutableArray * menu = [NSMutableArray array];
        [_shortcutsByMenu setObject:menu forKey:menuName]; 
    }
    
    // Create shortcutsByKey
    _shortcutsByKey = [NSMutableDictionary dictionary];
    
    // Loop through all keys
    for (NSDictionary * keyDict in keysArray) {
        
        // Parse dictionary
        NSString * key = [keyDict objectForKey:@"key"];
        NSString * action = [keyDict objectForKey:@"action"];
        NSString * menuName = [keyDict objectForKey:@"menu"];
        NSAssert(key != nil, @"Missing key entry!");
        NSAssert(action != nil, @"Missing action entry!");
        
        // Create shortcut
        Shortcut * shortcut = [[Shortcut alloc] initWithKeystroke:key action:action];
        
        // Add to shortcutsByMenu
        if (menuName != nil && menuName.length > 0) {
            NSMutableArray * menu = [_shortcutsByMenu objectForKey:menuName];
            NSAssert(menu != nil, @"Invalid menu name");            
            [menu addObject:shortcut];
        }
        
        // Add to shortcutsByKey
        NSMutableArray * keys = [_shortcutsByKey objectForKey:shortcut.key];
        if (keys == nil) {
            keys = [NSMutableArray array];
            [_shortcutsByKey setObject:keys forKey:shortcut.key];
        }
        [keys addObject:shortcut];
        
    }
    
}

- (NSString *)userDataPath {
    NSArray * docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * docDir = [docDirs objectAtIndex:0];
    NSString * userDataPath = [docDir stringByAppendingPathComponent:@"userData.plist"];
    return userDataPath;
}

- (void)loadUserData {
    
    NSString * userDataPath = [self userDataPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:userDataPath]) {
        NSData * userDataData = [NSData dataWithContentsOfFile:userDataPath];
        _userData = [NSKeyedUnarchiver unarchiveObjectWithData:userDataData];
    } else {
        _userData = [[UserData alloc] initWithFavorites:[NSMutableArray array] favoritesFontSize:16.0];
    }
    
}

- (void)loadSounds {
    NSString *clickPath = [[NSBundle mainBundle] pathForResource:@"click10" ofType:@"wav"];
    NSURL *clickURL = [NSURL fileURLWithPath:clickPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)clickURL, &_clickSound);
    
    NSString *paperPath = [[NSBundle mainBundle] pathForResource:@"paper4" ofType:@"wav"];
    NSURL *paperURL = [NSURL fileURLWithPath:paperPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)paperURL, &_paperSound);
    
    NSString *rustlePath = [[NSBundle mainBundle] pathForResource:@"rustle4" ofType:@"wav"];
    NSURL *rustleURL = [NSURL fileURLWithPath:rustlePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)rustleURL, &_rustleSound);
}

- (void)saveUserData {
    NSString * userDataPath = [self userDataPath];
    NSData * userDataData = [NSKeyedArchiver archivedDataWithRootObject:_userData];
    [userDataData writeToFile:userDataPath atomically:YES];
}

- (BOOL)addFavorite:(Shortcut *)favorite {
    if (![_userData.favorites containsObject:favorite]) {
        [self playPaper];
        [_userData.favorites addObject:favorite];
        [self saveUserData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddFavorite" object:favorite];
        return TRUE;
    } else {
        [self playClick];
        return FALSE;
    }
}

- (void)removeFavorite:(Shortcut *)favorite {
    [_userData.favorites removeObject:favorite];
    [self saveUserData];
}

- (void)setFavoritesFontSize:(float)fontSize {
    _userData.favoritesFontSize = fontSize;
    [self saveUserData];
}

- (id)init {
    if ((self = [super init])) {
        [self loadShortcuts];
        [self loadUserData];
        [self loadSounds];
    }
    return self;
}

- (void)playClick {
    AudioServicesPlaySystemSound(_clickSound);
}

- (void)playPaper {
    AudioServicesPlaySystemSound(_paperSound);
}

- (void)playRustle {
    AudioServicesPlaySystemSound(_rustleSound);
}

@end
