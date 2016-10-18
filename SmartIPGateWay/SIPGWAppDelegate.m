//
//  SIPGWAppDelegate.m
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-5.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import "SIPGWAppDelegate.h"
#import "SIPGWActionPerformer.h"
#import "InfoPanelViewController.h"
#import "SIPGWPreferenceController.h"
#import "SIPGWNotificationsFetcher.h"
#import "SIPGWNetStatGeter.h"

@implementation SIPGWAppDelegate
@synthesize uid;
@synthesize pass;
@synthesize selectedIndex;
@synthesize ipStatus;
@synthesize ipStatus2;
@synthesize username;

+(void)initialize{
    NSMutableDictionary *defaults=[NSMutableDictionary dictionary];
    [defaults setValue:@"" forKey:@"uid"];
    [defaults setValue:@"" forKey:@"pass"];
    [defaults setValue:@(NO) forKey:@"isFee"];
    [defaults setValue:@(YES) forKey:@"showStatBarItem"];
    [defaults setValue:@(NO) forKey:@"showDockIcon"];
    [defaults setValue:@(YES) forKey:@"autoConnect"];
    [defaults setValue:@(YES) forKey:@"notifyUser"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    actionPerformer=[[SIPGWActionPerformer alloc]init];
    [self willChangeValueForKey:@"notconnecting"];
    notconnecting=YES;
    [self didChangeValueForKey:@"notconnecting"];
    popup=[[NSWindow alloc]init];
    [self setUid:[[NSUserDefaults standardUserDefaults] objectForKey:@"uid"]];
    [self setPass:[[NSUserDefaults standardUserDefaults] objectForKey:@"pass"]];
    [self setSelectedIndex:[[NSUserDefaults standardUserDefaults] boolForKey:@"isFee"]?1:0];
    statString=@"尚未联网";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showDockIcon"]) {
        [self showDockIcon];
    } else {
        [self hideDockIcon];
        [self showMainWindow:nil];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showStatBarItem"]) {
        [self showMenuBar];
    }
    [self setIpStatus:@"网关未连接"];
    [self setIpStatus2:@"<包月情况>"];
    [self setUsername:@"<姓名>"];
    [[self table] setDoubleAction:@selector(openWebView:)];
    [self refreshStat:nil];
    statRefreshTimer=[NSTimer scheduledTimerWithTimeInterval:60*3 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
    //[NSApp setDelegate:self];
}
-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{
    if (isFeeConnected) {
        [self disconnect:nil];
        return NSTerminateLater;
    }else{
        return NSTerminateNow;
    }
}
-(void)timerFire:(NSTimer*)timer{
    [self refreshStat:nil];
}
-(void)openWebView:(id)sender{
    NSDictionary *currentItem=[notis objectAtIndex:[[self table] clickedRow]];
    NSURL *baseUrl=[NSURL URLWithString:@"https://its.pku.edu.cn"];
    NSURL *url=[NSURL URLWithString:[currentItem objectForKey:@"href"] relativeToURL:baseUrl];
    [wv setMainFrameURL:@"about:blank"];
    [NSApp beginSheet:wvwindow modalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [wv setMainFrameURL:[url absoluteString]];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    if(flag){
        return NO;
    }else{
        [[self window] makeKeyAndOrderFront:self];
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        return YES;
    }
}
-(void)showMenuBar{
    statusItem=[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:iconMenu];
    [self refreshTitle];
}
-(void)refreshTitle{
    [statusItem setTitle:statString];
}
-(void)hideMenuBar{
    if (statusItem) {
        [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    }
}

-(void)showDockIcon {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);
}

-(void)hideDockIcon {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToUIElementApplication);
}
- (IBAction)menuPreference:(id)sender {
    
}

-(IBAction)menuConnectFree:(id)sender{
    [self setSelectedIndex:0];
    [self connect:nil];
}
-(IBAction)menuConnectFee:(id)sender{
    [self setSelectedIndex:1];
    [self connect:nil];
}
-(IBAction)menuDisconnect:(id)sender{
    [self disconnect:nil];
}
-(IBAction)menuDisconnectall:(id)sender{
    [self disconnectall:nil];
}

-(BOOL)isFee{
    return selectedIndex==1;
}
-(void)save{
    [[NSUserDefaults standardUserDefaults] setObject:self.uid forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] setObject:self.pass forKey:@"pass"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isFee] forKey:@"isFee"];
}
-(void)wantDisconnect:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    if (returnCode==NSAlertDefaultReturn) {
        willConnect=YES;
        [self disconnectall:nil];
    }
}
- (IBAction)closeWebSheet:(id)sender {
    [NSApp endSheet:wvwindow];
    [wvwindow orderOut:sender];
}

