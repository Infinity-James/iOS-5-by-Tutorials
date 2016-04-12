//
//  ViewController.m
//  CITest
//
//  Created by James Valaitis on 07/11/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Resize.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
	CGContextRef		_cgContext;
	CIContext			*_context;
	CIFilter			*_filter;
	CIImage				*_image;
	CIImage				*_maskImage;
	UIPopoverController	*_popoverController;
}

#pragma mark - Setters & Getters

- (NSMutableArray *)appliedFilters
{
	if (!_appliedFilters)
		_appliedFilters			= [NSMutableArray array];
	
	return _appliedFilters;
}

- (NSArray *)filters
{
	if (!_filters)
	{
		//	applies a transformation ti the image
		CIFilter *affineTransform		= [CIFilter filterWithName: @"CIAffineTransform" keysAndValues:kCIInputImageKey, _image, @"inputTransform", [NSValue valueWithCGAffineTransform: CGAffineTransformMake(1.0, 0.4, 0.5, 1.0, 0.0, 0.0)], nil];
		
		//	fix an image taken slightly at an angle
		CIFilter *straightenFilter		= [CIFilter filterWithName:@"CIStraightenFilter" keysAndValues:kCIInputImageKey, _image, @"inputAngle", [NSNumber numberWithFloat:2.0], nil];
		
		//	increases colour intensity
		CIFilter *vibrance				= [CIFilter filterWithName:@"CIVibrance" keysAndValues:kCIInputImageKey, _image,@"inputAmount", [NSNumber numberWithFloat:-0.85], nil];
		
		//	changes brightness, contrast and saturation
		CIFilter *colorControls			= [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, _image, @"inputBrightness", [NSNumber numberWithFloat:-0.5], @"inputContrast", [NSNumber numberWithFloat:3.0], @"inputSaturation", [NSNumber numberWithFloat:1.5], nil];
		
		//	inverts colours
		CIFilter *colorInvert			= [CIFilter filterWithName: @"CIColorInvert" keysAndValues:kCIInputImageKey, _image, nil];
		
		//	changed values of highlights and shadows in image
		CIFilter *highlightsAndShadows	= [CIFilter filterWithName: @"CIHighlightShadowAdjust" keysAndValues:kCIInputImageKey, _image, @"inputShadowAmount", [NSNumber numberWithFloat:1.5], @"inputHighlightAmount", [NSNumber numberWithFloat:0.2], nil];
		
		_filters						= [[NSArray alloc] initWithObjects:affineTransform, straightenFilter, vibrance, colorControls,																colorInvert, highlightsAndShadows, nil];
		
		_index							= 0;
	}
	
	return _filters;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self setupCGContext];
	
	[self setupCoreImage];
}

#pragma mark - Convenience Methods

- (CIImage *)addBackgroundLayer:(CIImage *)image
{
	//	get the background image as a ciimage
	CIImage *background			= [CIImage imageWithContentsOfURL:[NSURL
												  fileURLWithPath:[[NSBundle mainBundle]
												  pathForResource:@"NewBryce"
														   ofType:@"png"]]];
	
	//	create a filter with our images
	CIFilter *sourceOver		= [CIFilter filterWithName:@"CISourceOverCompositing"
											 keysAndValues:kCIInputImageKey, image, kCIInputBackgroundImageKey, background, nil];
	
	//	return the filtered image
	return sourceOver.outputImage;
}

- (CIImage *)applyMaskFilterToImage:(CIImage *)image
{
	if (!_maskImage)//	get the ciimage from the url
		_maskImage					= [CIImage imageWithCGImage:[self drawMyCircleMaskAt:self.imageView.center andReset:YES]];
	
	//	adds a new mask filter
	CIFilter *maskFilter		= [CIFilter filterWithName:@"CISourceAtopCompositing" keysAndValues:kCIInputImageKey, image,
								   kCIInputBackgroundImageKey, _maskImage, nil];
	
	//	get the output image from the mask filter
	return maskFilter.outputImage;
}

