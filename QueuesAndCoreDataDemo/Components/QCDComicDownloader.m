//
//  QCDComicDownloader.m
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//

#import "QCDComicDownloader.h"

@interface QCDComicDownloader () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong)   NSURLConnection     *connection;
// Our tether to the wwweb
@property (nonatomic, assign)   NSUInteger          comicIndex;
// Index of the comic this will be downloading
@property (nonatomic, copy)     QCDCompletionBlock  completionBlock;
// ALWAYS COPY A BLOCK - this is our copy of the one we start the call with
@property (nonatomic, strong)   NSMutableData       *data;
// The data we are downloading - it accumulates here
@property (nonatomic, strong)   NSURLRequest        *request;
// The request for the comic

@end

@implementation QCDComicDownloader

#pragma mark - Public

- (void)cancel
{
    // Cancel the download, if any
    [_connection cancel];
}

#pragma mark - Private

- (void)cleanUp
{
    // keep a slim memory profile as soon as possible
    self.data               = nil;
    self.connection         = nil;
    self.request            = nil;
    self.completionBlock    = nil;
}

- (void)start
{
    // Prepare our place to accumulate data
    _data = [[NSMutableData alloc] init];
    // Construct the download URL
    NSURL *downloadURL = [[NSURL URLWithString:kXkcdBaseURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"%u", _comicIndex]];
    // Set the request with a 30s timeout
    _request = [NSURLRequest requestWithURL:downloadURL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:30.0];
    // Use the main queue for work but it's very light in this case (NSURLConnection)
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connection = [[NSURLConnection alloc] initWithRequest:_request
                                                          delegate:self
                                                  startImmediately:YES];
    });
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Cool! From the response, we could allocate the memory we need for the data but we'll do this automatically for the moment.
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Collect it!
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Aaaaaaand... we're done!
    _completionBlock(nil, _data);
    [self cleanUp];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // We've hit an error. Ordinarily, I'd use DDLog (Lumberjack ROCKS) to log it but for now we'll just
    // call our callback. If we're uncertain of it, check it's assigned first (the callback).
    _completionBlock(error, nil);
    [self cleanUp];
}

#pragma mark - Class Methods

+ (QCDComicDownloader *)downloadXkcdComicAtIndex:(NSUInteger)index withCompletionBlock:(QCDCompletionBlock)completionBlock
{
    QCDComicDownloader *comicDownloader;
    @autoreleasepool {
        // Pro-tip! : Even though we have ARC, we STILL have to be wise memory managers. Auto-release pools FTW!
        comicDownloader = [[QCDComicDownloader alloc] init];
        [comicDownloader setComicIndex:index];
        [comicDownloader setCompletionBlock:completionBlock];
        [comicDownloader start];
    }
    return comicDownloader;
}

@end
