//
//  Tweak.xm
//  Stepper 2
//
//  Created by Timm Kandziora on 11.11.14.
//  Copyright (c) 2014 Timm Kandziora (shinvou). All rights reserved.
//

#import "Stepper2-Header.h"

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.stepper2.plist"

static BOOL showLabel = YES;
static BOOL showSlider = YES;
static BOOL updateSliderAnimated = YES;
static BOOL showStatusBar = YES;
static BOOL goalEnabled = YES;
static BOOL goalAlertShown = NO;
static BOOL reminderEnabled = YES;
static BOOL reminderAlertShown = NO;
static BOOL unlockedAfterReboot = NO;

static int stepGoal = 1000;
static int stepCount = 0;
static int textSize = 17;
static int textColor = 3;
static int bubbleColor = 0;
static int bubbleradius = 55;
static int xcoordinate = 5;
static int ycoordinate = 110;

static NSString *customReminderTime = @"20:00";
static NSString *originalDateFormat = nil;
static NSString *statusBarSeparator = @"|";

static UILabel *lockScreenLabel = nil;
static SBLockScreenView *lockScreenView = nil;

static UIColor* GetUIColorForColorNumber(int colorNumber)
{
	switch (colorNumber) {
		case 0:
			return [UIColor blackColor];
			break;
		case 1:
			return [UIColor darkGrayColor];
			break;
		case 2:
			return [UIColor lightGrayColor];
			break;
		case 3:
			return [UIColor whiteColor];
			break;
		case 4:
			return [UIColor grayColor];
			break;
		case 5:
			return [UIColor redColor];
			break;
		case 6:
			return [UIColor greenColor];
			break;
		case 7:
			return [UIColor blueColor];
			break;
		case 8:
			return [UIColor cyanColor];
			break;
		case 9:
			return [UIColor yellowColor];
			break;
		case 10:
			return [UIColor magentaColor];
			break;
		case 11:
			return [UIColor orangeColor];
			break;
		case 12:
			return [UIColor purpleColor];
			break;
		case 13:
			return [UIColor brownColor];
			break;
		default:
			return [UIColor clearColor];
			break;
	}
}

static void SetStatusBarText()
{
	if (showStatusBar) {
		SBStatusBarStateAggregator *statusBarStateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
		NSDateFormatter *dateFormatter = MSHookIvar<NSDateFormatter *>(statusBarStateAggregator, "_timeItemDateFormatter");

		if (!originalDateFormat) {
			originalDateFormat = [dateFormatter dateFormat];
		}

		[dateFormatter setDateFormat:[NSString stringWithFormat:@"%@ '%@' %d", originalDateFormat, statusBarSeparator, stepCount]];

		[statusBarStateAggregator _updateTimeItems];
	} else {
		if (originalDateFormat) {
			SBStatusBarStateAggregator *statusBarStateAggregator = [%c(SBStatusBarStateAggregator) sharedInstance];
			NSDateFormatter *dateFormatter = MSHookIvar<NSDateFormatter *>(statusBarStateAggregator, "_timeItemDateFormatter");

			[dateFormatter setDateFormat:[NSString stringWithFormat:@"%@", originalDateFormat]];

			[statusBarStateAggregator _updateTimeItems];
		}
	}
}

static void UpdateTheInterface()
{
	[lockScreenView setCustomSlideToUnlockText:[NSString stringWithFormat:@"%d steps", stepCount] animated:updateSliderAnimated];
	SetStatusBarText();
}

static void GoalAlertShown(BOOL babybool)
{
	goalAlertShown = babybool;

	NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
	[settings setObject:@(babybool) forKey:@"goalAlertShown"];
	[settings writeToFile:settingsPath atomically:YES];
}

