//
//  SIPGWActionPerformer.h
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-5.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^SIPGWActionPerformerResultBlock)(NSDictionary* result,NSError *error);
typedef void (^SIPGWActionPerformerSimpleResultBlock)(BOOL result,NSError *error);


@interface SIPGWActionPerformer : NSObject<NSURLConnectionDataDelegate>{
    SIPGWActionPerformerResultBlock resultBlock;
    SIPGWActionPerformerSimpleResultBlock simpleResultBlock;
    NSURLConnection *connection;
    NSMutableData *responseData;
    NSString *baseUrlString;
    NSMutableDictionary *userData;
    NSString *currentOperation;
    BOOL finished;
}
-(void)connectIPGWwithUid:(NSString*)uid password:(NSString*)password isFeeArea:(BOOL)isFee block:(SIPGWActionPerformerResultBlock)theBlock;
-(void)disconnectIPGWwithBlock:(SIPGWActionPerformerSimpleResultBlock)theBlock;
-(void)disconnectAllIPGWwithUid:(NSString*)uid password:(NSString*)password block:(SIPGWActionPerformerSimpleResultBlock)theBlock;

@end
