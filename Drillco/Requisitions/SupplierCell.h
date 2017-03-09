//
//  SupplierCell.h
//  Drillco
//
//  Created by rodrigoe on 09-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SupplierCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *requisitionNumber;
@property (weak, nonatomic) IBOutlet UILabel *requisitionDate;
@property (weak, nonatomic) IBOutlet UILabel *requisitionTotal;

@end
