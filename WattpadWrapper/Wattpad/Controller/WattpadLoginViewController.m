//
//  WattpadLoginViewController.m
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-03.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import "WattpadLoginViewController.h"
#import "AFNetworking.h"
#import "Wattpad.h"

NSString* const WattpadAuthenticationSuccessful = @"WattpadAuthenticationSuccessful";
NSString* const WattpadAuthenticationFailed = @"WattpadAuthenticationFailed";

NSString* const oauthUrl = @"https://www.wattpad.com/oauth/code";
NSString* const authorizationUrl = @"https://api.wattpad.com/v4/auth/token?grantType=authorizationCode";



@interface WattpadLoginViewController() <UIWebViewDelegate> {
    UIView *headerView;
    UIWebView *webView;
}
@end

@implementation WattpadLoginViewController

- (id) init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    const float headerHeight = 64.0f;
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    [headerView setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:headerView];
    
    const float backBtnFontSize = 14.0f;
    const float backBtnWidth = 75.0f;
    const float backBtnHeight = 30.0f;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    [backBtn setFrame:CGRectMake(-8.0f, headerView.frame.size.height - backBtnHeight, backBtnWidth, backBtnHeight)];
    [backBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:backBtnFontSize]];
    [backBtn setTintColor:[UIColor whiteColor]];
    [backBtn addTarget:self action:@selector(onBackBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backBtn];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, headerHeight, self.view.frame.size.width, self.view.frame.size.height - headerHeight)];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    
    NSString *loginUrlString = [NSString stringWithFormat:@"%@?api_key=%@&scope=%@&redirect_uri=%@", oauthUrl, _apiKey, _scope, [_redirectUri stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    NSURL *loginUrl = [NSURL URLWithString:loginUrlString];
    NSURLRequest *loginRequest = [NSURLRequest requestWithURL:loginUrl];
    
    [webView loadRequest:loginRequest];
    
}

- (void) onBackBtnPressed:(UIButton*)sender {
    [self dismissViewControllerAnimated:_animatedPresentation completion:NULL];
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *uri = [NSURL URLWithString:_redirectUri];
    NSString *scheme = [uri scheme];
    
    if([request.URL.scheme isEqualToString:scheme]) {
        // Redirect must end with a forward slash
        NSString *redirect = _redirectUri;
        NSString *redirectLastChar = [_redirectUri substringFromIndex:_redirectUri.length-1];
        if(![redirectLastChar isEqualToString:@"/"]) {
            redirect = [redirect stringByAppendingString:@"/"];
        }
        
        // Deconstruct returned parameters into a dictionary
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *query = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@?", redirect] withString:@""];
        for (NSString *param in [query componentsSeparatedByString:@"&"]) {
            
            NSRange firstEquals = [param rangeOfString:@"="];
            if(firstEquals.location != NSNotFound) {
                NSString *key = [param substringToIndex:firstEquals.location];
                NSString *val = [param substringFromIndex:firstEquals.location+1];
                [params setObject:val forKey:key];
            }
        }
 
        // Successfully retrieved the code
        if([params objectForKey:@"code"]) {
            
            NSDictionary *authParams = @{@"apiKey":_apiKey, @"secret":_apiSecret, @"authCode":[params objectForKey:@"code"], @"redirectUri":_redirectUri};
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            
            [manager POST:authorizationUrl parameters:authParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *response = (NSDictionary*)responseObject;
                NSDictionary *authDict = [response objectForKey:@"auth"];
                
                NSString *token = [authDict objectForKey:@"token"];
                NSString *username = [authDict objectForKey:@"username"];
                
                // Notify subscribing objects that login was successful
                NSDictionary *userInfo = @{@"token": token, @"username":username};
                [[NSNotificationCenter defaultCenter] postNotificationName:WattpadAuthenticationSuccessful object:nil userInfo:userInfo];
                
                // Store the token in a user default for making requests
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:token forKey:WattpadTokenKey];
                [defaults setValue:username forKey:WattpadUsernameKey];
                [defaults synchronize];

                
                [self dismissViewControllerAnimated:_animatedPresentation completion:NULL];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:WattpadAuthenticationFailed object:error userInfo:nil];
                
                [self dismissViewControllerAnimated:_animatedPresentation completion:NULL];
            }];
        }
        // Error retrieving code
        else if([params objectForKey:@"error"]) {
            // TO DO: Handle this
        }
        return NO;
    }
    
    return YES;
}

@end
