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
    NSString *result=[[NSString alloc]initWithData:responseData encoding:-2147482063];
    if (!notis) {
        notis=[[NSMutableArray alloc]init];
    }
    [notis removeAllObjects];
    NSRange begin=[result rangeOfString:@"<!--AnnBegin-->"];
    NSRange end=[result rangeOfString:@"<!--AnnEnd-->"];
    NSString *notisraw=[result substringWithRange:NSMakeRange(begin.location+begin.length, end.location-(begin.location+begin.length))];
    //<li class="style"> <a href="/announce/tz20130627142920.jsp">校园网紧急通知</a>（2013.06.27）</li>
    NSRegularExpression *reg=[[NSRegularExpression alloc]initWithPattern:@"(<li class=\"style\"> <a href=\")(.+?)(\">)(.+?)(</a>（)(.+?)(）</li>)" options:0 error:nil];
    NSArray *matches=[reg matchesInString:notisraw options:0 range:NSMakeRange(0, [notisraw length])];
    for (int i=0; i<[matches count]; i++) {
        NSTextCheckingResult *r=[matches objectAtIndex:i];
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setObject:[notisraw substringWithRange:[r rangeAtIndex:2]] forKey:@"href"];
        [dict setObject:[notisraw substringWithRange:[r rangeAtIndex:4]] forKey:@"title"];
        [dict setObject:[notisraw substringWithRange:[r rangeAtIndex:6]] forKey:@"time"];
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
