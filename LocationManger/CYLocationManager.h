//
//  CYLocationManager.h
//  LocationManger
//
//  Created by Lancy on 4/5/13.
//  Copyright (c) 2013 GraceLancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    CYGPSSignalStrengthInvalid = 0,
    CYGPSSignalStrengthWeak,
    CYGPSSignalStrengthStrong
} CYGPSSignalStrength;

@class CYLocationManager;

@protocol CYLocationManagerDelegate <NSObject>

@optional
- (void)locationManager:(CYLocationManager *)locationManager didUpdateSignalStrength:(CYGPSSignalStrength)signalStrength;
- (void)locationManagerSignalConsistentlyWeak:(CYLocationManager *)locationManager;

- (void)locationManager:(CYLocationManager *)locationManager didUpdateDistance:(CLLocationDistance)distance;

- (void)locationManager:(CYLocationManager *)locationManager didFailWithError:(NSError *)error;

@end


@interface CYLocationManager : NSObject

@property (nonatomic, weak) id<CYLocationManagerDelegate> delegate;
@property (nonatomic, readonly) CYGPSSignalStrength signalStrength;
@property (nonatomic, readonly) CLLocationDistance distance;

+ (CYLocationManager *)shareManager;

- (BOOL)prepareLocationUpdates;
- (BOOL)startLocationUpdates;
- (void)stopLocationUpdates;
- (void)resetLocationUpdates;

@end
