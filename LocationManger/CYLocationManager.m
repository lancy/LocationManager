//
//  CYLocationManager.m
//  LocationManger
//
//  Created by Lancy on 4/5/13.
//  Copyright (c) 2013 GraceLancy. All rights reserved.
//

#import "CYLocationManager.h"
static const NSUInteger kDistanceFilter = 10;
static const NSUInteger kHeadingFilter = 30;
static const NSUInteger kNumberOfLocationsToKeep = 5;
static const NSUInteger kMinNumberOfLocationsRequiredToCalculate = 3;
static const NSUInteger kGPSSignalRecheckInterval = 15;
static const CGFloat kRequiredHorizontalAccuracy = 20.0;
static const CGFloat kMaxAcceptableHorizontalAccuracy = 40.0;
static const NSTimeInterval kCalculationInterval = 3;
static const NSTimeInterval kValidIntervalWithKeepedLocation = 3;
static const NSUInteger kUpdateLocationMaxInterval = 10;



@interface CYLocationManager() <CLLocationManagerDelegate>

@property (nonatomic, readwrite) CYGPSSignalStrength signalStrength;
@property (nonatomic, readwrite) CLLocationDistance distance;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *currentKeepLocations;
@property (nonatomic, strong) NSDate *startTimestamp;
@property (nonatomic, strong) CLLocation *lastRecordedLocation;
@property (nonatomic) NSTimeInterval lastCalculationTimestamp;
@property (nonatomic, strong) NSTimer *updateLocationMaxIntervalTimer;


@property (nonatomic, getter = isCheckingSignalStregth) BOOL checkingSignalStrength;
@property (nonatomic, getter = isAllowUseMaxAcceptableAccuracy) BOOL allowUseMaxAcceptableAccuracy;
@property (nonatomic, getter = isNeedForceCalculation) BOOL needForceCalculation;

@end

@implementation CYLocationManager

+ (CYLocationManager *)shareManager
{
    static dispatch_once_t pred;
    static CYLocationManager *locationManagerSingleton = nil;
    
    dispatch_once(&pred, ^{
        locationManagerSingleton = [[self alloc] init];
    });
    return locationManagerSingleton;
}

#pragma mark - Life 

- (id)init {
    if ((self = [super init])) {
        if ([CLLocationManager locationServicesEnabled]) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.distanceFilter = kDistanceFilter;
            self.locationManager.headingFilter = kHeadingFilter;
        }
        
        self.currentKeepLocations = [NSMutableArray arrayWithCapacity:kNumberOfLocationsToKeep];
        [self resetLocationUpdates];
    }
    
    return self;
}

- (void)dealloc {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    self.startTimestamp = nil;
    self.lastRecordedLocation = nil;
    self.updateLocationMaxIntervalTimer = nil;
    
    self.currentKeepLocations = nil;
}
- (void)setSignalStrength:(CYGPSSignalStrength)signalStrength {
    BOOL needToUpdateDelegate = _signalStrength != signalStrength;
    
    _signalStrength = signalStrength;
    
    if (self.signalStrength == CYGPSSignalStrengthStrong) {
        self.allowUseMaxAcceptableAccuracy = NO;
    } else if (self.signalStrength == CYGPSSignalStrengthWeak) {
        [self checkSignalStrength];
    }
    
    if (needToUpdateDelegate) {
        if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateSignalStrength:)]) {
            [self.delegate locationManager:self didUpdateSignalStrength:self.signalStrength];
        }
    }
}


#pragma mark - signal methods
- (void)checkSignalStrength {
    if (!self.isCheckingSignalStregth) {
        self.checkingSignalStrength = YES;
        
        double delayInSeconds = kGPSSignalRecheckInterval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.checkingSignalStrength = NO;
            if (self.signalStrength == CYGPSSignalStrengthWeak) {
                self.allowUseMaxAcceptableAccuracy = YES;
                if ([self.delegate respondsToSelector:@selector(locationManagerSignalConsistentlyWeak:)]) {
                    [self.delegate locationManagerSignalConsistentlyWeak:self];
                }
            } else if (self.signalStrength == CYGPSSignalStrengthInvalid) {
                self.allowUseMaxAcceptableAccuracy = YES;
                self.signalStrength = CYGPSSignalStrengthWeak;
                if ([self.delegate respondsToSelector:@selector(locationManagerSignalConsistentlyWeak)]) {
                    [self.delegate locationManagerSignalConsistentlyWeak:self];
                }
            }
        });
    }
}


