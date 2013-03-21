//
//  FPUser.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/11/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTUser : NSObject
{
}

@property int typeOfUser;
@property (nonatomic, retain) NSDictionary  *info;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *bDate;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *about;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic) int rating;

@property (nonatomic, retain) NSMutableArray *favouritesItems;

- (void) parseUserInfo;

- (BOOL) contentInFavouriteObjectWithID:(int)nID;

@end
