//
//  InfoPanelViewController.h
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-6.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InfoPanelViewController : NSViewController{
    NSString *detail;
}
@property (nonatomic)NSString *detail;
@property (weak) IBOutlet NSTextField *labelName;
@property (weak) IBOutlet NSTextField *labelType;
@property (weak) IBOutlet NSTextField *labelCurrent;
@property (weak) IBOutlet NSProgressIndicator *progressbar;
@property (weak) IBOutlet NSTextField *progressMax;
@property (weak) IBOutlet NSTextField *progressMin;
@property (weak) IBOutlet NSTextField *progressTip;
- (IBAction)closeInfoPane:(id)sender;
- (IBAction)showMoreInfo:(id)sender;
@property (weak) IBOutlet NSLevelIndicator *connections;
@property (weak) IBOutlet NSTextField *dateMax;
@property (weak) IBOutlet NSProgressIndicator *dateProgress;
@property (weak) IBOutlet NSTextField *dateTip;
@property (weak) IBOutlet NSTextField *dateMin;

@end
