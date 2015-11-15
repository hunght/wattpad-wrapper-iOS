//
//  WattpadStoryStatus.h
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-15.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WattpadStoryStatus : NSObject
@property int storyId;
@property NSDictionary *listStatuses;
@property BOOL archive;
@property BOOL library;
@end
