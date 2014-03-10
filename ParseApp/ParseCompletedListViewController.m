//
//  ParseCompletedListViewController.m
//  ParseApp
//
//  Created by Ziyang Tan on 5/31/13.
//  Copyright (c) 2013 Ziyang Tan. All rights reserved.
//

#import "ParseCompletedListViewController.h"
#import "Parse/Parse.h"

@interface ParseCompletedListViewController ()

@property (nonatomic) NSMutableArray *items;
@property (nonatomic) NSArray *completedList;
@property (nonatomic) ParseListViewController *listView;

@end

@implementation ParseCompletedListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Set Title
        self.title = @"Completed List";
        // Load Items
        [self loadItems];
        // Add Observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCompletedList:) name:@"ParseCompletedListDidChangeNotification" object:nil];
    }
    return self;
}

// Set the ParseListViewController
-(void)setMyListView:(ParseListViewController *)view {
    self.listView = view;
}

// Update List based on notification from list view
- (void)updateCompletedList:(NSNotification *)notification {
    NSLog(@"Update in Completed");
    self.items = [NSMutableArray arrayWithArray:[self.listView getItemList]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"completed view");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Set items with array
- (void)setItems:(NSMutableArray *)items {
    if (_items != items) {
        _items = items;
        // Build Shopping List
        [self buildCompletedList];
    }
}

// Build Completed List
- (void)buildCompletedList {
    NSMutableArray *buffer = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.items count]; i++) {
        PFObject *item = [self.items objectAtIndex:i];
        if ([[item objectForKey:@"isCompleted"] boolValue]) {
            // Add Item to Buffer
            [buffer addObject:item];
        }
    }
    // Set completeted List
    self.completedList = [NSArray arrayWithArray:buffer];
}

// Set Completed List
- (void)setCompletedList:(NSArray *)completedList {
    if (_completedList != completedList) {
        _completedList = completedList;
        // Reload Table View
        [self.tableView reloadData];
    }
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
            NSLog(@"find successful in completed");
            self.items = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        } else {
            // The network was inaccessible and we have no cached data for
            // this query.
            NSLog(@"Error in find completed: %@ %@", error, [error userInfo]);
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
            
            [myItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    // The item saved successfully.
                    NSLog(@"Successfully saved");
                } else {
                    // There was an error saving the items.
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
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
    return [self.completedList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    // Fetch Item
    PFObject *item = [self.completedList objectAtIndex:[indexPath row]];
    // Configure Cell
    [cell.textLabel setText:[item objectForKey:@"name"]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd' 'hh:mm a"];
    NSString *myDate = [formatter stringFromDate:[item objectForKey:@"dueDate"]];
    cell.detailTextLabel.text = myDate;
    
    
    // Setup cell style
    CGFloat nRed= 34.0/255.0;
    CGFloat nBlue= 139.0/255.0;
    CGFloat nGreen= 34.0/255.0;
    UIColor *myColor=[[UIColor alloc]initWithRed:nRed green:nBlue blue:nGreen alpha:1];

    
    cell.accessoryView.backgroundColor = myColor;
    cell.contentView.backgroundColor = myColor;
    cell.detailTextLabel.backgroundColor = myColor;
    cell.textLabel.backgroundColor = myColor;
    
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12.0f]];
    cell.textLabel.textColor = [UIColor whiteColor];


    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
