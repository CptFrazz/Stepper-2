#import <Preferences/Preferences.h>
#import <Foundation/NSDistributedNotificationCenter.h>

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.stepper2.plist"

@interface Stepper2Banner : PSTableCell

@property (strong, nonatomic) UIImageView *backgroundImage;

@end

@implementation Stepper2Banner

- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stepper2BannerCell" specifier:specifier];

    if (self) {
        _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Stepper2Settings.bundle/bannerImage.png"]];
        [self addSubview:_backgroundImage];
    }

    return self;
}

@end

@interface Stepper2DatePicker : PSTableCell

@property (strong, nonatomic) UIDatePicker *datePicker;

@end

@implementation Stepper2DatePicker

- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stepper2DatePickerCell" specifier:specifier];

    if (self) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 205)];
        _datePicker.datePickerMode = UIDatePickerModeTime;
        _datePicker.date = [self getDateFromPreferences];

        [_datePicker addTarget:self action:@selector(saveDateToPreferences) forControlEvents:UIControlEventValueChanged];

        [self addSubview:_datePicker];
    }

    return self;
}

- (NSDate *)getDateFromPreferences
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];

    if (settings) {
        if ([settings objectForKey:@"customTime"]) {
            return [dateFormatter dateFromString:[settings objectForKey:@"customTime"]];
        }
    }

    return [dateFormatter dateFromString:@"20:00"];
}

- (void)saveDateToPreferences
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];

    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
    [settings setObject:[formatter stringFromDate:_datePicker.date] forKey:@"customTime"];
    [settings writeToFile:settingsPath atomically:YES];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shinvou.stepper2/reloadSettings"), NULL, NULL, TRUE);
}

@end

@interface Stepper2NotificationsListController: PSListController { }
@end

@implementation Stepper2NotificationsListController

