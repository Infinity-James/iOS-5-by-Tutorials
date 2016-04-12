//
//  MasterViewController.m
//  True Topic
//
//  Created by James Valaitis on 12/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "ArticleData.h"
#import "MasterViewController.h"
#import "RXMLElement.h"
#import "TagWorker.h"
#import "WordCount.h"

#define kBackgroundQueue			dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kRSSURL						[NSURL URLWithString:@"http://feeds.feedburner.com/RayWenderlich"]

@implementation MasterViewController
{
	NSMutableArray					*_articles;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_articles						= [NSMutableArray array];
	
	//	get rss items in background
	dispatch_async(kBackgroundQueue,
	^{
		RXMLElement *xml			= [RXMLElement elementFromURL:kRSSURL];
		NSArray *items				= [[xml child:@"channel"] children:@"item"];
		
		//	iterate through articles
		for (RXMLElement *element in items)
		{
			ArticleData *article	= [[ArticleData alloc] init];
			article.title			= [[element child:@"title"] text];
			article.link			= [[element child:@"link"] text];
			[_articles addObject:article];
		}
		
		for (ArticleData *article in _articles)
		{
			TagWorker *worker		= [[TagWorker alloc] init];
			
			[worker get:5 ofRealTopicsAtURL:article.link withCompletion:^(NSArray *words)
			{
				article.topic		= [words componentsJoinedByString:@" "];
				
				//	on the main queue we reload the table with the new data
				dispatch_async(dispatch_get_main_queue(),
				^{
					[self.tableView reloadData];
				});
			}];
		}
		
		//	on the main queue we reload the table with the new data
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self.tableView reloadData];
		});
	});
}

#pragma mark - UITableViewDataSource Methods

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier	= @"Cell";
	UITableViewCell *cell			= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell)
	{
		cell						= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType			= UITableViewCellAccessoryDisclosureIndicator;
	}
	
	//	fill in the artcile data
	ArticleData *article			= [_articles objectAtIndex:indexPath.row];
	cell.textLabel.text				= article.title;
	cell.detailTextLabel.text		= article.topic;
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
	return _articles.count;
}

@end
