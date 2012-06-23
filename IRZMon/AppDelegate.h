//
//  AppDelegate.h
//  IRZMon
//
//  Created by  on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    @private
    NSTimer* _updateTimer;
    NSMutableData*  _reseivedData;
    NSURL*  _baseURL;
    NSWindow *_window;
    NSMenu *_statusMenu;
    NSStatusItem *_statusItem;
}
@property (assign,nonatomic) IBOutlet NSWindow *window;
@property (retain,nonatomic) IBOutlet NSMenu *statusMenu;
@property (retain,nonatomic) IBOutlet NSStatusItem *statusItem;

- (IBAction)login:(id)sender;
- (IBAction)quit:(id)sender;
@end
