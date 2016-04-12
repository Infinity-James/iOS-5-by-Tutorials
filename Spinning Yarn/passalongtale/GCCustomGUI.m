//
//  GCCustomGUI.m
//  Spinning Yarn
//
//  Created by James Valaitis on 06/11/2012.
//
//

#import <GameKit/GameKit.h>
#import "GCCustomGUI.h"
#import "MatchCell.h"

NSString	*const	CellIdentifier			= @"Match Cell";

@interface GCCustomGUI ()

@end

@implementation GCCustomGUI
{
	NSArray					*_allMyMatches;
}

#pragma mark - View Lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style])
	{
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//	sets some parameters for the table view
	self.tableView.rowHeight				= 220;
	self.tableView.editing					= NO;
	
	//	add the necessary buttons to our view
	[self addButtons];
	
	//	register our cell
	[self.tableView registerNib:[UINib nibWithNibName:@"MatchCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
}

#pragma mark - Action & Selector Methods

/**
 *	adds a new match
 */
- (void)addNewMatch
{
	//	initialise a match request and define it
	GKMatchRequest *request					= [[GKMatchRequest alloc] init];
	request.maxPlayers						= 12;
	request.minPlayers						= 2;
	
	//	use the request to find a match
	[GKTurnBasedMatch findMatchForRequest:request withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error)
	{
		if (error)
			NSLog(@"Error finding a match: %@", error.localizedDescription);
		else
		{
			NSLog(@"Successfully found a match.");
			
			//	dismiss this view controller to show the game
			[self.viewController dismissViewControllerAnimated:YES completion:
			^{
				//	use our helper class to deal with the match we found
				[[GCTurnBasedMatchHelper sharedInstance] turnBasedMatchmakerViewController:nil didFindMatch:match];
			}];
		}
	}];
}

/**
 *	dismisses this view controller
 */
- (void)cancel
{
	//	dismiss the view
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Convenience Methods

/**
 *	adds buttons to the view
 */
- (void)addButtons
{
	//	create a button for adding matches
	UIBarButtonItem *plus					= [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
											   target:self
											   action:@selector(addNewMatch)];
	
	//	create a button for dismissing this view
	UIBarButtonItem *cancel					= [[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
											   target:self
											   action:@selector(cancel)];
	
	//	add the buttons
	self.navigationItem.rightBarButtonItem	= plus;
	self.navigationItem.leftBarButtonItem	= cancel;
	
	//	fetch the matches and reload the table view with them
	[self reloadTableView];
}

/**
 *	returns whether this view has loaded and is being shown
 */
- (BOOL)isVisible
{
	//	only return true if the gui is currently the top view
	return [self isViewLoaded] && self.view.window;
}

#pragma mark - MatchCellDelegate Methods

- (void)loadAMatch:(GKTurnBasedMatch *)match
{
	[self.viewController dismissViewControllerAnimated:YES completion:
	^{
		[[GCTurnBasedMatchHelper sharedInstance] turnBasedMatchmakerViewController:nil didFindMatch:match];
	}];
}

/**
 *	reloads the table view with all of the matches relevent to this player
 */
- (void)reloadTableView
{
	//	load all of the matches
	[GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
	 {
		 //	if there was a problem loading the matches, we log it
		 if (error)
			 NSLog(@"Error loading matches: %@", error);
		 
		 //	if it all went smoothly though
		 else
		 {
			 //	create three arrays for three separate types of matches (this users turn / other users turn / ended matches)
			 NSMutableArray *myMatches		= [NSMutableArray array];
			 NSMutableArray *otherMatches	= [NSMutableArray array];
			 NSMutableArray *endedMatches	= [NSMutableArray array];
			 
			 //	we then iterate through each match
			 for (GKTurnBasedMatch *match in matches)
			 {
				 //	a variable to store our match outcome for each match
				 GKTurnBasedMatchOutcome myOutcome;
				 
				 //	for each participant in the match
				 for (GKTurnBasedParticipant *participant in match.participants)
				 {
					 //	if this is us we take the match outcome
					 if ([participant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
						 myOutcome			= participant.matchOutcome;
				 }
				 
				 NSLog(@"My Outcome: %d For Match: %@", myOutcome, match);
				 
				 //	if the game is not over...
				 if (match.status != GKTurnBasedMatchStatusEnded && myOutcome != GKTurnBasedMatchOutcomeQuit)
				 {
					 //	if it's our turn, we add it to the respective array
					 if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
						 [myMatches addObject:match];
					 
					 //	if it's not our turn, we add it to the 'not our turn' array
					 else
						 [otherMatches addObject:match];
				 }
				 
				 //	if the game is in anyway over, we add it to the ended matches array
				 else
					 [endedMatches addObject:match];
			 }
			 
			 //	store all of the different arrays of matches
			 _allMyMatches					= [[NSArray alloc]
											   initWithObjects:myMatches, otherMatches, endedMatches, nil];
			 
			 //	reload the table with our new data
			 [self.tableView reloadData];
		 }
	 }];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _allMyMatches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//	load our match cell layout
	UITableViewCell *cell					= [tableView dequeueReusableCellWithIdentifier:CellIdentifier
																			  forIndexPath:indexPath];
	
	//	get the relevant match
	GKTurnBasedMatch *match					= [[_allMyMatches objectAtIndex:indexPath.section]
															  objectAtIndex:indexPath.row];
	
	//	cast the cell as a match cell
	MatchCell *matchCell					= (MatchCell *)cell;
	
	//	set ourselves as the delegate for this cell
	[matchCell setDelegate:self];
	
	//	give the match cell it's match
	matchCell.match							= match;
	
	//	if the story is already started we show an excerpt and how long since it started
	if (match.matchData.length > 0)
	{
		//	pass story into cell to display
		matchCell.storyText.text			= [NSString stringWithUTF8String:match.matchData.bytes];
		
		//	get the amount of days it has been since the story was started
		int days							= -floor([match.creationDate timeIntervalSinceNow] / (60 * 60 * 24));
		
		//	use the days to give a status for the match as well as an estimate of the length (about five letters per word)®
		matchCell.statusLabel.text			= [NSString stringWithFormat:@"Story started %d days ago and is about %d words long.",
											   days, matchCell.storyText.text.length / 5];
	}
	
	//	if we are in the game ended section
	if (indexPath.section == 2)
		[matchCell.quitButton setTitle:@"Remove" forState:UIControlStateNormal];
	
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_allMyMatches objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:			return @"My Turn";		break;
		case 1:			return @"Their Turn";	break;
		case 2:			return @"Game Ended";	break;
		default:		return @"Error";		break;
	}
}

#pragma mark - UITableViewDelegate Methods



@end
