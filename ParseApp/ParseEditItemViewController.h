//
//  ParseEditItemViewController.h
//  ParseApp
//
//  Created by Ziyang Tan on 5/31/13.
//  Copyright (c) 2013 Ziyang Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@protocol ParseEditItemViewControllerDelegate;
@interface ParseEditItemViewController : UIViewController
@property IBOutlet UITextField *nameTextField;
@property IBOutlet UIDatePicker *datePicker;

#pragma mark -
#pragma mark Initialization
- (id)initWithItem:(PFObject *)item andDelegate:(id<ParseEditItemViewControllerDelegate>)delegate;
@end

@protocol ParseEditItemViewControllerDelegate <NSObject>
- (void)controller:(ParseEditItemViewController *)controller didUpdateItem:(PFObject *)item;
@end