//
//  DataViewController.m
//  MyPageView
//
//  Created by James Valaitis on 29/10/2012.
//  Copyright (c) 2012 &Beyond. All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController ()

@end

@implementation DataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text			= [self.dataObject description];
}

@end
