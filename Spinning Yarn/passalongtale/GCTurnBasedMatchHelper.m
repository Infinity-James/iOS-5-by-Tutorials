//
//  GCTurnBasedMatchHelper.m
//  Spinning Yarn
//
//  Created by James Valaitis on 01/11/2012.
//
//

#import "GCTurnBasedMatchHelper.h"
#import "AppDelegate.h"

@implementation GCTurnBasedMatchHelper

static GCTurnBasedMatchHelper *sharedHelper	= nil;

#pragma mark - Setters & Getters

/**
 *	the check for whether game centre is available
 */
- (BOOL)isGameCentreAvailable
{
	//	check for the presence of gklocalplayer api
	Class gcClass							= (NSClassFromString(@"GKLocalPlayer"));
	
	//	check device running ios 4.1 or later (it must be, because this app requires ios 6)
	NSString *requiresSystemVersion			= @"4.1";
	NSString *currentSystemVersion			= [[UIDevice currentDevice] systemVersion];
	
	BOOL osVersionSupported					= ([currentSystemVersion compare:requiresSystemVersion
																		 options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

#pragma mark - Initialisation

/**
 *	basic initialiser
 */
- (id)init
{
	if (self = [super init])
	{
		//	checks if this device can run game centre
		_gameCentreAvailable				= [self isGameCentreAvailable];
		
		//	if it can we register for authentication change notifications
		if (_gameCentreAvailable)
		{			
			[[NSNotificationCenter defaultCenter] addObserver:self
												     selector:@selector(authenticationChanged)
														 name:GKPlayerAuthenticationDidChangeNotificationName
													   object:nil];
		}
		
		_userAuthenticated						= NO;
	}
	
	return self;
}

/**
 *	a singleton method returning a single instance of this class
 */
+ (GCTurnBasedMatchHelper *)sharedInstance
{
	//	if we have not initialised the singleton instance, we do so, and then return it
	if (!sharedHelper)
		sharedHelper						= [[GCTurnBasedMatchHelper alloc] init];
	
	return sharedHelper;
}

#pragma mark - Actions & Selector Methods

/**
 *	called when authentication has changed
 */
- (void)authenticationChanged
{
	//	if the user logged in successfully we keep track of that
	if ([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated)
	{
		NSLog(@"Authentication Changed - Player Authenticated.");
		_userAuthenticated					= TRUE;
	}
	//	same for if the user did not log in successfully
	else if (![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated)
	{
		NSLog(@"Authentication Changed - Player Is Not Authenticated.");
		_userAuthenticated					= FALSE;
	}
	else
		NSLog(@"Nothing.");
}

#pragma mark - Custom Methods

/**
 *	called to authenticate the players game centre id
 */
- (void)authenticateLocalUser
{
	if (!self.gameCentreAvailable)			return;
	
	NSLog(@"Authenticating Local User.");
	
	if ([GKLocalPlayer localPlayer].authenticated == NO)
	{
		[[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController* viewcontroller, NSError *error)
		{
			NSLog(@"Inside Authentication Handler.");
			
			//	set this class as the event handler delegate
			GKTurnBasedEventHandler *event	= [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
			[event setDelegate:self];
			
			//	logging whether we are the delegate or not
			NSLog(@"Event Handler Delegate: %@ Compared To Self: %@", event.delegate, self);
			
			//	if there was no error, and we got a valid view controller to display
			if (!error && viewcontroller)
			{
				//	get a handle to the app delegate
				AppDelegate *delegate		= [UIApplication sharedApplication].delegate;
				
				//	use the view controller in the app delegate to present the authentication view controller
				[delegate.viewController presentViewController:viewcontroller animated:YES completion:
				^{
					//	once the view controller has been displayed, register the change in authentication
					[self authenticationChanged];
				}];
			}
			
			/*
			//	load all of the matches the player is currently a part of
			[GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
			{
				NSLog(@"Error loading matches: %@", error);
				
				//	create some placeholder match data
				NSString *matchString			= @"Deleting match";
				NSData *matchData				= [matchString dataUsingEncoding:NSUTF8StringEncoding];
				
				//	for each match
				for (GKTurnBasedMatch *match in matches)
				{
					//	log the id of the match
					NSLog(@"ID of match we are removing: %@", match.matchID);
					
					//	for each player we set their outcome to 'tied'
					for (GKTurnBasedParticipant *participant in match.participants)
						participant.matchOutcome		= GKTurnBasedMatchOutcomeTied;
					
					//	end the match
					[match endMatchInTurnWithMatchData:matchData completionHandler:^(NSError *error)
					{
						NSLog(@"Error ending the match: %@", error);
						
						//	and then remove it
						[match removeWithCompletionHandler:^(NSError *error)
						 {
							 NSLog(@"Error removing match: %@", error);
						 }];
					}];
				}
			}];
			 */
			 
		}];
	}
	else
		NSLog(@"Already Authenticated.");
}

/**
 *	called to find a match with a minimum and maximum amount of player
 *
 *	@param
 *	@param
 *	@param
 */
- (void)findMatchWithMinPlayers:(int)minPlayers
					 maxPlayers:(int)maxPlayers
				 viewController:(UIViewController *)viewController
{
	//	if game centre isn't available, we can't do anything
	if (!_gameCentreAvailable)				return;
	
	//	store the view controller
	_presentingViewController				= viewController;
	
	//	create a game kit match request
	GKMatchRequest *request					= [[GKMatchRequest alloc] init];
	request.minPlayers						= minPlayers;
	request.maxPlayers						= maxPlayers;
	
	//	create a matchmaker view controller and initalise with our request
	GKTurnBasedMatchmakerViewController *matchmakerController;
	matchmakerController					= [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
	
	//	set ourselves to be the delegate of the matchmaker view controller
	[matchmakerController setTurnBasedMatchmakerDelegate:self];
	//	shows all the matches that the player has been involved in
	matchmakerController.showExistingMatches= YES;
	
	//	present the match maker view controller
	[_presentingViewController presentViewController:matchmakerController animated:YES completion:NULL];
}

#pragma mark = GKTurnBasedEventHandlerDelegate Methods

/**
 *	sent to delegate when local player received invitation to a new turn-based match
 *
 *	@param	playersToInvite					an array of player id's of players to invite to game
 */
- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite
{
	//	dismiss anypresent view controller
	[_presentingViewController dismissViewControllerAnimated:YES completion:
	^{
		//	set up the match request
		GKMatchRequest *request				= [[GKMatchRequest alloc] init];
		request.playersToInvite				= playersToInvite;
		request.maxPlayers					= 12;
		request.minPlayers					= 2;
		
		//	set up our match maker view controller
		GKTurnBasedMatchmakerViewController *viewController;
		viewController						= [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
		viewController.showExistingMatches	= NO;
		[viewController setTurnBasedMatchmakerDelegate:self];
		
		//	present the match maker view controller
		[_presentingViewController presentViewController:viewController animated:YES completion:NULL];
	}];
}

/**
 *	sent to delegate when a match that the local player is paritcipating in has ended
 *
 *	@param	match							the match which has coem to an end
 */
- (void)handleMatchEnded:(GKTurnBasedMatch *)match
{
	NSLog(@"The match has ended.");
	
	//	if the current match has ended
	if ([match.matchID isEqualToString:self.currentMatch.matchID])
		[self.delegate receiveEndGame:match];
	
	//	otherwise, if another match has ended
	else
		[self.delegate sendNotice:@"Different match to the one being viewed has ended" forMatch:match];
}

/**
 *	sent to delegate when it is the local player's turn in this turn based match
 *
 *	@param	match							the match which this player needs ot take their turn in
 *	@param	didBecomeActive					set to yes if the match has been brought to the foreground
 */
- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match
				didBecomeActive:(BOOL)didBecomeActive
{
	//	if this match is the current match
	if ([match.matchID isEqualToString:self.currentMatch.matchID])
	{
		//	and if it's now our turn in the current match
		if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
		{
			//	the current match has been updated with new match data, so we update our handle
			self.currentMatch				= match;
			
			//	ask our delegate to take our turn
			[self.delegate takeTurn:match];
		}
		
		//	otherwise, if it is not our turn in the current match
		else
		{
			//	the current match has been updated with new match data, so we update our handle
			self.currentMatch				= match;
			
			//	lay out the match
			[self.delegate layoutMatch:match];
		}
	}
	
	//	or if it's not the current match
	else
	{
		//	if it's our turn
		if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
			[self.delegate sendNotice:@"It is now your turn for another match" forMatch:match];
		
		//	otherwise it's not our turn
		else
			NSLog(@"Somebody else's turn for a match which is not the current one.");
	}
}

#pragma mark - GKTurnBasedMatchmakerViewControllerDelegate Methods


/**
 *	called when any error occurs
 *
 *	@param	viewController					the view controller which received an error
 *	@param	error							an error object describing the error
 */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)	viewController
						 didFailWithError:(NSError *)								error
{
	[_presentingViewController dismissViewControllerAnimated:YES completion:
	^{
		NSLog(@"Failed to find a match: %@", [error localizedDescription]);
	}];
}

/**
 *	called when user selects match to view
 *
 *	@param	viewController					the view controller which found a match
 *	@param	match							that match that the player selected
 */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)	viewController
							 didFindMatch:(GKTurnBasedMatch *)						match
{
	//	if we found a match get rid of the match maker controller
	[_presentingViewController dismissViewControllerAnimated:YES completion:NULL];
	
	NSLog(@"Found a match: %@", match);
	//	get a handle of the current match and the first player
	self.currentMatch					= match;
	GKTurnBasedParticipant *firstPlayer	= [match.participants objectAtIndex:0];
	
	//	if this is a new match, handle appropriately
	if (firstPlayer.lastTurnDate == NULL)
		[self.delegate enterNewGame:match];
	
	//	otherwise it's an existing game
	else
	{
		//	if it's our turn, take the turn
		if ([match.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
			[self.delegate takeTurn:match];
		
		//	otherwise it's not our turn so we simply display the game state
		else
			[self.delegate layoutMatch:match];
	}
}

/**
 *	called when player decides to quit the match
 *
 *	@param	viewController					the view controller that the player interacted with
 *	@param	match							that match that the player has chosen to quit
 */
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)	viewController
					   playerQuitForMatch:(GKTurnBasedMatch *)						match
{
	NSLog(@"Player quit for match: %@ \n With: %@", match, match.currentParticipant);
	
	//	get the current player's index (that would be this player)
	NSUInteger currentPlayerIndex			= [match.participants indexOfObject:match.currentParticipant];
	
	//	use it to get the index of the next player
	NSMutableArray *nextParticipants		= [NSMutableArray array];
	
	//	for each next possible player, we must make sure that they haven't quit
	for (int i = 0; i < match.participants.count; i++)
	{
		GKTurnBasedParticipant *nextParticipant						= [match.participants
																	   objectAtIndex:(currentPlayerIndex + 1 + i) % match.participants.count];
		
		if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit)
			[nextParticipants addObject:nextParticipant];
	}
	
	//	allow for two weeks before time out of turn
	NSTimeInterval timeForTurn				= 14 * 24 * 3600;
	
	//	give the next player the next turn (skipping over current player, and assigning matchoutcomequit to them
	[match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit
						   nextParticipants:nextParticipants
								turnTimeout:timeForTurn
								  matchData:match.matchData.bytes
						  completionHandler:NULL];
}

/**
 *	called when the user hits the cancel button
 *
 *	@param	viewController					the view controller that the player cancelled
 */
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
	[_presentingViewController dismissViewControllerAnimated:YES completion:
	^{
		NSLog(@"Matchmaking was cancelled.");
	}];
}

#pragma mark - GCTurnBasedMatchHelperDelegate Methods

/**
 *	called when player is presented with a new game
 *
 *	@param	match							the new match instance
 */
- (void)enterNewGame:(GKTurnBasedMatch *)match
{

}

/**
 *	called when player wants to view match during other players turn
 *
 *	@param	match							the match to show
 */
- (void)layoutMatch:(GKTurnBasedMatch *)match
{
	
}

/**
 *	called when player is notified that a match has ended, either by this player or another player
 *
 *	@param	match							the match that has ended
 */
- (void)receiveEndGame:(GKTurnBasedMatch *)match
{
	
}

/**
 *	called upon receival of event in a match we are not viewing
 *
 *	@param	notice							the notice of the particular event
 *	@param	match							the match for which the notice applies
 */
- (void)sendNotice:(NSString *)notice
		  forMatch:(GKTurnBasedMatch *)match
{
	
}

/**
 *	called when it's the players' turn in an existing match
 *
 *	@param	match							the match to take a turn in
 */
- (void)takeTurn:(GKTurnBasedMatch *)match
{

}














































@end
