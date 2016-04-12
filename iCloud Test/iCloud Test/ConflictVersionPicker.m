//
//  ConflictVersionPicker.m
//  iCloud Test
//
//  Created by James Valaitis on 16/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "ConflictVersionPicker.h"

@implementation ConflictVersionPicker

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title					= @"Pick a Version";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.thisDeviceContentView.text	= self.thisDeviceNoteContent;
	self.otherDeviceContentView.text	= self.otherDeviceNoteContent;
}

#pragma mark - Convenience Methods

- (void)cleanConflicts
{
	NSArray *conflicts			= [NSFileVersion unresolvedConflictVersionsOfItemAtURL:self.note.fileURL];
	
	for (NSFileVersion *conflict in conflicts)
		conflict.resolved		= YES;
	
	NSError *error;
	
	BOOL allCool				= [NSFileVersion removeOtherVersionsOfItemAtURL:self.note.fileURL error:&error];
	
	if (!allCool)
		NSLog(@"Can't remove other versions because of this bloody error: %@", error.localizedDescription);
}

- (void)resolveConflicts
{
	[self cleanConflicts];
	[self.navigationController popViewControllerAnimated:YES];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.andbeyond.jamesvalaitis.conflictResolved" object:self];
}

#pragma mark - Action & Selector Methods

- (IBAction)pickOtherVersion:(id)sender
{
	self.note.noteContent		= self.otherDeviceContentView.text;
	
	[self resolveConflicts];
}

- (IBAction)pickThisVersion:(id)sender
{
	self.note.noteContent		= self.thisDeviceContentView.text;
	
	[self resolveConflicts];
}

@end
