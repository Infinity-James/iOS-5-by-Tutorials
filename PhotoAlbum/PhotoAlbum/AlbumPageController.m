//
//  AlbumPageController.m
//  PhotoAlbum
//
//  Created by James Valaitis on 30/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "AlbumPageController.h"

// ----------------------------------------------------------------------------------------------------------------
//										Album Page Controller Private Interface
// ----------------------------------------------------------------------------------------------------------------

@interface AlbumPageController ()

@property (nonatomic, strong)	NSMutableArray			*pictureViews;

@end

// ----------------------------------------------------------------------------------------------------------------
//										Album Page Controller Implementation
// ----------------------------------------------------------------------------------------------------------------

@implementation AlbumPageController

#pragma mark - Setters & Getters

- (NSMutableArray *)pictureViews
{
	if (!_pictureViews)
		_pictureViews					= [NSMutableArray array];
	
	return _pictureViews;
}

#pragma mark - View Lifecycle

/**
 *	we get this message when the app has received a memory warning
 */
- (void)didReceiveMemoryWarning
{
	self.picturesArray					= nil;
	self.pictureViews					= nil;
}

/**
 *	initialises this view controller with a specified view
 *
 *	@param	nibNameOrNil			name of the .xib file holding the view
 *	@param	nibBundleOrView			bundle to look in for the view
 */
- (id)initWithNibName:(NSString *)nibNameOrNil
			   bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		
	}
	
	return self;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self layoutPicturesAnimated:NO withDuration:0 forInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//	for each picture name in our array, create an image view from it and store it
	for (NSString *pictureName in self.picturesArray)
	{
		UIImageView *picture			= [[UIImageView alloc] initWithImage:[UIImage imageNamed:pictureName]];
		[self.pictureViews addObject:picture];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	[self layoutPicturesAnimated:YES withDuration:duration forInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - Convenience Methods

- (void)layoutPicturesAnimated:(BOOL)animated
				  withDuration:(NSTimeInterval)duration
	   forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//	if we want to lay them out in an animated fashion, we do so
	if (animated)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
		[UIView setAnimationDelay:0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	}
	
	//	now we calculate the frames of the image views
	CGRect orientationFrame;
	
	//	if this is an ipad...
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		//	if portait we set to the size of the whole display
		if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
			orientationFrame				= CGRectMake(0, 0, 768, 1004);
		//	if landscape we set to size of half display (because we are showing two pages)
		else
			orientationFrame				= CGRectMake(0, 0, 502, 768);
	}
	//	if on an iphone...
	else
	{
		//	set to the size of the display in both cases
		if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
			orientationFrame				= CGRectMake(0, 0, 320, 480);
		else
			orientationFrame				= CGRectMake(0, 0, 480, 320);
	}
	
	//	if there is a picture in the array
	if (self.picturesArray.count > 0)
	{
		//	if there is only one picture, set the frame to be the whole page
		if (self.picturesArray.count == 1)
			[self setPictureAtIndex:0 inFrame:orientationFrame];
		
		//	if there are two pictures, set the frame to be half of the display in either orientation
		else if (self.picturesArray.count == 2)
		{
			CGRect frameOne;
			CGRect frameTwo;
			
			if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
				&& UIInterfaceOrientationIsLandscape(interfaceOrientation))
			{
				frameOne					= CGRectMake(0, 0, orientationFrame.size.width * 0.5, orientationFrame.size.height);
				frameTwo					= CGRectMake(orientationFrame.size.width * 0.5, 0,
														 orientationFrame.size.width * 0.5, orientationFrame.size.height);
				
				[self setPictureAtIndex:0 inFrame:frameOne];
				[self setPictureAtIndex:1 inFrame:frameTwo];
			}
			else
			{
				frameOne					= CGRectMake(0, 0, orientationFrame.size.width, orientationFrame.size.height * 0.5);
				frameTwo					= CGRectMake(0, orientationFrame.size.height * 0.5,
														 orientationFrame.size.width * 0.5, orientationFrame.size.height);
				
				[self setPictureAtIndex:0 inFrame:frameOne];
				[self setPictureAtIndex:1 inFrame:frameTwo];
			}
		}
		
		//	if there are three or four, we lay them out in quarters
		else
		{
			CGRect frameOne;
			CGRect frameTwo;
			CGRect frameThree;
			CGRect frameFour;
			
			frameOne						= CGRectMake(0, 0, orientationFrame.size.width * 0.5, orientationFrame.size.height * 0.5);
			
			frameTwo						= CGRectMake(orientationFrame.size.width * 0.5, 0,
														 orientationFrame.size.width * 0.5, orientationFrame.size.height * 0.5);
			
			frameThree						= CGRectMake(0, orientationFrame.size.height * 0.5,
														 orientationFrame.size.width * 0.5, orientationFrame.size.height * 0.5);
			
			frameFour						= CGRectMake(orientationFrame.size.width * 0.5, orientationFrame.size.height * 0.5,
														 orientationFrame.size.width * 0.5, orientationFrame.size.height * 0.5);
			
			[self setPictureAtIndex:0 inFrame:frameOne];
			[self setPictureAtIndex:1 inFrame:frameTwo];
			[self setPictureAtIndex:2 inFrame:frameThree];
			
			//	check if there is a fourth picture
			if (self.picturesArray.count == 4)
				[self setPictureAtIndex:3 inFrame:frameFour];
		}
	}
	
	//	if this is animated, we commit the animations
	if (animated)
		[UIView commitAnimations];
}

- (void)setPictureAtIndex:(NSUInteger)index
				  inFrame:(CGRect)frameForPicture
{
	//	get the picture view at the correct index
	UIImageView *picture					= [self.pictureViews objectAtIndex:index];
	
	//	we are going to scale the image according to the dimensions, obviously
	CGFloat scale;
	
	// if this is a landscape picture
	if (picture.image.size.width >= picture.image.size.height)
	{
		//	get the ratio of height to width
		scale								= picture.image.size.height / picture.image.size.width;
		
		//	make the actual picture a frame four fifths of the whole size, and scale it according to ratio above
		picture.frame						= CGRectMake(0, 0, frameForPicture.size.width * 0.80,
															frameForPicture.size.width * 0.80 * scale);
		
		//	get the centre of the picture using the centre of the frame for the picture
		picture.center						= CGPointMake(frameForPicture.origin.x + (frameForPicture.size.width * 0.5),
														  frameForPicture.origin.y + (frameForPicture.size.height * 0.5));
	}
	
	//	if the picture was taken in portrait
	else
	{
		//	get the ratio of width to height
		scale								= picture.image.size.width / picture.image.size.height;
		
		//	make the actual picture a frame four fifths of the whole size, and scale it according to ratio above
		picture.frame						= CGRectMake(0, 0, frameForPicture.size.width * 0.80 * scale,
														 frameForPicture.size.width * 0.80);
		
		//	get the centre of the picture using the centre of the frame for the picture
		picture.center						= CGPointMake(frameForPicture.origin.x + (frameForPicture.size.width * 0.5),
														  frameForPicture.origin.y + (frameForPicture.size.height * 0.5));
	}
	
	//	add the picture to the superview
	[self.view addSubview:picture];
}

@end
