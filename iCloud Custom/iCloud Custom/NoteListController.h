//
//  ViewController.h
//  iCloud Custom
//
//  Created by James Valaitis on 15/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "Note.h"
#import "NotesDocument.h"

@class NoteController;

@interface NoteListController : UITableViewController

@property (nonatomic, strong)		NoteController		*noteController;
@property (nonatomic, strong)		NotesDocument		*notesDocument;

- (void)	loadNotes;
- (void)	loadData:	(NSMetadataQuery *)	query;

@end
