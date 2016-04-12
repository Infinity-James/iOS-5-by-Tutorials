//
//  Shortcut.h
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

@interface Shortcut : NSObject <NSCoding> {
    NSString * _key;
    NSString * _action;
    NSString * _keystroke;
    BOOL _modifierCommand;
    BOOL _modifierOption;
    BOOL _modifierShift;
    BOOL _modifierControl;
}

@property (strong) NSString * key;
@property (strong) NSString * action;
@property (strong) NSString * keystroke;
@property (assign) BOOL modifierCommand;
@property (assign) BOOL modifierOption;
@property (assign) BOOL modifierShift;
@property (assign) BOOL modifierControl;

- (id)initWithKey:(NSString *)key action:(NSString *)action modifierCommand:(BOOL)modifierCommand modifierOption:(BOOL)modifierOption modifierShift:(BOOL)modifierShift modifierControl:(BOOL)modifierControl;
- (id)initWithKeystroke:(NSString *)keystroke action:(NSString *)action;
- (NSString *)keystroke;

- (BOOL)isEqual:(id)object;


@end
