//
//  ParseListViewController.m
//  ParseApp
//
//  Created by Ziyang Tan on 5/31/13.
//  Copyright (c) 2013 Ziyang Tan. All rights reserved.
//

#import "ParseListViewController.h"
#import "ParseAddItemViewController.h"
#import "ParseEditItemViewController.h"

@interface ParseListViewController ()

@property NSMutableArray *items;
@property PFObject *undoItem;
@property   NSDateFormatter *formatter;
@end

@implementation ParseListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Set Title
        self.title = @"To-Do Items";
        // Load Items
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"MM/dd/yyyy' 'hh:mm a"];
        [self loadItems];
    }
    return self;
}

// Load Item from Parse or from plist if Parse doesnt work
- (void)loadItems {
    PFQuery *query = [PFQuery queryWithClassName:@"item"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query orderByAscending:@"dueDate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Results were successfully found, looking first on the
            // network and then on disk.
            NSLog(@"find successful");
            self.items = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        } else {
            // The network was inaccessible and we have no cached data for
            // this query.
            NSLog(@"Error in find: %@ %@", error, [error userInfo]);
            [self itemsFromPList];
        }
    }];
}


// Load item from plist if Pharse API does not work
-(void)itemsFromPList
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud boolForKey:@"PaserUserDefaultsSeedItems"]) {
        // Load Seed Items
        NSLog(@"load items inner");
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"seed" ofType:@"plist"];
        NSArray *seedItems = [NSArray arrayWithContentsOfFile:filePath];
        self.items = [[NSMutableArray alloc] init];
        // Create List of Items
        for (int i = 0; i < [seedItems count]; i++) {
            // print the items from plist
            NSDictionary *seedItem = [seedItems objectAtIndex:i];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd' 'hh:mm a"];
            
            // upload item to cloud
            PFObject *myItem = [PFObject objectWithClassName:@"item"];
            [myItem setObject:[seedItem objectForKey:@"name"] forKey:@"name"];
            [myItem setObject:[seedItem objectForKey:@"dueDate"] forKey:@"dueDate"];
            [myItem setObject:[NSNumber numberWithBool:NO] forKey:@"isCompleted"];
            
            [self.items addObject:myItem];
            
            [self saveItem:myItem];
        }
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"Items > %@", self.items);

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Make Bar Buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editItems:)];
}

// Get item list
-(NSMutableArray *)getItemList{
    return self.items;
}


// Handle add items buttons
- (void)addItem:(id)sender {
    // Initialize Add Item View Controller
    ParseAddItemViewController *addItemViewController = [[ParseAddItemViewController alloc] initWithNibName:@"ParseAddItemViewController" bundle:nil];
    // Set Delegate
    [addItemViewController setDelegate:self];
    // Present View Controller
    [self presentViewController:addItemViewController animated:YES completion:nil];
}


// Handle edit items button
- (void)editItems:(id)sender {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Make list view to be the first responder
- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

// Shake to Undo item
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"shake begin");
    if (self.undoItem) {
        [self saveItem:self.undoItem];
        [self.items addObject:self.undoItem];
        
        self.undoItem = nil;
        
        [self.tableView reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    // Configure Cell
    [cell.textLabel setText:[[self.items objectAtIndex:[indexPath row]] objectForKey:@"name"]];
    NSString *myDate = [_formatter stringFromDate:[[self.items objectAtIndex:[indexPath row]] objectForKey:@"dueDate"]];
    cell.detailTextLabel.text = myDate;
    
    // custom accessory button
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    UIButton *myAccessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [myAccessoryButton addTarget:self
			   action:@selector(accessoryButtonTapped:withEvent:)
	 forControlEvents:UIControlEventTouchUpInside];
    [myAccessoryButton setBackgroundColor:[UIColor clearColor]];
    [myAccessoryButton setImage:[UIImage imageNamed:@"yellowarrow"] forState:UIControlStateNormal];
    [cell setAccessoryView:myAccessoryButton];
    
    
    [self cancelScheduleAlarm:((PFObject*)[self.items objectAtIndex:[indexPath row]]).objectId];
    
    // Show/Hide Checkmark
    if ([[[self.items objectAtIndex:[indexPath row]] objectForKey:@"isCompleted"] boolValue]) {
        [cell.imageView setImage:[UIImage imageNamed:@"checkmark"]];
        cell.imageView.frame = CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y-5, cell.imageView.frame.size.width, 30);
    } else {
        [cell.imageView setImage:nil];
        PFObject *task = (PFObject*)[self.items objectAtIndex:indexPath.row];
        if ([(NSDate*)[task objectForKey:@"dueDate"] compare:[NSDate new]] == NSOrderedDescending) {
            [self setUpAlarm:[self.items objectAtIndex:indexPath.row]];
        }
      //  [self setUpAlarm:[self.items objectAtIndex:indexPath.row]];
    }
    
    // color density for tasks
    CGFloat nRed=(0.0 + [indexPath row] * 50.0)/255.0;
    CGFloat nBlue=0.0;
    CGFloat nGreen=0.0;
    UIColor *myColor=[[UIColor alloc]initWithRed:nRed green:nBlue blue:nGreen alpha:1];
    
    cell.accessoryView.backgroundColor = myColor;
    cell.contentView.backgroundColor = myColor;
    cell.detailTextLabel.backgroundColor = myColor;
    cell.textLabel.backgroundColor = myColor;
    cell.backgroundColor = myColor;
    
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12.0f]];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
    
}

