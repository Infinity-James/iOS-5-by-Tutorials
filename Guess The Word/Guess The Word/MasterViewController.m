//
//  MasterViewController.m
//  Guess The Word
//
//  Created by James Valaitis on 08/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "MasterViewController.h"

#define kCellIdentifier			@"MyGreatCell"
#define kCellTitleTag			20

@interface MasterViewController ()
{
    int			_currentWord;
}

@property (nonatomic, strong)	NSArray	*objects;
@property (nonatomic, strong)	NSArray	*answers;

@end

@implementation MasterViewController

#pragma mark - View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title				= @"Guess the Word";
		
		self.objects			= [NSArray arrayWithObjects:@"backpack", @"banana", @"hat", @"pineapple", nil];
		
		self.answers			= [NSArray arrayWithObjects:
								   [NSArray arrayWithObjects:@"backpack", @"bag", @"chair", nil],
								   [NSArray arrayWithObjects:@"orange", @"banana", @"strawberry", nil],
								   [NSArray arrayWithObjects:@"hat", @"head", @"hut", nil],
								   [NSArray arrayWithObjects:@"apple", @"poppler", @"pineapple", nil], nil];
		
		_currentWord			= 0;
		
		[self.tableView registerNib:[UINib nibWithNibName:@"MyCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellIdentifier];
	}
	
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

#pragma mark - Convenience Methods

- (void)showDefinition:(NSString *)word
{
	UIReferenceLibraryViewController *dictionaryView;
	dictionaryView				= [[UIReferenceLibraryViewController alloc] initWithTerm:word];
	
	[self presentViewController:dictionaryView animated:YES completion:NULL];
	
	if (_currentWord + 1 < self.objects.count)
		_currentWord++;
	else
		_currentWord			= 0;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//	1 question
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell		= [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	UILabel *cellLabel			= (UILabel *)[cell viewWithTag:kCellTitleTag];
	
	cellLabel.text				= [(NSArray *)[self.answers objectAtIndex:_currentWord] objectAtIndex:indexPath.row];
	cellLabel.textColor			= [UIColor whiteColor];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	//	image is 150 px high
	return 150.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//	3 possible answers
	return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSString *imageName			= [NSString stringWithFormat:@"object_%@", [self.objects objectAtIndex:_currentWord]];
	
	UIImageView *image			= [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	
	image.frame					= CGRectMake(0, 0, 150, 150);
	image.contentMode			= UIViewContentModeScaleAspectFit;
	
	return image;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *word				= [self.objects objectAtIndex:_currentWord];
	
	UITableViewCell *cell		= [tableView cellForRowAtIndexPath:indexPath];
	
	[cell setSelected:NO];
	
	UILabel *cellLabel			= (UILabel *)[cell viewWithTag:kCellTitleTag];
	
	if ([word compare:cellLabel.text] == NSOrderedSame)
		cellLabel.textColor		= [UIColor greenColor];
	else
		cellLabel.textColor		= [UIColor redColor];
	
	[self performSelector:@selector(showDefinition:) withObject:cellLabel.text afterDelay:1.5];
}

@end
