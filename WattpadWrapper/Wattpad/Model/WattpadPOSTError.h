//
//  WattpadPOSTError.h
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-08.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WattpadPOSTError : NSObject
@property int httpCode;
@property int code;
@property NSString *type;
@property NSString *message;
@end
