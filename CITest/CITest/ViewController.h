//
//  ViewController.h
//  CITest
//
//  Created by James Valaitis on 07/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	NSUInteger							_index;
	IBOutlet UILabel					*_filterTitle;
}

@property (nonatomic, strong)			NSMutableArray	*appliedFilters;
@property (nonatomic, strong)			NSArray			*filters;
@property (nonatomic, strong) IBOutlet	UIImageView		*imageView;

- (IBAction)autoEnhance;
- (IBAction)changeFilterValue:			(UISlider *)	slider;
- (IBAction)loadPhoto:					(UIButton *)	sender;
- (IBAction)maskMode:					(UIButton *)	button;
- (IBAction)rotateFilters;
- (IBAction)savePhoto;
			
@end