#pragma mark - Manager methods

- (BOOL)prepareLocationUpdates
{
    if ([CLLocationManager locationServicesEnabled]) {
        [self.currentKeepLocations removeAllObjects];
        self.signalStrength = CYGPSSignalStrengthInvalid;
        self.needForceCalculation = YES;
        self.allowUseMaxAcceptableAccuracy = NO;
        self.lastCalculationTimestamp = 0;

        [self checkSignalStrength];
        
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];

        
        return YES;
    } else {
        return NO;
    }

    
}
- (BOOL)startLocationUpdates
{
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
        [self.locationManager startUpdatingHeading];
        return YES;
    } else {
        return NO;
    }

}

- (void)stopLocationUpdates
{
    [self.updateLocationMaxIntervalTimer invalidate];
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    self.lastRecordedLocation = nil;
}
- (void)resetLocationUpdates
{
    self.distance = 0;
    self.startTimestamp = [NSDate dateWithTimeIntervalSinceNow:0];

}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CYLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (oldLocation == nil) return;
    // make the timer invalidate while CoreLocationManager update an location
    [self.updateLocationMaxIntervalTimer invalidate];
    BOOL isStaleLocation = ([oldLocation.timestamp compare:self.startTimestamp] == NSOrderedAscending);
    self.signalStrength = newLocation.horizontalAccuracy <= kRequiredHorizontalAccuracy ? CYGPSSignalStrengthStrong : CYGPSSignalStrengthWeak;
    double horizontalAccuracy = self.isAllowUseMaxAcceptableAccuracy ? kMaxAcceptableHorizontalAccuracy: kRequiredHorizontalAccuracy;
    
    if (!isStaleLocation
        && newLocation.horizontalAccuracy >= 0
        && newLocation.horizontalAccuracy <= horizontalAccuracy) {
        
        [self.currentKeepLocations addObject:newLocation];
        if ([self.currentKeepLocations count] > kNumberOfLocationsToKeep) {
            [self.currentKeepLocations removeObjectAtIndex:0];
        }
        
        BOOL canUpdateDistanceAndSpeed = ([self.currentKeepLocations count] >= kMinNumberOfLocationsRequiredToCalculate);
        
        if (self.isNeedForceCalculation || [NSDate timeIntervalSinceReferenceDate] - self.lastCalculationTimestamp > kCalculationInterval) {
            self.needForceCalculation = NO;
            self.lastCalculationTimestamp = [NSDate timeIntervalSinceReferenceDate];
            
            CLLocation *lastLocation = (self.lastRecordedLocation != nil) ? self.lastRecordedLocation : oldLocation;
            
            CLLocation *bestLocation = nil;
            CGFloat bestAccuracy = kRequiredHorizontalAccuracy;
            for (CLLocation *location in self.currentKeepLocations) {
                if ([NSDate timeIntervalSinceReferenceDate] - [location.timestamp timeIntervalSinceReferenceDate] <= kValidIntervalWithKeepedLocation) {
                    if (location.horizontalAccuracy < bestAccuracy && location != lastLocation) {
                        bestAccuracy = location.horizontalAccuracy;
                        bestLocation = location;
                    }
                }
            }
            if (bestLocation == nil) bestLocation = newLocation;
            
            CLLocationDistance distance = [bestLocation distanceFromLocation:lastLocation];
            if (canUpdateDistanceAndSpeed) self.distance += distance;
            self.lastRecordedLocation = bestLocation;
            
            if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateDistance :)]) {
                [self.delegate locationManager:self didUpdateDistance:self.distance];
            }
        }
    }
    self.updateLocationMaxIntervalTimer = [NSTimer timerWithTimeInterval:kUpdateLocationMaxInterval target:self selector:@selector(requestNewLocation) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.updateLocationMaxIntervalTimer forMode:NSRunLoopCommonModes];

}

- (void)requestNewLocation {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
}


- (void)locationManager:(CYLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    self.needForceCalculation = YES;
}


- (void)locationManager:(CYLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [self.delegate locationManager:self didFailWithError:error];
        }
        [self stopLocationUpdates];
    }
}



@end
