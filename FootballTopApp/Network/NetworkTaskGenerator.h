//
//  NetworkTaskGenerator.h
//  iPhoneGraduateApp
//
//  Created by Alex Petrinich on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DispatchTools.h"
#import "SBJsonWriter.h"
#import "SBJsonParser.h"

enum
{
    EmailOrUsernameError = 409,
};

@class FTItem;

@interface NetworkTaskGenerator : DispatchTask
{
    SBJsonWriter         *jsonWriter;
    SBJsonParser         *jsonParser;
    NSURL                *_url;
    NSURLConnection      *_connection;
    BOOL                 isSuccessful;
        
    NSMutableString      *_data;//if bad data
    
    int          statusCode;
    
    BOOL                 isShowPopupForExpiringEvent;
}

@property BOOL           isSuccessful;
@property (readonly)     id _data;
@property int            statusCode;
@property BOOL           isShowPopupForExpiringEvent;
@property (retain)       NSError *intenetError;

+ (NetworkTaskGenerator *) generateTaskForLanguage:(NSString *)lang Login:(NSString *) login password:(NSString *)pass completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForLogoutWithCompleteBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForRegistrationWithUser:(NSString *) user email:(NSString *)email country:(int)country language:(NSString *)lang completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForPasswordReestablishingWithEmail:(NSString *)email completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetCountriesWithLanguage:(NSString *)lang completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForTestWithCompleteBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetRateWithCompleteBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForUploadProfileImage:(NSData *) imageData completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetNewsCategoriesForLanguage:(NSString *)lang withCompleteBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetListNewsWithViewMode:(int)viewMode page:(int)page limit:(int)limit category:(int)category newsType:(NSString *)newsType createdafter:(int) timestamp completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetNewsWithID:(NSString *)ID completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetItems:(NSString *)itemType language:(NSString *) lang page:(int)page limit:(int)limit completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForSearchText:(NSString *)text language:(NSString *) lang page:(int)page limit:(int)limit completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetItemWithID:(int)ID completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetCommentsForNewsID:(int)ID page:(int)page limit:(int)limit completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetVotesForObject:(FTItem *)obj completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetProfileWithID:(int)uid completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForAddVoteForNodeId:(int)nid completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForAddCommentForNodeId:(int)nid comment:(NSString *)comment completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForChangePassword:(NSString *)newPassword oldPassword:(NSString *) oldPassword completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForUpdateUserInfo:(NSDictionary *)userInfo completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForDeleteFavouriteObjectWithID:(int)ID completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForAddFavouriteObjectWithID:(int)ID completeBlock:(DispatchBlock) completeBlock;
+ (NetworkTaskGenerator *) generateTaskForGetPlotDataForObject:(int)ID completeBlock:(DispatchBlock) completeBlock;

- (id) initWithURL:(NSURL *)url params:(NSMutableDictionary *)parametrs executeBlock:(DispatchBlock)_executeBlock andCompletitionBlock:(DispatchBlock)_completeBlock;

- (id) objectFromString;

@end