// Custom accessory button handler
- (void) accessoryButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil ) {
        return;
    }
    
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Fetch Item
    PFObject *myItem = [self.items objectAtIndex:[indexPath row]];
    // Initialize Edit Item View Controller
    ParseEditItemViewController *editItemViewController = [[ParseEditItemViewController alloc] initWithItem:myItem andDelegate:self];
    // Push View Controller onto Navigation Stack
    [self.navigationController pushViewController:editItemViewController animated:YES];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *myItem = [self.items objectAtIndex:[indexPath row]];
        
        // Delete Item from Items
        [self.items removeObjectAtIndex:[indexPath row]];
        // Update Table View
       [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        
        NSLog(@"the id is %@", myItem.objectId);
         
         self.undoItem = [PFObject objectWithClassName:@"item"];
         [self.undoItem setObject:[myItem objectForKey:@"name"] forKey:@"name"];
         [self.undoItem setObject:[myItem objectForKey:@"dueDate"] forKey:@"dueDate"];
         [self.undoItem setObject:[myItem objectForKey:@"isCompleted"] forKey:@"isCompleted"];

        // Save Changes to Disk
        [myItem deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // The item deleted successfully.
                NSLog(@"Successfully deleted");
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"ParseCompletedListDidChangeNotification" object:self];
                
                [self sortItems];
                
            } else {
                // There was an error deleting the item.
                NSLog(@"Error in delete: %@ %@", error, [error userInfo]);
            }
        }];
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Fetch Item
    PFObject *item = [self.items objectAtIndex:[indexPath row]];
    // Update Item
    bool theValue = [[item objectForKey:@"isCompleted"] boolValue];
    theValue = !theValue;
    [item setObject: [NSNumber numberWithBool:theValue] forKey:@"isCompleted"];
    // Update Cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([[item objectForKey:@"isCompleted"] boolValue]) {
        [cell.imageView setImage:[UIImage imageNamed:@"checkmark"]];
    } else {
        [cell.imageView setImage:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParseCompletedListDidChangeNotification" object:self];
    // Save Items
    [self saveItem: item];
}


// Save items
- (void)controller:(ParseAddItemViewController *)controller didSaveItemWithName:(NSString *)name andDueDate:(NSDate *)dueDate {
    // Create Item
    PFObject *myItem = [PFObject objectWithClassName:@"item"];
    [myItem setObject:name forKey:@"name"];
    [myItem setObject:dueDate forKey:@"dueDate"];
    [myItem setObject:[NSNumber numberWithBool:NO] forKey:@"isCompleted"];
    // Add Item to Data Source
    [self.items addObject:myItem];
    // Add Row to Table View
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.items count] - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    // Save Items
    [self saveItem:myItem];
}

// Sort items based on due dates
-(void)sortItems {
    id mySort = ^(PFObject *obj1, PFObject *obj2) {
        return [[obj1 objectForKey:@"dueDate"] compare: [obj2 objectForKey:@"dueDate"]];
    };
    
    NSArray *sortDates = [self.items sortedArrayUsingComparator:mySort];
    self.items = [NSMutableArray arrayWithArray:sortDates];
    [self.tableView reloadData];

}

- (NSDate *)dateWithZeroSeconds:(NSDate *)date
{
    NSTimeInterval time = floor([date timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

-(void)setUpAlarm:(PFObject *)item {
    
    NSDate *alertTime = [self dateWithZeroSeconds:[item objectForKey:@"dueDate"]];
    NSLog(@"the dute date for alert %@", [_formatter stringFromDate:alertTime]);
    UIApplication* app = [UIApplication sharedApplication];
    UILocalNotification* notifyAlarm = [[UILocalNotification alloc]
                                        init];
    if (notifyAlarm) {
        notifyAlarm.fireDate = alertTime;
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = 0;
        NSMutableString *task = [[NSMutableString alloc] init];
        [task appendString: [item objectForKey:@"name"]];
        [task appendString: @" is due"];
        notifyAlarm.alertBody = task;
        notifyAlarm.alertAction =@"view";
        NSDictionary *customInfo =[NSDictionary dictionaryWithObject:item.objectId forKey:@"Notification"];
        notifyAlarm.userInfo = customInfo;
        notifyAlarm.applicationIconBadgeNumber = 1;
        
        if ([[item objectForKey:@"isCompleted"] boolValue] == NO) {
            [app scheduleLocalNotification:notifyAlarm];
            NSLog(@"setup notif");
        }
        
        else {
            [app cancelLocalNotification:notifyAlarm];
            NSLog(@"cancel notif");
        }
    }
}

-(void)cancelScheduleAlarm:(NSString*)objectId {
    NSString *name;
    UIApplication* app = [UIApplication sharedApplication];
    NSMutableArray *Arr=[[NSMutableArray alloc] initWithArray:[[UIApplication sharedApplication]scheduledLocalNotifications]];
    for (int k=0;k<[Arr count];k++) {
        UILocalNotification *not=[Arr objectAtIndex:k];
        name = [not.userInfo valueForKey:@"Notification"];
        if ([name isEqualToString:objectId]) {
            [app cancelLocalNotification:not];
            NSLog(@"cancelled alarm:%@", name);
        }
    }
}


// Save item and local notification
- (void)saveItem:(PFObject *)item {
    [item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
                // The item saved successfully.
            NSLog(@"Successfully saved in many");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ParseCompletedListDidChangeNotification" object:self];
            NSLog(@"the id is %@", item.objectId);
            [self sortItems];
         
        }
        else {
                // There was an error saving the item.
            NSLog(@"Error in many: %@ %@", error, [error userInfo]);
        }
    }];
}


// Update items
- (void)controller:(ParseEditItemViewController *)controller didUpdateItem:(PFObject *)item {
    // Fetch Item
    for (int i = 0; i < [self.items count]; i++) {
        PFObject *anItem = [self.items objectAtIndex:i];
        if ([anItem.objectId isEqualToString:item.objectId]) {
            // Update Table View Row
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self saveItem:item];
        }
    }
}

@end
