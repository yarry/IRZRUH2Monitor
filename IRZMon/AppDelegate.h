//
//  AppDelegate.h
//  IRZMon
//
//  Created by  on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSMenu *statusMenu;
@property (strong) IBOutlet NSStatusItem *statusItem;

@property (strong) IBOutletCollection(NSMenuItem) NSArray* items;

- (IBAction)login:(id)sender;

@end
