//
//  NoteDetailController.h
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

// ----------------------------------------------------------------------------------------------------------------
//									Note Detail Controller Public Interface
// ----------------------------------------------------------------------------------------------------------------

@interface NoteDetailController : UIViewController <UITextViewDelegate>

@property									BOOL				isChanged;
@property	(nonatomic, strong) IBOutlet	UITextView			*noteTextView;

@end
