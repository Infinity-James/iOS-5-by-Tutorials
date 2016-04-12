//
//  Shortcut.m
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

#import "Shortcut.h"

@implementation Shortcut
@synthesize key = _key;
@synthesize action = _action;
@synthesize keystroke = _keystroke;
@synthesize modifierCommand = _modifierCommand;
@synthesize modifierOption = _modifierOption;
@synthesize modifierShift = _modifierShift;
@synthesize modifierControl = _modifierControl;

- (id)initWithKey:(NSString *)key action:(NSString *)action modifierCommand:(BOOL)modifierCommand modifierOption:(BOOL)modifierOption modifierShift:(BOOL)modifierShift modifierControl:(BOOL)modifierControl {
    if ((self = [super init])) {
        self.key = key;
        self.action = action;
        self.modifierCommand = modifierCommand;
        self.modifierOption = modifierOption;
        self.modifierShift = modifierShift;
        self.modifierControl = modifierControl;
        
        // Format keystroke for display
        NSMutableArray * parts = [NSMutableArray array];
        if (_modifierControl) {
            [parts addObject:@"⌃"];
        }
        if (_modifierOption) {
            [parts addObject:@"⌥"];
        }
        if (_modifierShift) {
            [parts addObject:@"⇧"];
        }
        if (_modifierCommand) {
            [parts addObject:@"⌘"];
        }
        [parts addObject:_key];
        self.keystroke = [parts componentsJoinedByString:@""];        
    }
    return self;
}

- (id)initWithKeystroke:(NSString *)keystroke action:(NSString *)action {
    NSArray * splitKeystroke = [keystroke componentsSeparatedByString:@"-"];
    NSAssert(splitKeystroke.count > 0, @"Invalid keystroke");

    NSString * key = [splitKeystroke objectAtIndex:0];
    BOOL modifierCommand = NO;
    BOOL modifierOption = NO;
    BOOL modifierShift = NO;
    BOOL modifierControl = NO;
    for (int i = 1; i < splitKeystroke.count; ++i) {
        NSString * component = [splitKeystroke objectAtIndex:i];
        if ([component compare:@"command" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            modifierCommand = YES;
        } else if ([component compare:@"option" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            modifierOption = YES;
        } else if ([component compare:@"shift" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            modifierShift = YES;
        } else if ([component compare:@"control" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            modifierControl = YES;
        }
    }
    
    return [self initWithKey:key action:action modifierCommand:modifierCommand modifierOption:modifierOption modifierShift:modifierShift modifierControl:modifierControl];    
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", _action, _keystroke];
}

- (NSComparisonResult)compare:(Shortcut *)other {
    return [_action compare:other.action];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        Shortcut * other = (Shortcut *) object;
        return [other.key compare:_key] == NSOrderedSame && other.modifierCommand == _modifierCommand && other.modifierShift == _modifierShift && other.modifierOption == _modifierOption && other.modifierControl == _modifierControl && [other.action compare:_action] == NSOrderedSame;
    }
    return FALSE;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeObject:_action forKey:@"action"];
    [aCoder encodeBool:_modifierCommand forKey:@"modifierCommand"];
    [aCoder encodeBool:_modifierOption forKey:@"modifierOption"];
    [aCoder encodeBool:_modifierShift forKey:@"modifierShift"];
    [aCoder encodeBool:_modifierControl forKey:@"modifierControl"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSString * key = [aDecoder decodeObjectForKey:@"key"];
    NSString * action = [aDecoder decodeObjectForKey:@"action"];
    BOOL modifierCommand = [aDecoder decodeBoolForKey:@"modifierCommand"];
    BOOL modifierOption = [aDecoder decodeBoolForKey:@"modifierOption"];
    BOOL modifierShift = [aDecoder decodeBoolForKey:@"modifierShift"];
    BOOL modifierControl = [aDecoder decodeBoolForKey:@"modifierControl"];
    return [self initWithKey:key action:action modifierCommand:modifierCommand modifierOption:modifierOption modifierShift:modifierShift modifierControl:modifierControl];
}

@end
