//
//  ParseListViewController.h
//  ParseApp
//
//  Created by Ziyang Tan on 5/31/13.
//  Copyright (c) 2013 Ziyang Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParseAddItemViewController.h"
#import "ParseEditItemViewController.h"
#import "Parse/Parse.h"

@interface ParseListViewController : UITableViewController <ParseAddItemViewControllerDelegate, ParseEditItemViewControllerDelegate>

-(NSMutableArray *)getItemList;
@end
