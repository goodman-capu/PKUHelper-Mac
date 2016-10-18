//
//  SIPGWNetStatGeter.h
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-9.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^NetStatGeterResultBlock)(BOOL result);

@interface SIPGWNetStatGeter : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>{
    NetStatGeterResultBlock block;
    NSURLConnection *connection;
    BOOL gettingIts;
}
-(void)getItsAvaliableWithBlock:(NetStatGeterResultBlock) theBlock;
-(void)getBaiduAvaliableWithBlock:(NetStatGeterResultBlock)theBlock;
-(void)getAdobeAvaliableWithBlock:(NetStatGeterResultBlock)theBlock;
@end
