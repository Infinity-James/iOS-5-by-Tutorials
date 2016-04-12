//
//  TagWorker.m
//  True Topic
//
//  Created by James Valaitis on 12/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "TagWorker.h"

@implementation TagWorker
{
	NSLinguisticTagger	*_tagger;
	NSMutableArray		*_words;
}

#pragma mark - Custom Methods

- (void)	  get:(int)number
ofRealTopicsAtURL:(NSString *)url
   withCompletion:(TaggingCompletionBlock)completionHandler
{
	//	initialise kinguistic tagger
	_tagger				= [[NSLinguisticTagger alloc]
						   initWithTagSchemes:[NSArray arrayWithObjects:NSLinguisticTagSchemeLexicalClass, NSLinguisticTagSchemeLemma, nil]
									  options:kNilOptions];
	
	_words				= [NSMutableArray arrayWithCapacity:1000];
	
	//	get the text from the web page
	NSString *text		= [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:NULL];
	
	//	list of regexes to clean up html content
	NSArray *cleanup	= [NSArray arrayWithObjects:@"\\A.*?<body.*?>", @"</body>.*?\\Z", @"<[^>]+>", @"\\W+$", nil];
	
	//	run the regexes to extract the pure text
	for (NSString *regexString in cleanup)
	{
		NSRegularExpression *regex	= [NSRegularExpression regularExpressionWithPattern:regexString
																			    options:NSRegularExpressionDotMatchesLineSeparators
																				  error:NULL];
		
		text					= [regex stringByReplacingMatchesInString:text
																  options:NSRegularExpressionDotMatchesLineSeparators
																	range:NSMakeRange(0, text.length)
															 withTemplate:@""];
	}
	
	//	add an aritificial end of the text
	text						= [text stringByAppendingString:@"\nSTOP."];
	
	//	put the text into the tagger
	[_tagger setString:text];
	
	//	get the tags out of the text
	[_tagger enumerateTagsInRange:NSMakeRange(0, text.length)
						   scheme:NSLinguisticTagSchemeLexicalClass
						  options:NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames |NSLinguisticTaggerOmitOther
					   usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop)
	{
		//	check for just nouns
		if ([tag isEqualToString:NSLinguisticTagNoun])
		{
			WordCount *word		= [WordCount wordWithString:[text substringWithRange:tokenRange]];
			
			double index		= [_words indexOfObject:word];
			
			//	if it's an existing word, we just increase the count
			if (index != NSNotFound)
				((WordCount *)[_words objectAtIndex:index]).count++;
			//	otherwise we add it to the list
			else
				[_words addObject:word];
		}
		
		if (text.length == sentenceRange.location + sentenceRange.length)
		{
			*stop				= YES;
			
			[_words sortUsingSelector:@selector(compare:)];
			
			NSRange resultRange	= NSMakeRange(0, (number < _words.count) ? number : _words.count);
			
			completionHandler([_words subarrayWithRange:resultRange]);
		}
	}];
}

@end
