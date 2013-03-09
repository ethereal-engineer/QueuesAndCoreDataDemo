//
//  QCDComicDownloader.h
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//
/// Because downloading something on a non-main thread/queue is not a trivial task, this class handles that.

#import <Foundation/Foundation.h>

typedef void(^QCDCompletionBlock)(NSError *error, NSData *payload);
// Block definition for our callback

@interface QCDComicDownloader : NSObject

- (void)cancel;
// Cancel the download

+ (QCDComicDownloader *)downloadXkcdComicAtIndex:(NSUInteger)index withCompletionBlock:(QCDCompletionBlock)completionBlock;
// The one-shot call to download an xkcd comic (html) by index

@end
