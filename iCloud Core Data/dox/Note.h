//
//  Note.h
//  iCloud Core Data
//
//  Created by James Valaitis on 20/11/2012.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * noteContent;
@property (nonatomic, retain) NSString * noteTitle;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
