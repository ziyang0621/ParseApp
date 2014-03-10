//
//  ParseEditItemViewController.m
//  ParseApp
//
//  Created by Ziyang Tan on 5/31/13.
//  Copyright (c) 2013 Ziyang Tan. All rights reserved.
//

#import "ParseEditItemViewController.h"
#import "Parse/Parse.h"

@interface ParseEditItemViewController ()
@property PFObject *item;
@property (weak) id<ParseEditItemViewControllerDelegate> delegate;
@end


@implementation ParseEditItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithItem:(PFObject *)item andDelegate:(id<ParseEditItemViewControllerDelegate>)delegate {
    self = [super initWithNibName:@"ParseEditItemViewController" bundle:nil];
    if (self) {
        // Set Item
        self.item = item;
        // Set Delegate
        self.delegate = delegate;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    
    // Done Button for name text field
    [self.nameTextField setReturnKeyType:UIReturnKeyDone];
    [self.nameTextField addTarget:self
                       action:@selector(textFieldFinished:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
    
    if (self.item) {
        [self.nameTextField setText:[self.item objectForKey:@"name"]];
        [self.datePicker setDate:[self.item objectForKey:@"dueDate"]];
    }
}

- (IBAction)textFieldFinished:(id)sender
{
    // [sender resignFirstResponder];
}

// Handle Save Button
- (void)save:(id)sender {
    // Load user Data
    NSString *name = self.nameTextField.text;
    NSDate *dueDate = self.datePicker.date;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd' 'hh:mm a"];

    // Update Item
    [self.item setObject:name forKey:@"name"];
    [self.item setObject:dueDate forKey:@"dueDate"];
    // Notify Delegate
    [self.delegate controller:self didUpdateItem:self.item];
    // Pop View Controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pickeDate:(id)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
