//
//  Wattpad.m
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-03.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import "Wattpad.h"
#import "AFNetworking.h"

NSString* const baseURL = @"https://api.wattpad.com/v4";

NSString* const WattpadTokenKey = @"wattpad_token";
NSString* const WattpadUsernameKey = @"wattpad_username";

@interface Wattpad()
{

}
@property (nonatomic) NSString *apiKey;
@property (nonatomic) NSString *apiSecret;
@property (nonatomic) NSString *callbackUrl;
@end

@implementation Wattpad

+ (instancetype) sharedInstance
{
    static Wattpad *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

+ (instancetype) initWattpadWithAPIKey:(NSString *)apiKey apiSecret:(NSString *)apiSecret callbackUrl:(NSString *)callback
{
    [[[self class] sharedInstance] setApiKey:apiKey];
    [[[self class] sharedInstance] setApiSecret:apiSecret];
    [[[self class] sharedInstance] setCallbackUrl:callback];
    
    return [[self class] sharedInstance];
}

+ (void) presentWattpadLoginViewControllerAnimated:(BOOL)animated
                                            target:(UIViewController *)targetViewController
                                        onComplete:(void (^)(void))completion {
    WattpadLoginViewController *loginViewController = [[WattpadLoginViewController alloc] init];
    loginViewController.apiKey = [[[self class] sharedInstance] apiKey];
    loginViewController.apiSecret = [[[self class] sharedInstance] apiSecret];
    loginViewController.scope = @"read";
    loginViewController.redirectUri = [[[self class] sharedInstance] callbackUrl];
    loginViewController.animatedPresentation = animated;
    [targetViewController presentViewController:loginViewController animated:animated completion:completion];
}

/*
 * STATUS
 */
+ (void) getLoginStatus:(void (^)(WattpadLoginStatus))onComplete; {
    [self authenticatedGETRequestForEndpoint:@"auth/loginStatus" parameters:nil success:^(NSDictionary *response) {
        NSString *status = response[@"auth"][@"loginStatus"];
        if([status isEqualToString:@"loggedOut"]) {
            onComplete(WattpadLoginStatusLoggedOut);
        } else {
            onComplete(WattpadLoginStatusLoggedIn);
        }
    } failure:^(NSDictionary *response, NSError *err) {
    }];
}

+ (void) logOutUser {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:WattpadTokenKey];
    [defaults removeObjectForKey:WattpadUsernameKey];
    [defaults synchronize];
}

/*
 * CATEGORIES
 */

+ (void) getCategories:(NSString*)tag success:(void (^)(NSArray *categories))success error:(void (^)(WattpadGETError *))error
{
    NSDictionary *params = [NSMutableDictionary dictionary];
    if(tag) {
        [params setValue:tag forKey:@"tag"];
    }
    [self unauthenticatedGETRequestForEndpoint:@"categories" parameters:params success:^(NSDictionary *response) {
        NSArray *categoryArray = [response objectForKey:@"categories"];
        NSMutableArray *categories = [NSMutableArray array];
        for(int i = 0; i < categoryArray.count; i++) {
            NSDictionary *currentCategory = categoryArray[i];
            WattpadCategory *category = [[WattpadCategory alloc] init];
            category.categoryId = [[currentCategory objectForKey:@"id"] intValue];
            category.name = [currentCategory objectForKey:@"name"];
            [categories addObject:category];
        }
        success(categories);
    } failure:^(NSDictionary *response, NSError *err) {
        WattpadGETError *wpError = [self generateGETError:response];
        error(wpError);
    }];
}

/*
 * LISTS
 */

+ (void) addReadingList:(NSString*)name
                success:(void (^)(WattpadReadingList *))success
                  error:(void (^)(WattpadPOSTError *))error
{
    NSDictionary *params = @{@"name":name};
    [self authenticatedPOSTRequestForEndpoint:@"lists" parameters:params success:^(NSDictionary *response) {
        
    } failure:^(NSDictionary *response, NSError *err) {
        WattpadPOSTError *wpError = [self generatePOSTError:response];
        error(wpError);
    }];
    
}