static void ReloadSettings()
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

	if (settings) {
		if ([settings objectForKey:@"showLabel"]) {
			showLabel = [[settings objectForKey:@"showLabel"] boolValue];
			lockScreenLabel = nil;
		}

		if ([settings objectForKey:@"showSlider"]) {
			showSlider = [[settings objectForKey:@"showSlider"] boolValue];
		}

		if ([settings objectForKey:@"updateSliderAnimated"]) {
			updateSliderAnimated = [[settings objectForKey:@"updateSliderAnimated"] boolValue];
		}

		if ([settings objectForKey:@"showStatusBar"]) {
			showStatusBar = [[settings objectForKey:@"showStatusBar"] boolValue];
			SetStatusBarText();
		}

		if ([settings objectForKey:@"statusBarSeparator"]) {
			if ([[settings objectForKey:@"statusBarSeparator"] isEqualToString:@""]) {
				statusBarSeparator = @"|";
				SetStatusBarText();
			} else {
				statusBarSeparator = [settings objectForKey:@"statusBarSeparator"];
				SetStatusBarText();
			}
		}

		if ([settings objectForKey:@"goalEnabled"]) {
			goalEnabled = [[settings objectForKey:@"goalEnabled"] boolValue];
		}

		if ([settings objectForKey:@"customSteps"]) {
			if ([[settings objectForKey:@"customSteps"] isEqualToString:@""]) {
				stepGoal = 10000;
			} else {
				stepGoal = [[settings objectForKey:@"customSteps"] intValue];
			}
        }

		if ([settings objectForKey:@"reminderEnabled"]) {
			reminderEnabled = [[settings objectForKey:@"reminderEnabled"] boolValue];
		}

		if ([settings objectForKey:@"customTime"]) {
			if (![[settings objectForKey:@"customTime"] isEqualToString:customReminderTime]) {
				reminderAlertShown = NO;
			}

			customReminderTime = [settings objectForKey:@"customTime"];
		}

		if ([settings objectForKey:@"x"]) {
			xcoordinate = [[settings objectForKey:@"x"] intValue];
			lockScreenLabel = nil;
		}

		if ([settings objectForKey:@"y"]) {
			ycoordinate = [[settings objectForKey:@"y"] intValue];
			lockScreenLabel = nil;
		}

		if ([settings objectForKey:@"textSize"]) {
			textSize = [[settings objectForKey:@"textSize"] intValue];
			lockScreenLabel = nil;
		}

		if ([settings objectForKey:@"bubbleRadius"]) {
			bubbleradius = [[settings objectForKey:@"bubbleRadius"] intValue];
			lockScreenLabel = nil;
		}

		if ([settings objectForKey:@"textColor"]) {
			textColor = [[settings objectForKey:@"textColor"] intValue];
			lockScreenLabel = nil;
		}

		if ([settings objectForKey:@"bubbleColor"]) {
			bubbleColor = [[settings objectForKey:@"bubbleColor"] intValue];
			lockScreenLabel = nil;
		}

		if ([settings objectForKey:@"goalAlertShown"]) {
			goalAlertShown = [[settings objectForKey:@"goalAlertShown"] boolValue];
		}
	}
}

%hook SBStatusBarStateAggregator

- (void)_updateTimeItems
{
	%orig;

	NSString *timeItemTimeString = MSHookIvar<NSString *>(self, "_timeItemTimeString");

	if ([timeItemTimeString containsString:customReminderTime] && !reminderAlertShown) {
		reminderAlertShown = YES;

		UIAlertView *reminderAlert = [[UIAlertView alloc ] initWithTitle:@"Stepper 2"
																 message:[NSString stringWithFormat:@"You took %d steps until now, your goal is %d steps.", stepCount, stepGoal]
																delegate:nil
													   cancelButtonTitle:@"Ok"
													   otherButtonTitles:nil];
		[reminderAlert show];
	}
}

%end

%hook SBLockScreenView

- (id)initWithFrame:(CGRect)frame
{
	SBLockScreenView *nietzsche = %orig(frame);

	lockScreenView = nietzsche;

	return nietzsche;
}

- (id)_defaultSlideToUnlockText
{
	if (showSlider) {
		return [NSString stringWithFormat:@"%d steps", stepCount];
	} else {
		return %orig;
	}
}

