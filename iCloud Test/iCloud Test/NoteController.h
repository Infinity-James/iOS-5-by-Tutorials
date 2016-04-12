//
//  ViewController.h
//  iCloud Test
//
//  Created by James Valaitis on 14/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import "Note.h"

@interface NoteController : UIViewController <MFMailComposeViewControllerDelegate,
												UISplitViewControllerDelegate,
													UITextViewDelegate>

@property (nonatomic)					BOOL				isReinstated;
@property (nonatomic, strong)			Note				*note;
@property (nonatomic, strong)			UIBarButtonItem		*reinstateButton;
@property (nonatomic, weak) IBOutlet	UIButton			*undoButton;
@property (nonatomic, weak) IBOutlet	UIButton			*redoButton;
@property (nonatomic, weak) IBOutlet	UITextView			*noteView;

- (NSURL *)	generateExportURL;
- (IBAction)performUndo:(id)sender;
- (IBAction)performRedo:(id)sender;
- (void)	reload;

@end
