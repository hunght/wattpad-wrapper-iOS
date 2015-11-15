#Wattpad Wrapper for iOS
A wrapper for the Wattpad API (beta) to be used for developing iOS applications.  

##Getting Started
1. Go to the [Wattpad Developer site](https://developer.wattpad.com) and create a new app.
2. Pull from the repository and add the following folders to your project:

	* WattpadWrapper
	* AFNetworking
	* UIKit+AFNetworking
3. Build the project to ensure the files have been added correctly.

##Usage

###Initialization
You will need to initialize the wrapper in your App Delegate, providing your API Key, API Secret, and OAuth Callback URL.  This is found on the My App page on the Wattpad developer website.

Example:

	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    	// Override point for customization after application launch.
    	NSString *apiKey = @"YOUR-API-KEY";
    	NSString *apiSecret = @"YOUR-API-SECRET";
    	NSString *callbackUrl = @"YOUR-OAUTH-CALLBACK-URL";
    
    	[Wattpad initWattpadWithAPIKey:apiKey apiSecret:apiSecret callbackUrl:callbackUrl];
    	return YES;
	} 

###User Authentication
This wrapper contains a View Controller to help with the login process.  You can either do this manually by instantiating the WattpadLoginViewController class, or with the following method:

	[Wattpad presentWattpadLoginViewControllerAnimated:(BOOL) target:(UIViewController *) onComplete:^(void)completion]

Either way will work, with the only difference being you will need to assign the WattpadLoginViewController properties if done manually, as everything else would have been provided in the initialization of the wrapper.

Upon completion, the WattpadLoginViewController will post one of two notifications:

* <b>WattpadAuthenticationSuccessful</b> - the userInfo returned for this notification contains a key for token (the API access token), and username (the username of the person who just logged in)
* <b>WattpadAuthenticationFailed</b> - posted if retrieving the access token fails

<i>Note: The current implementation does not handle all cases</i>

###Methods

#####Status
Returns the login status of the current user

	+ (void) getLoginStatus:(void (^)(WattpadLoginStatus status))onComplete;

Log out the current user (removes the API token and username from User Defaults)

	+ (void) logOutUser

#####Categories
Returns an array of WattpadCategory objects

	+ (void) getCategories:(NSString*)tag success:(void (^)(NSArray *categories))success error:(void (^)(WattpadGETError *wattpadError))error;

####Stories
Returns stories with filters (hot, new, top_category)

	+ (void) fetchStories:(NSString*)filter query:(NSString*)query category:(NSString*)category offset:(int)offset limit:(int)limit success:(void (^)(int total, NSArray *stories))success error:(void (^)(WattpadGETError *error))error;
	
Returns tatuses of the stories in the current user's collections
	
	+ (void) getStatusOfStories:(NSString*)storyIds success:(void (^)(WattpadCollection *collection))success error:(void (^)(WattpadGETError *wattpadError))error;

####Users
Returns an array of WattpadReadingList objects for the given username

	+ (void) fetchReadingListsForUser:(NSString*)username offset:(int)offset limit:(int)limit success:(void (^)(NSString *nextUrl, int total, NSArray *lists))success failure:(void (^)(NSError *error))failure;

<i>NOTE: Does not appear to return the list of stories in the reading list</i>

##Known Issues
#####General
When sending a storyId or listId, it always seems to return with a 404 error, even with the IDs being returned by Wattpad.  These methods are affected by this:

	+ (void) fetchReadingList:(int)listId offset:(int)offset limit:(int)limit success:(void (^)(WattpadReadingList *))success failure:(void (^)(NSError *))failure;
	+ (void) addStoriesToReadingList:(int)listId storyIds:(NSString *)storyIds success:(void (^)())success error:(void (^)(WattpadPOSTError *))error 
	+ (void) updateStoryCover:(int)storyId image:(UIImage *)image copyright:(NSString *)copyright success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
	+ (void) addStoriesToReadingList:(int)listId storyIds:(NSString *)storyIds success:(void (^)())success error:(void (^)(WattpadPOSTError *error))error;
	+ (void) addStoriesToUser:(NSString*)username storyIds:(NSString*)storyIds success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;

#####Lists
	+ (void) addReadingList:(NSString*)name success:(void (^)(WattpadReadingList *))success failure:(void (^)(NSError *))failure;
This method will always return with a 500 server error

#####Stories
	+ (void) fetchReadingListsForUser:(NSString*)username offset:(int)offset limit:(int)limit success:(void (^)(NSString *nextUrl, int total, NSArray *lists))success failure:(void (^)(NSError *error))failure;
Returns the array of reading lists for the user, but does not appear to return the list of stories contained within the list

#####User
	+ (void) addStoriesToUser:(NSString*)username storyIds:(NSString*)storyIds success:(void (^)(NSDictionary *response))success error:(void (^)(WattpadPOSTError *error))error;
Returns an unknown user error, regardless of the username entered