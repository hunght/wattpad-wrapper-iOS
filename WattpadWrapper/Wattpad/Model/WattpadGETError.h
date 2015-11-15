//
//  WattpadError.h
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-03.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WattpadGETError : NSObject
@property int httpCode;
@property int errorCode;
@property NSString *type;
@property NSString *message;
@end
