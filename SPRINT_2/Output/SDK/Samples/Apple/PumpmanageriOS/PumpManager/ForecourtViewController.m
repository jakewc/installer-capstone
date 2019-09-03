//
//  ForecourtViewController.m
//  Enabler Pump Manager
//
//  Created by ITL on 27/05/15.
//  Copyright © 2015 Integration Technologies Limited. All rights reserved.
//

#import "ForecourtViewController.h"
#import "PumpCellView.h"
#import "PumpViewController.h"

extern ENBForecourt *_forecourt;

@interface ForecourtViewController ()
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ForecourtViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem
     setTitle:[NSString stringWithFormat:@"Forecourt-Terminal %ld",
               (long)_forecourt.terminalID]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegation
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return _forecourt.pumps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    
    PumpCellView *cell =
    [[PumpCellView alloc] initWithStyle:UITableViewCellStyleValue1
                        reuseIdentifier:cellIdentifier];
    
    [cell setupPump:[_forecourt.pumps getByIndex:(int)indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PumpViewController *pumpView =
    [self.storyboard instantiateViewControllerWithIdentifier:@"pumpView"];
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    ENBPump *pump = [_forecourt.pumps getByIndex:(int)path.row];
    
    [pumpView setCurrentPump:pump];
    
    [pumpView setCurrentIndex:path.row];
    
    [pumpView setTitle:@"Pump Details"];
    
    [self.navigationController pushViewController:pumpView animated:YES];
}
@end
