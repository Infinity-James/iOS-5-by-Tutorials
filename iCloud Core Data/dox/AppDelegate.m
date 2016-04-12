//
//  SMAppDelegate.m
//  dox
//
//  Created by cesarerocchi Rocchi on 10/11/11.
//  Copyright (c) 2011 studiomagnolia.com. All rights reserved.
//

#import "AppDelegate.h"
#import "NoteListController.h"
#import "NoteController.h"

#define UbiquitousStoreIdentifier		@"com.andbeyond.jamesvalaitis.coredata.notes"

@implementation AppDelegate

@synthesize managedObjectContext		= _managedObjectContext;
@synthesize managedObjectModel			= _managedObjectModel;
@synthesize persistentStoreCoodinator	= _persistentStoreCoodinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window						= [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NoteListController *masterViewController;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        masterViewController		= [[NoteListController alloc] initWithNibName:@"NoteListView_iPhone" bundle:nil];
        
    else 
        masterViewController		= [[NoteListController alloc] initWithNibName:@"NoteListView_iPad" bundle:nil];
	
	[masterViewController setManagedObjectContext:self.managedObjectContext];
    
    self.navigationController		= [[UINavigationController alloc] initWithRootViewController:masterViewController];
    self.window.rootViewController	= self.navigationController;
    
    [self.window makeKeyAndVisible];
	
    return YES;
}

#pragma mark - Setter & Getter Methods

- (NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext)
		return _managedObjectContext;
	
	if (self.persistentStoreCoodinator)
	{
		//	initialise the context to be bound to the main thread meaning all code executed by it is performed there
		_managedObjectContext		= [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		
		//	configure context properties asynchronously
		[_managedObjectContext performBlockAndWait:
		^{
			[_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoodinator];
			
			//	register to be notified when contents of ubiquitous store are imported
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(mergeChangesFromiCloud:)
														 name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
													   object:self.persistentStoreCoodinator];
		}];
	}
	
	return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
	//	if we have already initialised the managed object model, return it
	if (_managedObjectModel)
		return _managedObjectModel;
	
	//	get the file url of the data model
	NSURL *modelURL					= [[NSBundle mainBundle] URLForResource:@"notesModel" withExtension:@"momd"];
	
	//	use it to initialise an object and then return it
	_managedObjectModel				= [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	
	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoodinator
{
	//	if we have already initialised it, return it
	if (_persistentStoreCoodinator)
		return _persistentStoreCoodinator;
	
	//	otherwise we initialise a persistent store coordinator
	_persistentStoreCoodinator		= [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
	^{
		//	create a file url of the sqlite data model
		NSURL *storeURL					= [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iCloud.sqlite"];
		
		//	build the file path to store transaction logs by creating a subdirectory in the app's ubiquity container
		NSFileManager *fileManager		= [NSFileManager defaultManager];
		NSURL *transactionLogsURL		= [[fileManager URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"iCloud_data"];
		
		//	build an options array to use in the persistent store co-ordinator
		NSDictionary *options			= [NSDictionary dictionaryWithObjectsAndKeys:
										   UbiquitousStoreIdentifier, NSPersistentStoreUbiquitousContentNameKey,
										   transactionLogsURL, NSPersistentStoreUbiquitousContentURLKey,
										   [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, nil];
		
		//	for multi-threaded safety we prevent other threads excutions by locking the persistent store coordinator
		[_persistentStoreCoodinator lock];
		
		//	create a persistent store for the coordinator of type sqlite with our url & options - if it fails log it & abort
		NSError *error;
		if (![_persistentStoreCoodinator addPersistentStoreWithType:NSSQLiteStoreType
													  configuration:nil
																URL:storeURL
															options:options
															  error:&error])
		{
			NSLog(@"Core Data error: %@, %@", error, error.userInfo);
			abort();
		}
		
		//	the persistent store coordinator has been created, and so we unlock it
		[_persistentStoreCoodinator unlock];
		
		//	on the main queue we then update the user interface with a notification
		dispatch_async(dispatch_get_main_queue(),
		^{
			NSLog(@"Persistent store coordinator has been correctly initialised");
						   
			[[NSNotificationCenter defaultCenter] postNotificationName:FetchNotesNotification object:self];
		});
		
	});
	
	//	if everything is fine, return the persistent store coordinator
	return _persistentStoreCoodinator;
}

#pragma mark - Action & Selector Methods

- (void)mergeChangesFromiCloud:(NSNotification *)notification
{
	//	perform the method back on the main thread
	[self.managedObjectContext performBlock:
	 ^{
		 [self mergeiCloudChanges:notification forContext:self.managedObjectContext];
	 }];
}

#pragma mark - Helper Methods

- (NSURL *)applicationDocumentsDirectory
{
	return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

- (void)mergeiCloudChanges:(NSNotification *)notification
				forContext:(NSManagedObjectContext *)context
{
	//	updates notified objects as changed, inserted or deleted
	[context mergeChangesFromContextDidSaveNotification:notification];
}

- (void)saveContext
{
	NSError *error;
	
	//	call the save method of the context, and if it goes wrong log and abort
	if (self.managedObjectContext.hasChanges && ![self.managedObjectContext save:&error])
	{
		NSLog(@"Core Data error: %@, %@", error, error.userInfo);
		abort();
	}
}

@end
