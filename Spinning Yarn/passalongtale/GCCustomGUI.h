//
//  GCCustomGUI.h
//  Spinning Yarn
//
//  Created by James Valaitis on 06/11/2012.
//
//

#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"
#import "MatchCell.h"
#import "ViewController.h"

@interface GCCustomGUI : UITableViewController <MatchCellDelegate>

@property (nonatomic, strong)	ViewController		*viewController;

- (BOOL)isVisible;

@end