- (id)specifiers
{
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];

        NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

        [self setTitle:@"Notifications"];

        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:@"Goal notification"];
        [firstGroup setProperty:@"You'll get a notification when you reached your daily goal." forKey:@"footerText"];
        [specifiers addObject:firstGroup];

        PSSpecifier *goal_enabled = [PSSpecifier preferenceSpecifierNamed:@"Goal notification"
                                                                   target:self
                                                                      set:@selector(setValue:forSpecifier:)
                                                                      get:@selector(getValueForSpecifier:)
                                                                   detail:Nil
                                                                     cell:PSSwitchCell
                                                                     edit:Nil];
        [goal_enabled setIdentifier:@"goal_enabled"];
        [goal_enabled setProperty:@(YES) forKey:@"enabled"];
        [specifiers addObject:goal_enabled];

        PSTextFieldSpecifier *custom_steps = [PSTextFieldSpecifier preferenceSpecifierNamed:nil
                                                                                     target:self
                                                                                        set:@selector(setValue:forSpecifier:)
                                                                                        get:@selector(getValueForSpecifier:)
                                                                                     detail:Nil
                                                                                       cell:PSEditTextCell
                                                                                       edit:Nil];
        [custom_steps setPlaceholder:@"Set your custom step goal here ..."];
        [custom_steps setIdentifier:@"custom_steps"];
        [custom_steps setProperty:@(YES) forKey:@"enabled"];
        [specifiers addObject:custom_steps];

        if (settings) {
            if ([settings objectForKey:@"goalEnabled"]) {
                if (![[settings objectForKey:@"goalEnabled"] boolValue]) {
                    [specifiers removeLastObject];
                }
            }
        }

        PSSpecifier *secondGroup = [PSSpecifier groupSpecifierWithName:@"Reminder notification"];
        [secondGroup setProperty:@"You'll get a notification informing you how many steps you've done at the chosen time." forKey:@"footerText"];
        [specifiers addObject:secondGroup];

        PSSpecifier *reminder_enabled = [PSSpecifier preferenceSpecifierNamed:@"Reminder notification"
                                                                       target:self
                                                                          set:@selector(setValue:forSpecifier:)
                                                                          get:@selector(getValueForSpecifier:)
                                                                       detail:Nil
                                                                         cell:PSSwitchCell
                                                                         edit:Nil];
        [reminder_enabled setIdentifier:@"reminder_enabled"];
        [reminder_enabled setProperty:@(YES) forKey:@"enabled"];
        [specifiers addObject:reminder_enabled];

        PSSpecifier *datePicker = [PSSpecifier preferenceSpecifierNamed:nil
                                                                 target:self
                                                                    set:NULL
                                                                    get:NULL
                                                                 detail:Nil
                                                                   cell:PSStaticTextCell
                                                                   edit:Nil];
        [datePicker setProperty:[Stepper2DatePicker class] forKey:@"cellClass"];
        [datePicker setProperty:@"205" forKey:@"height"];
        [datePicker setIdentifier:@"datePicker"];
        [datePicker setProperty:@(YES) forKey:@"enabled"];
        [specifiers addObject:datePicker];

        if (settings) {
            if ([settings objectForKey:@"reminderEnabled"]) {
                if (![[settings objectForKey:@"reminderEnabled"] boolValue]) {
                    [specifiers removeLastObject];
                }
            }
        }

        _specifiers = specifiers;
    }

    return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if ([specifier.identifier isEqualToString:@"goal_enabled"]) {
        if (settings) {
            if ([settings objectForKey:@"goalEnabled"]) {
                return [settings objectForKey:@"goalEnabled"];
            } else {
                return @(YES);
            }
        } else {
            return @(YES);
        }
    } else if ([specifier.identifier isEqualToString:@"custom_steps"]) {
        if (settings) {
            if ([settings objectForKey:@"customSteps"]) {
                return [settings objectForKey:@"customSteps"];
            } else {
                return @"10000";
            }
        } else {
            return @"10000";
        }
    } else if ([specifier.identifier isEqualToString:@"reminder_enabled"]) {
        if (settings) {
            if ([settings objectForKey:@"reminderEnabled"]) {
                return [settings objectForKey:@"reminderEnabled"];
            } else {
                return @(YES);
            }
        } else {
            return @(YES);
        }
    }

    return nil;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

    if ([specifier.identifier isEqualToString:@"goal_enabled"]) {
        [settings setObject:value forKey:@"goalEnabled"];
        [settings writeToFile:settingsPath atomically:YES];

        if ([value boolValue]) {
            PSTextFieldSpecifier *custom_steps = [PSTextFieldSpecifier preferenceSpecifierNamed:nil
                                                                                         target:self
                                                                                            set:@selector(setValue:forSpecifier:)
                                                                                            get:@selector(getValueForSpecifier:)
                                                                                         detail:Nil
                                                                                           cell:PSEditTextCell
                                                                                           edit:Nil];
            [custom_steps setPlaceholder:@"Set your custom step goal here ..."];
            [custom_steps setIdentifier:@"custom_steps"];
            [custom_steps setProperty:@(YES) forKey:@"enabled"];

            [self insertSpecifier:custom_steps afterSpecifierID:@"goal_enabled" animated:YES];
        } else {
            [self removeSpecifierID:@"custom_steps" animated:YES];
        }
    } else if ([specifier.identifier isEqualToString:@"custom_steps"]) {
        [settings setObject:value forKey:@"customSteps"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"reminder_enabled"]) {
        [settings setObject:value forKey:@"reminderEnabled"];
        [settings writeToFile:settingsPath atomically:YES];

        if ([value boolValue]) {
            PSSpecifier *datePicker = [PSSpecifier preferenceSpecifierNamed:nil
                                                                     target:self
                                                                        set:NULL
                                                                        get:NULL
                                                                     detail:Nil
                                                                       cell:PSStaticTextCell
                                                                       edit:Nil];
            [datePicker setProperty:[Stepper2DatePicker class] forKey:@"cellClass"];
            [datePicker setProperty:@"205" forKey:@"height"];
            [datePicker setIdentifier:@"datePicker"];
            [datePicker setProperty:@(YES) forKey:@"enabled"];

            [self insertSpecifier:datePicker afterSpecifierID:@"reminder_enabled" animated:YES];
        } else {
            [self removeSpecifierID:@"datePicker" animated:YES];
        }
    }

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shinvou.stepper2/reloadSettings"), NULL, NULL, TRUE);
}

