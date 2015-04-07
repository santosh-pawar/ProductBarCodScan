//
//  ProductScanBarCodeViewController.m
//  ProductBarCodScan
//
//  Created by Pawar, Santosh-CW on 4/3/15.
//  Copyright (c) 2015 Pawar, Santosh-CW. All rights reserved.
//

#import "ProductScanBarCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UiApplication+Additions.h"

#define kItalicFontName                             @"AvenirNext-Italic"

@interface ProductScanBarCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    UIView *_overLayView;
}

@end

@implementation ProductScanBarCodeViewController

- (void)setupScanImage{
    CGSize currentSize = [UIApplication currentSize];
    CGRect frame = CGRectMake(0, 0, currentSize.width, currentSize.height);

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, currentSize.width, 44)];
    [label setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.7]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:kItalicFontName size:11.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setText:@"Align Barcode/QR code with scan area."];
    [_overLayView setUserInteractionEnabled:NO];
    _overLayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"giftcardscanoverlay"]];
    [_overLayView setFrame:frame];
    [_overLayView addSubview:label];
    
    [self.view addSubview:_overLayView];
}


- (void)setupInputOutputDevices{
    //Instantiate session for scanning
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if(_input){
        [_session addInput:_input];
    }
    else{
        NSLog(@"Error: %@",error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if(_output){
        [_session addOutput:_output];
    }
    else{
        NSLog(@"Error: %@",error);
    }
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
}


- (void)setupVideoPreviewForScanning{
    
    CGSize currentSize = [UIApplication currentSize];
    CGRect frame = CGRectMake(0, 40, currentSize.width, currentSize.height);
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.frame = frame;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_previewLayer];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupInputOutputDevices];
    [self setupVideoPreviewForScanning];
    [self setupScanImage];
    
    if(_session){
        [_session startRunning];
    }
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{

    [self __stopRunning];
    __weak typeof(self) this = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect highLightViewRect = CGRectZero;
        AVMetadataMachineReadableCodeObject *barCodeObject = nil;
        NSString *codeDetectedString = nil, *scannedType;
        NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                                  AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                                  AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        for (AVMetadataObject *metaDataObject in metadataObjects) {
            for(NSString *type in barCodeTypes){
                if([metaDataObject.type isEqualToString:type]){
                    barCodeObject = (AVMetadataMachineReadableCodeObject*)[_previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject*)metaDataObject];
                    highLightViewRect = barCodeObject.bounds;
                    codeDetectedString = [(AVMetadataMachineReadableCodeObject*)metaDataObject stringValue];
                    scannedType = metaDataObject.type;
                    break;
                }
            }
        }
        [this parseScanResult:codeDetectedString forType:scannedType];
    });
}


- (void)parseScanResult:(NSString *)result forType:(NSString *)type {
    [self __stopRunning];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Scanning Completed!" message:[NSString stringWithFormat:@"Your scannded code is:\n %@",result] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Rescan" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        [self __startRunning];
    }];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Copy & Quit" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        UIPasteboard *copyScannedCode = [UIPasteboard generalPasteboard];
        copyScannedCode.string = result;
        exit(0);
    }];
    
    [alertController addAction:okButton];
    [alertController addAction:cancelButton];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)__startRunning {
    if (_session.isRunning) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_session startRunning];
    });
}


- (void)__stopRunning {
    if (!_session.isRunning) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_session stopRunning];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

