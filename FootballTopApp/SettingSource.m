//
//  SettingSource.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 10/5/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "SettingSource.h"
#import "DataSource.h"
#import "NetworkTaskGenerator.h"

@implementation SettingSource

static SettingSource *_source = nil;

+ (SettingSource *) source
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _source = [[SettingSource alloc] init];
    });
    
    return _source;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings.plist" ofType:nil];
        settings = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    
    return self;
}

- (void) dealloc
{
    [settings removeAllObjects];
    [settings release];
    [countriesList release];
    [super dealloc];
}

- (NSArray *) countries
{
    if (!countriesList)
    {
        NetworkTaskGenerator *task = [NetworkTaskGenerator generateTaskForGetCountriesWithLanguage:@"ru" completeBlock:^(DispatchTask *item) {
            if (((NetworkTaskGenerator *)item).isSuccessful)
            {
                countriesList = [[NSMutableArray alloc] init];
                
                NSDictionary *response = [(NetworkTaskGenerator *)item objectFromString];
                for (NSString *key in response)
                {
                    if ([[response objectForKey:key] length] > 0)
                    {
                        NSDictionary *country = [NSDictionary dictionaryWithObjectsAndKeys:key, @"ID",
                                                 [response objectForKey:key], @"Country", nil];
                        [countriesList addObject:country];
                    }
                }
                
                [countriesList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSString *country1 = [(NSDictionary *)obj1 objectForKey:@"Country"];
                    NSString *country2 = [(NSDictionary *)obj2 objectForKey:@"Country"];
                    
                    return [country1 compare:country2];
                }];
            }
        }];
        [[DispatchTools Instance] addTask:task];
    }
    
    return countriesList;
}

- (int) sections
{
    return [settings count];
}

- (int) rowsForSection:(int)section
{
    NSArray *_section = [settings objectAtIndex:section];
    return [_section count];
}

- (NSString *) nameRow:(int)row inSection:(int)section
{
    NSArray *_section = [settings objectAtIndex:section];
    NSDictionary *rowInfo = [_section objectAtIndex:row];
    NSString *nameRow = [rowInfo objectForKey:@"key"];
    
    return nameRow;
}

- (Class) classForCellInRow:(int)row inSection:(int)section
{
    NSArray *_section = [settings objectAtIndex:section];
    NSDictionary *rowInfo = [_section objectAtIndex:row];
    NSString *nameClass = [rowInfo objectForKey:@"class"];
    
    return NSClassFromString(nameClass);
}

- (NSString *) identifierForCellInRow:(int)row inSection:(int)section
{
    NSArray *_section = [settings objectAtIndex:section];
    NSDictionary *rowInfo = [_section objectAtIndex:row];
    NSString *identifier = [rowInfo objectForKey:@"identifier"];
    
    return identifier;
}

- (NSString *) jsonKeyForRow:(int)row inSection:(int)section
{
    NSArray *_section = [settings objectAtIndex:section];
    NSDictionary *rowInfo = [_section objectAtIndex:row];
    NSString *jsonKey = [rowInfo objectForKey:@"jsonKey"];
    
    return jsonKey;

}

- (void) saveValue:(NSString *)value toSourceForRow:(int)row section:(int)section
{
    NSArray *_section = [settings objectAtIndex:section];
    NSDictionary *rowInfo = [_section objectAtIndex:row];
    NSString *nameRow = [rowInfo objectForKey:@"key"];
    
    [[DataSource data] setObject:value forKey:nameRow];
}

@end
