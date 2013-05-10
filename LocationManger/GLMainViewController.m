//
//  GLMainViewController.m
//  LocationManger
//
//  Created by Lancy on 4/5/13.
//  Copyright (c) 2013 GraceLancy. All rights reserved.
//

#import "GLMainViewController.h"
#import "CYLocationManager.h"

@interface GLMainViewController () <CYLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *signalLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation GLMainViewController

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
- (IBAction)tapPrepareButton:(id)sender {
    [[CYLocationManager shareManager] setDelegate:self];
    [[CYLocationManager shareManager] prepareLocationUpdates];
    [self.stateLabel setText:@"Prepare"];
}
- (IBAction)tapStartButton:(id)sender {
    [[CYLocationManager shareManager] startLocationUpdates];
    [self.stateLabel setText:@"Start"];

}
- (IBAction)tapStopButton:(id)sender {
    [[CYLocationManager shareManager] stopLocationUpdates];
    [self.stateLabel setText:@"Stop"];

}
- (IBAction)tapResetButton:(id)sender {
    [[CYLocationManager shareManager] resetLocationUpdates];
    [self.stateLabel setText:@"Reset"];

}

- (void)locationManager:(CYLocationManager *)locationManager didUpdateSignalStrength:(CYGPSSignalStrength)signalStrength
{
    if (signalStrength == CYGPSSignalStrengthInvalid) {
        [self.signalLabel setText:@"Invalid"];
    } else if (signalStrength == CYGPSSignalStrengthStrong)
    {
        [self.signalLabel setText:@"Strong"];
    } else if (signalStrength == CYGPSSignalStrengthWeak)
    {
        [self.signalLabel setText:@"Weak"];
    }
}
- (void)locationManagerSignalConsistentlyWeak:(CYLocationManager *)locationManager
{
    [self.signalLabel setText:@"Consistently Weak"];
}

- (void)locationManager:(CYLocationManager *)locationManager didUpdateDistance:(CLLocationDistance)distance
{
    [self.distanceLabel setText:[NSString stringWithFormat:@"%f", distance]];
}

- (void)locationManager:(CYLocationManager *)locationManager didFailWithError:(NSError *)error
{
    [self.errorLabel setText:[NSString stringWithFormat:@"%@", error]];
}


#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(GLFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

- (void)viewDidUnload {
    [self setErrorLabel:nil];
    [super viewDidUnload];
}
@end
