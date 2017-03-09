//
//  ProductCell.h
//  Drillco
//
//  Created by rodrigoe on 09-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *productMONEY;
@property (weak, nonatomic) IBOutlet UILabel *productSINGLE_AMOUNT;
@property (weak, nonatomic) IBOutlet UILabel *productSUPPLIER_NAME;

@end
