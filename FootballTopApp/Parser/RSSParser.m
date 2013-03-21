//
//  RSSParser.m
//  FootballTopApp
//
//  Created by Alex Petrinich on 9/25/12.
//  Copyright (c) 2012 Alex Petrinich. All rights reserved.
//

#import "RSSParser.h"
#import "News.h"

#define SMALLIMAGEURL @"http://www.footballtop.ru/sites/default/files/styles/news_full/public/photos/news"
#define BIGIMAGEURL   @"http://www.footballtop.ru/sites/default/files/photos/news"

@implementation RSSParser

+ (id) rssParser
{
    RSSParser *parser = [[RSSParser alloc] initRssParser];
    return [parser autorelease];
}

- (void) dealloc
{
    [super dealloc];
    [_newsArray release];
    [_news release];
}

- (id) initRssParser
{
    if ((self = [super init]))
    {
        _newsArray = [[NSMutableArray alloc] init];
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:NEWS_RSS]];
        parser.delegate = (id)self;
        [parser parse];
        [parser release];
    }
    
    return self;
}

- (int) numberOfNews
{
    return [_newsArray count];
}

- (News *) newsWithIndex:(int)index
{
    return [_newsArray objectAtIndex:index];
}

#pragma mark XMLDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _currentElement = [elementName retain];
    dbgLog(@"elementStart = %@", elementName);
    if ([elementName isEqualToString:@"item"])
    {
        _news = [News new];
        _title = [NSMutableString string];
        _descritption = [NSMutableString string];
        _guid         = [NSMutableString string];
        _creator      = [NSMutableString string];
        _pubDate      = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    dbgLog(@"elementend = %@", elementName);
    if ([elementName isEqualToString:@"item"])
    {
        _news.title = _title;
        _news.description = _descritption;
        
        NSRange range = [_guid rangeOfString:@" "];
        NSString *ID = [_guid substringToIndex:range.location];
        _news.newsID = ID;
        
        _news.pubDate = _pubDate;
        _news.creator = _creator;
        
        [_newsArray addObject:_news];
        [_news release];
        _news = nil;
    }
    [_currentElement release];
    _currentElement = nil;
    dbgLog(@"count = %d", [_currentElement retainCount]);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([_currentElement isEqualToString:@"title"])
    {
        [_title appendString:string];
    }
    else if ([_currentElement isEqualToString:@"description"])
    {
        int lengthSmallImageURL = [SMALLIMAGEURL length];
        int lengthBigImageURL   = [BIGIMAGEURL length];
        if ([string length] >= lengthSmallImageURL)
        {
            NSString *subStrSmallURL = [string substringToIndex:lengthSmallImageURL];
            NSString *subStrBigURL = [string substringToIndex:lengthBigImageURL];
            if ([subStrBigURL hasSuffix:BIGIMAGEURL])
            {
                _news.bigImageURL = string;
            }
            else if ([subStrSmallURL hasSuffix: SMALLIMAGEURL])
            {
                _news.smallImageURL = string;
            }
        }
        [_descritption appendString:string];
    }
    else if ([_currentElement isEqualToString:@"guid"])
    {
        [_guid appendString:string];
    }
    else if ([_currentElement isEqualToString:@"dc:creator"])
    {
        [_creator appendString:string];
    }
    else if ([_currentElement isEqualToString:@"pubDate"])
    {
        [_pubDate appendString:string];
    }
}

//- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
//{
//     dbgLog(@"name = %@ val = %@", name, value);
//}
//
//- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
//{
//    
//}
//
//- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
//{
//    dbgLog(@"element = %@ model = %@", elementName, model);
//}
//
//- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
//{
//    dbgLog(@"data = %@", data);
//}
//
//- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
//{
//	NSString *someString = [[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding] autorelease];
//	dbgLog(@"some = %@", someString);
//}

@end
