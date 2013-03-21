//
//  RSSParser.h
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/25/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import <Foundation/Foundation.h>

@class News;

@interface RSSParser : NSObject<NSXMLParserDelegate>
{
    NSString         *_currentElement;
    
    NSMutableString         *_title, *_descritption, *_guid, *_creator, *_pubDate;
    
    NSMutableArray   *_newsArray;
    
    News             *_news;
}

+ (id) rssParser;

- (id) initRssParser;

- (int) numberOfNews;
- (News *) newsWithIndex:(int)index;

@end
