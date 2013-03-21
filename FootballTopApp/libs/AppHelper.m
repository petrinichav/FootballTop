//
//  AppHelper.m
//  iPhoneExpoTools
//
//  Created by Alex Petrinich on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppHelper.h"
#import "Base64.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <sys/types.h>
#include <sys/xattr.h>
#import "CommonCrypto/CommonDigest.h"
#import "UnderlinedButton.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f

@implementation AppHelper

+ (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (uint64_t)freeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    
    __autoreleasing NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
        } else {
            NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], [error code]);
        }
    
    return totalFreeSpace;
}

+ (NSString*) randomStringWithLength:(int) strLength
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *string = [NSMutableString stringWithCapacity:strLength];
    for (NSUInteger i = 0U; i < strLength; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [string appendFormat:@"%c", c];
    }
    dbgLog(@"%@", string);
    return string;
}

#pragma mark -

+ (NSString *)getMacAddress
{
    int         mgmtInfoBase[6];
    char        *msgBuffer = NULL;
    size_t       length;
    unsigned char    macAddress[6];
    struct if_msghdr  *interfaceMsgStruct;
    struct sockaddr_dl *socketStruct;
    NSString      *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;    // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;    // Routing table info
    mgmtInfoBase[2] = 0;       
    mgmtInfoBase[3] = AF_LINK;    // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST; // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0) 
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0) 
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        dbgLog(@"Error: %@", errorFlag);
        free(msgBuffer);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                                  macAddress[0], macAddress[1], macAddress[2], 
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

+ (NSString *) UUID
{
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = [(NSString*)CFUUIDCreateString(nil, uuid) autorelease];
    CFRelease(uuid);
    
    return uuidString;
}

+ (NSString*) getDeviceID
{
    NSString *result = nil;
    NSString *isu = [AppHelper getMacAddress];
    if(isu) 
    {
        unsigned char digest[16];
        NSData *data = [isu dataUsingEncoding:NSASCIIStringEncoding];
        CC_MD5([data bytes], [data length], digest);
        result = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                  digest[0], digest[1], 
                  digest[2], digest[3],
                  digest[4], digest[5],
                  digest[6], digest[7],
                  digest[8], digest[9],
                  digest[10], digest[11],
                  digest[12], digest[13],
                  digest[14], digest[15]];
        result = [result uppercaseString];
    }
    return result;
}

+ (NSString *) pathInDirectoryForFile:(NSString *)name
{
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, name];
    return path;
}

+ (NSString *) documentDirectory
{
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0]; 
    return documentsDirectory;
}

+ (NSArray *) files
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSError *error = nil;
    NSArray *arrayOfPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:&error];
    return arrayOfPaths;
}

+ (NSString *) deleteBadCharacterFromString:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\f" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\v" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\b" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\a" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\x02" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\x03" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\x04" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\x05" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\x06" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\x0e" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\x0f" withString:@""];
    
    return str;
}

+ (float) getCellSizeForText:(NSString *)text font:(UIFont *)font width:(CGFloat) width
{ 
    float cellSize = 0;
    
    CGSize constraint = CGSizeMake(width, 5000.0f);
    CGSize size = [text sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
    cellSize+=size.height;        
    
    dbgLog(@"App helper cell size %lf",cellSize);
    return cellSize;
}

+ (float) getCellSizeForSurveyPreview:(NSString *)text font:(UIFont *)font
{
    float cellSize = 0;
    
    CGSize constraint = CGSizeMake(270., 20000.0f);
    CGSize size = [text sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    cellSize+=size.height;        
    
//    dbgLog(@"App helper cell size %lf",cellSize);
    return cellSize;
}

+ (NSDate *) dateFromString:(NSString *) value forFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:value];
    return date;
}

+ (NSString *) date:(NSDate *)date withFormat:(NSString *) format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
    [formatter setLocale:locale];
    [locale release];
    
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:format];
    NSString *value = [formatter stringFromDate:date];
    [formatter release];
    return value;
}

