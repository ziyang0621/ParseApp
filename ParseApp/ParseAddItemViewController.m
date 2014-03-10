//
//  ParseAddItemViewController.m
//  ParseApp
//
//  Created by Ziyang Tan on 5/31/13.
//  Copyright (c) 2013 Ziyang Tan. All rights reserved.
//

#import "ParseAddItemViewController.h"

@interface ParseAddItemViewController ()

@end

@implementation ParseAddItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    
    // Done Button for name text field
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];
    [self.nameTextField addTarget:self
                           action:@selector(textFieldFinished:)
                 forControlEvents:UIControlEventEditingDidEndOnExit];

}

- (IBAction)textFieldFinished:(id)sender
{
    // [sender resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickeDate:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Handle Save Button
- (IBAction)save:(id)sender {
    // Extract User Input
    NSString *name = self.nameTextField.text;
    NSDate *dueDate = self.datePicker.date;
    
    // Notify Delegate
    [self.delegate controller:self didSaveItemWithName:name andDueDate:dueDate];
    // Dismiss View Controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
