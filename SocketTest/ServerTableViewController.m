//
//  ServerTableViewController.m
//  SocketTest
//
//  Created by apple on 15/10/22.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "ServerTableViewController.h"
#import "GCDAsyncSocket.h"

@interface ServerTableViewController ()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_serverSocket;
    NSMutableArray *_peerSocketArray;
    NSMutableDictionary *_onlineUsers;
}
@end

@implementation ServerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _peerSocketArray = [NSMutableArray array];
    _onlineUsers = [NSMutableDictionary dictionary];
    _serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_serverSocket acceptOnPort:1234 error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _onlineUsers.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OnlineUser" forIndexPath:indexPath];
    cell.textLabel.text = [_onlineUsers.allKeys objectAtIndex:indexPath.row];
    return cell;
}

//有新的连接进来了
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    [_peerSocketArray addObject:newSocket];
    [newSocket readDataToData:[GCDAsyncSocket ZeroData] withTimeout:-1 tag:0];
    
}

//有一个连接断开了
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [_peerSocketArray removeObject:sock];
    if (sock.userData) {
        [_onlineUsers removeObjectForKey:sock.userData];
        NSLog(@"%@ 下线了", sock.userData);
        [self.tableView reloadData];
    }
}

    //从某个链接收到了数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSData *msgData = [NSData dataWithBytes:data.bytes length:data.length - 1];
    NSDictionary *msgDic = [NSJSONSerialization JSONObjectWithData:msgData options:NSJSONReadingAllowFragments error:nil];
    NSString *from = [msgDic objectForKey:@"from"];
    NSString *to = [msgDic objectForKey:@"to"];
    NSString *msg = [msgDic objectForKey:@"msg"];
    if ([to isEqualToString:@"server"]) {
        sock.userData = from;
        [_onlineUsers setObject:sock forKey:from];
        NSLog(@"%@ 上线了", from);
        [self.tableView reloadData];
    }else{
      //需要转发
        GCDAsyncSocket *toSock = [_onlineUsers objectForKey:to];
        if (toSock&&toSock.isConnected) {
            NSLog(@"%@给%@发送了消息:%@",from,to,msg);
            [toSock writeData:data withTimeout:-1 tag:0];
            [toSock readDataToData:[GCDAsyncSocket ZeroData] withTimeout:-1 tag:0];
        }
    }
        [sock readDataToData:[GCDAsyncSocket ZeroData] withTimeout:-1 tag:0];
}

@end






