//
//  RequisitionCell.h
//  Drillco
//
//  Created by Rodrigo Esquivel on 07-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequisitionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *requisition_ID;
@property (weak, nonatomic) IBOutlet UILabel *requisition_VENDOR_ID;
@property (weak, nonatomic) IBOutlet UILabel *requisition_CURRENCY_ID;
@property (weak, nonatomic) IBOutlet UILabel *requisition_DESIRED_RECV_DATE;
@property (weak, nonatomic) IBOutlet UILabel *requisition_NAME;

@end
