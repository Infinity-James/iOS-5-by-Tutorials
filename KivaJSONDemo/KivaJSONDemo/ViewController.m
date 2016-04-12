//
//  ViewController.m
//  KivaJSONDemo
//
//  Created by James Valaitis on 08/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

//	this macro will give us a background queue
#define kBackgroundQueue		dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

//	returns an nsurl pointing us to kiva's list of loans in json format
#define kLatestKivaLoansURL		[NSURL URLWithString:@"http://api.kivaws.org/v1/loans/search.json?status=fundraising"]

#import "NSDictionary+JSON.h"
#import "ViewController.h"

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	dispatch_async(kBackgroundQueue,
	^{
		NSData *data			= [NSData dataWithContentsOfURL:kLatestKivaLoansURL];
		[self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
	});
}

#pragma mark - Convenience Methods

- (void)buildJSONData:(NSDictionary *)json
{
	//	an output error in case something goes wrong whilst creating the data
	NSError *error;
	
	//	store the loans from the json dictionary
	NSArray *latestLoans		= [json objectForKey:@"loans"];
	
	//	get the latest loan
	NSDictionary *loan			= [latestLoans objectAtIndex:0];
	
	//	build an info object to convert to json
	NSDictionary *info			= [NSDictionary dictionaryWithObjectsAndKeys:[loan objectForKey:@"name"], @"who", [(NSDictionary *)[loan objectForKey:@"location"] objectForKey:@"country" ], @"where", [NSNumber numberWithFloat:0.2f], @"what",	nil];
	
	//	convert the object into data
	NSData *jsonData			= [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
	
	//	display the json data we have created
	_jsonSummary.text			= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/**
 *	presents some of the json data in a human readable format
 *
 *	@param	json				a dictionary of json data with which to present
 */
- (void)presentHumanReadable:(NSDictionary *)json
{
	//	store the loans from the json dictionary
	NSArray *latestLoans		= [json objectForKey:@"loans"];
	
	//	get the latest loan
	NSDictionary *loan			= [latestLoans objectAtIndex:0];
	
	//	get the funded and loan amount
	NSNumber *fundedAmount		= [loan objectForKey:@"funded_amount"];
	NSNumber *loanAmount		= [loan objectForKey:@"loan_amount"];
	float outstandingAmount		= loanAmount.floatValue - fundedAmount.floatValue;
	
	//	set the label appropriately
	_humanReadable.text			= [NSString stringWithFormat:@"Latest loan: %@ from %@ needs another $%0.2f until freedom",
								   [loan objectForKey:@"name"],
								   [(NSDictionary *)[loan objectForKey:@"location"] objectForKey:@"country"],
								   outstandingAmount];

}

#pragma mark - Action & Selector Methods

/**
 *	parses the json data we have pulled
 *
 *	@param	responseData		json to parse
 */
- (void)fetchedData:(NSData *)responseData
{
	//	an output error in case something goes wrong whilst parsing
	NSError *error;
	
	//	parse the json data
	NSDictionary *json			= [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
	
	//	if there was an error, log it
	if (error)
		NSLog(@"Error parsing JSON: %@", error.localizedDescription);
	
	[self presentHumanReadable:json];
	
	[self buildJSONData:json];
}

@end
