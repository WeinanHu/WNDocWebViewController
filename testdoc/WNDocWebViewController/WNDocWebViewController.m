//
//  WNDocWebViewController.m
//  testdoc
//
//  Created by HuWeinan on 2018/7/24.
//  Copyright © 2018年 perhwn. All rights reserved.
//

#import "WNDocWebViewController.h"

#import <WebKit/WebKit.h>
#define MAX_SIZE_PERCENT 4

#define MIN_SIZE_PERCENT 0.7
#define DECELARRATION 0.3
#define KEY_FOR_SIZE_PERCENT @"WNDocWebViewControllerSizePercent"

@interface WNDocWebViewController ()<WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property(nonatomic,strong) WKWebView *webView;
@property(nonatomic,strong) NSURL *docUrl;
@property(nonatomic,strong) UIPinchGestureRecognizer *pinch;
@property(nonatomic,assign) CGFloat sizePercent;

@property(nonatomic,assign) CGFloat contentWidth;
@property(nonatomic,assign) CGFloat paddingLeft;
@property(nonatomic,assign) CGFloat paddingRight;
@property(nonatomic,assign) CGFloat paddingTop;
@property(nonatomic,assign) CGFloat paddingBottom;
@property(nonatomic,assign) CGRect viewFrame;


@end

@implementation WNDocWebViewController
-(instancetype)initWithDocUrl:(NSURL *)docUrl viewFrame:(CGRect)frame{
    if (self = [super init]) {
        self.docUrl = docUrl;
        self.viewFrame = frame;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.frame = self.viewFrame;
    CGRect webframe = CGRectMake(0, 0, self.viewFrame.size.width, self.viewFrame.size.height);
    WKWebView *webView = [[WKWebView alloc]initWithFrame:webframe];
    _webView = webView;
    [self.view addSubview:webView];
    if (!_docUrl) {
        return;
    }
//    NSString *path = [[NSBundle mainBundle]pathForResource:@"test5.docx" ofType:nil];
    
    webView.navigationDelegate = self;
    webView.scrollView.delegate = self;
    
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaGesture:)];
    _pinch.delegate = self;
    [webView addGestureRecognizer:_pinch];
    self.sizePercent = [self loadSizePercent];
    

    self.webView.scrollView.bounces = NO;
    [webView loadRequest:[NSURLRequest requestWithURL:_docUrl]];
    
    self.contentWidth = 595;//暂时设为A4纸的宽，有设自动变换宽度的代码
    self.paddingLeft = 15;
    self.paddingRight = 15;
    self.paddingTop = 15;
    self.paddingBottom = 15;
    
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)scaGesture:(UIPinchGestureRecognizer *)sender{
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        self.sizePercent = self.sizePercent * 1+(sender.scale-1)*DECELARRATION;
        if (self.sizePercent>MAX_SIZE_PERCENT) {
            self.sizePercent = MAX_SIZE_PERCENT;
        }
        if (self.sizePercent<MIN_SIZE_PERCENT) {
            self.sizePercent = MIN_SIZE_PERCENT;
        }
        [self saveSizePercent:self.sizePercent];
        [self changeSizePercent:self.sizePercent];
    }
    NSLog(@"sender.scale:%@",@(sender.scale));
    [self.webView.scrollView setZoomScale:self.view.frame.size.width/self.contentWidth animated:NO];//防止webView内部手势缩放
    
}
#pragma mark - set方法

