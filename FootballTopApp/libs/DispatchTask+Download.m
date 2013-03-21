//
//  DispatchTask+Download.m
//  IPhoneSpeedTracker
//
//  Created by destman on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DispatchTask+Download.h"
#import "DataSource.h"
#import "SBJsonWriter.h"

#define TimeOut 10

NSString *kDispatchTaskDownloadUseBGTask = @"kDispatchTaskDownloadUseBGTask";

@implementation DispatchTaskDownload

@synthesize data=data;
@synthesize downloadProgressBlock;

#if !HAVE_ARC
-(void) dealloc
{
    [_url release];
    [_fileName release];
    [data release];
    [_response release];
    [downloadProgressBlock release];
    [super dealloc];
}
#endif

-(void) startDownload
{
    if(_connection==nil)
    {
        if([[self objectForKey:kDispatchTaskDownloadUseBGTask] boolValue])
        {
            if ([[UIDevice currentDevice] isMultitaskingSupported]) 
            {
                NSInteger backgroundDownloadID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
                [self setObject:[NSNumber numberWithInt:backgroundDownloadID] forKey:@"backgroundDownloadID"];
            }
        }
        
        NSURLRequest *req = [NSURLRequest requestWithURL:_url 
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad 
                                         timeoutInterval:TimeOut];
        _connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
        [_connection start];
        dbgLog(@"%@ started",[self description]);
    }
}


-(void) finishNetworkTask
{
    if(_connection)
    {
        if([self objectForKey:@"backgroundDownloadID"]!=nil)
        {
            [[UIApplication sharedApplication] endBackgroundTask:(NSInteger)[self objectForKey:@"backgroundDownloadID"]];
            [self removeObjectForKey:@"backgroundDownloadID"];
        }
        
        
        dbgLog(@"%@ finised",[self description]);
        RELEASE(_connection);
        _connection = nil;
        
        RELEASE(_fileHandle);
        _fileHandle = nil;
        
        RELEASE(_response);
        _response = nil;
        
        [[DataSource source] endLoadingDataForURL:_url];
    }
    [super finishNetworkTask];
}

- (id) initWithURL:(NSURL *)url cacheData:(BOOL)cacheData fileName:(NSString *)fileName andCompletitionBlock:(DispatchBlock)completeBlock_in
{
    if(url==nil || [[DataSource source] isLoadingDataWithURL:url])
    {
        RELEASE(self);
        return nil;
    }
    if( (self=[super initNetworkTaskWithExecuteBlock:^(DispatchTask *task){[(DispatchTaskDownload*)task startDownload];} 
                                andCompletitionBlock:completeBlock_in]))
    {
        _cacheData  = cacheData;
        _url        = RETAIN(url);
        _fileName   = RETAIN(fileName);
    }
    return self;
}

+ (DispatchTaskDownload *)downloadTaskWithURL:(NSURL *)url cacheData:(BOOL)cacheData andCompletitionBlock:(DispatchBlock)completeBlock
{
    DispatchTaskDownload *rv = [[self alloc] initWithURL:url cacheData:cacheData fileName:nil andCompletitionBlock:completeBlock];
    return AUTORELEASE(rv);
}

+ (DispatchTaskDownload *)downloadTaskWithURL:(NSURL *)url andCompletitionBlock:(DispatchBlock)completeBlock
{
    DispatchTaskDownload *rv = [[self alloc] initWithURL:url cacheData:NO fileName:nil andCompletitionBlock:completeBlock];
    return AUTORELEASE(rv);
}

+ (DispatchTaskDownload *)downloadTaskWithURL:(NSURL *)url toFile:(NSString *)fileName andCompletitionBlock:(DispatchBlock)completeBlock
{
    DispatchTaskDownload *rv = [[self alloc] initWithURL:url cacheData:NO fileName:fileName andCompletitionBlock:completeBlock];
    return AUTORELEASE(rv);
}

-(long long) contentLength
{
    if(_response==nil)
    {
        return -1;
    }
    long long contentLength = [_response expectedContentLength];
    if (contentLength == NSURLResponseUnknownLength)    
    {
        return -1;
    }
    return contentLength;
}

- (float) currentDownloadProgress
{
    if (self.contentLength <= 0)
        return 0.0;
    return (float)_currentContentLength / self.contentLength;
}

#pragma mark NSURLConnectionDelegate
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    if(_connection!=connection)
    {
        return nil;
    }
    if(_cacheData)
    {
        NSCachedURLResponse *modResponse = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.data];
        return AUTORELEASE(modResponse);
    }
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    if(_connection!=connection)
    {
        return;
    }

    if(_response)
    {
        RELEASE(_response);
        _response = nil;
    }
    _response = (NSHTTPURLResponse *)RETAIN(response);
    dbgLog(@"%@ got response. Status code=%d",[self description],[_response statusCode]);
    if([_response statusCode]!=200)
    {
        dbgLog(@"%@ failed",[self description]);
        [self finishNetworkTask];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)dataVal 
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
        if([_fileName length]==0)
        {
            if(data == nil)
            {
                _currentContentLength = 0;
                data = [[NSMutableData alloc] initWithData:dataVal];
            }else
            {
                [data appendData:dataVal];
            }
        }else
        {
            if(_fileHandle == nil)
            {
                _currentContentLength = 0;
                [[NSFileManager defaultManager] createFileAtPath:_fileName contents:dataVal attributes:nil];
                _fileHandle = RETAIN([NSFileHandle fileHandleForWritingAtPath:_fileName]);
                [_fileHandle seekToEndOfFile];
            }else
            {
                [_fileHandle writeData:dataVal];
            }
        }
        
        _currentContentLength += [dataVal length];
        if (downloadProgressBlock)
        {
            [DispatchTools doOnMainThread:^
             {
                 downloadProgressBlock(self);
             }];
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    if(_connection!=connection)
    {
        return;
    }
    
    dbgLog(@"%@ error = %@",[self description], error);
    [self finishNetworkTask];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<DispatchTaskDownload>(%@)",[_url absoluteString]];
}

@end
