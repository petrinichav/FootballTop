//
//  FPUser.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/11/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "FTUser.h"
#import "FTItem.h"

#define ABOUT @"О себе"
#define BDAY  @"Дата рождения"
#define NAME  @"Реальное имя"
#define COUNTRY @"Страна"
#define CLUB @"club"
#define COACH @"coach"
#define TEAM @"country"
#define PLAYER @"player"

@implementation FTUser

- (void) dealloc
{
    [_info release];
    [_name release];
    [_bDate release];
    [_about release];
    [_country release];
    [_avatar release];
    [_favouritesItems release];
    [super dealloc];
}

- (void) parseDictionary:(NSDictionary *)data forKey:(NSString *) headKey
{
    for (NSString *key in data)
    {
        NSString *value = [data objectForKey:key];
        if (value != nil)
        {
            if ([key isEqualToString:ABOUT])
            {
                self.about = value;
            }
            else if ([key isEqualToString:BDAY])
            {
                self.bDate = value;
            }
            else if ([key isEqualToString:NAME])
            {
                self.name = value;
            }
            else if ([key isEqualToString:COUNTRY])
            {
                self.country = value;
            }
            dbgLog(@"%@: %@ = %@", headKey, key, [data objectForKey:key]);
        }
    }
}

- (void) parseUserInfo
{
    if (self.typeOfUser == User)
    {
        self.favouritesItems = [NSMutableArray array];
        
        NSDictionary *profile = [self.info objectForKey:@"profile"];
        for (NSString *k in profile)
        {
            NSDictionary *data = [profile objectForKey:k];
            if ([data isKindOfClass:[NSDictionary class]])
            {
                [self parseDictionary:data forKey:k];
            }
            else if ([data isKindOfClass:[NSNumber class]])
            {
                self.rating = [(NSString *)data intValue];
            }
        }
        
        NSDictionary *favourites = [self.info objectForKey:@"favourites"];
        for (NSString *favKey in favourites)
        {
            NSDictionary *favItem = [favourites objectForKey:favKey];
            if (favItem)
            {
                FTItem *item = nil;
                if ([favKey isEqualToString:CLUB])
                {
                    item = [FTItem createItemWithType:ItemClub info:favItem];
                }
                else if ([favKey isEqualToString:TEAM])
                {
                    item = [FTItem createItemWithType:ItemTeam info:favItem];
                }
                else if ([favKey isEqualToString:COACH])
                {
                    item = [FTItem createItemWithType:ItemCoach info:favItem];
                }
                else if ([favKey isEqualToString:PLAYER])
                {
                    item = [FTItem createItemWithType:ItemPlayer info:favItem];
                }
                if (item!= nil)
                    [self.favouritesItems addObject:item];

            }
        }
        self.avatar = [self.info objectForKey:@"avatar"];
    }
}

- (BOOL) contentInFavouriteObjectWithID:(int)nID
{
    for (FTItem *item in self.favouritesItems)
    {
        if (item.nID == nID)
            return YES;
    }
    
    return NO;
}

@end
