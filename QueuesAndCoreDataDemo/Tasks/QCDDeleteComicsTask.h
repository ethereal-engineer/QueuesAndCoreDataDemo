//
//  QCDDeleteComicsTask.h
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//
/// Clears out the database in one background operation!

#import <Foundation/Foundation.h>

@interface QCDDeleteComicsTask : NSOperation

+ (QCDDeleteComicsTask *)task;
// A quick creator

@end
