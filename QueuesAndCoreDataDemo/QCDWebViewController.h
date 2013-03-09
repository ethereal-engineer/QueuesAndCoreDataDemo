//
//  QCDWebViewController.h
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//
/// For viewing - note that we only cache the html of the page in the database in this example

#import <UIKit/UIKit.h>

@interface QCDWebViewController : UIViewController

@property (nonatomic, strong) NSData *webData;
// The html data that will be loaded

@property (weak, nonatomic) IBOutlet UIWebView *webView;
// The main point of this vc

@end
