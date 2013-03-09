//
//  QCDComicTask.m
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//

#import "QCDComicTask.h"
#import "QCDComicDownloader.h"
#import "QCDCoreData.h"

@interface QCDComicTask ()

@property (nonatomic, assign) NSUInteger comicIndex;
// The desired comic index

@end

@implementation QCDComicTask

#pragma mark - Main

- (void)main
{
    // This runs in it's own autorelease pool on any random thread (bar main). For that
    // reason, (especially when working with Core Data), we have to be really careful about containment.
    
    // RULE #1: One Thread Per Context In CONFINEMENT Mode
    // Each "main" routine for a task can run in any random thread so we have to create a context for each use.
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    
    // Point it to the ONLY persistent store coordinator object
    [context setPersistentStoreCoordinator:[[QCDCoreData sharedInstance] persistentStoreCoordinator]];
    
    // Now we're ready to mess with the DB!
    
    // Have we already downloaded this comic before?
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comic"];
    // This specific comic?
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"index == %u", _comicIndex]];
    // We really don't want the comic data in this case - just a count of how many there are (should be either 0 or 1)
    [fetchRequest setResultType:NSCountResultType];
    
    // This will return an array with one record - a number object with the count
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        // Crap! Core Data Error (Very rarely happens)
        NSLog(@"Core Data Error on Fetch: %@", error);
        // And bail!
        return;
    }
    
    NSNumber *comicCount = [results lastObject];
    if (comicCount.unsignedIntegerValue) {
        // If it's non-zero then we've already got this one - so bail
        return;
    }
    
    // If we're here, we should download it
    
    // First step, successfully download the html file (keep it all working on this thread as much as possible, however,
    // because NSURLConnections don't really use that much processing power, having them run on the main thread for their
    // work is simpler, so we will do that.
    
    // To ensure that we block this thread until the job is done, we'll use a semaphore
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSData *data = nil;
    
    [QCDComicDownloader downloadXkcdComicAtIndex:_comicIndex
                             withCompletionBlock:^(NSError *error, NSData *payload) {
                                 if (error) {
                                     // Boo! Download failed!
                                     NSLog(@"Download error: %@", error);
                                 } else {
                                     // Woo! Download worked!
                                     // Strong link this data so that it isn't autoreleased
                                     data = payload;
                                 }
                                 // Regardless of the outcome, release the lock
                                 dispatch_semaphore_signal(semaphore);
                             }];
    
    // Wait here and allow other threads to run whilst the asnyc downloader does its thing
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        dispatchDoRunloop();
    }
    
    // The wait is over - release the semaphore (only required in versions under... something recent)
    //dispatch_release(semaphore);
    
    // Did it work?
    if (!data) {
        // No? Oh well. Skip creating data.
        return;
    }
    
    // Let's move on to the real meat of this - Core Data Import & Saving!
    
    // In our context, create a new object
    NSManagedObject *comic = [NSEntityDescription insertNewObjectForEntityForName:@"Comic" inManagedObjectContext:context];
    // Populate it (because I haven't exported a class descendant, I'll do it by key-value here)
    [comic setValue:[NSNumber numberWithUnsignedInteger:_comicIndex] forKey:@"index"];
    [comic setValue:data forKey:@"htmlData"];
    
    // Now hopefully save...
    if (![context save:&error]) {
        // The save failed for some reason
        NSLog(@"Core Data Save Error: %@", error);
        // Rollback the context
        [context rollback];
    }
    
}

#pragma mark - Class Methods

+ (QCDComicTask *)comicTaskWithIndex:(NSUInteger)index
{
    QCDComicTask *task;
    @autoreleasepool {
        // There's a note about these somewhere in here...
        task = [[QCDComicTask alloc] init];
        [task setComicIndex:index];
    }
    return task;
}

@end
