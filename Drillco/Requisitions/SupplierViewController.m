//
//  SupplierViewController.m
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "SupplierViewController.h"
#import "SupplierCell.h"

@interface SupplierViewController ()
@property (weak, nonatomic) IBOutlet UITableView *supplierDetailTableView;

@end

@implementation SupplierViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PROVEEDOR";
    [self.supplierDetailTableView registerNib:[UINib nibWithNibName:@"SupplierViewCell_style_1" bundle:nil] forCellReuseIdentifier:@"SupplierIdentifier"];
    self.supplierDetailTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar.backItem setTitle:@""];
    self.navigationController.navigationBar.topItem.title = @"";
    self.supplierName_lbl.text = self.supplierName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.supplier_result count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SupplierCell *cell = [self.supplierDetailTableView dequeueReusableCellWithIdentifier:@"SupplierIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.supplierDetailTableView dequeueReusableCellWithIdentifier:@"SupplierIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *supplier = [self.supplier_result objectAtIndex:indexPath.row];
    NSLog(@"%@", supplier);
    
    cell.requisitionNumber.text = [supplier[@"ID"] description];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"dd/MM/yyyy"]; // Date formater
    NSString *date = [dateformate stringFromDate:supplier[@"REQUISITION_DATE"]];
    cell.requisitionDate.text = date;
    cell.requisitionTotal.text = [supplier[@"total_amt_ordered"] description];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.supplierDetailTableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
