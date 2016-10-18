//
//  SIPGWNotificationsFetcher.m
//  SmartIPGateWay
//
//  Created by 熊典 on 13-12-6.
//  Copyright (c) 2013年 熊典. All rights reserved.
//

#import "SIPGWNotificationsFetcher.h"

@implementation SIPGWNotificationsFetcher
-(void)fetchNotisWithBlock:(NotificationsFetcherResultBlock)theBlock{
    NSURL *url=[NSURL URLWithString:@"https://its.pku.edu.cn/announce/index.jsp"];
    resultBlock=[theBlock copy];
    NSURLRequest *req=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    connection=[NSURLConnection connectionWithRequest:req delegate:self];
    if(connection){
        responseData=[[NSMutableData alloc]init];
    }
}
-(void)cleanup{
    responseData=nil;
    resultBlock=nil;
    connection=nil;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [responseData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *result=[[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    if (!notis) {
        notis=[[NSMutableArray alloc]init];
    }
    [notis removeAllObjects];
    NSRange begin=[result rangeOfString:@"<!--AnnBegin-->"];
    NSRange end=[result rangeOfString:@"<!--AnnEnd-->"];
    NSString *notisraw=[result substringWithRange:NSMakeRange(begin.location+begin.length, end.location-(begin.location+begin.length))];
    NSRegularExpression *reg=[[NSRegularExpression alloc]initWithPattern:@"(<li><a href=\")(.+?)(\">)(.+?)(<span class=\"s-dt\">)(.+?)(</span></a></li>)" options:0 error:nil];
    NSArray *matches=[reg matchesInString:notisraw options:0 range:NSMakeRange(0, [notisraw length])];
    for (int i=0; i<[matches count]; i++) {
        NSTextCheckingResult *r=[matches objectAtIndex:i];
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setObject:[notisraw substringWithRange:[r rangeAtIndex:2]] forKey:@"href"];
        [dict setObject:[notisraw substringWithRange:[r rangeAtIndex:4]] forKey:@"title"];
        NSString *time = [notisraw substringWithRange:[r rangeAtIndex:6]];
        [dict setObject:[time substringWithRange:NSMakeRange(1, time.length - 2)] forKey:@"time"];
        [notis addObject:dict];
        dict=nil;
    }
    resultBlock([notis copy],nil);
    [self cleanup];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    resultBlock(nil,error);
    [self cleanup];
}
@end
