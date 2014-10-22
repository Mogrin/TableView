//
//  TCLMainViewController.m
//  TestCatalog
//
//  Created by Могрин on 10/19/14.
//  Copyright (c) 2014 Могрин. All rights reserved.
//

#import "TCLMainViewController.h"


@interface TCLMainViewController ()

@end


@implementation TCLMainViewController

@synthesize directories;
@synthesize player;
//@synthesize runDirectory;
//@synthesize runDirectoryId;

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    [self reloadTableView];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.runDirectoryId = 0;
    
    UIBarButtonItem *editButton = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(insertNewObject:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    //addButton.enabled = false;
    
    NSArray *rightButtons = [[NSArray alloc] initWithObjects: addButton, editButton, nil];
    self.navigationItem.rightBarButtonItems = rightButtons;
    
    //insert object to play
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newDir= [NSEntityDescription insertNewObjectForEntityForName:@"Directory"
                                                           inManagedObjectContext:context];
    [newDir setValue:@"Pantera - Strength Beyond Strength" forKey:@"title"];
    [self.directories insertObject:newDir atIndex:0];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)insertNewObject:(id)sender
{
    /*TCLRecordViewController *recordViewController = [[TCLRecordViewController alloc]
                                                   initWithNibName:@"TCLRecordViewController" bundle:nil];
    [self.navigationController pushViewController:recordViewController animated:YES];*/
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}



#pragma mark - Table view data source

-(void)reloadTableView
{
    [self.directories removeAllObjects];    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Directory"];
    self.directories = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.directories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];    
    NSManagedObject *directory = [self.directories objectAtIndex:indexPath.row];
    [cell.textLabel setText:[directory valueForKey:@"title"]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [context deleteObject:[self.directories objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        [self.directories removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } 
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError *eror;
    for (int i = 0; i < self.directories.count; i++) {
        NSManagedObject *tmpDir = [self.directories objectAtIndex:i];
        NSString *fileTmpName = [tmpDir valueForKey:@"title"];
        NSString *fileTmpPath = [[NSBundle mainBundle] pathForResource:fileTmpName ofType:@"mp3"];
        NSURL *tmpUrl = [NSURL fileURLWithPath:fileTmpPath];
        player = [[TCLPlayer alloc] initWithContentsOfURL:tmpUrl error:&eror];
        [player stop];
    }
    NSManagedObject *directory = [self.directories objectAtIndex:indexPath.row];
    NSString *fileName = [directory valueForKey:@"title"];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    player = [[TCLPlayer alloc] initWithContentsOfURL:url error:&eror];
    [player setNumberOfLoops:1];
    [player play];
}

@end
