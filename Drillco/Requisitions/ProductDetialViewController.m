//
//  ProductDetialViewController.m
//  Drillco
//
//  Created by rodrigoe on 09-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import "ProductDetialViewController.h"
#import "ProductCell.h"

typedef void(^myCompletion) (BOOL);


@interface ProductDetialViewController ()
@property (weak, nonatomic) IBOutlet UITableView *productTabelView;
@property (weak, nonatomic) IBOutlet UILabel *productName_lbl;
@property (nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation ProductDetialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Historia";
    [self.productTabelView registerNib:[UINib nibWithNibName:@"ProductCellView_style_1" bundle:nil] forCellReuseIdentifier:@"ProductIdentifier"];
    self.productTabelView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.productName_lbl.text = self.productName;
    [self checkProducts];
}

- (void)checkProducts{
    if([self.products count] > 0){
        self.productTabelView.backgroundView = nil;
        self.productTabelView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }else{
        [self.spinner stopAnimating];
        [self.spinner hidesWhenStopped];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageLabel.text = @"No existen historias asociadas al producto.";
        messageLabel.textColor = [UIColor grayColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Helvética Neue" size:20];
        [messageLabel sizeToFit];
        
        self.productTabelView.backgroundView = messageLabel;
        self.productTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    [self.productTabelView reloadData];
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
    return 86;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [self.productTabelView dequeueReusableCellWithIdentifier:@"ProductIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [self.productTabelView dequeueReusableCellWithIdentifier:@"ProductIdentifier" forIndexPath:indexPath];
    }
    NSDictionary *product = [self.products objectAtIndex:indexPath.row];
    cell.productMONEY.text = [product[@"MONEDA"] description];
    cell.productSINGLE_AMOUNT.text = [self formatterAmount:[product[@"PRECIO UNIT"] description]];
    cell.productSUPPLIER_NAME.text = [product[@"NOMBRE PROVEEDOR"] description];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.productTabelView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Formatter
- (NSString *)formatterAmount:(NSString *)amount{
    NSNumber *number = @([amount intValue]);
    NSString *str = [NSNumberFormatter localizedStringFromNumber:number numberStyle:NSNumberFormatterCurrencyPluralStyle];
    return [str stringByReplacingOccurrencesOfString:@","
                                          withString:@"."];
}
@end
