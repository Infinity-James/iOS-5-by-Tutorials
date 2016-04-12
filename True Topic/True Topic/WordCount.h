//
//  WordCount.h
//  True Topic
//
//  Created by James Valaitis on 13/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordCount : NSObject

@property (nonatomic, strong)	NSString		*word;
@property						int				count;

+ (WordCount *)wordWithString:	(NSString *)	string;

@end
