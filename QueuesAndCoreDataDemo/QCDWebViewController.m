//
//  QCDWebViewController.m
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//

#import "QCDWebViewController.h"

@interface QCDWebViewController ()

@end

@implementation QCDWebViewController

#pragma mark - Private

- (void)updateUI
{
    // Convert the web data back into usable text and display it
    if (!_webData) {
        return;
    }
    // Most html is UTF8-encoded (assumption here)
    [_webView loadData:_webData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:kXkcdBaseURL]];
}

#pragma mark - Accessors

- (void)setWebData:(NSData *)webData
{
    if (_webData == webData) {
        return;
    }
    _webData = webData;
    if (self.isViewLoaded) {
        [self updateUI];
    }
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateUI];
}

@end
