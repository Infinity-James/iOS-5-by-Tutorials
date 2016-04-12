#import "ViewController.h"
#import "GCCustomGUI.h"

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [_textInputField setDelegate:self];
	[[GCTurnBasedMatchHelper sharedInstance] setDelegate:self];
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[[UIImage imageNamed:@"paper"]
													resizableImageWithCapInsets:UIEdgeInsetsMake(100, 100, 100, 100)]]];
	
	//	greet the player but don't allow them to type because they are not in a game with anyone
	_textInputField.enabled					= NO;
	_statusLabel.text						= @"Welcome. Press the Game Centre button to get started.";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    _mainTextController						= nil;
    _inputView								= nil;
    _textInputField							= nil;
    _characterCountLabel					= nil;
}

#pragma mark - Custom Methods

- (void)animateTextField:(UITextField*)textField
					  up:(BOOL)up
{
    const int movementDistance				= 210; // tweak as needed
    const float movementDuration			= 0.3f; // tweak as needed
    
    int movement							= (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    int textFieldMovement					= movement * 0.75;
	
    _inputView.frame						= CGRectOffset(_inputView.frame, 0, movement);
	
    _mainTextController.frame				= CGRectMake(_mainTextController.frame.origin.x,
														 _mainTextController.frame.origin.y,
														 _mainTextController.frame.size.width,
														 _mainTextController.frame.size.height + textFieldMovement);
	
    [UIView commitAnimations];
	
    NSLog(@"%f", _mainTextController.frame.size.height);
}

- (void)checkForEnding:(NSData *)matchData
{
	if (matchData.length > 3000)
		_statusLabel.text					= [NSString stringWithFormat:@"%@ Only about %d letters left.",
																			_statusLabel.text, 4000 - matchData.length];
}

#pragma mark - Action & Selector Methods

- (IBAction)presentGCTurnViewController:(id)sender
{
	[[GCTurnBasedMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:12 viewController:self];
}

- (IBAction)presentGCCustomGUI:(id)sender
{
	_newGUI									= [[GCCustomGUI alloc] initWithNibName:@"GCCustomGUI" bundle:nil];
	UINavigationController *navController	= [[UINavigationController alloc] initWithRootViewController:_newGUI];
	_newGUI.viewController					= self;
	[self presentViewController:navController animated:YES completion:NULL];
}

- (IBAction)sendTurn:(id)sender
{
	//	get a handle of the current match
	GKTurnBasedMatch *currentMatch			= [GCTurnBasedMatchHelper sharedInstance].currentMatch;
	
	//	create string to store new text player has written
	NSString *newStoryString;
	
	//	if the text exceeds the maximum length, cut it short, otherwise save as is
	if ([_textInputField.text length] > 250)
		newStoryString						= [_textInputField.text substringToIndex:249];
	else
		newStoryString						= _textInputField.text;
	
	//	the string that we will send will include the story up until now as well as the new text
	NSString *sendString					= [NSString stringWithFormat:@"%@ %@", _mainTextController.text, newStoryString];
	
	//	store the string as data to send
	NSData *data							= [sendString dataUsingEncoding:NSUTF8StringEncoding];
	
	//	show the string in our view
	_mainTextController.text				= sendString;
	
	//	get the index of the current player
	NSUInteger currentIndex					= [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
	
	//	use it to get the index of the next player
	NSMutableArray *nextParticipants		= [NSMutableArray array];
	
	//	for each next possible player, we must make sure that they haven't quit
	for (int i = 0; i < currentMatch.participants.count; i++)
	{
		GKTurnBasedParticipant *nextParticipant						= [currentMatch.participants
												 objectAtIndex:(currentIndex + 1 + i) % currentMatch.participants.count];
		
		if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit)
			[nextParticipants addObject:nextParticipant];
	}
	
	//	allow for two weeks before time out of turn
	NSTimeInterval timeForTurn				= 14 * 24 * 3600;
	
	//	if the data is large enough to end the game
	if (data.length > 3800)
	{
		//	for each player we set their outcome to 'tied'
		for (GKTurnBasedParticipant *participant in currentMatch.participants)
			participant.matchOutcome		= GKTurnBasedMatchOutcomeTied;
		
		//	we then end the game
		[currentMatch endMatchInTurnWithMatchData:data completionHandler:^(NSError *error)
		{
			if (error)
				NSLog(@"An error occured whilst trying to end the match: %@", error);
		}];
		
		//	aware the player of the end of the match
		_statusLabel.text					= @"Game has ended.";
	}
	
	//	otherwise, if the game should not end yet
	else
	{
		//	end the turn with the next participants, the two week timeout, the story data, and a completion handler
		[currentMatch endTurnWithNextParticipants:nextParticipants
									  turnTimeout:timeForTurn
										matchData:data
								completionHandler:^(NSError *error)
		{
			if (error)
			{
				NSLog(@"Error ending the turn: %@", error);
				_statusLabel.text				= @"There was a problem, try again.";
			}
			
			else
			{
				_statusLabel.text				= @"Your turn is now over.";
				_textInputField.enabled			= NO;
			}
		}];
	}
	
	//	log the turn
	NSLog(@"Sending turn: %@ to: %@", data, nextParticipants);
	
	//	reset view
	_textInputField.text					= @"";
	_characterCountLabel.text				= @"250";
	_characterCountLabel.textColor			= [UIColor blackColor];
}

- (IBAction)updateCount:(id)sender
{
    UITextField *textField					= (UITextField *)sender;
	
    int length								= [textField.text length];
	
    int remainingCharacters					= 250 - length;
	
    _characterCountLabel.text				= [NSString stringWithFormat:@"%d", remainingCharacters];
	
    if (remainingCharacters < 0)
        _characterCountLabel.textColor		= [UIColor redColor];
	else
        _characterCountLabel.textColor		= [UIColor blackColor];
}

#pragma mark - GCTurnBasedMatchHelperDelegate Methods

/**
 *	called when player is presented with a new game
 *
 *	@param	match							the new match instance
 */
- (void)enterNewGame:(GKTurnBasedMatch *)match
{
	NSLog(@"Entering new game.");
	
	//	tell the player it is their turn
	_statusLabel.text						= @"Player 1's Turn - You";
	
	//	allow them to enter text, because it is their turn
	_textInputField.enabled					= YES;
	
	//	if this is a new game, put the starter text in the field
	_mainTextController.text				= @"Once upon a time ";
}

/**
 *	called when player wants to view match during other players turn
 *
 *	@param	match							the match to show
 */
- (void)layoutMatch:(GKTurnBasedMatch *)match
{
	NSLog(@"Viewing the match whilst it is not this players' turn.");
	NSString *statusString;
	
	//	if the game is over, tell the player
	if (match.status == GKTurnBasedMatchStatusEnded)
		statusString						= @"Match Ended";
	
	//	however, if it is not over, tell the player who's turn it is (adding one to remove a player zero)
	else
	{
		int playerNumber					= [match.participants indexOfObject:match.currentParticipant] + 1;
		statusString						= [NSString stringWithFormat:@"Player %d's Turn", playerNumber];
	}
	
	//	set the label to reflect the message we want to give the player
	_statusLabel.text						= statusString;
	
	//	do not allow the player to try to take a turn
	_textInputField.enabled					= NO;
	
	//	show the player the stroy so far by decoding the data string
	_mainTextController.text				= [NSString stringWithUTF8String:match.matchData.bytes];
	
	//	check how close we are to end of match
	[self checkForEnding:match.matchData];
}

/**
 *	called when player is notified that a match has ended, either by this player or another player
 *
 *	@param	match							the match that has ended
 */
- (void)receiveEndGame:(GKTurnBasedMatch *)match
{
	//	show the match now
	[self layoutMatch:match];
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
	if ([_newGUI isVisible])
		[_newGUI reloadTableView];
	
	else
	{
		//	make the alternate match the match sending the alert for easy switching to
		[GCTurnBasedMatchHelper sharedInstance].alternateMatch	= match;
		
		//	create an alert to show the player
		UIAlertView *alert						= [[UIAlertView alloc]
												   initWithTitle:@"Another game requires your attention."
														 message:notice
														delegate:self
											   cancelButtonTitle:@"Fair Play"
											   otherButtonTitles:@"Curious", @"All the Matches", nil];
		
		//	show the alert
		[alert show];
	}
}

/**
 *	called when it's the players' turn in an existing match
 *
 *	@param	match							the match to take a turn in
 */
- (void)takeTurn:(GKTurnBasedMatch *)match
{
	NSLog(@"Taking turn in existing game.");
	
	//	get the index of the player who is currently taking a turn
	int playerNumber						= [match.participants indexOfObject:match.currentParticipant] + 1;
	
	//	use the index to tell the player it is their turn, and what number player they are
	_statusLabel.text						= [NSString stringWithFormat:@"Player %d's Turn", playerNumber];
	
	//	allow the player to type because it is their turn
	_textInputField.enabled					= YES;
	
	//	if there is data received from the other player
	if (match.matchData.bytes)
	{
		//	decode the string data
		NSString *storySoFar				= [NSString stringWithUTF8String:match.matchData.bytes];
		//	set the main text field to be the decoded string
		_mainTextController.text			= storySoFar;
	}
	
	//	check how close we are to end of match
	[self checkForEnding:match.matchData];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)   alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 1:
			[[GCTurnBasedMatchHelper sharedInstance] setCurrentMatch:[GCTurnBasedMatchHelper sharedInstance].alternateMatch];
			if ([[GCTurnBasedMatchHelper sharedInstance].currentMatch.currentParticipant.playerID
											isEqualToString:[GKLocalPlayer localPlayer].playerID])
				[self takeTurn:[GCTurnBasedMatchHelper sharedInstance].currentMatch];
			else
				[self layoutMatch:[GCTurnBasedMatchHelper sharedInstance].currentMatch];
			break;
			
		case 2:	[self presentGCCustomGUI:nil];	break;
			
		default:								break;
	}
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
	
    NSLog(@"text view up");
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

@end
