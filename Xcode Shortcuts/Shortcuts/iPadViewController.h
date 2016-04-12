//
//  iPadViewController.h
//  Shortcuts
//
//  Created by James Valaitis on 08/11/2012.
//  Copyright (c) 2012 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DictionaryViewController;
@class FavoritesViewController;
@class SearchableShortcutsViewController;
@class SettingsViewController;

@interface iPadViewController : UIViewController
{
	DictionaryViewController			*_keysViewController;
	DictionaryViewController			*_menusViewController;
	FavoritesViewController				*_favouritesViewController;
	SearchableShortcutsViewController	*_allShortcutsViewController;
	SettingsViewController				*_settingsViewController;
	UINavigationController				*_allNavigationController;
	UINavigationController				*_keysNavigationController;
	UINavigationController				*_menusNavigationController;
}

@property (weak, nonatomic) IBOutlet UIView			*bottomView;
@property (weak, nonatomic) IBOutlet UIView			*decorationView;
@property (weak, nonatomic) IBOutlet UIView			*leftView;
@property (weak, nonatomic) IBOutlet UIView			*middleView;
@property (weak, nonatomic) IBOutlet UIView			*rightView;

@property (weak, nonatomic) IBOutlet UIImageView	*backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView	*favouritesImageView;

@property (weak, nonatomic) IBOutlet UIButton		*favouritesButton;
@property (weak, nonatomic) IBOutlet UIButton		*settingsButton;

- (IBAction)favouritesButtonTapped;
- (IBAction)settingsButtonTapped;

@end
