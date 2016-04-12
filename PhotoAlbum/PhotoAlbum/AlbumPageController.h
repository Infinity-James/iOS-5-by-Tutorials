//
//  AlbumPageController.h
//  PhotoAlbum
//
//  Created by James Valaitis on 30/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

// ----------------------------------------------------------------------------------------------------------------
//										Album Page Controller Public Interface
// ----------------------------------------------------------------------------------------------------------------

@interface AlbumPageController : UIViewController

@property (nonatomic, strong)	NSArray					*picturesArray;
@property (nonatomic)			NSUInteger				index;

@end
