//
//  AppDelegate.m
//  IRZMon
//
//  Created by  on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#include <SystemConfiguration/SystemConfiguration.h>

@interface AppDelegate()<NSURLConnectionDelegate>
{

}
@property (strong) NSTimer* updateTimer;
@property (strong) NSMutableData*  reseivedData;
@property (strong) NSURL*  baseURL;
@end

@implementation AppDelegate

@synthesize updateTimer = _updateTimer;
@synthesize window = _window;
@synthesize statusMenu = _statusMenu;
@synthesize statusItem = _statusItem;
@synthesize reseivedData = _reseivedData;
@synthesize baseURL = _baseURL;

- (void)updateData:(NSTimer*)sender
{
    if(!self.statusItem) {
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength]; 
        [_statusItem setMenu:_statusMenu];
        [_statusItem setTitle:@"IRZ"];
        [_statusItem setHighlightMode:YES];
    }
    
    NSURLRequest* req = [NSURLRequest requestWithURL:_baseURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1];
    
    
    [self.reseivedData setLength:0];
    [NSURLConnection connectionWithRequest:req delegate:self ];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.reseivedData = [NSMutableData dataWithCapacity:[[[(NSHTTPURLResponse*)response allHeaderFields] objectForKey:@"ContentSize"] intValue]];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.reseivedData appendData:data];
}

- (void)login:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"cgi-bin/index.cgi" relativeToURL:_baseURL]];
}

- (void) scanMenu:(NSString*) data
{
    NSScanner* skanner = [NSScanner scannerWithString:data];
    if([skanner scanUpToString:@"Current SIM card:" intoString:NULL]) {

        NSArray* items = _statusMenu.itemArray;
        for(int i =0;i<items.count-3;i++)
        {
            NSString* line = nil;
            [skanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line];
            [skanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
            
            [[items objectAtIndex:i] setHidden:!(line.length>0)];
            if(line) {
                [[items objectAtIndex:i] setTitle:line];
            }
        }
    }
}

- (void) cleanMenu
{
     NSArray* items = _statusMenu.itemArray;
    for(int i =0;i<items.count-3;i++)
    {
        [[items objectAtIndex:i] setHidden:YES];
    }    

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
     _statusItem.title = @"IRZ";
    [self cleanMenu];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // parse     
    NSString* data = [[NSString alloc] initWithBytes:_reseivedData.bytes length:_reseivedData.length encoding:NSUTF8StringEncoding];
    
    NSString *connectionType,*connectionState;
    int connectionQuality=-1;
    
    NSLog(@"%@",data);
    

    BOOL ok=YES;
    
    NSScanner* skanner = [NSScanner scannerWithString:data];
    if([skanner scanUpToString:@"dBm (" intoString:NULL]) {
        if([skanner scanString:@"dBm (" intoString:NULL]) {
            [skanner scanInt:&connectionQuality];
        }
    }
    else ok = NO;
    
    if([skanner scanUpToString:@"Connection type: " intoString:NULL]) {
        if([skanner scanString:@"Connection type: " intoString:NULL]) {
            [skanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&connectionType];
        }
    } 
    else ok = NO;
    
    if([skanner scanUpToString:@"onnection state: " intoString:NULL]) {
        if([skanner scanString:@"onnection state: " intoString:NULL]) {
            [skanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&connectionState];
        }
    }     
    else ok = NO;
    
    if(ok) {
        [self scanMenu:data];

        if([connectionState isEqualToString:@"established"]) {
            
            if([connectionType isEqualToString:@"UMTS"]) connectionType = @"U";
            else if([connectionType isEqualToString:@"HSPA"]) connectionType = @"H";
            else if([connectionType isEqualToString:@"HSDPA"]) connectionType = @"HD";
            else if([connectionType isEqualToString:@"HSUPA"]) connectionType = @"HU";
            else connectionType = [connectionType substringToIndex:1];
            
            _statusItem.title = [NSString stringWithFormat:@"%@:%d",connectionType,connectionQuality];
        }
        else {
            [self scanMenu:data];
            _statusItem.title = @"-NC-";
        }
    }
    else {
        [self cleanMenu];
        _statusItem.title = @"IRZ";
    }
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    SCDynamicStoreRef ds = SCDynamicStoreCreate(NULL, CFSTR("setDNS"), NULL, NULL);
    CFDictionaryRef dict = SCDynamicStoreCopyValue(ds,CFSTR("State:/Network/Global/IPv4"));
    CFStringRef router = CFDictionaryGetValue(dict, CFSTR("Router")); 
    self.baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/",router]];
    CFRelease(ds);
    CFRelease(dict);
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:29 target:self selector:@selector(updateData:) userInfo:nil repeats:YES];
    [_updateTimer performSelector:@selector(fire) withObject:nil afterDelay:10];
}

@end