@end

@interface Stepper2AppearanceListController: PSListController { }
@end

@implementation Stepper2AppearanceListController

- (id)specifiers
{
    if (_specifiers == nil) {
        [self setTitle:@"Appearance"];

        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:@"X-Coordinate"];
        [firstGroup setProperty:@"Set the X-Coordinate for the label on the lock screen.\n \nNumber gets rounded down to the nearest whole number." forKey:@"footerText"];

        PSSpecifier *x_coordinate = [PSSpecifier preferenceSpecifierNamed:nil
                                                                   target:self
                                                                      set:@selector(setValue:forSpecifier:)
                                                                      get:@selector(getValueForSpecifier:)
                                                                   detail:Nil
                                                                     cell:PSSliderCell
                                                                     edit:Nil];
        [x_coordinate setIdentifier:@"x_coordinate"];
        [x_coordinate setProperty:@(YES) forKey:@"enabled"];

        int width = [[UIScreen mainScreen] bounds].size.width;

        [x_coordinate setProperty:@(0) forKey:@"min"];
        [x_coordinate setProperty:@(width) forKey:@"max"];
        [x_coordinate setProperty:@(YES) forKey:@"showValue"];

        PSSpecifier *secondGroup = [PSSpecifier groupSpecifierWithName:@"Y-Coordinate"];
        [secondGroup setProperty:@"Set the Y-Coordinate for the label on the lock screen.\n \nNumber gets rounded down to the nearest whole number." forKey:@"footerText"];

        PSSpecifier *y_coordinate = [PSSpecifier preferenceSpecifierNamed:nil
                                                                   target:self
                                                                      set:@selector(setValue:forSpecifier:)
                                                                      get:@selector(getValueForSpecifier:)
                                                                   detail:Nil
                                                                     cell:PSSliderCell
                                                                     edit:Nil];
        [y_coordinate setIdentifier:@"y_coordinate"];
        [y_coordinate setProperty:@(YES) forKey:@"enabled"];

        int height = [[UIScreen mainScreen] bounds].size.height;

        [y_coordinate setProperty:@(0) forKey:@"min"];
        [y_coordinate setProperty:@(height) forKey:@"max"];
        [y_coordinate setProperty:@(YES) forKey:@"showValue"];

        PSSpecifier *thirdGroup = [PSSpecifier groupSpecifierWithName:@"Text size"];
        [thirdGroup setProperty:@"Choose the text size for the label on the lock screen.\n \nNumber gets rounded down to the nearest whole number." forKey:@"footerText"];

        PSSpecifier *text_size = [PSSpecifier preferenceSpecifierNamed:nil
                                                                target:self
                                                                   set:@selector(setValue:forSpecifier:)
                                                                   get:@selector(getValueForSpecifier:)
                                                                detail:Nil
                                                                  cell:PSSliderCell
                                                                  edit:Nil];
        [text_size setIdentifier:@"text_size"];
        [text_size setProperty:@(YES) forKey:@"enabled"];

        [text_size setProperty:@(1) forKey:@"min"];
        [text_size setProperty:@(100) forKey:@"max"];
        [text_size setProperty:@(YES) forKey:@"showValue"];

        PSSpecifier *fourthGroup = [PSSpecifier groupSpecifierWithName:@"Bubble radius"];
        [fourthGroup setProperty:@"Choose the radius for the bubble on the lock screen.\n \nNumber gets rounded down to the nearest whole number." forKey:@"footerText"];

        PSSpecifier *bubble_radius = [PSSpecifier preferenceSpecifierNamed:nil
                                                                target:self
                                                                   set:@selector(setValue:forSpecifier:)
                                                                   get:@selector(getValueForSpecifier:)
                                                                detail:Nil
                                                                  cell:PSSliderCell
                                                                  edit:Nil];
        [bubble_radius setIdentifier:@"bubble_radius"];
        [bubble_radius setProperty:@(YES) forKey:@"enabled"];

        [bubble_radius setProperty:@(0) forKey:@"min"];
        [bubble_radius setProperty:@(200) forKey:@"max"];
        [bubble_radius setProperty:@(YES) forKey:@"showValue"];

        PSSpecifier *fifthGroup = [PSSpecifier groupSpecifierWithName:@"Choose colors"];

        PSSpecifier *text_color = [PSSpecifier preferenceSpecifierNamed:@"Choose text color"
                                                                    target:self
                                                                       set:@selector(setValue:forSpecifier:)
                                                                       get:@selector(getValueForSpecifier:)
                                                                    detail:[PSListItemsController class]
                                                                      cell:PSLinkListCell
                                                                      edit:Nil];
        [text_color setIdentifier:@"text_color"];
        [text_color setProperty:@(YES) forKey:@"enabled"];
        [text_color setValues:@[@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10), @(11), @(12), @(13)]
                       titles:@[@"Black Color", @"Dark Gray Color", @"Light Gray Color", @"White Color", @"Gray Color", @"Red Color", @"Green Color", @"Blue Color", @"Cyan Color", @"Yellow Color", @"Magenta Color", @"Orange Color", @"Purple Color", @"Brown Color"]
                  shortTitles:@[@"Black Color", @"Dark Gray Color", @"Light Gray Color", @"White Color", @"Gray Color", @"Red Color", @"Green Color", @"Blue Color", @"Cyan Color", @"Yellow Color", @"Magenta Color", @"Orange Color", @"Purple Color", @"Brown Color"]];

        PSSpecifier *bubble_color = [PSSpecifier preferenceSpecifierNamed:@"Choose bubble color"
                                                                    target:self
                                                                       set:@selector(setValue:forSpecifier:)
                                                                       get:@selector(getValueForSpecifier:)
                                                                    detail:[PSListItemsController class]
                                                                      cell:PSLinkListCell
                                                                      edit:Nil];
        [bubble_color setIdentifier:@"bubble_color"];
        [bubble_color setProperty:@(YES) forKey:@"enabled"];
        [bubble_color setValues:@[@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10), @(11), @(12), @(13)]
                         titles:@[@"Black Color", @"Dark Gray Color", @"Light Gray Color", @"White Color", @"Gray Color", @"Red Color", @"Green Color", @"Blue Color", @"Cyan Color", @"Yellow Color", @"Magenta Color", @"Orange Color", @"Purple Color", @"Brown Color"]
                    shortTitles:@[@"Black Color", @"Dark Gray Color", @"Light Gray Color", @"White Color", @"Gray Color", @"Red Color", @"Green Color", @"Blue Color", @"Cyan Color", @"Yellow Color", @"Magenta Color", @"Orange Color", @"Purple Color", @"Brown Color"]];

        _specifiers = [NSArray arrayWithObjects:firstGroup, x_coordinate, secondGroup, y_coordinate, thirdGroup, text_size, fourthGroup, bubble_radius, fifthGroup, text_color, bubble_color, nil];
    }

    return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if ([specifier.identifier isEqualToString:@"x_coordinate"]) {
        if (settings) {
            if ([settings objectForKey:@"x"]) {
                return [settings objectForKey:@"x"];
            } else {
                return @(5);
            }
        } else {
            return @(5);
        }
    } else if ([specifier.identifier isEqualToString:@"y_coordinate"]) {
        if (settings) {
            if ([settings objectForKey:@"y"]) {
                return [settings objectForKey:@"y"];
            } else {
                return @(110);
            }
        } else {
            return @(110);
        }
    } else if ([specifier.identifier isEqualToString:@"text_size"]) {
        if (settings) {
            if ([settings objectForKey:@"textSize"]) {
                return [settings objectForKey:@"textSize"];
            } else {
                return @(17);
            }
        } else {
            return @(17);
        }
    } else if ([specifier.identifier isEqualToString:@"bubble_radius"]) {
        if (settings) {
            if ([settings objectForKey:@"bubbleRadius"]) {
                return [settings objectForKey:@"bubbleRadius"];
            } else {
                return @(55);
            }
        } else {
            return @(55);
        }
    } else if ([specifier.identifier isEqualToString:@"text_color"]) {
        if (settings) {
            if ([settings objectForKey:@"textColor"]) {
                return [settings objectForKey:@"textColor"];
            } else {
                return @(3);
            }
        } else {
            return @(3);
        }
    } else if ([specifier.identifier isEqualToString:@"bubble_color"]) {
        if (settings) {
            if ([settings objectForKey:@"bubbleColor"]) {
                return [settings objectForKey:@"bubbleColor"];
            } else {
                return @(0);
            }
        } else {
            return @(0);
        }
    }

    return nil;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

    if ([specifier.identifier isEqualToString:@"x_coordinate"]) {
        [settings setObject:value forKey:@"x"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"y_coordinate"]) {
        [settings setObject:value forKey:@"y"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"text_size"]) {
        [settings setObject:value forKey:@"textSize"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"bubble_radius"]) {
        [settings setObject:value forKey:@"bubbleRadius"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"text_color"]) {
        [settings setObject:value forKey:@"textColor"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"bubble_color"]) {
        [settings setObject:value forKey:@"bubbleColor"];
        [settings writeToFile:settingsPath atomically:YES];
    }

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shinvou.stepper2/reloadSettings"), NULL, NULL, TRUE);
}

