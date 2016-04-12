//
//  SMAppDelegate.h
//  dox
//
//  Created by cesarerocchi Rocchi on 10/11/11.
//  Copyright (c) 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong, readonly)	NSManagedObjectContext			*managedObjectContext;
@property (nonatomic, strong, readonly)	NSManagedObjectModel			*managedObjectModel;
@property (nonatomic, strong, readonly)	NSPersistentStoreCoordinator	*persistentStoreCoodinator;
@property (nonatomic, strong)			UINavigationController			*navigationController;
@property (nonatomic, strong)			UIWindow						*window;

- (NSURL *)	applicationDocumentsDirectory;
- (void)	mergeiCloudChanges:(NSNotification *)			notification
					forContext:(NSManagedObjectContext *)	context;
- (void)	saveContext;

@end
