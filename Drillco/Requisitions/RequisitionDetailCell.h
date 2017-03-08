//
//  RequisitionDetailCell.h
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequisitionDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *providerName;
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (weak, nonatomic) IBOutlet UILabel *single_amount;
@property (weak, nonatomic) IBOutlet UILabel *total_amount;

@end
