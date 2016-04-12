//
//  MatchCell.h
//  Spinning Yarn
//
//  Created by James Valaitis on 06/11/2012.
//
//

#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>

@protocol MatchCellDelegate <NSObject>

- (void)loadAMatch:(GKTurnBasedMatch *)match;
- (void)reloadTableView;

@end

@interface MatchCell : UITableViewCell

@property (nonatomic, strong) id <MatchCellDelegate>	delegate;
@property (nonatomic, strong) GKTurnBasedMatch			*match;
@property (nonatomic, strong) IBOutlet	UIButton		*quitButton;
@property (nonatomic, strong) IBOutlet	UILabel			*statusLabel;
@property (nonatomic, strong) IBOutlet	UITextView		*storyText;

- (IBAction)loadGame:(id)sender;
- (IBAction)quitGame:(id)sender;

@end
