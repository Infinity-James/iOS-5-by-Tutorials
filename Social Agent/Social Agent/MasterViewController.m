//
//  MasterViewController.m
//  Social Agent
//
//  Created by James Valaitis on 09/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "MasterViewController.h"

#define kBackgroundQueue				dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kContactsList					[NSURL URLWithString:@"http://www.touch-code-magazine.com/services/ContactsDemo/"]

@interface MasterViewController ()
{
	NSArray			*_contacts;
}

- (void)importContacts;

@end

@implementation MasterViewController

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title								= @"Social Agent";
		self.tableView.allowsMultipleSelection	= YES;
		
		self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Import Selected"
																				  style:UIBarButtonItemStyleDone
																				 target:self
																				 action:@selector(importContacts)];
		
		//	read the directory
		dispatch_async(kBackgroundQueue,
		^{
			_contacts							= [NSArray arrayWithContentsOfURL:kContactsList];
			
			dispatch_async(dispatch_get_main_queue(),
			^{
				[self.tableView reloadData];
			});
		});
	}
	
	return self;
}

#pragma mark - Convenience Methods

- (void)importContacts
{
	//	get an array of the selected cells index paths
	NSArray *selectedCells				= [self.tableView indexPathsForSelectedRows];
	
	//	if there are no selected cells ther eis no point in continuing
	if (!selectedCells)					return;
	
	//	for every id we append it to the mutable string
	NSMutableString *IDs				= [NSMutableString stringWithString:@""];
	
	for (NSIndexPath *path in selectedCells)
		[IDs appendFormat:@"%i,", path.row];
	
	//	just making sure it is all working as expected
	NSLog(@"Selected: %@", IDs);
	
	dispatch_async(kBackgroundQueue,
	^{
		NSString *request				= [NSString stringWithFormat:@"%@?%@", kContactsList, IDs];
		NSData *responseData			= [NSData dataWithContentsOfURL:[NSURL URLWithString:request]];
		
		NSLog(@"Request for contact data: %@", request);
		
		CFErrorRef *error				= NULL;
		
		//	pget an instance of the address book
		ABAddressBookRef addressBook	= ABAddressBookCreateWithOptions(kNilOptions, error);
		//	create an empty address book record
		ABRecordRef record				= ABPersonCreate();
		
		//	parses vcard data amd returns an nsarray of people
		//	@param	record				the abrecordref to use as a source
		//	@param	responseData		the data of the vcard text for the record
		NSArray *importedPeople			= (__bridge_transfer NSArray *)ABPersonCreatePeopleInSourceWithVCardRepresentation
																						(record, (__bridge CFDataRef)responseData);
		
		//	releases an object retained through the bridge
		CFBridgingRelease(record);
		
		//	define message to display in the alert later on and it will be later used and modified in a block
		__block NSMutableString *message
										= [NSMutableString stringWithString:
										   @"Contacts are imported to your Address Book. Also you can add them in Facebook: "];
		
		//	we want nsstring handle of a few constants to be used later for accessing properties
		NSString *serviceKey			= (NSString *)kABPersonSocialProfileServiceKey;
		NSString *facebookValue			= (NSString *)kABPersonSocialProfileServiceFacebook;
		NSString *usernameKey			= (NSString *)kABPersonSocialProfileUsernameKey;
		
		//	for each person we imported
		for (int i = 0; i < importedPeople.count; i++)
		{
			//	store the current person from the list into the personref
			ABRecordRef personRef		= (__bridge ABRecordRef)[importedPeople objectAtIndex:i];
			//	add that record to the address book
			ABAddressBookAddRecord(addressBook, personRef, error);
			
			//	get the list of their social profiles
			ABMultiValueRef profilesref	= ABRecordCopyValue(personRef, kABPersonSocialProfileProperty);
			//	now get a nice array of all of those profiles
			NSArray *profiles			= (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(profilesref);
			
			//	for each social profile this person has...
			for (NSDictionary *profile in profiles)
			{
				//	store the type of service this is
				NSString *currentServiceValue
										= [profile objectForKey:serviceKey];
				
				//	if this is a facebook profile we add the username to our message string
				if ([facebookValue compare:currentServiceValue] == NSOrderedSame)
					[message appendFormat:@"%@, ", [profile objectForKey:usernameKey]];
			}
			
			//	release the list of social profile to avoid the leaking of memory
			CFBridgingRelease(profilesref);
		}
		
		//	save the address book that we have created to the device's address book
		ABAddressBookSave(addressBook, error);
		//	release the address book
		CFBridgingRelease(addressBook);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[[UIAlertView alloc] initWithTitle:@"Done"
									   message:message
									  delegate:nil
							 cancelButtonTitle:@"Nice One Man"
							 otherButtonTitles:nil, nil] show];
		});
	});
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier		= @"Cell";
	
	UITableViewCell *cell				= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell)
		cell							= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
	NSDictionary *contact				= [_contacts objectAtIndex:indexPath.row];
	
	cell.textLabel.text					= [NSString stringWithFormat:@"%@ %@",
										   [contact objectForKey:@"name"], [contact objectForKey:@"family"]];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return _contacts.count;
}

#pragma mark - UITableViewDelegate Methods

- (void)		tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *selected					= [self.tableView indexPathsForSelectedRows];
	self.title							= [NSString stringWithFormat:@"%i Items Selected", selected.count];
}

- (void)	  tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *selected					= [self.tableView indexPathsForSelectedRows];
	self.title							= [NSString stringWithFormat:@"%i Items Selected", selected.count];
}

@end
