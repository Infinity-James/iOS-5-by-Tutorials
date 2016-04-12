//
//  SMMasterViewController.h
//  dox
//
//  Created by cesarerocchi Rocchi on 10/11/11.
//  Copyright (c) 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "NoteController.h"
#import "Tag.h"

@class NoteController;

@interface NoteListController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong)	NoteController				*detailViewController;
@property (nonatomic, strong)	NSFetchedResultsController	*fetchedResultsController;
@property (nonatomic, strong)	NSManagedObjectContext		*managedObjectContext;
@property (nonatomic, strong)	NSMutableArray				*notes;

@end
