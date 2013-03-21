//
//  SettingSource.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingSource : NSObject
{
    NSMutableArray       *settings;
    NSMutableArray       *countriesList;
}

+ (SettingSource *) source;

- (NSArray *) countries;

- (int) sections;
- (int) rowsForSection:(int)section;
- (NSString *) nameRow:(int)row inSection:(int)section;
- (Class) classForCellInRow:(int)row inSection:(int)section;
- (NSString *) identifierForCellInRow:(int)row inSection:(int)section;
- (NSString *) jsonKeyForRow:(int)row inSection:(int)section;
- (void) saveValue:(NSString *)value toSourceForRow:(int)row section:(int)section;

@end
