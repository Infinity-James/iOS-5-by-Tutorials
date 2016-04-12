//
//  NotesDocument.h
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

// ----------------------------------------------------------------------------------------------------------------
//											Notes Document Public Interface
// ----------------------------------------------------------------------------------------------------------------

@interface NotesDocument : UIDocument

@property	(nonatomic, strong)				NSMutableArray		*entries;
@property	(nonatomic, strong)				NSFileWrapper		*fileWrapper;

- (void)		addNote:			(Note *)		note;
- (NSInteger)	count;
- (void)		deleteNoteAtIndex:	(NSInteger)		index;
- (Note *)		entryAtIndex:		(NSUInteger)	index;
- (Note *)		noteByID:			(NSString *)	noteID;

@end
