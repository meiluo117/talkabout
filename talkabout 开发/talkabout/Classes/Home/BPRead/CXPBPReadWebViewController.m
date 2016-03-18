//
//  CXPBPReadWebViewController.m
//  talkabout
//
//  Created by 于波 on 15/12/24.
//  Copyright © 2015年 于波. All rights reserved.
//

//http://blog.csdn.net/yiyaaixuexi/article/details/7658409

#define BPFile_weakSelf [NSString stringWithFormat:@"%@.%@",weakSelf.bpNameStr,weakSelf.bpfileTypeStr]
#define BPFile [NSString stringWithFormat:@"%@.%@",self.bpNameStr,self.bpfileTypeStr]
#define BPFile_WebLoad [NSString stringWithFormat:@"file://%@/%@.%@",self.documentPathStr,self.bpNameStr,self.bpfileTypeStr]

#import "CXPBPReadWebViewController.h"
#import "CXPGetFile.h"
#import "CXPNavItemBtn.h"
#import "CXPGetFileContentMD5.h"

@interface CXPBPReadWebViewController ()<UIWebViewDelegate>
@property (copy,nonatomic)UIActivityIndicatorView *activityIndicator;
@property (copy,nonatomic) NSString *filePathStr;
@property (weak, nonatomic) IBOutlet UIWebView *readBPWebV;
@property (copy,nonatomic) NSString *documentPathStr;

@end

@implementation CXPBPReadWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self downLoadFile];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)creatUI{
    self.navigationItem.title               = @"BP阅读";
    UIButton *lBtn                          = [CXPNavItemBtn btnWithWidth:12 height:20 andBtnName:@"left"];
    [lBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBtn                = [[UIBarButtonItem alloc] initWithCustomView:lBtn];
    self.navigationItem.leftBarButtonItem   = leftBtn;
    
    self.readBPWebV.delegate          = self;
    self.readBPWebV.scalesPageToFit   = YES;//开启webview缩放
    //沙盒document路径
    self.documentPathStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

//返回
- (void)backBtnClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 下载文档
- (void)downLoadFile{
    WS(weakSelf)
    //得到指定文件类型的全部文件
    NSArray *existFilesArray = [CXPGetFile getFilenamelistOfType:self.bpfileTypeStr fromDirPath:self.documentPathStr];
    
    __block BOOL isExist = NO;
    [existFilesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:BPFile_weakSelf]) {
            isExist = YES;
        }
    }];
    
    if (isExist) {
        CXP_LOG(@"文件存在!!判断md5");
        //文件存在，取出文件地址url去加载
        NSString *loadStr = BPFile_WebLoad;
        NSMutableString *string = [[NSMutableString alloc] initWithString:loadStr];
        
        if ([string hasPrefix:@"file://"]) {
            [string replaceOccurrencesOfString:@"file://" withString:@"" options:NSCaseInsensitiveSearch  range:NSMakeRange(0, loadStr.length)];
        }
        //得到文件md5
        NSString *fileMd5 = [CXPGetFileContentMD5 getFileMD5WithPath:string];
        
        if ([fileMd5 isEqualToString:self.bpmd5]) {
            
            CXP_LOG(@"文件名和md5都一样!!!!");
            [self.readBPWebV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[loadStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
            
        }else{
            [self down];
        }
        
    }else{
        [self down];
    }

}

- (void)down{
    WS(weakSelf)
    [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeLinear];
    [MMProgressHUD showWithTitle:nil status:@"正在拼命读取"];
    //创建请求（iOS7-）
    AFURLSessionManager *sessionManager;
    if (sessionManager) {
        sessionManager = nil;
    }
    
    sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //添加请求接口
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.bpReadUrl]];
    //发送下载请求
    NSURLSessionDownloadTask *downloadTask = [sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        //设置存放文件的位置 保存在iPhone沙盒中的Documents文件夹中
        NSURL *filePath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
        
        return [filePath URLByAppendingPathComponent:BPFile_weakSelf];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        //下载完成
        CXP_LOG(@"下载完成目录: %@", filePath);
        
        //            NSArray *filename = [CXPGetFile getFilenamelistOfType:@"docx"
        //                                                         fromDirPath:weakSelf.documentPathStr];
        //            NSInteger count = filename.count;
        //            NSLog(@"I have %d books in DocumentsDir",count);
        //            for (int i = 0; i<count; i++) {
        //                NSLog(@"NO.%d is %@",i+1,[filename objectAtIndex:i]);
        //            }
        [MMProgressHUD dismissWithSuccess:@"加载完成"];
        [weakSelf.readBPWebV loadRequest:[NSURLRequest requestWithURL:filePath]];
        
    }];
    //开始下载
    [downloadTask resume];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{

    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [_activityIndicator setCenter:view.center];
    [_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [view addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [_activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
    
    //web字体大小
//    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'"];
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [_activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
}

- (void)dealloc{
    self.readBPWebV.delegate = nil;
    [self.readBPWebV removeFromSuperview];
}

@end
