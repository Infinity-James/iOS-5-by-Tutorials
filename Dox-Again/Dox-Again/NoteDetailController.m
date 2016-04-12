//
//  NoteDetailController.m
//  Dox-Again
//
//  Created by James Valaitis on 24/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "NoteDetailController.h"

// ----------------------------------------------------------------------------------------------------------------
//									Note Detail Controller Private Interface
// ----------------------------------------------------------------------------------------------------------------

@interface NoteDetailController ()

@end

// ----------------------------------------------------------------------------------------------------------------
//									Note Detail Controller Implementation
// ----------------------------------------------------------------------------------------------------------------

@implementation NoteDetailController

#pragma mark - View Lifecycle

/**
 *	message received when there is low memory
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 *	called when controller's view is loaded into memory
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//	set ourselves as the text view delegate
	[self.noteTextView setDelegate:self];
}

@end