- (IBAction)connect:(id)sender {
    [self save];
    [btconnect setEnabled:NO];
    [btdisconnectall setEnabled:NO];
    [self willChangeValueForKey:@"notconnecting"];
    notconnecting=NO;
    [self didChangeValueForKey:@"notconnecting"];
    [pro startAnimation:nil];
    NSLog(@"connecting");
    [actionPerformer connectIPGWwithUid:uid password:pass isFeeArea:[self isFee] block:^(NSDictionary *result, NSError *error) {
        NSLog(@"connected");
        [pro stopAnimation:nil];
        [self willChangeValueForKey:@"notconnecting"];
        notconnecting=YES;
        [self didChangeValueForKey:@"notconnecting"];
        [btconnect setEnabled:YES];
        [btdisconnectall setEnabled:YES];
        if (![self.window isKeyWindow]) {
            NSUserNotification *noti=[[NSUserNotification alloc]init];
            if(!error){
                [noti setTitle:@"网络连接成功"];
                [noti setInformativeText:[NSString stringWithFormat:@"当前连接：%@",[result objectForKey:@"访问范围"]]];
            }else{
                [noti setTitle:@"网络连接失败"];
                [noti setInformativeText:[@"连接网络的时候出现了错误：" stringByAppendingString:[error localizedDescription]]];
            }
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:noti];
            if (isFeeConnected && [((NSString*)[result objectForKey:@"包月累计时长"]) rangeOfString:@"超时"].length>0&&[[NSUserDefaults standardUserDefaults] boolForKey:@"notifyUser"]) {
                NSUserNotification *noti=[[NSUserNotification alloc]init];
                [noti setTitle:@"注意！"];
                [noti setInformativeText:@"收费时常已超，请及时断开连接。"];
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:noti];
            }
            if(error) return;
        }else{
            if (error) {
                if([[error localizedDescription] rangeOfString:@"连接数超过"].length>0){
                    [[NSAlert alertWithMessageText:@"连接数超过预定值" defaultButton:@"断开全部连接并重连" alternateButton:@"好" otherButton:nil informativeTextWithFormat:@"要断开全部连接并重连嘛？"] beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(wantDisconnect:returnCode:contextInfo:) contextInfo:nil];
                }else{
                    NSBeep();
                    [[NSAlert alertWithError:error] beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
                }
                return;
            }
        }
        infoPanel=[[InfoPanelViewController alloc]init];
        [popup setFrame:[infoPanel.view frame] display:YES];
        popup.contentView=infoPanel.view;
        [[infoPanel labelName]setStringValue:[result objectForKey:@"用户名"]];
        [[infoPanel labelCurrent]setStringValue:[result objectForKey:@"访问范围"]];
        [[infoPanel labelType]setStringValue:[result objectForKey:@"包月状态"]];
        [[infoPanel connections]setIntegerValue:[[(NSString*)[result objectForKey:@"当前连接"] substringToIndex:1] integerValue]];
        BOOL displayTimeInfo=YES;
        NSString *feeStatus;
        if([[result objectForKey:@"包月状态"] isEqual:@"30元200小时包月"]){
            [[infoPanel progressMax]setStringValue:@"200 h"];
            [[infoPanel progressbar]setMaxValue:200];
            feeStatus=@"200小时";
        }else if([[result objectForKey:@"包月状态"] isEqual:@"50元280小时包月"]){
            [[infoPanel progressMax]setStringValue:@"280 h"];
            [[infoPanel progressbar]setMaxValue:280];
            feeStatus=@"280小时";
        }else if([[result objectForKey:@"包月状态"] isEqual:@"0元120小时包月"]||[[result objectForKey:@"包月状态"] isEqual:@"免费包月"]){
            [[infoPanel progressMax]setStringValue:@"120 h"];
            [[infoPanel progressbar]setMaxValue:120];
            feeStatus=@"120小时";
        }else{
            [[infoPanel progressbar]setHidden:YES];
            [[infoPanel progressMax]setHidden:YES];
            [[infoPanel progressMin]setHidden:YES];
            [[infoPanel progressTip]setHidden:YES];
            [[infoPanel dateMax] setHidden:YES];
            [[infoPanel dateMin] setHidden:YES];
            [[infoPanel dateProgress] setHidden:YES];
            [[infoPanel dateTip] setHidden:YES];
            displayTimeInfo=NO;
            if([[result objectForKey:@"包月状态"] isEqual:@"0元120小时包月"]||[[result objectForKey:@"包月状态"] isEqual:@"免费包月"]){
                feeStatus=@"120小时";
            }else{
                feeStatus=@"∞小时";
            }
        }
        NSDate *now=[NSDate date];
        [[infoPanel dateMax] setStringValue:[NSString stringWithFormat:@"%li号",(long)[self maxDaysOfMonthInDate:now]]];
        [[infoPanel dateProgress] setMaxValue:(double)[self maxDaysOfMonthInDate:now]];
        [[infoPanel dateProgress] setDoubleValue:(double)[self dayInDate:now]];
        if(displayTimeInfo){
            NSString *usedTimeInString=(NSString*)[result objectForKey:@"包月累计时长"];
            double usedTime=[[usedTimeInString substringToIndex:[usedTimeInString rangeOfString:@"小时"].location] doubleValue];
            [[infoPanel progressbar]setDoubleValue:usedTime];
        }
        NSMutableString *str=[[NSMutableString alloc]init];
        for(NSString *key in [result allKeys]){
            [str appendFormat:@"%@:%@\n",key,(NSString*)[result objectForKey:key]];
        }
        [infoPanel setDetail:str];
        isFeeConnected=[self isFee];
        if ([self.window isKeyWindow]) {
            [NSApp beginSheet:popup modalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
        }
        if(isFeeConnected && [((NSString*)[result objectForKey:@"包月累计时长"]) rangeOfString:@"超时"].length>0&&[[NSUserDefaults standardUserDefaults] boolForKey:@"notifyUser"]){
            [[NSAlert alertWithMessageText:@"请注意，收费时长已超！" defaultButton:@"我知道了" alternateButton:nil otherButton:nil informativeTextWithFormat:@"[土豪请无视→_→]"] beginSheetModalForWindow:popup modalDelegate:nil didEndSelector:nil contextInfo:nil];
        }
        [self setIpStatus:[NSString stringWithFormat:@"网关已连接：%@",isFeeConnected?@"收费地址":@"免费地址"]];
        if(![feeStatus isEqualToString:@"未包月"]){
            feeStatus=[NSString stringWithFormat:@"%.1f / %@",[[infoPanel progressbar] doubleValue],feeStatus];
        }
        [self setIpStatus2:[NSString stringWithFormat:@"包月状态：%@",feeStatus]];
        [self setUsername:[NSString stringWithFormat:@"用户名：%@",[result objectForKey:@"用户名"]]];
        if([[self btRefreshStat] isEnabled]) [self refreshStat:nil];
    }];
}

