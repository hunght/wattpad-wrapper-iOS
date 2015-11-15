//
//  StorySelectionTableViewController.h
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-09.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StorySelectionTableViewController : UITableViewController
{
    
}
@property (nonatomic) NSString *filter;
- (void) refreshStories;
@end
