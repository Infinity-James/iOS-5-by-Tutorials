//
//  VersionPickerController.h
//  iCloud Test
//
//  Created by James Valaitis on 16/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface VersionPickerController : UIViewController

@property (nonatomic, weak) IBOutlet	UITextView	*oldContentView;
@property (nonatomic, weak) IBOutlet	UITextView	*newerContentView;

@property (nonatomic, strong)			NSString	*oldNoteContent;
@property (nonatomic, strong)			NSString	*newerNoteContent;

@property (nonatomic, strong)			Note		*note;

- (IBAction)pickNewVersion:(id)sender;
- (IBAction)pickOldVersion:(id)sender;

@end
