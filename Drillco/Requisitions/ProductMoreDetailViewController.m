//
//  ProductMoreDetailViewController.m
//  Drillco
//
//  Created by Rodrigo Esquivel on 16-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "ProductMoreDetailViewController.h"
#import "ProductMoreDetailCell.h"

@interface ProductMoreDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *productTableView;


@end

@implementation ProductMoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Detalle";
    [self.productTableView registerNib:[UINib nibWithNibName:@"ProductMoreDetailCell_style_1" bundle:nil] forCellReuseIdentifier:@"ProductIdentifier"];
    self.productTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
     self.requisition_number.text = self.requisition_num;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductMoreDetailCell *cell = [self.productTableView dequeueReusableCellWithIdentifier:@"ProductIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.productTableView dequeueReusableCellWithIdentifier:@"ProductIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *product = [self.results objectAtIndex:indexPath.row];
    NSLog(@"%@", product);
    cell.quantity.text = [product[@"CANTIDAD"] description];
    cell.unit_cost.text = [self formatterAmount:[product[@"PRECIO UNITARIO"] description]];
    cell.total.text = [self formatterAmount:[product[@"TOTAL FINAL"] description]];
    cell.product.text = [product[@"PRODUCTO"] description];
    
    return cell;
}

#pragma mark - Formatter
- (NSString *)formatterAmount:(NSString *)amount{
    NSNumber *number = @([amount intValue]);
    NSString *str = [NSNumberFormatter localizedStringFromNumber:number numberStyle:NSNumberFormatterCurrencyPluralStyle];
    return [str stringByReplacingOccurrencesOfString:@","
                                          withString:@"."];
}


@end
