//
//  ViewController.h
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface NoteController : UIViewController <UISplitViewControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong)			Note		*note;
@property (nonatomic, weak) IBOutlet	UITextView	*noteView;

- (void)reload;
- (void)saveNote;

@end
