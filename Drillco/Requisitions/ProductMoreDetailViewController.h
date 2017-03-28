//
//  ProductMoreDetailViewController.h
//  Drillco
//
//  Created by Rodrigo Esquivel on 16-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductMoreDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *requisition_number;
@property (nonatomic) NSArray *results;
@property (nonatomic) NSString *requisition_num;
@end
