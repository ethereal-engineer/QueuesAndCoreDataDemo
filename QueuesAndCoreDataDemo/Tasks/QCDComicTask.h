//
//  QCDComicTask.h
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//
/// Downloads an xkcd comic html and stores it in the Core Data database

#import <Foundation/Foundation.h>

@interface QCDComicTask : NSOperation

+ (QCDComicTask *)comicTaskWithIndex:(NSUInteger)index;
// Download *that* comic

@end
