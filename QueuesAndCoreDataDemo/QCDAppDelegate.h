//
//  QCDAppDelegate.h
//  QueuesAndCoreDataDemo
//
//  Created by Adam Iredale on 9/03/13.
//  Copyright (c) 2013 Stormforge Software. All rights reserved.
//

/// This is a simple demo app of how to correctly use Core Data with NSOperationQueue to deliver a harmonious,
/// non-blocking user experience. Off the top of my head, I've decided that it will download and store xkcd pages.
/// I <3 xkcd.

/// To throw this together as quickly as possible (and to avoid giving out copyrighted code),
/// I may use vendor components where prudent to do so.

#import <UIKit/UIKit.h>

@interface QCDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
