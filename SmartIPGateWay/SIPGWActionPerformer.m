//
//  SIPGWActionPerformer.m
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-5.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import "SIPGWActionPerformer.h"

@implementation SIPGWActionPerformer
/*
 https://its.pku.edu.cn:5428/ipgatewayofpku?uid=1101111141&password=pas&operation=connect&range=2&timeout=2
 
 operation: connect, disconnect, disconnectall
 range: 1(fee), 2(free)
 
 */
-(id)init{
    self=[super init];
    if(self){
        baseUrlString=@"https://its.pku.edu.cn:5428/ipgatewayofpku";
    }
    return self;
}
-(void)connectIPGWwithUid:(NSString *)uid password:(NSString *)password isFeeArea:(BOOL)isFee block:(SIPGWActionPerformerResultBlock)theBlock{
    resultBlock=[theBlock copy];
    NSString *operation=@"connect";
    currentOperation=operation;
    NSInteger range=isFee?1:2;
    NSInteger timeout=3;
    NSURL *baseurl=[NSURL URLWithString:[NSString stringWithFormat:@"%@?uid=%@&password=%@&operation=%@&range=%li&timeout=%li",baseUrlString,uid,password,operation,(long)range,(long)timeout]];
    //NSLog(@"%@",[baseurl absoluteString]);
    NSURLRequest *req=[[NSURLRequest alloc]initWithURL:baseurl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    connection=[[NSURLConnection alloc]initWithRequest:req delegate:self];
    if(connection){
        responseData=[[NSMutableData alloc]init];
    }
}
-(void)disconnectIPGWwithBlock:(SIPGWActionPerformerSimpleResultBlock)theBlock{
    simpleResultBlock=[theBlock copy];
    NSString *operation=@"disconnect";
    currentOperation=operation;
    NSURL *baseurl=[NSURL URLWithString:[NSString stringWithFormat:@"%@?uid=12345&password=12345&operation=%@&range=2&timeout=3",baseUrlString,operation]];
    NSURLRequest *req=[[NSURLRequest alloc]initWithURL:baseurl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:3];
    connection=[[NSURLConnection alloc]initWithRequest:req delegate:self];
    finished=NO;
    if(connection){
        responseData=[[NSMutableData alloc]init];
    }
    while(!finished){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}
-(void)disconnectAllIPGWwithUid:(NSString *)uid password:(NSString *)password block:(SIPGWActionPerformerSimpleResultBlock)theBlock{
    simpleResultBlock=[theBlock copy];
    NSString *operation=@"disconnectall";
    currentOperation=operation;
    NSURL *baseurl=[NSURL URLWithString:[NSString stringWithFormat:@"%@?uid=%@&password=%@&operation=%@&range=2&timeout=3",baseUrlString,uid,password,operation]];
    NSURLRequest *req=[[NSURLRequest alloc]initWithURL:baseurl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:3];
    connection=[[NSURLConnection alloc]initWithRequest:req delegate:self];
    if(connection){
        responseData=[[NSMutableData alloc]init];
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{NSLog(@"didRecieveData");
    [responseData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{NSLog(@"didFinishLoading");
    finished=YES;
    NSString *result=[[NSString alloc]initWithData:responseData encoding:-2147482063];
    //NSLog(@"%@,%ld",result,[responseData length]);
    if([currentOperation isEqualToString:@"connect"]){
        userData=[NSMutableDictionary dictionary];
        //<!--IPGWCLIENT_START SUCCESS=NO REASON=被封/账户名错/注销 IPGWCLIENT_END-->
        NSRange begin=[result rangeOfString:@"<!--IPGWCLIENT_START"];
        NSRange end=[result rangeOfString:@"IPGWCLIENT_END-->"];
        NSString *ipgwinfo=[result substringWithRange:NSMakeRange(begin.location+begin.length, end.location-(begin.location+begin.length))];
        if([ipgwinfo rangeOfString:@"SUCCESS=NO"].length!=0){
            NSRange reasonRange=[ipgwinfo rangeOfString:@"REASON="];
            NSString *reason=[NSString stringWithFormat:@"%@%@",@"无法连接网关，原因可能是",[ipgwinfo substringFromIndex:reasonRange.location+reasonRange.length]];
            resultBlock(nil,[NSError errorWithDomain:NSPOSIXErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey]]);
            [self cleanUp];
            return;
        }
        begin=[result rangeOfString:@"<table noborder>"];
        end=[result rangeOfString:@"</table>"];
        NSString *sub=[result substringWithRange:NSMakeRange(begin.location+begin.length, end.location-(begin.location+begin.length))];
        sub=[sub stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        sub=[sub stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        sub=[sub stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        sub=[sub stringByReplacingOccurrencesOfString:@"：" withString:@""];
        NSRegularExpression *font=[[NSRegularExpression alloc]initWithPattern:@"<font.*?>|</font>|</?b>" options:0 error:nil];
        NSTextCheckingResult *i;
        do{
            i=[font firstMatchInString:sub options:0 range:NSMakeRange(0, [sub length])];
            if(i) sub=[sub stringByReplacingCharactersInRange:i.range withString:@""];
        }while(i);
        NSRegularExpression *reg=[[NSRegularExpression alloc]initWithPattern:@"(<tr><td>)(.+?)(</td><td>)(.+?)(</td></tr>)" options:0 error:nil];
        NSArray *matchs=[reg matchesInString:sub options:0 range:NSMakeRange(0, [sub length])];
        for (int i=0; i<[matchs count]; i++) {
            NSTextCheckingResult *r=[matchs objectAtIndex:i];
            [userData setObject:[sub substringWithRange:[r rangeAtIndex:4]] forKey:[sub substringWithRange:[r rangeAtIndex:2]]];
        }
        resultBlock(userData,nil);
    }else if([currentOperation isEqualToString:@"disconnect"]){
        if([result rangeOfString:@"网络断开成功"].length>0){
            simpleResultBlock(YES,nil);
        }else{
            NSString *reason=@"断开网络失败，可能是由于未知原因。";
            simpleResultBlock(NO,[NSError errorWithDomain:NSPOSIXErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey]]);
        }
    }else{
        if([result rangeOfString:@"断开全部连接成功"].length>0){
            simpleResultBlock(YES,nil);
        }else{
            NSString *reason=@"断开全部连接失败，可能是由于用户名或密码错误。";
            simpleResultBlock(NO,[NSError errorWithDomain:NSPOSIXErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey]]);
        }
    }
    [self cleanUp];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{NSLog(@"didFailWithError");
    finished=YES;
    if(resultBlock) resultBlock(nil,error);
    if(simpleResultBlock) simpleResultBlock(NO,error);
    [self cleanUp];
}
-(void)cleanUp{
    resultBlock=nil;
    simpleResultBlock=nil;
    connection=nil;
    responseData=nil;
    userData=nil;
}
@end
