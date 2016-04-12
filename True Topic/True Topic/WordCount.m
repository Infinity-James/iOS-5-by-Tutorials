//
//  WordCount.m
//  True Topic
//
//  Created by James Valaitis on 13/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "WordCount.h"

@implementation WordCount

+ (WordCount *)wordWithString:(NSString *)string
{
	WordCount *word			= [[WordCount alloc] init];
	word.word				= string;
	word.count				= 1;
	
	return word;
}

- (NSComparisonResult)compare:(WordCount *)otherObject
{
	return otherObject.count - self.count;
}

- (NSString *)description
{
	return self.word;
}

- (BOOL)isEqual:(id)object
{
	return [self.word isEqualToString:((WordCount *)object).word];
}

@end
