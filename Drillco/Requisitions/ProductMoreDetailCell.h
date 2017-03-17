//
//  ProductMoreDetailCell.h
//  Drillco
//
//  Created by Rodrigo Esquivel on 16-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductMoreDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (weak, nonatomic) IBOutlet UILabel *unit_cost;
@property (weak, nonatomic) IBOutlet UILabel *total;
@property (weak, nonatomic) IBOutlet UILabel *product;

@end
