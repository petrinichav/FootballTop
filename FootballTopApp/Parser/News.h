//
//  News.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/25/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface News : NSObject
{
    
}

@property (nonatomic, copy)    NSString     *smallImageURL;
@property (nonatomic, copy)    NSString     *bigImageURL;
@property (nonatomic, copy)    NSString     *title;
@property (nonatomic, copy)    NSString     *htmlBody;
@property (nonatomic, copy)    NSString     *htmlFullBody;
@property (nonatomic, retain)  NSDictionary *author;
@property (nonatomic) int newsID;
@property (nonatomic) int comments;
@property (nonatomic) NSTimeInterval pubDate;

@end
