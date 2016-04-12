//
//  TagWorker.h
//  True Topic
//
//  Created by James Valaitis on 12/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordCount.h"

typedef void (^TaggingCompletionBlock)(NSArray *words);

@interface TagWorker : NSObject

- (void)	  get:(int)						number
ofRealTopicsAtURL:(NSString *)				url
   withCompletion:(TaggingCompletionBlock)	completionHandler;

@end
