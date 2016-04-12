//
//  Note.h
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

// ----------------------------------------------------------------------------------------------------------------
//											Note Public Interface
// ----------------------------------------------------------------------------------------------------------------

@interface Note : NSObject <NSCoding>

@property	(nonatomic, copy)			NSString			*noteID;
@property	(nonatomic, copy)			NSString			*noteContent;
@property	(nonatomic, strong)			NSDate				*createdAt;
@property	(nonatomic, strong)			NSDate				*updatedAt;

@end
