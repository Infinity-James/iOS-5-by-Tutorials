//
//  ConflictVersionPicker.h
//  iCloud Test
//
//  Created by James Valaitis on 16/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface ConflictVersionPicker : UIViewController

@property (nonatomic, weak) IBOutlet	UITextView	*thisDeviceContentView;
@property (nonatomic, weak) IBOutlet	UITextView	*otherDeviceContentView;

@property (nonatomic, strong)			NSString	*thisDeviceNoteContent;
@property (nonatomic, strong)			NSString	*otherDeviceNoteContent;

@property (nonatomic, strong)			Note		*note;

- (void)	cleanConflicts;
- (IBAction)pickThisVersion:	(id)	sender;
- (IBAction)pickOtherVersion:	(id)	sender;

@end
