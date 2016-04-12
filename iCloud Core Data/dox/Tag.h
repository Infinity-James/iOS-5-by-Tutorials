//
//  Tag.h
//  iCloud Core Data
//
//  Created by James Valaitis on 20/11/2012.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * tagContent;
@property (nonatomic, retain) NSSet *notes;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
