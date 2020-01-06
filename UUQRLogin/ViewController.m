//
//  ViewController.m
//  UUQRLogin
//
//  Created by wdgeeker on 2019/12/19.
//  Copyright © 2019 wdgeeker. All rights reserved.
//

#import "ViewController.h"
#import "QRViewController.h"
#import "UUTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *qrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qrBtn.frame = CGRectMake(100, 100, 100, 30);
    [qrBtn setTitle:@"扫码登录" forState:UIControlStateNormal];
    qrBtn.backgroundColor = [UIColor redColor];
    [qrBtn addTarget:self action:@selector(clickQRBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:qrBtn];
    
}

- (void)clickQRBtn {
    
    NSLog(@"%@===%@",[UUTool getCurrentVC], self);
    
    QRViewController *QRVC = [[QRViewController alloc] init];
    QRVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:QRVC animated:NO completion:nil];
}


@end