-(NSInteger)maxDaysOfMonthInDate:(NSDate*)date{
    NSCalendar *cal=[NSCalendar currentCalendar];
    NSDateComponents *dc=[cal components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    switch ([dc month]) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
            break;
        case 2:
            if([self isRYear:[dc year]])
            return 29;
            else return 28;
            break;
        default:
            return 30;
            break;
    }
}
-(NSInteger)dayInDate:(NSDate*)date{
    NSCalendar *cal=[NSCalendar currentCalendar];
    NSDateComponents *dc=[cal components:NSDayCalendarUnit fromDate:date];
    return [dc day];
}
-(BOOL)isRYear:(NSInteger)year{
    return year%400==0||(year%4==0&&year%100!=0);
}
- (IBAction)disconnect:(id)sender {
    [self willChangeValueForKey:@"notconnecting"];
    notconnecting=NO;
    [self didChangeValueForKey:@"notconnecting"];
    [pro startAnimation:nil];
    NSLog(@"disconnect");
    [actionPerformer disconnectIPGWwithBlock:^(BOOL result, NSError *error) {
            [pro stopAnimation:nil];
            [self willChangeValueForKey:@"notconnecting"];
            notconnecting=YES;
            [self didChangeValueForKey:@"notconnecting"];
        if (![self.window isKeyWindow]) {
            NSUserNotification *noti=[[NSUserNotification alloc]init];
            if(!error){
                [noti setTitle:@"网络断开成功"];
                [noti setInformativeText:@"网络连接已经断开"];
            }else{
                [noti setTitle:@"网络断开失败"];
                [noti setInformativeText:[@"断开网络连接的时候出现了错误：" stringByAppendingString:[error localizedDescription]]];
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:noti];
                return;
            }
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:noti];
        }else{
            if(error){
                NSBeep();
                [[NSAlert alertWithError:error] beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
                [NSApp replyToApplicationShouldTerminate:NO];
                return;
            }else{
                [NSApp replyToApplicationShouldTerminate:YES];
                NSAlert *alt=[NSAlert alertWithMessageText:@"断开连接成功" defaultButton:@"好" alternateButton:nil otherButton:nil informativeTextWithFormat:@"已断开IP网关"];
                [alt beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            }
        }
        isFeeConnected=NO;
        [self setIpStatus:@"网关未连接"];
        [self setIpStatus2:@"<包月状态>"];
        [self setUsername:@"<姓名>"];
        if([[self btRefreshStat] isEnabled]) [self refreshStat:nil];
    }];
}

