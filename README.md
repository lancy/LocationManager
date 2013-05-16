# CYLocationManager

## About
CYLocationManager use CoreLocation Framework to track user travel distance.

## Required
* iOS 5.0 or later
* support ARC

## Installation
Simply add *CYLocationManager.h* and *CYLocationManager.m* to your project, and import "CYLocationManager.h".

## API and Parameters
### Type Define
    typedef enum {
        CYGPSSignalStrengthInvalid = 0,
        CYGPSSignalStrengthWeak,
        CYGPSSignalStrengthStrong
    } CYGPSSignalStrength;
    
##### Discussion: 
* GPS signal strength depend on the horizontalAccuracy of updated location. (see CLLocation.horizontalAccuracy). 
* you can change the parameters kRequiredHorizontalAccuracy and kMaxAcceptableHorizontalAccuracy in CYLocationManager.m to make the program determine the signal strength in a different way. 
* If the horizontalAccuracy of latest updated location is less then kRequiredHorizontalAccuracy, the GPS signal strength suppose to be strong, else it will be weak.

### Interface
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
    
##### Discussion: 
* You should use the shareManager method to access the manager. However you also can alloc and init a new instance by yourself.
* I recommend you set the delegate first before any operation, in order to get the callback when something you cared changed. However, you are not asked to do that, it's optional.
* You should always prepareLocationUpdates first before you startLocationUpdates.
* When you stopLocationUpdates, you could use startLocationUpdates to restart it, it won't reset the current calculation unless you use the resetLocationUpdates.
* prepareLocationUpdates and startLocationUpdates will return a boolean value to determine whether it can do that. (Something like, GPS is not available and device can not connect the internet, or user reject your app to get his/her location)


### Protocol callback methods
    @protocol CYLocationManagerDelegate <NSObject>
    
    @optional
    - (void)locationManager:(CYLocationManager *)locationManager didUpdateSignalStrength:(CYGPSSignalStrength)signalStrength;
    - (void)locationManagerSignalConsistentlyWeak:(CYLocationManager *)locationManager;
    - (void)locationManager:(CYLocationManager *)locationManager didUpdateDistance:(CLLocationDistance)distance;
    - (void)locationManager:(CYLocationManager *)locationManager didFailWithError:(NSError *)error;
    
    @end

#### Discussion:
* Pretty straight forward, I'm sure your will know how to use them.
* didFailWithError return the same error from CLLocationManager.


### Parameters
    static const NSUInteger kDistanceFilter = 10;
    static const NSUInteger kHeadingFilter = 30;
    static const NSUInteger kNumberOfLocationsToKeep = 5;
    static const NSUInteger kMinNumberOfLocationsRequiredToCalculate = 3;
    static const NSUInteger kGPSSignalRecheckInterval = 15;
    static const CGFloat kRequiredHorizontalAccuracy = 20.0;
    static const CGFloat kRequiredHorizontalAccuracy = 70.0;
    static const NSTimeInterval kCalculationInterval = 3;
    static const NSTimeInterval kValidIntervalWithKeptLocation = 3;
    static const NSUInteger kUpdateLocationMaxInterval = 10;
    
#### Discussion:
* kDistanceFilter see CLLocationManager.distanceFilter
* kHeadingFilter see CLLocationManager.headingFilter
* kNumberOfLocationsToKeep, kMinNumberOfLocationsRequiredToCalculate: We keep multi location in order to pick up the datas which have the best accuracy to calculate the distance.
* kGPSSignalRecheckInterval, interval of rechecking GPS Signal.
* kRequiredHorizontalAccuracy, kRequiredHorizontalAccuracy: discussed in GPS signal strength. 
* kCalculationInterval: We calculate the distance kCalculationInterval seconds once.
* kValidIntervalWithKeptLocation: The valid interval between current location and kept locations. 
* kUpdateLocationMaxInterval: if user stop walking or running, CoreLocation won't update the location, we need to force it to request a new location. It's mean we alway get a new location during kUpdateLocationMaxInterval seconds.


## Contact me
## Contact Me
* [Follow my github](https://github.com/lancy)
* [Write an issue](https://github.com/lancy/LocationManger/issues)
* Send Email to me: lancy1014@gmail.com