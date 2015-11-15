//
//  StoriesViewController.m
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-09.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import "StoriesViewController.h"
#import "StorySelectionTableViewController.h"

@interface StoriesViewController ()
{
    StorySelectionTableViewController *hotStoriesTableViewController;
    
    NSDictionary *filterOptions;
}
@end

@implementation StoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onProfileBtnPressed:(UIButton*)sender {
    NSString * const profileSegueId = @"segueToProfile";
    [self performSegueWithIdentifier:profileSegueId sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSString * const hotStoriesSegueId = @"embedHot";
    
    if([segue.identifier isEqualToString:hotStoriesSegueId]) {
        hotStoriesTableViewController = segue.destinationViewController;
        hotStoriesTableViewController.filter = @"hot";
        [hotStoriesTableViewController refreshStories];
    }
}


@end
