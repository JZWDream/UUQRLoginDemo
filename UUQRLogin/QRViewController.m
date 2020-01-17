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

@property (nonatomic,strong) UILabel *titleLable;//标题

@property (nonatomic,strong) UIButton *backBtn;//返回按钮

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //监听屏幕旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidLayoutSubviews) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self layerOrientationByDeviceOritation];
    
    [self loadHeadView];
    [self.view.layer addSublayer:self.videoPreviewLayer];
    [self startCapture];
    
    self.shadowView = [[ShadowView alloc] initWithFrame:CGRectMake(0, 40, kWidth, kHeight-40)];
    self.shadowView.uu_showSize = customShowSize;
    [self.view addSubview:self.shadowView];
}

- (void)clickBackBtn {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)loadHeadView {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 0, 40, 40);
    backBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [backBtn setImage:[UIImage imageNamed:@"SSBundle.bundle/icon_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    self.backBtn = backBtn;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kWidth, 40)];
    titleLable.text = @"神雕侠侣客户端扫码登录";
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.textColor = [UIColor blackColor];
    titleLable.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:titleLable];
    self.titleLable = titleLable;
}

//开始扫描
- (void)startCapture{
    if (![self requestDeviceAuthorization]) {
        [self alertWithTitle:@"没有相机权限" message:@"请在设置-通用-相机-允许访问" leftStr:@"去设置" rightStr:@"取消" leftItem:^{
            NSURL *openURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:openURL];
        } rightItem:^{
            
        }];
        
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
    [self.shadowView uu_scanStart];
}

//停止扫描
- (void)stopCapture{
    [self.captureSession stopRunning];
    [self.shadowView uu_scanStop];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //获取到扫描的数据
    AVMetadataMachineReadableCodeObject *dataObject = (AVMetadataMachineReadableCodeObject *) [metadataObjects lastObject];
    [self stopCapture];
    //识别结果，作比对和登录跳转
    NSLog(@"----%@", dataObject);
    //    [self.captureSession stopRunning];
    
}

#pragma mark - 请求权限
- (BOOL)requestDeviceAuthorization{
    
    AVAuthorizationStatus deviceStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (deviceStatus == AVAuthorizationStatusRestricted ||
        deviceStatus ==AVAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}

//判断当前屏幕方向
- (void)layerOrientationByDeviceOritation {
    self.titleLable.frame = CGRectMake(0, 0, kWidth, 40);
    self.videoPreviewLayer.frame = _videoPreviewLayer.frame = CGRectMake(0, 40, kWidth, kHeight-40);
    self.shadowView.frame = CGRectMake(0, 40, kWidth, kHeight-40);
    [self.shadowView setNeedsDisplay];
    
    UIDeviceOrientation screenOrientation = [UIDevice currentDevice].orientation;
    
    switch (screenOrientation) {
        case UIDeviceOrientationPortrait:
            self.videoPreviewLayer.connection.videoOrientation = UIDeviceOrientationPortrait;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            self.videoPreviewLayer.connection.videoOrientation = UIDeviceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            self.videoPreviewLayer.connection.videoOrientation = UIDeviceOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
            break;
            
        default:
            self.videoPreviewLayer.connection.videoOrientation = UIDeviceOrientationPortrait;
            break;
    }
    
}


/// 根据url拼接参数
/// @param url 拼接好的参数
- (NSDictionary *)paramerWithURL:(NSURL *)url {
    
    NSMutableDictionary *paramer = [[NSMutableDictionary alloc]init];
    //创建url组件类
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    //遍历所有参数，添加入字典
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [paramer setObject:obj.value forKey:obj.name];
    }];
    return paramer;
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message leftStr:(NSString * __nullable)leftStr rightStr:(NSString * __nullable)rightStr leftItem:(void (^ __nullable)(void))leftItem rightItem:(void (^ __nullable)(void))rightItem {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (leftStr) {
        UIAlertAction *leftAction = [UIAlertAction actionWithTitle:leftStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (leftItem) {
                leftItem();
            }
        }];
        [alertController addAction:leftAction];
    }
    
    if (rightStr) {
        UIAlertAction *rightAction = [UIAlertAction actionWithTitle:rightStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (rightItem) {
                rightItem();
            }
        }];
        [alertController addAction:rightAction];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


#pragma mark - 强制转屏
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
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
