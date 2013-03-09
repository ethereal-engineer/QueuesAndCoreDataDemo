//
//  QCDTaskMaster.m
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//

#import "QCDTaskMaster.h"
#import "QCDComicTask.h"
#import "QCDDeleteComicsTask.h"

static const QCDTaskMaster *_gQCDTaskMaster = nil;
// The one, the only instance variable ('g' stands for global)

@interface QCDTaskMaster ()

@property (nonatomic, strong) NSOperationQueue *queue;
// The queue that the task master will control

@end

@implementation QCDTaskMaster

#pragma mark - InitDealloc

- (id)init
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        // For the purposes of simplicity (and this is often all that is needed for most apps)
        // we set the queue to handle ONLY 1 SIMULTANEOUS OPERATION at a time. So it really acts like
        // a single-file lunch-line queue. Until you're more familiar with NSOperationQueue and NSOperation,
        // and you have a fully working, stable app, this shouldn't be changed.
        [_queue setMaxConcurrentOperationCount:1];
    }
    return self;
}

#pragma mark - Public

- (void)clearComics
{
    // Delete all comics before this point in the queue!
    [_queue addOperation:[QCDDeleteComicsTask task]];
}

- (void)downloadRandomComic
{
    // Pick a number between 1 and the max (arc4random is awesome btw)
    NSUInteger fastRandom = (arc4random() % kXkcdMaxIndex) + 1;
    // Create and add a task and get back out of here
    [_queue addOperation:[QCDComicTask comicTaskWithIndex:fastRandom]];
}

#pragma mark - Class Methods

+ (QCDTaskMaster *)sharedInstance
{
    // Make sure you read comments that sound like they were written by me.... :)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _gQCDTaskMaster = [[QCDTaskMaster alloc] init];
    });
    return (QCDTaskMaster *)_gQCDTaskMaster;
}

@end