- (void)setCustomSlideToUnlockText:(NSString *)unlockText animated:(BOOL)animated
{
	if (showSlider) {
		unlockText = [NSString stringWithFormat:@"%d steps", stepCount];
	}

	%orig(unlockText, animated);
}

- (void)shakeSlideToUnlockTextWithCustomText:(NSString *)customText
{
	if (showSlider) {
		customText = [NSString stringWithFormat:@"%d steps", stepCount];
	}

	%orig(customText);
}

- (void)layoutSubviews
{
	if ([self mediaControlsHidden]) {
		if (showLabel) {
			if (!lockScreenLabel) {
				lockScreenLabel = [[UILabel alloc] initWithFrame:CGRectMake(xcoordinate, ycoordinate, bubbleradius, bubbleradius)];
				lockScreenLabel.numberOfLines = 1;
				lockScreenLabel.textAlignment = NSTextAlignmentCenter;
				lockScreenLabel.textColor = GetUIColorForColorNumber(textColor);
				lockScreenLabel.backgroundColor = GetUIColorForColorNumber(bubbleColor);
				lockScreenLabel.clipsToBounds = YES;
				lockScreenLabel.layer.cornerRadius = bubbleradius / 2.0;
				lockScreenLabel.tag = 1337;
			}

			UIView *notificationView = MSHookIvar<UIView *>(self,"_notificationView");

			if (![lockScreenLabel superview] || [lockScreenLabel superview] != notificationView) {
				[notificationView addSubview:lockScreenLabel];
			}

			lockScreenLabel.font = [UIFont systemFontOfSize:textSize];
			lockScreenLabel.text = [NSString stringWithFormat:@"%d", stepCount];
		}
	}

	%orig;
}

- (void)setMediaControlsHidden:(BOOL)hidden forRequester:(NSString *)requester
{
	%orig;

	if (!hidden) {
		UIView *notificationView = MSHookIvar<UIView *>(self,"_notificationView");
		[[notificationView viewWithTag:1337] removeFromSuperview];
	}
}

%end

%hook SBLockScreenManager

- (void)_deviceLockedChanged:(id)notification
{
	%orig;

	if (!unlockedAfterReboot) {
		[self performSelector:@selector(startStepperAfterBoot) withObject:nil afterDelay:1.5];
	}
}

%new - (void)startStepperAfterBoot
{
	unlockedAfterReboot = YES;

	[[StepperFetcher sharedInstance] restartStepperFetcher];
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application
{
	%orig;

	[NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkDatabase) userInfo:nil repeats:YES];
}

%new - (void)checkDatabase
{
	if ([[DBManipulator sharedInstance] addDatabaseEntryIfNeeded]) {
		[[StepperFetcher sharedInstance] restartStepperFetcher];
	}
}

%end

%ctor {
	@autoreleasepool {
		[[DBManipulator sharedInstance] addDatabaseEntryIfNeeded];

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"StepperFetcherSuccess" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			stepCount = [[[notification userInfo] objectForKey:@"NumberOfSteps"] intValue];

			UpdateTheInterface();

			if ([[[notification userInfo] objectForKey:@"TimeInterval"] intValue] == 0 && goalEnabled && stepCount >= stepGoal && !goalAlertShown) {
				GoalAlertShown(YES);

				UIAlertView *goalReachedAlert = [[UIAlertView alloc ] initWithTitle:@"Stepper 2"
																			message:[NSString stringWithFormat:@"You reached your daily goal of %d steps, but don't think about stopping!", stepGoal]
																		   delegate:nil
																  cancelButtonTitle:@"Ok"
																  otherButtonTitles:nil];
				[goalReachedAlert show];
			}
		}];

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"Stepper2TimeIntervalChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[[StepperFetcher sharedInstance] restartStepperFetcher];
		}];

		[[NSNotificationCenter defaultCenter] addObserverForName:NSCalendarDayChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			GoalAlertShown(NO);

			[[StepperFetcher sharedInstance] midnightParty];
		}];

		ReloadSettings();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.shinvou.stepper2/reloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		[[StepperFetcher sharedInstance] startFetchingSteps];
	}
}