+ (void) fetchReadingList:(int)listId
                   offset:(int)offset
                    limit:(int)limit
                  success:(void (^)(WattpadReadingList *))success
                    error:(void (^)(WattpadGETError *))error;
{
    NSDictionary *params = @{@"offset":[NSNumber numberWithInt:offset], @"limit":[NSNumber numberWithInt:limit]};
    [self unauthenticatedGETRequestForEndpoint:[NSString stringWithFormat:@"lists/%i", listId] parameters:params success:^(NSDictionary *response) {
    } failure:^(NSDictionary *response, NSError *err) {
    }];
}

+ (void) addStoriesToReadingList:(int)listId storyIds:(NSString *)storyIds success:(void (^)())success error:(void (^)(WattpadPOSTError *))error {
    NSDictionary *params = @{@"storyIds": storyIds};
    [self authenticatedPOSTRequestForEndpoint:[NSString stringWithFormat:@"lists/%i", listId] parameters:params success:^(NSDictionary *response) {
        
    } failure:^(NSDictionary *response, NSError *err) {
        WattpadPOSTError *wpError = [self generatePOSTError:response];
        error(wpError);
    }];
}

/*
 * STORIES
 */

+ (void) fetchStories:(NSString *)filter
                query:(NSString *)query
             category:(NSString*)category
               offset:(int)offset
                limit:(int)limit
              success:(void (^)(int, NSArray *))success
                error:(void (^)(WattpadGETError *))error
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"filter":filter ?: [NSNull null], @"query":query ?: [NSNull null], @"offset":[NSNumber numberWithInt:offset], @"limit":[NSNumber numberWithInt:limit]}];
    
    if(category != nil) {
        [params setValue:category forKey:@"category"];
    }
    [self unauthenticatedGETRequestForEndpoint:@"stories" parameters:params success:^(NSDictionary *response) {
        int total = [[response objectForKey:@"total"] intValue];
        NSArray *storyArray = [response objectForKey:@"stories"];
        NSMutableArray *stories = [NSMutableArray array];
        for(int i = 0; i < storyArray.count; i++) {
            NSDictionary *currentDictionary = storyArray[i];
            WattpadStory *story = [[WattpadStory alloc] init];
            story.storyId = [[currentDictionary objectForKey:@"id"] intValue];
            story.title = [currentDictionary objectForKey:@"title"];
            story.cover = [currentDictionary objectForKey:@"cover"];
            story.storyDescription = [currentDictionary objectForKey:@"description"];
            story.user = [currentDictionary objectForKey:@"user"];
            story.numParts = [[currentDictionary objectForKey:@"numParts"] intValue];
            story.tags = [currentDictionary objectForKey:@"tags"];
            story.voteCount = [[currentDictionary objectForKey:@"voteCount"] intValue];
            story.readCount = [[currentDictionary objectForKey:@"readCount"] intValue];
            story.commentCount = [[currentDictionary objectForKey:@"commentCount"] intValue];
            story.creationDate = [currentDictionary objectForKey:@"createDate"];
            
            NSArray *categoriesArray = [currentDictionary objectForKey:@"categories"];
            story.categories = [[NSMutableArray alloc] init];
            for(int j = 0; j < categoriesArray.count; j++){
                story.categories[j] = [NSNumber numberWithInt:[categoriesArray[j] intValue]];
            }
            
            [stories addObject:story];
        }
        success(total, stories);
    } failure:^(NSDictionary *response, NSError *err) {
        WattpadGETError *wpError = [self generateGETError:response];
        error(wpError);
    }];
    
}

