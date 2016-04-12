//
//  NoteListController.h
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface NoteListController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic)			BOOL				useiCloud;
@property (nonatomic, strong)	NSMutableArray		*notes;
@property (nonatomic, strong)	UISwitch			*iCloudSwitch;

- (void)loadNotes;

@end
