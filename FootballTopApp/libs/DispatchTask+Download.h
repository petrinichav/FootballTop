//
//  DispatchTask+Download.h
//  IPhoneSpeedTracker
//
//  Created by destman on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DispatchTools.h"

extern NSString *kDispatchTaskDownloadUseBGTask;

/*! @interface DispatchTaskDownload
    @brief Subclass of DispatchTask that adds functions to create network tasks.
 */
@interface DispatchTaskDownload : DispatchTask
{
	NSMutableData   *data;
    DispatchBlock    downloadProgressBlock;

    /*! Response from server*/
    NSHTTPURLResponse   *_response;    
    
    /*! YES if we need to cacheData*/
    BOOL            _cacheData;
    /*! NSFileHandle where we will save data*/
    NSFileHandle    *_fileHandle;
    /*! NSString with fileName where we will save content*/
    NSString        *_fileName;
    /*! NSURL that we will try to donwload*/
    NSURL           *_url; 
    /*! NSURLConnection for our task*/
    NSURLConnection *_connection;
    /*! current donwloaded content lenght */
    long long        _currentContentLength;
}

/*! Contains downloaded data. Valid only if this is "download to memory" task.*/
@property (readonly,retain) NSMutableData * data;

/*! This block will be called each time after task recive new data*/
@property (copy)     DispatchBlock  downloadProgressBlock;
/*! Content lenght */
@property (readonly) long long contentLength;


/*! Allocate and initialize download task to memory without caching.
 *  @param url NSURL to donwload
 *  @param completeBlock DispatchBlock called when task is finished or cancelled.
 *  @returns Allocated and initilized object or nil if error happened or there is some other task that donwloading same URL.
 */
+ (DispatchTaskDownload *)downloadTaskWithURL:(NSURL *)url andCompletitionBlock:(DispatchBlock)completeBlock;

/*! Allocate and initialize download to memory task.
 *  @param url NSURL to donwload
 *  @param cacheData if YES - response will be cached.
 *  @param completeBlock DispatchBlock called when task is finished or cancelled.
 *  @returns Allocated and initilized object or nil if error happened or there is some other task that donwloading same URL.
 */
+ (DispatchTaskDownload *)downloadTaskWithURL:(NSURL *)url cacheData:(BOOL)cacheData andCompletitionBlock:(DispatchBlock)completeBlock;

/*! Allocate and initialize download to file task.
 *  @param url NSURL to donwload
 *  @param fileName NSString with full path of file where downloaded content will be saved.
 *  @param completeBlock DispatchBlock called when task is finished or cancelled.
 *  @returns Allocated and initilized object or nil if error happened or there is some other task that donwloading same URL.
 */
+ (DispatchTaskDownload *)downloadTaskWithURL:(NSURL *)url toFile:(NSString *)fileName andCompletitionBlock:(DispatchBlock)completeBlock;

/*! @returns progress of donwloading. Values are in range from 0 to 1.*/
- (float) currentDownloadProgress;
@end
