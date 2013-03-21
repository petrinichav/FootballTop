//
//  NetworkTaskGenerator.m
//  iPhoneGraduateApp
//
//  Created by Alex Petrinich on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkTaskGenerator.h"
#import "Reachability.h"
#import "DataSource.h"
#import "AlertModule.h"
#import "FTItem.h"

@implementation NetworkTaskGenerator
@synthesize _data;
@synthesize isSuccessful;
@synthesize statusCode;
@synthesize isShowPopupForExpiringEvent;

-(void) dealloc
{
    [_url release];
    [jsonParser release];
    [jsonWriter release];
    [_connection release];
    [_data release];
    [_intenetError release];
    [super dealloc];
}

- (BOOL) isInternetConnecting
{
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    BOOL isConnect;
    if (status == ReachableViaWiFi || status == ReachableViaWWAN)
    {
        isConnect = YES;
    }
    else
    {
        isConnect = NO;
        isSuccessful = NO;
        [[AlertModule instance] createAlertWithType:InternetError buttons:1 withCancelBlock:^(UIAlertView *_alert) {
            
        } completeBlock:^(UIAlertView *_alert) {
            
        }];
        [[AlertModule instance] showAlert];
    }
    
    return isConnect;
}

-(void) finishNetworkTask
{
    if(_connection)
    {
        dbgLog(@"%@ finised",[self description]);
        RELEASE(_connection);
        _connection = nil;
    }
    [super finishNetworkTask];
}

- (void) generateRequestWithString
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [request setHTTPMethod:@"POST"];
    NSString *requestBody = [NSString stringWithFormat:@"username=%@&password=%@&_spring_security_remember_me=",[params objectForKey:@"email"],
                             [params objectForKey:@"password"]];
    if ([[params objectForKey:@"_spring_security_remember_me"] boolValue]) {
        requestBody = [requestBody stringByAppendingString:@"true"];
    }else {
        requestBody = [requestBody stringByAppendingString:@"false"];
    }
    
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[requestBody  dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"body = %@ method = %@", requestBody, [request HTTPMethod]);
    NSLog(@"headers = %@",request.allHTTPHeaderFields);
    
    [request setHTTPShouldHandleCookies:YES];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:(id)self];
    [_connection start];
    
    [request release];
    
}


- (void) generateRequest
{
    dbgLog(@"URL = %@", _url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [request setHTTPMethod:@"POST"];    
    NSString *requestBody = [jsonWriter stringWithObject:params];    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setHTTPBody:[requestBody  dataUsingEncoding:NSUTF8StringEncoding]];
    
    dbgLog(@"body = %@ method = %@", requestBody, [request HTTPMethod]);
    dbgLog(@"headers = %@",request.allHTTPHeaderFields);
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:(id)self];
    [_connection start];
    
    [request release]; 
}

- (void) generateDeleteRequest
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [request setHTTPMethod:@"DELETE"];    
    NSString *requestBody = [jsonWriter stringWithObject:params];    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setHTTPBody:[requestBody  dataUsingEncoding:NSUTF8StringEncoding]];
    
    dbgLog(@"body = %@ method = %@", requestBody, [request HTTPMethod]);
    dbgLog(@"headers = %@",request.allHTTPHeaderFields);
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:(id)self];
    [_connection start];
    
    [request release]; 
}

- (void) generateRequestForUploadPhoto:(NSData *)imgData
{
    dbgLog(@"URL = %@", _url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [request setHTTPMethod:@"POST"];
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = [(NSString*)CFUUIDCreateString(nil, uuid) autorelease];
    CFRelease(uuid);
    NSString *boundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *postName = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"files\"; filename=\"photo.jpg\"\r\n"];
    [body appendData:[postName dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n"dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imgData];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n%@",[params objectForKey:@"uid"]];
    str = [str stringByAppendingFormat:@"\r\n--%@--\r\n",boundary];
    
    NSLog(@"body = %@",str);
    
    [body appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    NSString *bodyStr = [[NSString alloc] initWithData:body encoding:[NSString defaultCStringEncoding]];
    NSLog(@"header = %@",[request allHTTPHeaderFields]);
    NSLog(@"body = %@ method = %@", bodyStr, [request HTTPMethod]);
    [bodyStr release];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:(id)self];
    [_connection start];
    
    [request release];

}


+ (NSURL* ) urlForLang:(NSString *)lang method:(NSString *)method params:(NSDictionary *) params
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@api?language=%@&method=%@", SERVER_URL, lang, method]];
    return url;
}

