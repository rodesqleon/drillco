//
//  ProductDetialViewController.m
//  Drillco
//
//  Created by rodrigoe on 09-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "ProductDetialViewController.h"
#import "ProductCell.h"

@interface ProductDetialViewController ()
@property (weak, nonatomic) IBOutlet UITableView *productTabelView;
@property (weak, nonatomic) IBOutlet UILabel *productName_lbl;

@end

@implementation ProductDetialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HISTORIA";
    [self.productTabelView registerNib:[UINib nibWithNibName:@"ProductCellView_style_1" bundle:nil] forCellReuseIdentifier:@"ProductIdentifier"];
    self.productTabelView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar.backItem setTitle:@""];
    self.navigationController.navigationBar.topItem.title = @"";
    self.productName_lbl.text = self.productName;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.products count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [self.productTabelView dequeueReusableCellWithIdentifier:@"ProductIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.productTabelView dequeueReusableCellWithIdentifier:@"ProductIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *product = [self.products objectAtIndex:indexPath.row];
    NSLog(@"%@", product);
    cell.productMONEY.text = [product[@"MONEDA"] description];
    cell.productSINGLE_AMOUNT.text = [product[@"PRECIO UNIT"] description];
    cell.productSUPPLIER_NAME.text = [product[@"NOMBRE PROVEEDOR"] description];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.productTabelView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
