//
//  WattpadStory.h
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-03.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WattpadStory : NSObject
@property int storyId;
@property NSString *title;
@property NSString *cover;
@property NSString *storyDescription;
@property NSString *user;
@property int numParts;
@property NSString *tags;
@property int voteCount;
@property int readCount;
@property int commentCount;
@property NSString *creationDate;
@property NSMutableArray *categories;
@end
