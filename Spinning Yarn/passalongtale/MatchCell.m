//
//  MatchCell.m
//  Spinning Yarn
//
//  Created by James Valaitis on 06/11/2012.
//
//

#import "MatchCell.h"
#import "GCTurnBasedMatchHelper.h"

@implementation MatchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)loadGame:(id)sender
{
	[self.delegate loadAMatch:self.match];
}

- (IBAction)quitGame:(id)sender
{
	//	get a handle to the button
	UIButton *quitButton					= (UIButton *)sender;
	
	//	if the button is currently set to 'remove' we'll do exactly that
	if ([quitButton.titleLabel.text isEqualToString:@"Remove"])
	{
		NSLog(@"Removing the match: %@", self.match);
		[self.match removeWithCompletionHandler:^(NSError *error)
		{
			if (error)
				NSLog(@"Error removing the match: %@", error);
			[self.delegate reloadTableView];
		}];
		 
		return;
	}
	
	//	if we quit whilst it's our turn, handle appropriately
	if ([self.match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
		[[GCTurnBasedMatchHelper sharedInstance] turnBasedMatchmakerViewController:nil
																playerQuitForMatch:self.match];
	
	//	otherwise if we quit whilst it's not our turn
	else
	{
		[self.match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit
								  withCompletionHandler:^(NSError *error)
		{
			if (error)
				NSLog(@"Error quitting match out of turn: %@", error);
		}];
	}
	
	int participantsStillActive				= 0;
	
	//	we count all of the participants still in the game
	for (GKTurnBasedParticipant *participant in self.match.participants)
		if (participant.matchOutcome == GKTurnBasedMatchOutcomeNone)
			participantsStillActive++;
	
	//	if there are less than two active pariticipants
	if (participantsStillActive < 2)
	{
		//	for each participant, if one hasn't quit, we assign their outcome to tied
		for (GKTurnBasedParticipant *participant in self.match.participants)
			if (participant.matchOutcome == GKTurnBasedMatchOutcomeNone)
				participant.matchOutcome	= GKTurnBasedMatchOutcomeTied;
	
		
		//	end the turn
		[self.match endMatchInTurnWithMatchData:self.match.matchData completionHandler:^(NSError *error)
		{
			if (error)
				NSLog(@"Error ending the match: %@", error);
		}];
	}
	
	//	reload the table view now that one game has been quit
	[self.delegate reloadTableView];
}
@end