+ (NetworkTaskGenerator *) generateTaskForLanguage:(NSString *)lang Login:(NSString *) login password:(NSString *)pass completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/login.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:login forKey:@"username"];
    [params setObject:pass forKey:@"password"];    
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForLogoutWithCompleteBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/logout.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
       
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForRegistrationWithUser:(NSString *) user email:(NSString *)email country:(int)country language:(NSString *)lang completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/register.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:user forKey:@"user_name"];
    [params setObject:email forKey:@"mail"];
    [params setObject:[NSNumber numberWithInt:country] forKey:@"country"];
    [params setObject:lang forKey:@"language"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForPasswordReestablishingWithEmail:(NSString *)email completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/user_password_request.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:email forKey:@"mail"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}


+ (NetworkTaskGenerator *) generateTaskForGetCountriesWithLanguage:(NSString *)lang completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/get_countries.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:lang forKey:@"language"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}


+ (NetworkTaskGenerator *) generateTaskForTestWithCompleteBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@votingapi/set_votes.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:13791] forKey:@"entity_id"];
    [dict setObject:[NSNumber numberWithInt:2] forKey:@"votes"];
    //NSArray *array = [NSArray arrayWithObject:dict];
    
    [params setObject:dict forKey:@"votes"];
    [params setObject:[NSDictionary dictionary] forKey:@"criteria"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForGetRateWithCompleteBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@votingapi/select_votes.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:@"results" forKey:@"type"];
    //NSArray *array = [NSArray arrayWithObject:dict];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:10776] forKey:@"entity_id"];
    [params setObject:dict forKey:@"criteria"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForUploadProfileImage:(NSData *) imageData completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/user_avatar_upload.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[[DataSource data] objectForKey:USER_ID] forKey:@"uid"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequestForUploadPhoto:imageData];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForGetNewsCategoriesForLanguage:(NSString *)lang withCompleteBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/news_categories.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:lang forKey:@"language"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForGetListNewsWithViewMode:(int)viewMode page:(int)page limit:(int)limit category:(int)category newsType:(NSString *)newsType createdafter:(int) timestamp completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/news.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *newsViewMode = @"";
    switch (viewMode) {
        case NewsViewModeMini:
            newsViewMode =  @"mini";
            break;
        case NewsViewModeTeaser:
            newsViewMode =  @"teaser";
            break;
        case NewsViewModeFull:
            newsViewMode =  @"full";
            break;
            
        default:
            break;
    }
    if (timestamp > 0)
        [params setObject:[NSNumber numberWithInt:timestamp] forKey:@"created_after"];
    [params setObject:newsViewMode forKey:@"view_mode"];
    [params setObject:@"ru" forKey:@"language"];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:limit] forKey:@"limit"];
    if ([newsType length] > 0)
        [params setObject:newsType forKey:@"news_type"];
    if (category >= 0)
        [params setObject:[NSNumber numberWithInt:category] forKey:@"category"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForGetNewsWithID:(NSString *)ID completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/news.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:ID forKey:@"nid"];
    [params setObject:@"full" forKey:@"view_mode"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForGetItems:(NSString *)itemType language:(NSString *) lang page:(int)page limit:(int)limit completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/object_list.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:itemType forKey:@"type"];
    [params setObject:lang forKey:@"language"];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:limit] forKey:@"limit"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForSearchText:(NSString *)text language:(NSString *) lang page:(int)page limit:(int)limit completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/search.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:text forKey:@"keywords"];
    [params setObject:lang forKey:@"language"];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:limit] forKey:@"limit"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}


+ (NetworkTaskGenerator *) generateTaskForGetItemWithID:(int)ID completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/object.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%d", ID] forKey:@"nid"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForGetCommentsForNewsID:(int)ID page:(int)page limit:(int)limit completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/comment_load.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:ID] forKey:@"nid"];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:limit] forKey:@"limit"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}