+ (NSString *) dateFromString:(NSString *)dateStr fromFormat:(NSString *)oldFormat toFormat:(NSString *) newformat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:oldFormat];
    NSDate *date = [formatter dateFromString:dateStr];
    [formatter setDateFormat:newformat];
    NSString *value = [formatter stringFromDate:date];
    [formatter release];
    return value;
}

+ (NSString *) formatDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *value = [formatter stringFromDate:date];
    [formatter release];
    return value;
}

+ (NSString *) dateForLeadList:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"MM-dd-yyyy HH:mm:ss"];
    NSString *value = [formatter stringFromDate:date];
    [formatter release];
    return value;
}

+ (NSString *) dateForEventList:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"dd-MMMM-yyyy"];
    NSString *value = [formatter stringFromDate:date];
    [formatter release];
    return value;
}

+ (NSString *) dateRangeForMainScreen:(NSDate *)start end: (NSDate*) end
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"MMM"];
    NSString *startMonth = [formatter stringFromDate:start];
    NSString* endMonth = [formatter stringFromDate:end];
    
    [formatter setDateFormat:@"yyyy"];
    int startYear = [[formatter stringFromDate:start] intValue];
    int endYear =[[formatter stringFromDate:end] intValue]; 
    
    
    NSString *dateRange = nil;
    
    if ([startMonth isEqualToString:endMonth] && (startYear == endYear) ) {
        [formatter setDateFormat:@"dd"];
        dateRange = [formatter stringFromDate:start];
        [formatter setDateFormat:@"dd MMM yyy"];
        dateRange = [dateRange stringByAppendingFormat:@" - %@",[formatter stringFromDate:end]];
    }else {
        [formatter setDateFormat:@"dd MMM yyy"];
        dateRange = [formatter stringFromDate:start];
        dateRange = [dateRange stringByAppendingFormat:@" - %@",[formatter stringFromDate:end]];
    }

    [formatter release];

    return dateRange;   
}

+ (NSString*) dateForEventListStart: (NSDate*) startDate end: (NSDate*) endDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"MMMM-dd"];
    NSString *value = [formatter stringFromDate:startDate];
    [formatter setDateFormat:@"MMMM-dd-yyyy"];
    value = [value stringByAppendingFormat:@" - %@",[formatter stringFromDate:endDate]];    
    [formatter release];
    return value;   
}

+ (NSString *) shortFormatDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSArray *months = [formatter monthSymbols];
    dbgLog(@"%@", months);
    [formatter setDateFormat:@"MMMM, dd, yyyy"];
    NSString *value = [formatter stringFromDate:date];
    [formatter release];
    return value;
}

+ (NSString *) stringValueForNumber:(int) number
{
    int intValue = number/1000;
    int balance  = number - intValue*1000;
    
    NSString *balanceValue = [NSString stringWithFormat:@"%d", balance];    
    if ([balanceValue length] == 2)
    {
        balanceValue = [NSString stringWithFormat:@"0%d", balance];
    }
    else if ([balanceValue length] == 1)
    {
        balanceValue = [NSString stringWithFormat:@"00%d", balance];
    }
    else if ([balanceValue length] == 0)
    {
        balanceValue = @"000";
    }
    
    NSString *value = nil;
    if (intValue > 0)
        value = [NSString stringWithFormat:@"%d %@", intValue, balanceValue];
    else
        value = [NSString stringWithFormat:@"%d", number];
    
    return value;
}

+ (UnderlinedButton *) createUnderlinedButtonWithText:(NSString *)title fromView:(UIView *)parentView point:(CGPoint)point target:(id)target selector:(SEL)method
{
    CGSize constraintSize, offset;
    constraintSize.width  = 300.0f;
    constraintSize.height = MAXFLOAT;
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
    UIColor *fColor = [UIColor whiteColor];
    
    UnderlinedButton * btn = [UnderlinedButton buttonWithType:UIButtonTypeCustom];
    
    offset = [title sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeTailTruncation];
    [btn setSizeOfLine:offset];
    btn.frame = CGRectMake(point.x, point.y, offset.width + 15, offset.height);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:fColor forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    [btn addTarget:target action:method forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
    
    return btn;
}

+ (int) dayFromDate:(NSDate *) date
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:date];
    return [components day];
}

@end