- (IBAction)disconnectall:(id)sender {
    [self save];
    [btconnect setEnabled:NO];
    [btdisconnectall setEnabled:NO];
    [self willChangeValueForKey:@"notconnecting"];
    notconnecting=NO;
    [self didChangeValueForKey:@"notconnecting"];
    [pro startAnimation:nil];
    [actionPerformer disconnectAllIPGWwithUid:uid password:pass block:^(BOOL result, NSError *error) {
        [pro stopAnimation:nil];
        [self willChangeValueForKey:@"notconnecting"];
        notconnecting=YES;
        [self didChangeValueForKey:@"notconnecting"];
        [btconnect setEnabled:YES];
        [btdisconnectall setEnabled:YES];
        if (![self.window isKeyWindow]) {
            NSUserNotification *noti=[[NSUserNotification alloc]init];
            if(!error){
                [noti setTitle:@"断开全部连接成功"];
                [noti setInformativeText:@"网络连接已经全部断开"];
            }else{
                [noti setTitle:@"断开全部连接失败"];
                [noti setInformativeText:[@"断开全部网络连接的时候出现了错误：" stringByAppendingString:[error localizedDescription]]];
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:noti];
            }
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:noti];
        }else{
            if(error){
                NSBeep();
                [[NSAlert alertWithError:error] beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
                return;
            }else{
                if(willConnect){
                    willConnect=NO;
                    [self performSelector:@selector(connect:) withObject:nil afterDelay:0.01];
                }else{
                    NSAlert *alt=[NSAlert alertWithMessageText:@"断开全部连接成功" defaultButton:@"好" alternateButton:nil otherButton:nil informativeTextWithFormat:@"已断开账号%@的全部IP网关连接",uid];
                    [alt beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
                }
            }
        }
        isFeeConnected=NO;
        [self setIpStatus:@"网关未连接"];
        [self setIpStatus2:@"<包月状态>"];
        [self setUsername:@"<姓名>"];
        if([[self btRefreshStat] isEnabled]) [self refreshStat:nil];
    }];
}


