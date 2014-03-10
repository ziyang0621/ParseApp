//
//  ParseAddItemViewController.h
//  ParseApp
//
//  Created by Ziyang Tan on 5/31/13.
//  Copyright (c) 2013 Ziyang Tan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ParseAddItemViewControllerDelegate;


@interface ParseAddItemViewController : UIViewController
@property (weak) id<ParseAddItemViewControllerDelegate> delegate;

@property IBOutlet UITextField *nameTextField;
@property IBOutlet UIDatePicker *datePicker;
@end

@protocol ParseAddItemViewControllerDelegate <NSObject>
- (void)controller:(ParseAddItemViewController *)controller didSaveItemWithName:(NSString *)name andDueDate:(NSDate *)dueDate;
@end