- (CIImage *)createBoxAt:(CGPoint)location withColour:(CIColor *)colour
{
	//	this filter create a solid colour image
	CIImage *colourFilter		= [CIFilter filterWithName:@"CIConstantColorGenerator"
											 keysAndValues:@"inputColor", colour, nil].outputImage;
	
	//	returns an image using the solid colour to draw a box at the specified location
	return [CIFilter filterWithName:@"CICrop" keysAndValues:kCIInputImageKey, colourFilter, @"inputRectangle",
			[CIVector vectorWithCGRect:CGRectMake(location.x - 25, location.y - 25, 50, 50)], nil].outputImage;
}

- (CGImageRef)drawMyCircleMaskAt:(CGPoint)location andReset:(BOOL)reset
{
	//	if we need to resert the context
	if (reset)
		CGContextClearRect(_cgContext, CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height));
	
	//	our fill colour of the ellipse we're about to draw will be white with an alpha of 70%
	CGContextSetRGBFillColor(_cgContext, 1, 1, 1, 1);
	
	//	draw the ellipse with our context
	CGContextFillEllipseInRect(_cgContext, CGRectMake(location.x - 100, location.y - 100, 200.0, 200.0));
	
	//	create an image with what we've drawn so far (basically a circle)
	CGImageRef cgImage			= CGBitmapContextCreateImage(_cgContext);
	
	//	return the image we've drawn
	return cgImage;
}

- (void)filteredFace:(NSArray *)features
{
	CIImage *image				= _image;
	
	for (CIFaceFeature *feature in features)
	{
		//	if there is a left eye, draw a box around it using a filter
		if (feature.hasLeftEyePosition)
			image				= [CIFilter filterWithName:@"CISourceAtopCompositing"
											 keysAndValues:kCIInputImageKey,
											[self createBoxAt:CGPointMake(feature.leftEyePosition.x, feature.leftEyePosition.y)
												   withColour:[ CIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7]], kCIInputBackgroundImageKey,
														image, nil].outputImage;
		
		//	if there is a right, use a filter to add a box around it
		if (feature.hasRightEyePosition)
			image				= [CIFilter filterWithName:@"CISourceAtopCompositing"
											 keysAndValues:kCIInputImageKey,
											   [self createBoxAt:CGPointMake(feature.rightEyePosition.x, feature.rightEyePosition.y)
													  withColour:[ CIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.7]], kCIInputBackgroundImageKey,
															image, nil].outputImage;
		
		//	if there is a mouth, use a filter to draw a box around it
		if (feature.hasMouthPosition)
			image				= [CIFilter filterWithName:@"CISourceAtopCompositing"
										     keysAndValues:kCIInputImageKey,
											   [self createBoxAt:CGPointMake(feature.mouthPosition.x, feature.mouthPosition.y)
													  withColour:[ CIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.7]], kCIInputBackgroundImageKey,
															image, nil].outputImage;
	}
	
	//	update our filter with the new image
	[_filter setValue:image forKey:kCIInputImageKey];
	
	//	update the image on screen
	[self setFinalImage];
}

- (void)hasFace:(CIImage *)image
{
	CIDetector *faceDetector	= [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyHigh, CIDetectorAccuracy, nil]];
	
	NSArray *features			= [faceDetector featuresInImage:image];
	
	[self filteredFace:features];
}