#pragma tabview
//330 280
//600 400
-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem{
    NSRect current=[[self window] frame];
    if ([tabViewItem.identifier isEqualToString:@"2"]) {
        [[self window] setFrame:NSMakeRect(current.origin.x - 135, current.origin.y-120, current.size.width+270, current.size.height+120) display:YES animate:YES];
        if (![notis count]) {
            [self refreshData:nil];
        }
    }else{
        [[self window] setFrame:NSMakeRect(current.origin.x + 135, current.origin.y+120, current.size.width-270, current.size.height-120) display:YES animate:YES];
    }
}
#pragma end

-(IBAction)refreshData:(id)sender{
    if(!fetcher){
        fetcher=[[SIPGWNotificationsFetcher alloc]init];
    }
    [fetcher fetchNotisWithBlock:^(NSArray *result, NSError *error) {
        [[self notisPro] stopAnimation:nil];
        [btrefresh setEnabled:YES];
        if (error) {
            [[NSAlert alertWithError:error]beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
        }else{
            notis=result;
            [[self table] reloadData];
        }
    }];
    [btrefresh setEnabled:NO];
    [[self notisPro] startAnimation:nil];
}
-(IBAction)showPreference:(id)sender{
    if(!preferenceController){
        preferenceController=[[SIPGWPreferenceController alloc]init];
        [preferenceController setAppdelegate:self];
    }
    [preferenceController showWindow:nil];
}
-(IBAction)showMainWindow:(id)sender{
    [[self window] makeKeyAndOrderFront:self];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [notis count];
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return [[notis objectAtIndex:row] objectForKey:[tableColumn identifier]];
}
- (IBAction)refreshStat:(id)sender {NSLog(@"refreshStat");
    if(![[self btRefreshStat] isEnabled]) return;
    [[self netStatLI] setIntegerValue:0];
    [[self btRefreshStat]setEnabled:NO];
    [[self piRefreshStat]startAnimation:nil];
    if (!getter) {
        getter=[[SIPGWNetStatGeter alloc] init];
    }
    [self getItsStat];
}
-(void)getItsStat{
    [getter getItsAvaliableWithBlock:^(BOOL result) {
        if(!result){
            [self testOver];
            return;
        }
        [[self netStatLI] setIntegerValue:1];
        [self performSelector:@selector(getBaiduStat) withObject:nil afterDelay:0.01];
    }];
}
-(void)getBaiduStat{
    [getter getBaiduAvaliableWithBlock:^(BOOL result) {
        if(!result){
            [self testOver];
            return;
        }
        [[self netStatLI] setIntegerValue:2];
        [self performSelector:@selector(getAdobeStat) withObject:nil afterDelay:0.01];
    }];
}
-(void)getAdobeStat{
    [getter getAdobeAvaliableWithBlock:^(BOOL result) {
        if(!result){
            [self testOver];
            return;
        }
        [[self netStatLI] setIntegerValue:3];
        [self testOver];
    }];
}
-(void)testOver{
    switch ([[self netStatLI] integerValue]) {
        case 0:
            statString=@"尚未联网";
            break;
        case 1:
            statString=@"校内地址";
            break;
        case 2:
            statString=@"校外地址";
            break;
        case 3:
            statString=@"国际地址";
            break;
        default:
            break;
    }
    [self refreshTitle];
    [[self btRefreshStat] setEnabled:YES];
    [[self piRefreshStat] stopAnimation:nil];
}
@end
