
#import "DataSource.h"
#import "SDURLCache.h"

@implementation DataSource

@synthesize data;


#pragma mark Init Part

static int activityCounter = 0;

+ (void) startActivityIndicator 
{
	activityCounter ++;
	if (activityCounter > 0)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (void) stopActivityIndicator 
{
	activityCounter --;
	if (activityCounter <= 0)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) initDefaultData
{
	id delegate = [UIApplication sharedApplication].delegate;
	if ([delegate respondsToSelector:@selector(initDefaultData)])
		[delegate initDefaultData];
}

- (id) init 
{
	if ( (self=[super init]) )
	{
		data = [[NSMutableDictionary alloc] init];
        imgCache = [[NSMutableDictionary alloc] init];
        loadingData = [[NSMutableArray alloc] init];
        
        NSURLCache *sharedCache = [[SDURLCache alloc] initWithMemoryCapacity:1024*1024 diskCapacity:10*1024*1024 diskPath:[SDURLCache defaultCachePath]];
        [NSURLCache setSharedURLCache:sharedCache];
        RELEASE(sharedCache);
		[self loadData];
	}
	return self;
}

+ (DataSource *) source 
{
	static DataSource *sharedObject = nil;
    @synchronized(self) 
    {
        if (sharedObject == nil) 
        {
            sharedObject = [self alloc];
            sharedObject = [sharedObject init];
			[sharedObject initDefaultData];
		}
    }
    return sharedObject; 
}

+ (NSMutableDictionary *) data 
{
	return [self source].data;
}

- (NSString *) randomString
{
	const char letters[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	char rv[11];
    sranddev();        
	for(int i=0;i<10;i++)
	{
		int rval= arc4random()%sizeof(letters-1);
		rv[i] = letters[rval];
	}
	rv[10]=0;
	return [NSString stringWithCString:rv encoding:NSASCIIStringEncoding];	
}

- (NSString *)  tempFileName
{
    NSString *rv = nil;
    while(rv==nil || [[NSFileManager defaultManager] fileExistsAtPath:rv])
    {
        rv = [NSTemporaryDirectory() stringByAppendingPathComponent:[self randomString]];
    }
    return rv;
}


#pragma mark SaveLoad Logic
- (void) saveData 
{
	NSMutableData *tempData;

	NSString *archivePath = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@".Settings.archive"];
	NSKeyedArchiver *archiver;
	
	tempData = [NSMutableData data];
	archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:tempData];
	[archiver encodeObject:data forKey:@"data"];
	[archiver finishEncoding];
	[tempData writeToFile:archivePath atomically:YES];
    RELEASE(archiver);
}

- (void) loadData 
{
	NSData *tempData;
	NSKeyedUnarchiver *unarchiver;
	NSString *archivePath = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@".Settings.archive"];
	
	tempData = [NSData dataWithContentsOfFile:archivePath];
	
	if (tempData) 
    {
		unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:tempData];
		NSMutableDictionary *tmpDict = [unarchiver decodeObjectForKey:@"data"];
		if (tmpDict)
        {
            RELEASE(data);
			data = RETAIN(tmpDict);
        }
		[unarchiver finishDecoding];
        RELEASE(unarchiver);
	}
}

#pragma mark Image caching
- (BOOL) isLoadingDataWithURL:(NSURL *) url
{
    return [loadingData indexOfObject:url]!=NSNotFound;
}

- (void) setLoadingDataForURL:(NSURL *) url
{
    [loadingData addObject:url];
}

- (void) endLoadingDataForURL:(NSURL *) url
{
    [loadingData removeObject:url];
}

- (BOOL) haveCachedDataForURL:(NSURL *)url
{
    if(url==nil)
    {
        return NO;
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:url];        
    NSCachedURLResponse *response=[[NSURLCache sharedURLCache] cachedResponseForRequest:req];
    return response!=nil;
}

- (UIImage *) cachedImageForURL:(NSURL *) url
{
    if(url==nil)
        return 0;
    UIImage *rv = [imgCache objectForKey:url];
    if(rv == nil)
    {
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        NSURLCache *cashe = [NSURLCache sharedURLCache];
        NSCachedURLResponse *response=[cashe cachedResponseForRequest:req];
        UIImage *img = [UIImage imageWithData:response.data];
        if(img!=nil)
        {
            if([[url absoluteString] rangeOfString:@"@2x"].length>0)
            {
                img = [UIImage imageWithCGImage:img.CGImage scale:2.0 orientation:img.imageOrientation];
            }
            [imgCache setObject:img forKey:url];
            rv = img;
        }
    }
    
    return rv;
}

- (UIImage *) cachedImageForPath:(NSString *)path
{
    if(path==nil)
        return 0;
    UIImage *rv = [imgCache objectForKey:path];
    if(rv == nil)
    {
        NSData *req = [NSData dataWithContentsOfFile:path];        
        UIImage *img = [UIImage imageWithData:req];
        if(img!=nil)
        {
            [imgCache setObject:img forKey:path];
            rv = img;
        }
    }
    
    return rv;
}

- (UIImage *) cashedImageWithoutRequestForURL:(NSURL *)url
{
    if(url==nil)
        return 0;
    UIImage *rv = [imgCache objectForKey:url];
    if(rv == nil)
    {
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:imageData];
        if(img!=nil)
        {
            if([[url absoluteString] rangeOfString:@"@2x"].length>0)
            {
                img = [UIImage imageWithCGImage:img.CGImage scale:2.0 orientation:img.imageOrientation];
            }
            [imgCache setObject:img forKey:url];
            rv = img;
        }
    }
    
    return rv;
}

- (BOOL) contentImageCashDataForURL:(NSURL *)url
{
    if(url==nil)
        return NO;
    UIImage *rv = [imgCache objectForKey:url];
    if (rv == nil)
        return NO;
    
    return YES;
}

- (void) clearImageCache
{
#if HAVE_ARC
    [imgCache removeAllObjects];
#else
    NSArray *keys = [imgCache allKeys];
    for (NSString *key in keys)
    {
        UIImage *img = [imgCache objectForKey:key];
        if([img retainCount]==1)
        {
            [imgCache removeObjectForKey:key];
        }
    }
#endif
}

#pragma mark -
#pragma mark Application's directories

- (NSString *)applicationDocumentsDirectory 
{
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSString *)applicationLibraryCachesDirectory
{
    // location of discardable cache files (Library/Caches)
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSString *)applicationLibraryApplicationSupportDirectory
{
    // location of application support files (plug-ins, etc) (Library/Application Support)

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
