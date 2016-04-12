//
//  TagPickerController.h
//  iCloud Core Data
//
//  Created by James Valaitis on 20/11/2012.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "Tag.h"

@interface TagPickerController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong)	Note						*note;
@property (nonatomic, strong)	NSMutableSet				*pickedTags;
@property (nonatomic, strong)	NSFetchedResultsController	*fetchedResultsController;

@end
