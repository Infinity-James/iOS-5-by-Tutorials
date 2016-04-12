//
//  VersionPickerController.m
//  iCloud Test
//
//  Created by James Valaitis on 16/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "VersionPickerController.h"

@implementation VersionPickerController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title					= @"Pick a Version";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.oldContentView.text	= self.oldNoteContent;
	self.newerContentView.text	= self.newerNoteContent;
}

#pragma mark - Action & Selector Methods

- (IBAction)pickNewVersion:(id)sender
{
	self.note.noteContent		= self.newerContentView.text;
	[self.note updateChangeCount:UIDocumentChangeDone];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pickOldVersion:(id)sender
{
	self.note.noteContent		= self.oldContentView.text;
	[self.note updateChangeCount:UIDocumentChangeDone];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
