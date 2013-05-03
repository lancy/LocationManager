//
//  GLFlipsideViewController.m
//  LocationManger
//
//  Created by Lancy on 4/5/13.
//  Copyright (c) 2013 GraceLancy. All rights reserved.
//

#import "GLFlipsideViewController.h"

@interface GLFlipsideViewController ()

@end

@implementation GLFlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
