#import <GameKit/GameKit.h>
#import <UIKit/UIKit.h>
#import "GCTurnBasedMatchHelper.h"

@class GCCustomGUI;

@interface ViewController : UIViewController <GCTurnBasedMatchHelperDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
	GCCustomGUI				*_newGUI;
	IBOutlet UILabel		*_statusLabel;
    IBOutlet UITextView		*_mainTextController;
    IBOutlet UIView			*_inputView;
    IBOutlet UITextField	*_textInputField;
    IBOutlet UILabel		*_characterCountLabel;
}

- (void)	animateTextField:			(UITextField*)	textField
					      up:			(BOOL)			up;
- (IBAction)presentGCCustomGUI:			(id)			sender;
- (IBAction)presentGCTurnViewController:(id)			sender;
- (IBAction)sendTurn:					(id)			sender;
- (IBAction)updateCount:				(id)			sender;

@end
