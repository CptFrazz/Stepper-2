#import "sqlite3.h"
#import "CoreMotion/CMPedometer.h"
#import "Foundation/NSDistributedNotificationCenter.h"

@interface StepperFetcher : NSObject
@property int timeInterval;
@property (strong, nonatomic) CMPedometer *pedoMeter;
+ (id)sharedInstance;
- (void)startFetchingSteps;
- (void)restartStepperFetcher;
- (void)midnightParty;
@end

@interface DBManipulator : NSObject
@property (strong, nonatomic) NSMutableArray *database;
+ (id)sharedInstance;
- (BOOL)addDatabaseEntryIfNeeded;
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

@interface SpringBoard
- (void)applicationDidFinishLaunching:(id)application;
- (void)checkDatabase;
@end
