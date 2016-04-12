//
//  AboutController.m
//  Surf's Up
//
//  Created by James Valaitis on 25/10/2012.
//  Copyright (c) 2012 komorka technology, llc. All rights reserved.
//

#import "AboutController.h"

@interface AboutController ()

@end

@implementation AboutController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize viewSize = [[self view] frame].size;
    [self setContentSizeForViewInPopover:viewSize];
}

@end