+ (void) updateStoryCover:(int)storyId
                    image:(UIImage *)image
                copyright:(NSString *)copyright
                  success:(void (^)(NSDictionary *))success
                  error:(void (^)(WattpadPOSTError *))error
{
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSDictionary *params = @{@"storyCover": base64, @"copyright":copyright};
    
    [self authenticatedPOSTRequestForEndpoint:[NSString stringWithFormat:@"stories/%i/cover", storyId] parameters:params success:^(NSDictionary *response) {
        NSLog(@"%@", response);
    } failure:^(NSDictionary *response, NSError *err) {
        WattpadPOSTError *wpError = [self generatePOSTError:response];
        error(wpError);
    }];
}

+ (void) getStatusOfStories:(NSString *)storyIds
                    success:(void (^)(WattpadCollection *))success
                      error:(void (^)(WattpadGETError *))error
{
    if(storyIds == nil || [storyIds stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        return;
    }
    
    NSDictionary *params = @{@"storyIds":[storyIds stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]};
    
    [self unauthenticatedGETRequestForEndpoint:@"stories/collections" parameters:params success:^(NSDictionary *response) {
        NSLog(@"%@", response);
        
        NSDictionary *collectionsDict = response[@"collections"];
        
        WattpadCollection *collection = [[WattpadCollection alloc] init];
        NSMutableArray *stories = [NSMutableArray array];
        for(NSString *storyKey in collectionsDict) {
            NSDictionary *storyDict = collectionsDict[storyKey];
            WattpadStoryStatus *status = [[WattpadStoryStatus alloc] init];
            NSMutableDictionary *listStatuses = [NSMutableDictionary dictionary];
            for(NSString *key in storyDict) {
                if([key isEqualToString:@"archive"]) {
                    status.archive = [storyDict[@"archive"] boolValue];
                } else if([key isEqualToString:@"library"]) {
                    status.library = [storyDict[@"library"] boolValue];
                } else {
                    listStatuses[key] = [NSNumber numberWithInt:[storyDict[key] intValue]];
                }
            }
            status.listStatuses = listStatuses;
            [stories addObject:status];
        }
        collection.stories = [[NSArray alloc] initWithArray:stories];
        
        success(collection);
    } failure:^(NSDictionary *response, NSError *err) {
        WattpadGETError *wpError = [self generateGETError:response];
        error(wpError);
    }];
}

/*
 * USER
 */

+ (void) addStoriesToUser:(NSString*)username storyIds:(NSString*)storyIds success:(void (^)(NSDictionary *response))success error:(void (^)(WattpadPOSTError *))error {
    
    NSDictionary *params = @{@"storyIds":storyIds};
    
    [self authenticatedPOSTRequestForEndpoint:[NSString stringWithFormat:@"users/%@/library", username] parameters:params success:^(NSDictionary *response) {
        NSLog(@"%@", response);
    } failure:^(NSDictionary *response, NSError *err) {
        WattpadPOSTError *wpError = [self generatePOSTError:response];
        error(wpError);
    }];
}

+ (void) fetchReadingListsForUser:(NSString *)username
                           offset:(int)offset
                            limit:(int)limit
                          success:(void (^)(NSString *, int, NSArray *))success
                            error:(void (^)(WattpadGETError *))error {
    
    NSDictionary *params = @{@"offset":[NSNumber numberWithInt:offset], @"limit":[NSNumber numberWithInt:limit]};
    
    [self unauthenticatedGETRequestForEndpoint:[NSString stringWithFormat:@"users/%@/lists", username] parameters:params success:^(NSDictionary *response) {
        NSString *nextUrl = [response objectForKey:@"nextUrl"];
        int total = [[response objectForKey:@"total"] intValue];
        NSArray *listsArray = [response objectForKey:@"lists"];
        NSMutableArray *lists = [NSMutableArray array];
        for(int i = 0; i < listsArray.count; i++) {
            NSDictionary *currentDictionary = listsArray[i];
            WattpadReadingList *readingList = [[WattpadReadingList alloc] init];
            readingList.listId = [[currentDictionary objectForKey:@"id"] intValue];
            readingList.name = [currentDictionary objectForKey:@"name"];
            readingList.numStories = [[currentDictionary objectForKey:@"numStories"] intValue];
            readingList.isFeatured = [[currentDictionary objectForKey:@"isFeatured"] boolValue];
            readingList.coverUrl = [currentDictionary objectForKey:@"coverUrl"];
            [lists addObject:readingList];
        }
        success(nextUrl, total, lists);
    } failure:^(NSDictionary *response, NSError *err) {
        WattpadGETError *wpError = [self generateGETError:response];
        error(wpError);
    }];
}

/*
 *  Helper
 */

+ (WattpadGETError*)generateGETError:(NSDictionary*)errorDict {
    WattpadGETError *error = [[WattpadGETError alloc] init];
    error.errorCode = [[errorDict objectForKey:@"error_code"] intValue];
    error.type = [errorDict objectForKey:@"error_type"];
    error.message = [errorDict objectForKey:@"message"];
    return error;
}

+ (WattpadPOSTError*)generatePOSTError:(NSDictionary*)errorDict {
    NSDictionary *errorInfo = [errorDict objectForKey:@"error"];
    WattpadPOSTError *error = [[WattpadPOSTError alloc] init];
    error.httpCode = [[errorInfo objectForKey:@"HttpCode"] intValue];
    error.code = [[errorInfo objectForKey:@"Code"] intValue];
    error.type = [errorInfo objectForKey:@"Type"];
    error.message = [errorInfo objectForKey:@"Message"];
    return error;
}

+ (void) unauthenticatedGETRequestForEndpoint:(NSString*)endpoint
                                   parameters:(NSDictionary*)parameters
                                      success:(void (^)(NSDictionary* response))success
                                      failure:(void (^)(NSDictionary* response, NSError *err))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[[[self class] sharedInstance] apiKey] forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/%@", baseURL, endpoint] parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *responseDictionary = (NSDictionary*)responseObject;
        success(responseDictionary);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSDictionary *responseDictionary = (NSDictionary*)operation.responseObject;
        failure(responseDictionary, error);
    }];
}