+ (NetworkTaskGenerator *) generateTaskForGetVotesForObject:(FTItem *)obj completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@votingapi/select_votes.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"results" forKey:@"type"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:obj.nID] forKey:@"entity_id"];
    [dict setObject:@"node" forKey:@"entity_type"];
    [dict setObject:@"ftop:object" forKey:@"tag"];
    [dict setObject:@"votes" forKey:@"value_type"];
    
    [params setObject:dict forKey:@"criteria"];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"single"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForGetProfileWithID:(int)uid completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/user_profile_load.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (uid != 0)
        [params setObject:[NSNumber numberWithInt:uid] forKey:@"uid"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForAddVoteForNodeId:(int)nid completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/set_votes.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:nid] forKey:@"nid"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForAddCommentForNodeId:(int)nid comment:(NSString *)comment completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/comment_create.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:nid] forKey:@"nid"];
    [params setObject:comment forKey:@"comment"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForChangePassword:(NSString *)newPassword oldPassword:(NSString *) oldPassword completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/user_change_password.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:newPassword forKey:@"new_password"];
    [params setObject:oldPassword forKey:@"old_password"];
    [params setObject:[[DataSource data] objectForKey:USER_ID] forKey:@"uid"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForUpdateUserInfo:(NSDictionary *)userInfo completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/user_profile_update.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userInfo forKey:@"data"];
    [params setObject:[[DataSource data] objectForKey:USER_ID] forKey:@"uid"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

+ (NetworkTaskGenerator *) generateTaskForDeleteFavouriteObjectWithID:(int)ID completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/user_delete_favourite.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:ID] forKey:@"nid"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
    
}

+ (NetworkTaskGenerator *) generateTaskForAddFavouriteObjectWithID:(int)ID completeBlock:(DispatchBlock) completeBlock
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/user_set_favourite.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:ID] forKey:@"nid"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
    
}

+ (NetworkTaskGenerator *) generateTaskForGetPlotDataForObject:(int)ID completeBlock:(DispatchBlock) completeBlock
{//http://www.footballtop.ru/service/ftop/object_load_chart.json
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@ftop/object_load_chart.json", SERVER_URL]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:ID] forKey:@"nid"];
    
    NetworkTaskGenerator *task = [[NetworkTaskGenerator alloc] initWithURL:url params:params executeBlock:^(DispatchTask *item) {
        if ([(NetworkTaskGenerator *)item isInternetConnecting])
            [(NetworkTaskGenerator *)item  generateRequest];
        else
            [(NetworkTaskGenerator *)item finishNetworkTask];
    } andCompletitionBlock:completeBlock];
    
    return AUTORELEASE(task);
}

- (id) initWithURL:(NSURL *)url params:(NSMutableDictionary *)parametrs executeBlock:(DispatchBlock)_executeBlock andCompletitionBlock:(DispatchBlock)_completeBlock
{
    if ((self = [super initNetworkTaskWithExecuteBlock:_executeBlock andCompletitionBlock:_completeBlock]))
    {
        _url = RETAIN(url);
        [params addEntriesFromDictionary:parametrs];
        isNetwork = YES;
        
        jsonWriter = [[SBJsonWriter alloc] init];
        jsonParser = [[SBJsonParser alloc] init];    
        
        _data      = [[NSMutableString alloc] init];
        
        isShowPopupForExpiringEvent = YES;
    }
    return self;
}


- (id) objectFromString
{
    return [jsonParser objectWithString:_data];
}

#pragma mark URLConeection Delegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    dbgLog(@"authMethod = %@", challenge.protectionSpace.authenticationMethod);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
                           forAuthenticationChallenge:challenge];
        }
    else 
        {
             [challenge.sender cancelAuthenticationChallenge:challenge];
        }
   
    dbgLog(@"challenge.error = %@ challenge-response = %@", challenge.error, challenge.failureResponse);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(_connection!=connection)
    {
        return;
    }
    isSuccessful = NO;
    dbgLog(@"%@ error = %@",[self description], error);
    self.intenetError = error;
    [self finishNetworkTask];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(_connection!=connection)
    {
        return;
    }
    NSString *localiz = [NSHTTPURLResponse localizedStringForStatusCode:[(NSHTTPURLResponse*)response statusCode]];
    dbgLog(@"response = %d local = %@", [(NSHTTPURLResponse*)response statusCode], localiz);
           
    if([(NSHTTPURLResponse*)response statusCode]==200)
    {
        isSuccessful = YES;        
    }else
    {
        isSuccessful = NO;
        self.statusCode = [(NSHTTPURLResponse*)response statusCode];       
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    if(_connection!=connection)
    {
        return;
    }
    
    if(self.isCancelled)
    {
        [self finishNetworkTask];
    }else
    {
        
        if (data != nil)
        {
            NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dbgLog(@"response = %@", response);
            [_data appendString:response];  
            
            [response release];
        }
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(_connection!=connection)
    {
        return;
    }
    [self finishNetworkTask];
}


@end
