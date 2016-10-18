//
//  InfoPanelViewController.m
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-6.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import "InfoPanelViewController.h"

@interface InfoPanelViewController ()

@end

@implementation InfoPanelViewController
@synthesize detail;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}
- (IBAction)closeInfoPane:(id)sender {
    [NSApp endSheet:[self.view window]];
    [[self.view window] orderOut:sender];
}

- (IBAction)showMoreInfo:(id)sender {
    NSAlert *alt=[NSAlert alertWithMessageText:@"网关登录信息" defaultButton:@"好" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",[self detail]];
    [alt beginSheetModalForWindow:[self.view window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}
@end
