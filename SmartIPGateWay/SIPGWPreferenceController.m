//
//  SIPGWPreferenceController.m
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-6.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import "SIPGWPreferenceController.h"
#import "SIPGWAppDelegate.h"

@interface SIPGWPreferenceController ()

@end

@implementation SIPGWPreferenceController
@synthesize appdelegate;

-(id)init{
    self=[super initWithWindowNibName:@"SIPGWPreferenceController"];
    return self;
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
    [[self btconnect] setState:[def boolForKey:@"autoConnect"]];
    [[self btnotify] setState:[def boolForKey:@"notifyUser"]];
    [[self btstat] setState:[def boolForKey:@"showStatBarItem"]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)showIcon:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[(NSButton*)sender state]] forKey:@"showStatBarItem"];
    if ((BOOL)[(NSButton*)sender state]) {
        [appdelegate showMenuBar];
    }else{
        [appdelegate hideMenuBar];
    }
}

- (IBAction)autoConnect:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[(NSButton*)sender state]] forKey:@"autoConnect"];
}

- (IBAction)notifyUser:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[(NSButton*)sender state]] forKey:@"notifyUser"];
}
@end
