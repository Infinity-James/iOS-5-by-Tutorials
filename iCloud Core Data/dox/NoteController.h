//
//  SMNoteViewController.h
//  dox
//
//  Created by cesarerocchi Rocchi on 10/11/11.
//  Copyright (c) 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface NoteController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong)			Note		*currentNote;
@property (nonatomic)					BOOL		isChanged;
@property (nonatomic, strong) IBOutlet	UITextView	*noteContentView;
@property (nonatomic, strong) IBOutlet	UILabel		*tagsLabel;



@end
