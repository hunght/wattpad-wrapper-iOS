//
//  WattpadReadingList.h
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-03.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WattpadReadingList : NSObject
@property int listId;
@property NSString *name;
@property int numStories;
@property BOOL isFeatured;
@property NSString *coverUrl;
@end
