//
//  UIImage+Extras.h
//  AgileSpeed
//
//  Created by Evgen Bodunov on 8/6/10.
//  Copyright 2010 Evgen Bodunov <evgen.bodunov@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSource : NSObject 
{
	NSMutableDictionary *data;
	NSMutableDictionary *imgCache;
    
    NSMutableArray      *loadingData;
}

+ (DataSource *) source;
+ (NSMutableDictionary *)data;

- (NSString *)  randomString;
- (NSString *)  tempFileName;

- (BOOL) isLoadingDataWithURL:(NSURL *) url;
- (void) setLoadingDataForURL:(NSURL *) url;
- (void) endLoadingDataForURL:(NSURL *) url;
- (BOOL) contentImageCashDataForURL:(NSURL *)url;

- (BOOL) haveCachedDataForURL:(NSURL *)url;
- (UIImage *) cachedImageForURL:(NSURL *) url;
- (UIImage *) cashedImageWithoutRequestForURL:(NSURL *)url;
- (UIImage *) cachedImageForPath:(NSString *)path;
- (void) clearImageCache;

- (void) loadData;
- (void) saveData;

@property (nonatomic, readonly) NSMutableDictionary *data;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, readonly) NSString *applicationLibraryCachesDirectory;
@property (nonatomic, readonly) NSString *applicationLibraryApplicationSupportDirectory;

@end
