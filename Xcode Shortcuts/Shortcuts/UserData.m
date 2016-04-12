//
//  UserData.m
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

#import "UserData.h"

@implementation UserData
@synthesize favorites = _favorites;
@synthesize favoritesFontSize = _favoritesFontSize;

- (id)initWithFavorites:(NSMutableArray *)favorites favoritesFontSize:(float)favoritesFontSize {
    if ((self = [super init])) {
        _favorites = favorites;
        _favoritesFontSize = favoritesFontSize;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_favorites forKey:@"favorites"];
    [aCoder encodeFloat:_favoritesFontSize forKey:@"favoritesFontSize"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSMutableArray * favorites = [aDecoder decodeObjectForKey:@"favorites"];
    float favoritesFontSize = [aDecoder decodeFloatForKey:@"favoritesFontSize"];
    return [self initWithFavorites:favorites favoritesFontSize:favoritesFontSize];
}

@end