- (void)logAllFilters
{
	NSArray *properties			= [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
	
	NSLog(@"There are %d filters, and here they are:", properties.count);
	
	for (NSString *filterName in properties)
	{
		CIFilter *filter		= [CIFilter filterWithName:filterName];
		NSLog(@"The %@ filter has the attributes: %@", filterName, filter.attributes);
	}
}

- (void)setFinalImage
{
	//	image with filter applied
	CIImage *outputImage		= _filter.outputImage;
	
	//	add the correct title for this applied filter
	_filterTitle.text			= @"Sepia Tone Composite";
	
	for (NSString *appliedFilter in self.appliedFilters)
	{
		if ([appliedFilter isEqualToString:@"Mask Mode"])
		{
			outputImage			= [self applyMaskFilterToImage:outputImage];
		}
	}
	
	//	add the background layer
	outputImage					= [self addBackgroundLayer:outputImage];
	
	//	with this ciimage, we create a cgimage
	CGImageRef cgImage			= [_context createCGImage:outputImage fromRect:outputImage.extent];
	
	//	with this cg image, we create a uiimage
	UIImage *finalImage			= [UIImage imageWithCGImage:cgImage];
	
	//	set our view's image view with this image
	[self.imageView setImage:finalImage];
	
	//	we must release the image, as it is not arc
	CGImageRelease(cgImage);
}

- (void)setupCGContext
{
	//	width and height of the context
	NSUInteger width			= self.imageView.frame.size.width;
	NSUInteger height			= self.imageView.frame.size.height;
	
	//	encapsulates colour space information
	CGColorSpaceRef colourSpace	= CGColorSpaceCreateDeviceRGB();
	
	//	 this is 32 bit colour
	NSUInteger bytesPerPixel	= 4;
	NSUInteger bytesPerRow		= bytesPerPixel * width;
	
	//	considering this is 32 bit colour, we need 8 bits per channel
	NSUInteger bitsPerComponent	= 8;
	
	//	make the conext with all of the info we gathered
	_cgContext					= CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow,
														colourSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	//	release the colour space info now that we've used it
	CGColorSpaceRelease(colourSpace);
}

- (void)setupCoreImage
{
	//	get the image path found in the main bundle
	NSString *filePath			= [[NSBundle mainBundle] pathForResource:@"NewImage" ofType:@"png"];
	
	//	get a url for this path
	NSURL *fileNameAndPath		= [NSURL fileURLWithPath:filePath];
	
	//	get the original image which we intend on applying filters to
	_image						= [CIImage imageWithContentsOfURL:fileNameAndPath];
	
	//	create options for context
	NSDictionary *options		= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
															  forKey:kCIContextUseSoftwareRenderer];
	
	//	create a context that we will use to apply filters
	_context					= [CIContext contextWithOptions:options];
	
	//	create the filter
	_filter						= [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey, _image,
																		@"inputIntensity", [NSNumber numberWithFloat:0.8], nil];
	
	[self setFinalImage];
}

#pragma mark - Action & Selector Methods

- (IBAction)autoEnhance
{
	CIImage *image				= _image;
	NSArray *filters			= [image autoAdjustmentFilters];
	
	for (CIFilter *filter in filters)
	{
		[filter setValue:image forKey:kCIInputImageKey];
		image					= filter.outputImage;
		NSLog(@"Auto Adjustment Filter: %@", [filter.attributes valueForKey:@"CIAttributeFilterDisplayName"]);
	}
	
	[_filter setValue:image forKey:kCIInputImageKey];
	[self setFinalImage];
}

- (IBAction)changeFilterValue:(UISlider *)slider
{	
	//	get the value of the slider
	float sliderValue			= slider.value;
	
	//	change the intensity of the filter accordingly
	[_filter setValue:[NSNumber numberWithFloat:sliderValue] forKey:@"inputIntensity"];
	
	[self setFinalImage];
}

