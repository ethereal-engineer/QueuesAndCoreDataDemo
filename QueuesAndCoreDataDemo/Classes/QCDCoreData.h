//
//  QCDCoreData.h
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//
/// A singleton class that keeps all of the Core Data stuff together in one place.
/// The reason for using this and not the app delegate class is that quite often we will
/// want to use the code modules that we make in other projects. Linking back to the app delegate
/// from a class is generally frowned upon.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface QCDCoreData : NSObject

@property (strong, nonatomic) NSManagedObjectContext          *managedObjectContext;
// N.B. This moc MUST only ever be used by the main thread/queue (so it's for UI use mainly)
@property (strong, nonatomic) NSManagedObjectModel            *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator    *persistentStoreCoordinator;

#pragma mark - Class Methods

+ (NSManagedObjectContext *)sharedMoc;
// A quick shortcut to the UI moc, as it's the most frequently used

+ (QCDCoreData *)sharedInstance;
// The only way to access the single instance

@end
