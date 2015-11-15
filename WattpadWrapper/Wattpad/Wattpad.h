//
//  Wattpad.h
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-03.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WattpadLoginViewController.h"
#import "WattpadCategory.h"
#import "WattpadReadingList.h"
#import "WattpadStory.h"
#import "WattpadCollection.h"
#import "WattpadStoryStatus.h"
#import "WattpadGETError.h"
#import "WattpadPOSTError.h"

// User default key that will be used for making requests
extern NSString * const WattpadTokenKey;

// User default key to store the logged in username
extern NSString * const WattpadUsernameKey;

typedef enum {
    WattpadLoginStatusLoggedIn,
    WattpadLoginStatusLoggedOut
} WattpadLoginStatus;

@interface Wattpad : NSObject
{
    
}
+ (instancetype) initWattpadWithAPIKey:(NSString*)apiKey apiSecret:(NSString*)apiSecret callbackUrl:(NSString*)callback;

// Display the login view controller to authenticate the user
+ (void) presentWattpadLoginViewControllerAnimated:(BOOL)animated target:(UIViewController*)targetViewController onComplete:(void (^)(void))completion;

/*
 * STATUS
 */

// Gets the login status of the current user
+ (void) getLoginStatus:(void (^)(WattpadLoginStatus status))onComplete;

// Deletes the access token and username stored in user defaults
+ (void) logOutUser;

/*
 * CATEGORIES
 */

// Returns categories
+ (void) getCategories:(NSString*)tag success:(void (^)(NSArray *categories))success error:(void (^)(WattpadGETError *wattpadError))error;

/*
 * LISTS
 */

// Adds a reading list for the logged in user
+ (void) addReadingList:(NSString*)name success:(void (^)(WattpadReadingList *readingList))success error:(void (^)(WattpadPOSTError *wattpadError))error;

// Fetches the reading list and its stories
+ (void) fetchReadingList:(int)listId offset:(int)offset limit:(int)limit success:(void (^)(WattpadReadingList *readingList))success error:(void (^)(WattpadGETError *error))error;

// Adds stories to the given reading list
+ (void) addStoriesToReadingList:(int)listId storyIds:(NSString *)storyIds success:(void (^)())success error:(void (^)(WattpadPOSTError *error))error;

/*
 * STORIES
 */

// Returns stories with filters
+ (void) fetchStories:(NSString*)filter query:(NSString*)query category:(NSString*)category offset:(int)offset limit:(int)limit success:(void (^)(int total, NSArray *stories))success error:(void (^)(WattpadGETError *error))error;

// Updates the story's cover
+ (void) updateStoryCover:(int)storyId image:(UIImage*)image copyright:(NSString*)copyright success:(void (^)(NSDictionary *response))success error:(void (^)(WattpadPOSTError *error))error;

// Status of the stories in the current user's collections
+ (void) getStatusOfStories:(NSString*)storyIds success:(void (^)(WattpadCollection *collection))success error:(void (^)(WattpadGETError *wattpadError))error;

/*
 * USER
 */

// Adds stories to the users library
+ (void) addStoriesToUser:(NSString*)username storyIds:(NSString*)storyIds success:(void (^)(NSDictionary *response))success error:(void (^)(WattpadPOSTError *error))error;

// Fetches the users reading lists
+ (void) fetchReadingListsForUser:(NSString*)username offset:(int)offset limit:(int)limit success:(void (^)(NSString *nextUrl, int total, NSArray *lists))success error:(void (^)(WattpadGETError *error))error;
@end
