//
//  SIPGWNetStatGeter.m
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-9.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import "SIPGWNetStatGeter.h"

@implementation SIPGWNetStatGeter
-(void)getItsAvaliableWithBlock:(NetStatGeterResultBlock) theBlock{//NSLog(@"getting its");
    gettingIts=YES;
    NSURL *url=[NSURL URLWithString:@"https://its.pku.edu.cn"];
    NSURLRequest *req=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3];
    connection=[[NSURLConnection alloc]initWithRequest:req delegate:self];
    block=theBlock;
}
-(void)getBaiduAvaliableWithBlock:(NetStatGeterResultBlock)theBlock{//NSLog(@"getting baidu");
    gettingIts=NO;
    NSURL *url=[NSURL URLWithString:@"http://www.baidu.com"];
    NSURLRequest *req=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3];
    connection=[[NSURLConnection alloc]initWithRequest:req delegate:self];
    block=theBlock;
}
-(void)getAdobeAvaliableWithBlock:(NetStatGeterResultBlock)theBlock{//NSLog(@"getting adobe");
    gettingIts=NO;
    NSURL *url=[NSURL URLWithString:@"http://www.adobe.com"];
    NSURLRequest *req=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3];
    connection=[[NSURLConnection alloc]initWithRequest:req delegate:self];
    block=theBlock;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSString *result=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if([result rangeOfString:@"http://its.pku.edu.cn/?cause=unauthN"].length!=0&&!gettingIts){
        block(NO);
    }else{
        block(YES);
    }
    [self clean];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{//NSLog(@"error");
    block(NO);
    [self clean];
}
-(void)clean{
    [connection cancel];
    block=nil;
    connection=nil;
}
@end
