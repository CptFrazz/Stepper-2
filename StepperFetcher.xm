//
//  StepperFetcher.xm
//  Stepper 2
//
//  Created by Timm Kandziora on 13.11.14.
//  Copyright (c) 2014 Timm Kandziora (shinvou). All rights reserved.
//

#import "Stepper2-Header.h"

@implementation StepperFetcher

+ (id)sharedInstance
{
	static StepperFetcher *sharedInstance;

	static dispatch_once_t provider_token;
	dispatch_once(&provider_token, ^{
		sharedInstance = [[self alloc] init];
        sharedInstance.pedoMeter = [[CMPedometer alloc] init];
	});

	return sharedInstance;
}

- (void)startFetchingSteps
{
    [_pedoMeter stopPedometerUpdates];

	[_pedoMeter startPedometerUpdatesFromDate:[self getNSDateForSpecificTimePeriod] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
		if (!error) {
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"StepperFetcherSuccess" object:nil userInfo:@{ @"NumberOfSteps" : [pedometerData numberOfSteps], @"TimeInterval" : @(_timeInterval) }];
        } else {
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"StepperFetcherError" object:nil userInfo:@{ @"Error" : error }];
        }
    }];
}

- (NSDate *)getNSDateForSpecificTimePeriod
{
    int timeInterval = 0;

    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.shinvou.stepper2.plist"];

    if (settings) {
        if ([settings objectForKey:@"timeInterval"]) {
            timeInterval = [[settings objectForKey:@"timeInterval"] intValue];
        }
    }

	_timeInterval = timeInterval;

    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];

    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];

    NSDate *dayStart = [[NSCalendar currentCalendar] dateFromComponents:components];

    switch (timeInterval) {
        case 1:
            return [dayStart dateByAddingTimeInterval:-1*24*60*60];
            break;
        case 2:
            return [dayStart dateByAddingTimeInterval:-2*24*60*60];
            break;
        case 3:
            return [dayStart dateByAddingTimeInterval:-3*24*60*60];
            break;
        case 4:
            return [dayStart dateByAddingTimeInterval:-4*24*60*60];
            break;
        case 5:
            return [dayStart dateByAddingTimeInterval:-5*24*60*60];
            break;
        case 6:
            return [dayStart dateByAddingTimeInterval:-6*24*60*60];
            break;
        case 7:
            return [dayStart dateByAddingTimeInterval:-7*24*60*60];
            break;
        default:
            return dayStart;
            break;
    }
}

@end
