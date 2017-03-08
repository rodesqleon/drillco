//
//  RequisitionDetailViewController.h
//  Drillco
//
//  Created by rodrigoe on 08-03-17.
//  Copyright © 2017 Rodrigo Esquivel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SQLClient.h"

@interface RequisitionDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SQLClientDelegate>
@property (nonatomic) NSArray *requisitionDetail;
@property (nonatomic) NSString *provider_name;
@property (nonatomic) NSString *requisition_id;
@end