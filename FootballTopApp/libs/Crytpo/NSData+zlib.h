
#import <Foundation/Foundation.h>


@interface NSData (Compression) 

- (NSData *)gzipInflate;
- (NSData *)gzipDeflate;

@end
