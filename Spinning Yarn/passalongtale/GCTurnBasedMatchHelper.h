//
//  GCTurnBasedMatchHelper.h
//  Spinning Yarn
//
//  Created by James Valaitis on 01/11/2012.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCTurnBasedMatchHelperDelegate <NSObject>

@required

- (void)	enterNewGame:	(GKTurnBasedMatch *)	match;
- (void)	layoutMatch:	(GKTurnBasedMatch *)	match;
- (void)	receiveEndGame:	(GKTurnBasedMatch *)	match;
- (void)	sendNotice:		(NSString *)			notice
			  forMatch:		(GKTurnBasedMatch *)	match;
- (void)	takeTurn:		(GKTurnBasedMatch *)	match;

@end

@interface GCTurnBasedMatchHelper : NSObject <GKTurnBasedEventHandlerDelegate, GKTurnBasedMatchmakerViewControllerDelegate>
{
	UIViewController	*_presentingViewController;
	BOOL				_userAuthenticated;
}

@property	(nonatomic, strong)	GKTurnBasedMatch					*alternateMatch;
@property	(assign, readonly)	BOOL								gameCentreAvailable;
@property	(nonatomic, strong)	GKTurnBasedMatch					*currentMatch;
@property	(nonatomic, strong)	id <GCTurnBasedMatchHelperDelegate>	delegate;

+ (GCTurnBasedMatchHelper *)sharedInstance;
- (void)					authenticateLocalUser;
- (void)					findMatchWithMinPlayers:	(int)				minPlayers
										 maxPlayers:	(int)				maxPlayers
								     viewController:	(UIViewController *)viewController;

@end