@end

@interface Stepper2SettingsListController: PSListController { }
@end

@implementation Stepper2SettingsListController

- (id)specifiers
{
    if (_specifiers == nil) {
        [self setTitle:@"Stepper 2"];

        PSSpecifier *banner = [PSSpecifier preferenceSpecifierNamed:nil
                                                             target:self
                                                                set:NULL
                                                                get:NULL
                                                             detail:Nil
                                                               cell:PSStaticTextCell
                                                               edit:Nil];
        [banner setProperty:[Stepper2Banner class] forKey:@"cellClass"];
        [banner setProperty:@"205" forKey:@"height"];

        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:@"Steps on lockscreen"];

        PSSpecifier *lockscreen_enabled = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                                         target:self
                                                                            set:@selector(setValue:forSpecifier:)
                                                                            get:@selector(getValueForSpecifier:)
                                                                         detail:Nil
                                                                           cell:PSSwitchCell
                                                                           edit:Nil];
        [lockscreen_enabled setIdentifier:@"lockscreen_enabled"];
        [lockscreen_enabled setProperty:@(YES) forKey:@"enabled"];

        PSSpecifier *slidetounlock = [PSSpecifier preferenceSpecifierNamed:@"Replace 'slide to unlock'"
                                                                    target:self
                                                                       set:@selector(setValue:forSpecifier:)
                                                                       get:@selector(getValueForSpecifier:)
                                                                    detail:Nil
                                                                      cell:PSSwitchCell
                                                                      edit:Nil];
        [slidetounlock setIdentifier:@"slidetounlock"];
        [slidetounlock setProperty:@(YES) forKey:@"enabled"];

        PSSpecifier *secondGroup = [PSSpecifier groupSpecifierWithName:@"Steps on statusbar"];

        PSSpecifier *statusbar_enabled = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                                        target:self
                                                                           set:@selector(setValue:forSpecifier:)
                                                                           get:@selector(getValueForSpecifier:)
                                                                        detail:Nil
                                                                          cell:PSSwitchCell
                                                                          edit:Nil];
        [statusbar_enabled setIdentifier:@"statusbar_enabled"];
        [statusbar_enabled setProperty:@(YES) forKey:@"enabled"];

        PSTextFieldSpecifier *separator = [PSTextFieldSpecifier preferenceSpecifierNamed:nil
                                                                                  target:self
                                                                                     set:@selector(setValue:forSpecifier:)
                                                                                     get:@selector(getValueForSpecifier:)
                                                                                  detail:Nil
                                                                                    cell:PSEditTextCell
                                                                                    edit:Nil];
        [separator setPlaceholder:@"Enter some special character ..."];
        [separator setIdentifier:@"separator"];
        [separator setProperty:@(YES) forKey:@"enabled"];

        PSSpecifier *thirdGroup = [PSSpecifier groupSpecifierWithName:@"Customization"];

        PSSpecifier *customize_notifications = [PSSpecifier preferenceSpecifierNamed:@"Customize notifications"
                                                                              target:self
                                                                                 set:@selector(setValue:forSpecifier:)
                                                                                 get:@selector(getValueForSpecifier:)
                                                                              detail:[Stepper2NotificationsListController class]
                                                                                cell:PSLinkCell
                                                                                edit:Nil];
        [customize_notifications setIdentifier:@"customize_notifications"];
        [customize_notifications setProperty:@(YES) forKey:@"enabled"];

        PSSpecifier *customize_appearance = [PSSpecifier preferenceSpecifierNamed:@"Customize Stepper's appearance"
                                                                           target:self
                                                                              set:@selector(setValue:forSpecifier:)
                                                                              get:@selector(getValueForSpecifier:)
                                                                           detail:[Stepper2AppearanceListController class]
                                                                             cell:PSLinkCell
                                                                             edit:Nil];
        [customize_appearance setIdentifier:@"customize_appearance"];
        [customize_appearance setProperty:@(YES) forKey:@"enabled"];

        PSSpecifier *fourthGroup = [PSSpecifier groupSpecifierWithName:@"Time interval"];
        [fourthGroup setProperty:@"Choose a time interval of which the steps should get fetched from." forKey:@"footerText"];

        PSSpecifier *time_interval = [PSSpecifier preferenceSpecifierNamed:@"Set time interval"
                                                                    target:self
                                                                       set:@selector(setValue:forSpecifier:)
                                                                       get:@selector(getValueForSpecifier:)
                                                                    detail:[PSListItemsController class]
                                                                      cell:PSLinkListCell
                                                                      edit:Nil];
        [time_interval setIdentifier:@"time_interval"];
        [time_interval setProperty:@(YES) forKey:@"enabled"];
        [time_interval setValues:@[@(0), @(1), @(2), @(3), @(4), @(5), @(6), @(7)]
                             titles:@[@"Today", @"Today and yesterday", @"Today and last two days", @"Today and last three days", @"Today and last four days", @"Today and last five days", @"Today and last six days", @"Today and last seven days"]
                        shortTitles:@[@"Today", @"Today and yesterday", @"Today and last two days", @"Today and last three days", @"Today and last four days", @"Today and last five days", @"Today and last six days", @"Today and last seven days"]];

        PSSpecifier *fifthGroup = [PSSpecifier groupSpecifierWithName:@"contact developer"];
        [fifthGroup setProperty:@"Feel free to follow me on twitter for any updates on my apps and tweaks or contact me for support questions.\n \nThis tweak is Open-Source, so make sure to check out my GitHub." forKey:@"footerText"];

        PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"twitter"
                                                              target:self
                                                                 set:nil
                                                                 get:nil
                                                              detail:Nil
                                                                cell:PSLinkCell
                                                                edit:Nil];
        twitter.name = @"@biscoditch";
        twitter->action = @selector(openTwitter);
        [twitter setIdentifier:@"twitter"];
        [twitter setProperty:@(YES) forKey:@"enabled"];
        [twitter setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Stepper2Settings.bundle/twitter.png"] forKey:@"iconImage"];

        PSSpecifier *github = [PSSpecifier preferenceSpecifierNamed:@"github"
                                                             target:self
                                                                set:nil
                                                                get:nil
                                                             detail:Nil
                                                               cell:PSLinkCell
                                                               edit:Nil];
        github.name = @"https://github.com/shinvou";
        github->action = @selector(openGithub);
        [github setIdentifier:@"github"];
        [github setProperty:@(YES) forKey:@"enabled"];
        [github setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/Stepper2Settings.bundle/github.png"] forKey:@"iconImage"];

        _specifiers = [NSArray arrayWithObjects:banner, firstGroup, lockscreen_enabled, slidetounlock, secondGroup, statusbar_enabled, separator, thirdGroup, customize_notifications, customize_appearance, fourthGroup, time_interval, fifthGroup, twitter, github, nil];
    }

    return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if ([specifier.identifier isEqualToString:@"lockscreen_enabled"]) {
        if (settings) {
            if ([settings objectForKey:@"showLabel"]) {
                return [settings objectForKey:@"showLabel"];
            } else {
                return [NSNumber numberWithBool:YES];
            }
        } else {
            return [NSNumber numberWithBool:YES];
        }
    } else if ([specifier.identifier isEqualToString:@"slidetounlock"]) {
        if (settings) {
            if ([settings objectForKey:@"showSlider"]) {
                return [settings objectForKey:@"showSlider"];
            } else {
                return [NSNumber numberWithBool:YES];
            }
        } else {
            return [NSNumber numberWithBool:YES];
        }
    } else if ([specifier.identifier isEqualToString:@"statusbar_enabled"]) {
        if (settings) {
            if ([settings objectForKey:@"showStatusBar"]) {
                return [settings objectForKey:@"showStatusBar"];
            } else {
                return [NSNumber numberWithBool:YES];
            }
        } else {
            return [NSNumber numberWithBool:YES];
        }
    } else if ([specifier.identifier isEqualToString:@"separator"]) {
        if (settings) {
            if ([settings objectForKey:@"statusBarSeparator"]) {
                return [settings objectForKey:@"statusBarSeparator"];
            } else {
                return @"|";
            }
        } else {
            return @"|";
        }
    } else if ([specifier.identifier isEqualToString:@"time_interval"]) {
        if (settings) {
            if ([settings objectForKey:@"timeInterval"]) {
                return [settings objectForKey:@"timeInterval"];
            } else {
                return @(0);
            }
        } else {
            return @(0);
        }
    }

    return nil;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];

    if ([specifier.identifier isEqualToString:@"lockscreen_enabled"]) {
        [settings setObject:value forKey:@"showLabel"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"slidetounlock"]) {
        [settings setObject:value forKey:@"showSlider"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"statusbar_enabled"]) {
        [settings setObject:value forKey:@"showStatusBar"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"separator"]) {
        [settings setObject:value forKey:@"statusBarSeparator"];
        [settings writeToFile:settingsPath atomically:YES];
    } else if ([specifier.identifier isEqualToString:@"time_interval"]) {
        [settings setObject:value forKey:@"timeInterval"];
        [settings writeToFile:settingsPath atomically:YES];
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"Stepper2TimeIntervalChanged" object:nil userInfo:nil];
    }

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shinvou.stepper2/reloadSettings"), NULL, NULL, TRUE);
}

- (void)openTwitter
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=biscoditch"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/biscoditch"]];
    }
}

- (void)openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/shinvou"]];
}

@end
