//
//  QCDCoreData.m
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//

#import "QCDCoreData.h"

static const QCDCoreData *_gQCDCoreData = nil;
// The one, the only instance variable

@implementation QCDCoreData

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data stack (Pretty Much Straight from a "Use Core Data" Default Template with some important added bits)

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    // IMPORTANT NOTE HERE!!!! This is as good a point as any to set up a notification object that will automatically merge any
    // changes made in other contexts into our UI context. Another good place for this would be in the app delegate, but here is tidy.
    
    // Also, ordinarily, this returns an object that must be removed as an observer to clean up afterwards, but seeing as this is
    // a global object that is only freed on app termination, I'm ommiting that step.
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      // A change has occurred in some context!
                                                      // Merge the changes with the UI context
                                                      // If it's not the UI context that has changed
                                                      if (note.object == _managedObjectContext) {
                                                          return;
                                                      }
                                                      NSManagedObjectContext *noteContext = note.object;
                                                      if (noteContext.persistentStoreCoordinator != coordinator) {
                                                          return;
                                                      }
                                                      [_managedObjectContext mergeChangesFromContextDidSaveNotification:note];
                                                  }];
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"qcd" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"qcd.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Class Methods

+ (NSManagedObjectContext *)sharedMoc
{
    return [[self sharedInstance] managedObjectContext];
}

+ (QCDCoreData *)sharedInstance
{
    // This code will ONLY run once per static token. It relies on GCD, which is the basis of NSOperationQueue also.
    // dispatch_... commands are VERY useful... just sayin'. ;)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gQCDCoreData = [[QCDCoreData alloc] init];
    });
    return (QCDCoreData *)_gQCDCoreData;
}

@end
