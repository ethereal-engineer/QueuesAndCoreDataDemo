//
//  QCDTaskMaster.h
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//
/// I've called this the TaskMaster because it oversees all the background tasks. If we wanted to cancel them all
/// or something, we'd make a simple call to this guy from anywhere in the app.

#import <Foundation/Foundation.h>

@interface QCDTaskMaster : NSObject

- (void)clearComics;
// Delete all comics from the database asynchronously

- (void)downloadRandomComic;
// Picks a random comic page and downloads it

#pragma mark - Class Methods

+ (QCDTaskMaster *)sharedInstance;
// Singleton instance

@end
