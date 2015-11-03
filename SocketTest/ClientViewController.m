//
//  ClientViewController.m
//  SocketTest
//
//  Created by apple on 15/10/22.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "ClientViewController.h"
#import "GCDAsyncSocket.h"

@interface ClientViewController ()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_clientSock;
}


@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *receiverTextField;
@property (weak, nonatomic) IBOutlet UITextField *senderTextField;
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;

@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    }
- (IBAction)connectClicked:(id)sender {
    _clientSock = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_clientSock connectToHost:_addressTextField.text onPort:_portTextField.text.intValue error:nil];

}

- (IBAction)cutClicked:(id)sender {
    [_clientSock disconnect];
}

- (IBAction)sendClicked:(id)sender {
    NSString *msgFormat = @"{\"from\":\"%@\",\"to\":\"%@\",\"msg\":\"%@\"}";
    NSString *msg = [NSString stringWithFormat:msgFormat,_senderTextField.text,_receiverTextField.text,_msgTextView.text];
    NSData *msgdata = [msg dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableData *mData = [NSMutableData dataWithData:msgdata];
    [mData appendData:[GCDAsyncSocket ZeroData]];
    
    if (_clientSock.isConnected) {
        [_clientSock writeData:mData withTimeout:-1 tag:0];
        [_clientSock readDataToData:[GCDAsyncSocket ZeroData] withTimeout:-1 tag:0];
    }
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"已经连接到:%@:%u",host,port);
    NSString *msgFormat = @"{\"from\":\"%@\",\"to\":\"%@\",\"msg\":\"%@\"}";
    NSString *msg = [NSString stringWithFormat:msgFormat, _senderTextField.text, @"server",_msgTextView.text];
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mData = [NSMutableData dataWithData:msgData];
    [mData appendData:[GCDAsyncSocket ZeroData]];
    if (_clientSock.isConnected) {
        [_clientSock writeData:mData withTimeout:-1 tag:0];
        [_clientSock readDataToData:[GCDAsyncSocket ZeroData] withTimeout:-1 tag:0];
    }

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"服务器的连接断开:%@:%u",sock.connectedHost,sock.connectedPort);
    _clientSock = nil;
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *msgData = [NSData dataWithBytes:data.bytes length:data.length - 1];
    NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:msgData options:NSJSONReadingAllowFragments error:nil];
    NSString *from = [msgDic objectForKey:@"from"];
    NSString *msg = [msgDic objectForKey:@"msg"];
    _msgTextView.text = [NSString stringWithFormat:@"收到%@的消息:%@",from,msg];
    
    [_clientSock readDataToData:[GCDAsyncSocket ZeroData] withTimeout:-1 tag:0];
    }

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
