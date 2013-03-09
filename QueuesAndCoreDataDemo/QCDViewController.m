//
//  QCDViewController.m
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//

#import "QCDViewController.h"
#import "QCDCoreData.h"
#import "QCDTaskMaster.h"
#import "QCDWebViewController.h"

@interface QCDViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
// The very useful fetched results controller, with automatic refreshing if data in your context changes!
// Be warned, though - it can easily cause issues if updates happen when a view isn't visible! Many hours have been spent.

@end

@implementation QCDViewController

#pragma mark - Accessors

- (NSFetchedResultsController *)fetchedResultsController
{
    // Lazy load as much as possible, usually - it means I don't need to know when things are needed - they are created WHEN they are!
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comic"];
        // Pro Tip(s)!
        // Fetch requests for FR-Controllers MUST be sorted (and can't be modified once used in one)
        // @[] is shorthand for [NSArray arrayWithObjects:..., nil]
        // @{} is similar for dictionaries
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[QCDCoreData sharedMoc]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        [_fetchedResultsController setDelegate:self];
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            // Ooops! Error!
            NSLog(@"Fetch error: %@", error);
            _fetchedResultsController = nil;
        }

    }
    return _fetchedResultsController;
}

#pragma mark - Private

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *storedComic = [_fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell with data from the managed object.
    // The Index will do (for now)
    [cell.textLabel setText:[[storedComic valueForKey:@"index"] stringValue]];
}

- (void)triggerDownload:(id)sender
{
    [[QCDTaskMaster sharedInstance] downloadRandomComic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    // We only know one segue that we launch - the detail page
    QCDWebViewController *destinationViewController = segue.destinationViewController;
    // By the selected item...
    NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
    // Set what we need to show it
    NSManagedObject *storedComic = [_fetchedResultsController objectAtIndexPath:selectedPath];
    // Oh - and remember - NEVER PASS Managed Objects between contexts or threads. Just FWIW.
    // Here we are passing contained data only
    [destinationViewController setWebData:[storedComic valueForKey:@"htmlData"]];
}

#pragma mark - View Stuff

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Make a timer that downloads a random xkcd page once a second (it doesn't do much work, as you'll see...)
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(triggerDownload:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Datasource Methods (Copied right from the class reference doc)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Because we're using storyboard prototypes, we never have to create a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [_fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [_fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - Fetched Results Controller Delegate Methods (also copied straight from docs)

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            // Note that this calls the table directly and not the delegate (us)
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Actions

- (IBAction)clearTapped:(id)sender
{
    [[QCDTaskMaster sharedInstance] clearComics];
}

@end
