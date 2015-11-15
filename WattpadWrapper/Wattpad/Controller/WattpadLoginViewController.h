//
//  WattpadLoginViewController.h
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-03.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

// Notification name for when authentication is successful
extern NSString * const WattpadAuthenticationSuccessful;

// Notification name for when authentication fails
extern NSString * const WattpadAuthenticationFailed;


@interface WattpadLoginViewController : UIViewController
{
    
}
@property (nonatomic) NSString *apiKey;
@property (nonatomic) NSString *apiSecret;
@property (nonatomic) NSString *scope;
@property (nonatomic) NSString *redirectUri;
@property BOOL animatedPresentation;
@end
