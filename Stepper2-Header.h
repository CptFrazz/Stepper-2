#import <substrate.h>

#import "CoreMotion/CMPedometer.h"
#import "Foundation/NSDistributedNotificationCenter.h"
#import "sqlite3.h"

@interface StepperFetcher : NSObject
@property (nonatomic, retain) CMPedometer *pedoMeter;
@property int timeInterval;
+ (id)sharedInstance;
- (void)startFetchingSteps;
@end

@interface DBManipulator : NSObject
@property (nonatomic, strong) NSMutableArray *database;
- (id)initDBManipulator;
- (NSArray *)returnDatabase;
- (void)addSpringBoardEntryToDatabase;
@end

@interface SBStatusBarStateAggregator {
    NSString *_timeItemTimeString;
    NSDateFormatter *_timeItemDateFormatter;
}
- (id)sharedInstance;
- (void)_updateTimeItems;
@end

@interface SBLockScreenManager : NSObject
- (void)_deviceLockedChanged:(id)notification;
- (void)startStepperAfterBoot;
@end

@interface SBLockScreenView
- (id)initWithFrame:(CGRect)frame;
- (NSString *)_defaultSlideToUnlockText;
- (void)setCustomSlideToUnlockText:(NSString *)unlockText animated:(BOOL)animated;
- (void)shakeSlideToUnlockTextWithCustomText:(NSString *)customText;
- (void)layoutSubviews;
- (BOOL)mediaControlsHidden;
- (void)setMediaControlsHidden:(BOOL)hidden forRequester:(NSString *)requester;
@end
