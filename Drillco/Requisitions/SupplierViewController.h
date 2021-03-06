//
//  SupplierViewController.h
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLClient.h"

@interface SupplierViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *supplierName_lbl;
@property (nonatomic) NSString *supplierName;
@property (nonatomic) NSArray *supplier_result;
@property (nonatomic) NSArray *results;
@property (nonatomic) NSMutableArray *supplierTotal;
@end
