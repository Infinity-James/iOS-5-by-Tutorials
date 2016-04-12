//
//  NoteListController.h
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesDocument.h"


// ----------------------------------------------------------------------------------------------------------------
//									Note List Controller Public Interface
// ----------------------------------------------------------------------------------------------------------------

@interface NoteListController : UITableViewController
{
	NSMetadataQuery		*_query;
}

@property	(nonatomic, strong)				NotesDocument		*document;

- (void)	loadNotes;
- (void)	loadData:	(NSMetadataQuery *)	query;

@end
