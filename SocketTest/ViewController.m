//
//  ViewController.m
//  SocketTest
//
//  Created by apple on 15/10/22.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate>
{
    GCDAsyncSocket *_topClientSock;
    long _contentLength;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topClientSock = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
   // [_topClientSock connectToHost:@"10.80.64.3" onPort:80 withTimeout:10 error:nil];
   // [_topClientSock disconnect];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"已经连接到:%@:%u",host,port);
#if 0 //http request
    NSString *httpRequestString = @"GET/HTTP/1.1\r\nHost:10.80.64.3\r\n\r\n";
    [_topClientSock writeData:[httpRequestString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1 tag:2];
    [_topClientSock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:3 tag:2];
#endif
    
    [_topClientSock writeData:[NSData dataWithContentsOfFile:@"/Users/apple/Desktop/DressLink借口.txt"] withTimeout:-1 tag:3];
    [_topClientSock readDataWithTimeout:-1 tag:3];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
#if 0 //http response
    NSString *reponseStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *arr = [reponseStr componentsSeparatedByString:@":"];
    if ([[arr firstObject] isEqualToString:@"Content-Length"]) {
        NSString *str = [arr lastObject];
        _contentLength = [str integerValue];
    }
    NSLog(@"%@",reponseStr);
    if ([reponseStr isEqualToString:@"\r\n"]) {
    [_topClientSock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:3 tag:2];
    }else
    {
        [_topClientSock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:3 tag:3];
    }
#endif
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