+ (void) authenticatedPOSTRequestForEndpoint:(NSString*)endpoint
                                  parameters:(NSDictionary*)parameters
                                     success:(void (^)(NSDictionary* response))success
                                     failure:(void (^)(NSDictionary* response, NSError *err))failure
{
    NSString *storedToken = [[NSUserDefaults standardUserDefaults] valueForKey:WattpadTokenKey];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", storedToken] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:[[[self class] sharedInstance] apiKey] forHTTPHeaderField:@"Api-Key"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSLog(@"%@", [NSString stringWithFormat:@"%@/%@", baseURL, endpoint]);
    
    [manager POST:[NSString stringWithFormat:@"%@/%@", baseURL, endpoint] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDictionary = (NSDictionary*)responseObject;
        success(responseDictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", operation.responseString);
        NSDictionary *responseDictionary = (NSDictionary*)operation.responseObject;
        failure(responseDictionary, error);
    }];
}

+ (void) authenticatedGETRequestForEndpoint:(NSString*)endpoint
                                 parameters:(NSDictionary*)parameters
                                    success:(void (^)(NSDictionary* response))success
                                    failure:(void (^)(NSDictionary* response, NSError *err))failure
{
    NSString *storedToken = [[NSUserDefaults standardUserDefaults] valueForKey:WattpadTokenKey];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", storedToken] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:[[[self class] sharedInstance] apiKey] forHTTPHeaderField:@"Api-Key"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:[NSString stringWithFormat:@"%@/%@", baseURL, endpoint] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDictionary = (NSDictionary*)responseObject;
        success(responseDictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *responseDictionary = (NSDictionary*)operation.responseObject;
        failure(responseDictionary, error);
    }];
}

@end
