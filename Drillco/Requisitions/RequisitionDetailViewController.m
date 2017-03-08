//
//  RequisitionDetailViewController.m
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "RequisitionDetailViewController.h"
#import "RequisitionDetailCell.h"

NSString * const rd_host = @"200.72.13.150";
NSString * const rd_user = @"sa";
NSString * const rd_pass = @"13871388";
NSString * const rd_db = @"Drilprue";

@interface RequisitionDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *requisitionDetailTableView;
@property (weak, nonatomic) IBOutlet UILabel *providerName_lbl;

@end

@implementation RequisitionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Detalle Nº%@",self.requisition_id];
    [self.requisitionDetailTableView registerNib:[UINib nibWithNibName:@"RequisitionDetailCellView_style_1" bundle:nil] forCellReuseIdentifier:@"RequisitionDetailIdentifier"];
    self.requisitionDetailTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar.backItem setTitle:@""];
    self.navigationController.navigationBar.topItem.title = @"";
    self.providerName_lbl.text = self.provider_name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToSupplier:(id)sender {
    NSString *query = [NSString stringWithFormat:@"select top 5 p.ID, p.total_amt_ordered, P.REQUISITION_DATE, v.NAME from PURC_REQUISITION p, VENDOR v where p.vendor_id = v.id and p.status = 'C' and v.NAME = '%@' order by REQUISITION_DATE", self.provider_name];
    SQLClient* client = [SQLClient sharedInstance];
    client.delegate = self;
    [client connect:rd_host username:rd_user password:rd_pass database:rd_db completion:^(BOOL success) {
        if (success)
        {
            [client execute:query completion:^(NSArray* results) {
                NSLog(@"%@", results);
                [client disconnect];
                
            }];
        }
        else{
            NSLog(@"An error ocurr");
        }
    }];

}
#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.requisitionDetail count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequisitionDetailCell *cell = [self.requisitionDetailTableView dequeueReusableCellWithIdentifier:@"RequisitionDetailIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.requisitionDetailTableView dequeueReusableCellWithIdentifier:@"RequisitionDetailIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *requisitions = [self.requisitionDetail objectAtIndex:indexPath.row];
    
    cell.providerName.text = requisitions[@"PRODUCTO"];
    cell.quantity.text = requisitions[@"CANTIDAD"];
    cell.single_amount.text = requisitions[@"PRECIO UNITARIO"];
    cell.total_amount.text = requisitions[@"TOTAL FINAL"];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.requisitionDetailTableView deselectRowAtIndexPath:indexPath animated:YES];
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
