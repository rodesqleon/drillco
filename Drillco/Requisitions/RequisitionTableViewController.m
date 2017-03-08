//
//  RequisitionTableViewController.m
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "RequisitionTableViewController.h"
#import "RequisitionCell.h"

NSString * const r_host = @"200.72.13.150";
NSString * const r_user = @"sa";
NSString * const r_pass = @"13871388";
NSString * const r_db = @"Drilprue";

@interface RequisitionTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *requisitionTableView;
@property (weak, nonatomic) IBOutlet UILabel *username_lbl;
@end

@implementation RequisitionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"REQUISICIONES";
    [self.requisitionTableView registerNib:[UINib nibWithNibName:@"RequisitionCellView_style_1" bundle:nil] forCellReuseIdentifier:@"RequisitionIdentifier"];
    self.requisitionTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar.backItem setTitle:@""];
    self.username_lbl.text = self.username;
}

- (void) reloadData {
    [self.requisitionTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.requisition count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequisitionCell *cell = [self.requisitionTableView dequeueReusableCellWithIdentifier:@"RequisitionIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.requisitionTableView dequeueReusableCellWithIdentifier:@"RequisitionIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *requisitions = [self.requisition objectAtIndex:indexPath.row];
    
    cell.requisition_ID.text = requisitions[@"ID"];
    cell.requisition_VENDOR_ID.text = requisitions[@"VENDOR_ID"];
    cell.requisition_CURRENCY_ID.text = [requisitions[@"CURRENCY_ID"] stringByAppendingString:[NSString stringWithFormat:@" %@",requisitions[@"AMOUNT"]]];
    cell.requisition_DESIRED_RECV_DATE.text = requisitions[@"DESIRED_RECV_DATE"];
    cell.requisition_NAME.text = requisitions[@"NAME"];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = [self.requisition objectAtIndex:indexPath.row];
    [self.requisitionTableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - SQLClientDelegate

- (void)error:(NSString*)error code:(int)code severity:(int)severity
{
 
}
 
- (void)message:(NSString*)message
{
    NSLog(@"Message: %@", message);
}

@end