-(void)setBgColor:(id)bgColor{
    _bgColor = bgColor;
    
    [self changeBgColor:_bgColor];
}
-(void)setTextColor:(id)textColor{
    _textColor = textColor;
    [self changeTextColor:textColor];
}
#pragma mark - 存取字体大小
-(void)saveSizePercent:(CGFloat)sizePercent{
    [[NSUserDefaults standardUserDefaults] setFloat:self.sizePercent forKey:KEY_FOR_SIZE_PERCENT];
}
-(CGFloat)loadSizePercent{
    
    if (![[NSUserDefaults standardUserDefaults]floatForKey:KEY_FOR_SIZE_PERCENT]) {
        if (_defaultSizePercent) {
            _defaultSizePercent = _defaultSizePercent>MAX_SIZE_PERCENT?MAX_SIZE_PERCENT:(_defaultSizePercent<MIN_SIZE_PERCENT?MIN_SIZE_PERCENT:_defaultSizePercent);
            [[NSUserDefaults standardUserDefaults] setFloat:_defaultSizePercent forKey:KEY_FOR_SIZE_PERCENT];
        }else{
            [[NSUserDefaults standardUserDefaults] setFloat:1.5 forKey:KEY_FOR_SIZE_PERCENT];
            
        }
    }
    return [[NSUserDefaults standardUserDefaults]floatForKey:KEY_FOR_SIZE_PERCENT];
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //字体颜色
    //    [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= '#333333'" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {}];
//    [self changeTextColor:[UIColor redColor]];
    if (_textColor) {
        [self changeTextColor:_textColor];
    }
    //背景颜色
    if (_bgColor) {
        [self changeBgColor:_bgColor];
    }
//    [self changeBgColor:@"#C7EDCC"];
    //边框
    [self changePaddingLeft:self.paddingLeft paddingRight:self.paddingRight paddingTop:self.paddingTop paddingBottom:self.paddingBottom completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        
        //获取content-width
        [webView evaluateJavaScript:@"document.getElementsByTagName('meta')[1].content" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            if ([ret isKindOfClass:[NSString class]]) {
                NSString *contentStr = (NSString *)ret;
                NSString *num = @"595";
                if ([contentStr containsString:@"width="]) {
                    NSRange range = [contentStr rangeOfString:@"width="];
                    NSInteger index = 0;
                    for (NSInteger i = range.length+range.location; i<contentStr.length; i++) {
                        NSString *str = [contentStr substringWithRange:NSMakeRange(i, 1)];
                        if ([str isEqualToString:@","]) {
                            index = i;
                            num = [contentStr substringWithRange:NSMakeRange(range.length+range.location, index - (range.length+range.location))];
                            break;
                        }
                    }
                    __weak typeof(self)safe = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [safe.webView.scrollView setZoomScale:safe.view.frame.size.width/([num floatValue]) animated:NO];
                        safe.contentWidth = [num floatValue];
                        [safe changeWidth:([num floatValue]-(self.paddingLeft+self.paddingRight))completionHandler:^(id _Nullable ret, NSError * _Nullable error) {

                        }];
                    });
                }
            }
            
        }];
    }];
    [self changeSizePercent:self.sizePercent];

    
}
#pragma mark - 改变各种css属性
//UIColor转16进制字符串
- (NSString *)hexFromUIColor:(UIColor *)color
{
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    
    return [NSString stringWithFormat:@"#%02x%02x%02x", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}
//背景颜色
-(void)changeBgColor:(id)color{
    NSString *colorStr = @"#FFFFFF";
    if ([color isKindOfClass:[NSString class]]) {
        colorStr = (NSString*)color;
    }else if ([color isKindOfClass:[UIColor class]]){
        colorStr = [self hexFromUIColor:color];
    }
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.background='%@'",colorStr] completionHandler:^(id _Nullable ret, NSError * _Nullable error) {}];
}
//字体颜色
-(void)changeTextColor:(id)color{
    NSString *colorStr = @"#333333";
    if ([color isKindOfClass:[NSString class]]) {
        colorStr = (NSString*)color;
    }else if ([color isKindOfClass:[UIColor class]]){
        colorStr = [self hexFromUIColor:color];
    }
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor='%@'",colorStr] completionHandler:^(id _Nullable ret, NSError * _Nullable error) {}];
}
//文字宽
-(void)changeWidth:(CGFloat)width completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler{
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementsByClassName('s1')[0].style.width=%@",@(width)] completionHandler:completionHandler];
}
//边框
-(void)changePaddingLeft:(CGFloat)paddingLeft paddingRight:(CGFloat)paddingRight paddingTop:(CGFloat)paddingTop paddingBottom:(CGFloat)paddingBottom completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler{
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementsByClassName('s1')[0].style.paddingLeft=%@;document.getElementsByClassName('s1')[0].style.paddingRight=%@;document.getElementsByClassName('s1')[0].style.paddingTop=%@;document.getElementsByClassName('s1')[0].style.paddingBottom=%@",@(paddingLeft),@(paddingRight),@(paddingTop),@(paddingBottom)] completionHandler:completionHandler];
}
//字体大小
-(void)changeSizePercent:(CGFloat)percent{
    NSNumber *percentNum = @(percent*100);
    NSString *jsStr = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%@%%'",percentNum];
    [_webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable ret, NSError * _Nullable error) {}];
    
}

#pragma mark - 系统处理
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

