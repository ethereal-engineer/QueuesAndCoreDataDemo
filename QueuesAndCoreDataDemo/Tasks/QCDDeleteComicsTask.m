//
//  QCDDeleteComicsTask.m
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//

#import "QCDDeleteComicsTask.h"
#import "QCDCoreData.h"

@implementation QCDDeleteComicsTask

#pragma mark - Main

- (void)main
{
    // See other task(s) for more details comments on this process and important tips.
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setPersistentStoreCoordinator:[[QCDCoreData sharedInstance] persistentStoreCoordinator]];
    // Find them!
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comic"];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        // Crap! Core Data Error (Very rarely happens)
        NSLog(@"Core Data Error on Fetch (for delete): %@", error);
        // And bail!
        return;
    }
    
    // Anything to do?
    if (!results.count) {
        // Nope!
        return;
    }
    
    // Now... WIPE THEM OUT.... ALL of them... :D (well, when the save is executed)
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [context deleteObject:obj];
    }];
    
    // Ok, NOW wipe them out...
    if (![context save:&error]) {
        // The save failed for some reason
        NSLog(@"Core Data Save Error (for delete): %@", error);
        // Rollback the context
        [context rollback];
    }
}

#pragma mark - Class Methods

+ (QCDDeleteComicsTask *)task
{
    QCDDeleteComicsTask *task;
    @autoreleasepool {
        task = [[QCDDeleteComicsTask alloc] init];
    }
    return task;
}

@end
