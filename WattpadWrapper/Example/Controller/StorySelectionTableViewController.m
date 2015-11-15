//
//  StorySelectionTableViewController.m
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-09.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import "StorySelectionTableViewController.h"
#import "StoryTableViewCell.h"
#import "Wattpad.h"

@interface StorySelectionTableViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *currentStories;
}
@end

@implementation StorySelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshStories {
    [Wattpad fetchStories:_filter query:nil category:nil offset:0 limit:20 success:^(int total, NSArray *stories) {
        currentStories = stories;
        
        [self.tableView reloadData];
    } error:^(WattpadGETError *error) {
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return currentStories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    WattpadStory *story = (WattpadStory*)currentStories[indexPath.row];
    
    NSString *cellText = [NSString stringWithFormat:@"%@\nPosted by: %@", story.title, story.user];
    NSMutableAttributedString *attributedCellText = [[NSMutableAttributedString alloc] initWithString:cellText];
    [attributedCellText beginEditing];
    [attributedCellText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:cell.cellLabel.font.pointSize] range:NSMakeRange(0, story.title.length)];
    [attributedCellText endEditing];
    cell.cellLabel.attributedText = attributedCellText;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
