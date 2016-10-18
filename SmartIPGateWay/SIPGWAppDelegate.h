//
//  SIPGWAppDelegate.h
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-5.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@class SIPGWActionPerformer;
@class InfoPanelViewController;
@class SIPGWPreferenceController;
@class SIPGWNotificationsFetcher;
@class SIPGWNetStatGeter;

@interface SIPGWAppDelegate : NSObject <NSApplicationDelegate,NSTabViewDelegate,NSTableViewDataSource>{
    NSString *uid;
    NSString *pass;
    NSInteger selectedIndex;
    SIPGWActionPerformer *actionPerformer;
    IBOutlet NSProgressIndicator *pro;
    IBOutlet NSButton *btconnect;
    IBOutlet NSButton *btdisconnectall;
    BOOL notconnecting;
    NSWindow *popup;
    InfoPanelViewController *infoPanel;
    BOOL isFeeConnected;
    SIPGWPreferenceController *preferenceController;
    NSStatusItem *statusItem;
    BOOL willConnect;
    IBOutlet NSMenu *iconMenu;
    NSString *ipStatus;
    NSString *ipStatus2;
    NSString *username;
    const BOOL novalue;
    NSArray *notis;
    SIPGWNotificationsFetcher *fetcher;
    IBOutlet NSButton *btrefresh;
    IBOutlet NSWindow *wvwindow;
    IBOutlet WebView *wv;
    SIPGWNetStatGeter *getter;
    NSString *statString;
    NSTimer *statRefreshTimer;
}
@property NSString* ipStatus;
@property (nonatomic,readonly)BOOL isFee;
@property (assign) IBOutlet NSWindow *window;
@property (nonatomic) NSString *uid;
@property (nonatomic) NSString *pass;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) NSString *ipStatus2;
@property (nonatomic) NSString *username;
- (IBAction)closeWebSheet:(id)sender;

- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)disconnectall:(id)sender;
-(IBAction)showPreference:(id)sender;
-(void)showMenuBar;
-(void)hideMenuBar;
-(void)showDockIcon;
-(void)hideDockIcon;
-(IBAction)menuConnectFree:(id)sender;
-(IBAction)menuConnectFee:(id)sender;
-(IBAction)menuDisconnect:(id)sender;
-(IBAction)menuDisconnectall:(id)sender;
-(IBAction)showMainWindow:(id)sender;
-(IBAction)refreshData:(id)sender;
@property (weak) IBOutlet NSTableView *table;
@property (weak) IBOutlet NSProgressIndicator *notisPro;
@property (weak) IBOutlet NSLevelIndicator *netStatLI;
@property (weak) IBOutlet NSButton *btRefreshStat;
@property (weak) IBOutlet NSProgressIndicator *piRefreshStat;
- (IBAction)refreshStat:(id)sender;

@end