- (IBAction)loadPhoto:(UIButton *)sender
{
	UIImagePickerController *pickerController	= [[UIImagePickerController alloc] init];
	
	[pickerController setDelegate:self];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		CGRect rect								= sender.frame;
		
		_popoverController	= [[UIPopoverController alloc] initWithContentViewController:pickerController];
		
		[_popoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else
		[self presentViewController:pickerController animated:YES completion:NULL];
}

- (IBAction)maskMode:(UIButton *)button
{
	//	get the output image from the mask filter
	CIImage *outputImage		= [self applyMaskFilterToImage:_filter.outputImage];
	
	//	if the user clicked the button to trun the mask filter off
	if ([button.titleLabel.text isEqualToString:@"Mask Mode Off"])
	{
		[button setTitle:@"Mask Mode" forState:UIControlStateNormal];
		outputImage				= _filter.outputImage;
		[self.appliedFilters removeObject:@"Mask Mode"];
	}
	
	//	but if they wanted to turn it on
	else
	{
		[button setTitle:@"Mask Mode Off" forState:UIControlStateNormal];
		
		[self.appliedFilters addObject:@"Mask Mode"];
	}
	
	[self setFinalImage];
}

- (IBAction)rotateFilters
{
	CIFilter *filter			= [self.filters objectAtIndex:_index];
	CGImageRef imageRef			= [_context createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
	
	[self.imageView setImage:[UIImage imageWithCGImage:imageRef]];
	CGImageRelease(imageRef);
	
	_index						= (_index + 1) % self.filters.count;
	
	_filterTitle.text			= [filter.attributes valueForKey:@"CIAttributeFilterDisplayName"];
}

- (IBAction)savePhoto
{
	//	get the ci image from the filer
	CIImage *ciImageToSave		= _filter.outputImage;
	
	//	get the cg image from this ciimage
	CGImageRef cgImageToSave	= [_context createCGImage:ciImageToSave fromRect:ciImageToSave.extent];
	
	//	initialise the assets libray we will use to save the image
	ALAssetsLibrary *library	= [[ALAssetsLibrary alloc] init];
	
	//	save the image, and once it is done, release the cgimage
	[library writeImageToSavedPhotosAlbum:cgImageToSave metadata:ciImageToSave.properties completionBlock:
	^(NSURL *assetURL, NSError *error)
	{
		CGImageRelease(cgImageToSave);
	}];
}

#pragma mark - UIGestureRecognizer Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
	//	get the location of a touch within the image
	CGPoint location			= [touches.anyObject locationInView:self.imageView];
	
	//	if it is in the bounds
	if (location.y <= self.imageView.bounds.size.height && location.y >= 0)
	{
		//	get the location in core graphics coordinate system (origin at bottom left)
		location				= CGPointMake(location.x, self.imageView.frame.size.height - location.y);
		
		//	draw a circle at this location
		CGImageRef cgImage		= [self drawMyCircleMaskAt:location andReset:YES];
		
		//	set the mask image to be this circle
		_maskImage				= [CIImage imageWithCGImage:cgImage];
		
		[self setFinalImage];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//	get the location of a touch within the image
	CGPoint location			= [touches.anyObject locationInView:self.imageView];
	
	//	if it is in the bounds
	if (location.y <= self.imageView.bounds.size.height && location.y >= 0)
	{
		//	get the location in core graphics coordinate system (origin at bottom left)
		location				= CGPointMake(location.x, self.imageView.frame.size.height - location.y);
		
		//	draw a circle at this location
		CGImageRef cgImage		= [self drawMyCircleMaskAt:location andReset:NO];
		
		//	set the mask image to be this circle
		_maskImage				= [CIImage imageWithCGImage:cgImage];
		
		[self setFinalImage];
	}
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//	dismiss the picker controller
	[self dismissViewControllerAnimated:YES completion:NULL];
	
	//	retrieve the image that the user has chosen
	UIImage *chosenImage		= [info objectForKey:UIImagePickerControllerOriginalImage];
	
	//	scale the chosen image
	chosenImage					= [chosenImage scaleToSize:_image.extent.size];
	
	//	get the cgimage from the uiimage
	_image						= [CIImage imageWithCGImage:chosenImage.CGImage];
	
	//	set the filter image to be our new image
	[_filter setValue:_image forKey:kCIInputImageKey];
	
	//	perform face detection in background
	[self performSelectorInBackground:@selector(hasFace:) withObject:_image];
	
	//	handle the actual filtering and presenting of the image
	[self setFinalImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}






























































@end
