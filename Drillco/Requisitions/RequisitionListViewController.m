//
//  RequisitionListViewController.m
//  Drillco
//
//  Created by Rodrigo Esquivel on 07-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "RequisitionListViewController.h"
#import "RequisitionCell.h"

NSString * const Rhost = @"200.72.13.150";
NSString * const Ruser = @"sa";
NSString * const Rpass = @"13871388";
NSString * const Rdb = @"Drilprue";

@interface RequisitionListViewController ()
@property (weak, nonatomic) IBOutlet UILabel *username_lbl;
@property (nonatomic) NSArray *requisition;

@end

@implementation RequisitionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.requisition_tableview registerNib:[UINib nibWithNibName:@"RequisitionCellView_style_1" bundle:nil] forCellReuseIdentifier:@"RequisitionIdentifier"];
    [self performSelector:@selector(reloadTable) withObject:nil afterDelay:0.2];


}

- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"REQUISICIONES";
    self.username_lbl.text = self.username;
    //[self DBConnection];
}

- (void)reloadTable {
    [self.requisition_tableview reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) DBConnection{
    NSString *query = [NSString stringWithFormat:@"select P.ID, v.NAME, P.VENDOR_ID, pr.CURRENCY_ID, P.DESIRED_RECV_DATE, PR.AMOUNT from PURC_REQUISITION p, VENDOR v, PURC_REQ_CURR pr where pr.currency_id = P.CURRENCY_ID and p.ASSIGNED_TO = 'FPADILLA' and p.STATUS = 'I' and p.VENDOR_ID = v.ID and p.ID = pr.PURC_REQ_ID order by P.REQUISITION_DATE"];
    SQLClient* client = [SQLClient sharedInstance];
    client.delegate = self;
    [client connect:Rhost username:Ruser password:Rpass database:Rdb completion:^(BOOL success) {
        if (success)
        {
            [client execute:query completion:^(NSArray* results) {
                self.requisition = results;
                [self.requisition_tableview reloadData];
                [client disconnect];
                
            }];
        }
        else{
            NSLog(@"An error ocurr");
        }
    }];
}
#pragma mark - SQLClientDelegate

//Required
- (void)error:(NSString*)error code:(int)code severity:(int)severity
{
    /*NSLog(@"Error #%d: %@ (Severity %d)", code, error, severity);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];*/
}

//Optional
- (void)message:(NSString*)message
{
    NSLog(@"Message: %@", message);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.requisition count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequisitionCell *cell = [self.requisition_tableview dequeueReusableCellWithIdentifier:@"RequisitionIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.requisition_tableview dequeueReusableCellWithIdentifier:@"RequisitionIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *requisitions = [self.requisition objectAtIndex:indexPath.row];
    
    NSLog(@"%@", requisitions);
    
    return cell;
}
@end
