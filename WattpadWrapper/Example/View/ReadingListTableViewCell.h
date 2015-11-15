//
//  ReadingListTableViewCell.h
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-11.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadingListTableViewCell : UITableViewCell
@property (weak) IBOutlet UILabel *readingListNameLabel;
@property (weak) IBOutlet UILabel *readingListStoryCountLabel;
@end
