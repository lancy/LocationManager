//
//  GLFlipsideViewController.h
//  LocationManger
//
//  Created by Lancy on 4/5/13.
//  Copyright (c) 2013 GraceLancy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLFlipsideViewController;

@protocol GLFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(GLFlipsideViewController *)controller;
@end

@interface GLFlipsideViewController : UIViewController

@property (weak, nonatomic) id <GLFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
