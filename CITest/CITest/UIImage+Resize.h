//
//  NSObject+UIImage_Resize.h
//  CITest
//
//  Created by Jake Gundersen on 10/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (UIImageResize)
- (UIImage*)scaleToSize:(CGSize)size;
@end
