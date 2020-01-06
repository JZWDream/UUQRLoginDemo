//
//  QRViewController.m
//  UUQRLogin
//
//  Created by wdgeeker on 2019/12/19.
//  Copyright © 2019 wdgeeker. All rights reserved.
//

#import "QRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ShadowView.h"
#import "UUTool.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define customShowSize CGSizeMake(280, 280);

@interface QRViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong) AVCaptureSession *captureSession;//捕捉会话

@property (nonatomic,strong) AVCaptureDeviceInput *deviceInput;//输入流

@property (nonatomic,strong) AVCaptureMetadataOutput *metaDataOutput;//输出流

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;//预览图层

@property (nonatomic,strong) ShadowView *shadowView;//蒙层

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //监听屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidLayoutSubviews) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self loadHeadView];
    [self.view.layer addSublayer:self.videoPreviewLayer];
    [self startCapture];
//    [self loadShadowView];
    
    self.shadowView = [[ShadowView alloc] initWithFrame:CGRectMake(0, 40, kWidth, kHeight - 40)];
       [self.view addSubview:self.shadowView];
       self.shadowView.showSize = customShowSize;
}

- (void)clickBackBtn {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)loadHeadView {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 0, 40, 40);
    backBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kWidth, 40)];
    titleLable.text = @"客户端扫码登录";
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.textColor = [UIColor blackColor];
    titleLable.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:titleLable];
}

//开始扫描
- (void)startCapture{
    if (![self requestDeviceAuthorization]) {
        NSLog(@"没有访问相机权限！");
        return;
    }
    
    [self.captureSession beginConfiguration];
    if ([self.captureSession canAddInput:self.deviceInput]) {
        [self.captureSession addInput:self.deviceInput];
    }
    // 设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
    if ([self.captureSession canAddOutput:self.metaDataOutput]) {
        [self.captureSession addOutput:self.metaDataOutput];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSArray *types = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode93Code];
        self.metaDataOutput.metadataObjectTypes =types;
    }
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
}
//停止扫描
- (void)stopCapture{
    [self.captureSession stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //获取到扫描的数据
    AVMetadataMachineReadableCodeObject *dateObject = (AVMetadataMachineReadableCodeObject *) [metadataObjects lastObject];
    NSLog(@"metadataObjects[last]==%@",dateObject.stringValue);
    //识别结果，作比对和登录跳转
    [self.shadowView stop];
//    [self.captureSession stopRunning];
    
}
#pragma makr - 请求权限
- (BOOL)requestDeviceAuthorization{
    
    AVAuthorizationStatus deviceStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (deviceStatus == AVAuthorizationStatusRestricted ||
        deviceStatus ==AVAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}

- (void)layerOrientationByDeviceOritation {
    
    UIDeviceOrientation screenOrientation = [UIDevice currentDevice].orientation;
    
    switch (screenOrientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
            break;
            
        case UIDeviceOrientationLandscapeRight:
            self.videoPreviewLayer.connection.videoOrientation = UIDeviceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            self.videoPreviewLayer.connection.videoOrientation = UIDeviceOrientationLandscapeLeft;
            break;
            
        default:
            self.videoPreviewLayer.connection.videoOrientation = UIDeviceOrientationLandscapeRight;
            break;
    }
    
}

#pragma mark - 懒加载
- (AVCaptureSession *)captureSession{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    }
    return _captureSession;
}
- (AVCaptureDeviceInput *)deviceInput{
    if (!_deviceInput) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error = nil;
        _deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
        if (error) {
            return nil;
        }
    }
    return _deviceInput;
}
- (AVCaptureMetadataOutput *)metaDataOutput{
    if (!_metaDataOutput) {
        _metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metaDataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
 
    }
    return _metaDataOutput;
}
- (AVCaptureVideoPreviewLayer *)videoPreviewLayer{
    if (!_videoPreviewLayer) {
        _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _videoPreviewLayer.frame = CGRectMake(0, 40, kWidth, kHeight-40);
    }
    return _videoPreviewLayer;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layerOrientationByDeviceOritation];
}

- (void)dealloc {
    [self.captureSession stopRunning];
    self.deviceInput = nil;
    self.metaDataOutput = nil;
    self.captureSession = nil;
    self.videoPreviewLayer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
