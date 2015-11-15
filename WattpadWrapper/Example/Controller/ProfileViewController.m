//
//  ProfileViewController.m
//  WattpadWrapper
//
//  Created by Andrew Lee on 2015-11-11.
//  Copyright © 2015 Andrew Lee. All rights reserved.
//

#import "ProfileViewController.h"
#import "ReadingListTableViewCell.h"
#import "Wattpad.h"

@interface ProfileViewController ()
{
    __weak IBOutlet UIView *loginOverlay;
    __weak IBOutlet UILabel *headerLabel;
    __weak IBOutlet UITableView *readingListTableView;
    
    NSArray *currentReadingLists;
}
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWattpadAuthenticationSuccessful:) name:WattpadAuthenticationSuccessful object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWattpadAuthenticationFailed) name:WattpadAuthenticationFailed object:nil];
    
    readingListTableView.rowHeight = UITableViewAutomaticDimension;
    readingListTableView.estimatedRowHeight = 100.0f;
    
    // Do any additional setup after loading the view.
    loginOverlay.hidden = YES;
    [Wattpad getLoginStatus:^(WattpadLoginStatus status) {
        if(status == WattpadLoginStatusLoggedOut) {
            loginOverlay.hidden = NO;
            readingListTableView.hidden = YES;
        } else {
            loginOverlay.hidden = YES;
            readingListTableView.hidden = NO;
            
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:WattpadUsernameKey];
            
            headerLabel.text = username;
            
            [self onLoginSuccessful];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onLoginSuccessful{
    loginOverlay.hidden = YES;
    readingListTableView.hidden = NO;
    
    [Wattpad fetchReadingListsForUser:[[NSUserDefaults standardUserDefaults] objectForKey:WattpadUsernameKey] offset:0 limit:10 success:^(NSString *nextUrl, int total, NSArray *lists) {
        currentReadingLists = lists;
        
        [readingListTableView reloadData];
    } error:^(WattpadGETError *error) {
        
    }];
}

- (IBAction)onSignInBtnPressed:(UIButton*)sender {
    [Wattpad presentWattpadLoginViewControllerAnimated:YES target:self onComplete:^{
        
    }];
}

- (IBAction)onBackBtnPressed:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onWattpadAuthenticationSuccessful:(NSNotification*)notification {
    loginOverlay.hidden = YES;
    
    NSDictionary *info = notification.userInfo;
    headerLabel.text = info[@"username"];
    
    [self onLoginSuccessful];
}

- (void) onWattpadAuthenticationFailed {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return currentReadingLists.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReadingListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    WattpadReadingList *list = (WattpadReadingList*)currentReadingLists[indexPath.row];
    
    cell.readingListNameLabel.text = list.name;
    cell.readingListStoryCountLabel.text = [NSString stringWithFormat:@"%i", list.numStories];

    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end
