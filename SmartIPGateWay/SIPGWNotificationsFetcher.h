//
//  SIPGWNotificationsFetcher.h
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-6.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^NotificationsFetcherResultBlock)(NSArray *result,NSError *error);

@interface SIPGWNotificationsFetcher : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
    NotificationsFetcherResultBlock resultBlock;
    NSMutableData *responseData;
    NSURLConnection *connection;
    NSMutableArray *notis;
}
-(void)fetchNotisWithBlock:(NotificationsFetcherResultBlock)theBlock;

@end
