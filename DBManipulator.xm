//
//  DBManipulator.xm
//  Stepper 2
//
//  Created by Timm Kandziora on 16.11.14.
//  Copyright (c) 2014 Timm Kandziora (shinvou). All rights reserved.
//

#import "Stepper2-Header.h"

@implementation DBManipulator

- (id)initDBManipulator
{
	self = [super init];

	if (self) {
		_database = [[NSMutableArray alloc] init];
		
		return self;
	}

	return nil;
}

- (void)runQuery:(const char *)query executable:(BOOL)executable
{
	sqlite3 *database;

	NSString *databasePath = @"/var/mobile/Library/TCC/TCC.db";

	BOOL result_open = sqlite3_open([databasePath UTF8String], &database);

	if (result_open == SQLITE_OK) {
		sqlite3_stmt *statement;

		BOOL result_prepare = sqlite3_prepare_v2(database, query, -1, &statement, NULL);

		if (result_prepare == SQLITE_OK) {
			if (executable) {
				BOOL result_query = sqlite3_step(statement);

				if (result_query == SQLITE_DONE) {
					NSLog(@"Successfully written to database.");
				} else {
					NSLog(@"Following error occurred while writing to database: %s", sqlite3_errmsg(database));
				}
			} else {
				NSMutableArray *databaseData;

				while (sqlite3_step(statement) == SQLITE_ROW) {
					databaseData = [[NSMutableArray alloc] init];

					int columnCount = sqlite3_column_count(statement);

					for (int i = 0; i < columnCount; i++) {
						char *columnData = (char *)sqlite3_column_text(statement, i);

						if (columnData != NULL) {
							[databaseData addObject:[NSString stringWithUTF8String:columnData]];
						}
					}

					if (databaseData.count > 0) {
						[_database addObject:databaseData];
					}
				}
			}
		} else {
			NSLog(@"%s", sqlite3_errmsg(database));
		}

		sqlite3_finalize(statement);
	}

	sqlite3_close(database);
}

- (NSArray *)returnDatabase
{
	NSString *databaseQuery = @"select * from access";

    [self runQuery:[databaseQuery UTF8String] executable:NO];

    return _database;
}


- (void)addSpringBoardEntryToDatabase
{
	NSString *databaseQuery = @"insert into 'access' values('kTCCServiceMotion', 'com.apple.springboard', 0, 1, 0, NULL)";

    [self runQuery:[databaseQuery UTF8String] executable:YES];
}

@end
