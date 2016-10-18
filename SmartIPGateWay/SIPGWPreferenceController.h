//
//  SIPGWPreferenceController.h
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-6.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SIPGWAppDelegate;

@interface SIPGWPreferenceController : NSWindowController{
    SIPGWAppDelegate *appdelegate;
}
- (IBAction)showIcon:(id)sender;
- (IBAction)autoConnect:(id)sender;
- (IBAction)notifyUser:(id)sender;
@property (weak) IBOutlet NSButton *btstat;
@property (weak) IBOutlet NSButton *btconnect;
@property (weak) IBOutlet NSButton *btnotify;
@property SIPGWAppDelegate *appdelegate;

@end
