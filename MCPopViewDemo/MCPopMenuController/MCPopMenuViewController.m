//
//  MCPopMenuViewController.m
//  qikeyun
//
//  Created by 马超 on 16/3/29.
//  Copyright © 2016年 Jerome. All rights reserved.
//

#import "MCPopMenuViewController.h"


#define Kheight 44
#define KbottomMagin 44

@interface MCPopMenuViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,nonnull,strong)UITableView *tableView;
@property (nonatomic,nonnull,strong)UIView *coverView;

@end

@implementation MCPopMenuViewController

- (instancetype)initWithDataSource:(NSArray *)dataSource fromView:(UIView *)fromView
{
    return  [self initWithDataSource:dataSource fromView:fromView customFootView:nil];
}

- (instancetype)initWithDataSource:(NSArray *)dataSource fromView:(UIView *)fromView customFootView:(UIView *)customFootView
{
    self = [super init];
    
    if (self) {
        
        _dataSource = dataSource;
        _fromView = fromView;
        _customerFootView = customFootView;
        
        [self.view addSubview:customFootView];
        
    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self setupCoverView];
    [self setupTableView];
   
    
    [self adjustViewFrame];
    
    
}

#pragma mark ------------- 初始化控件 -------------

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

}
- (void)setupCoverView
{
    self.coverView = [[UIView alloc] init];
    self.coverView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.25];
    [self.view addSubview:self.coverView];
}
#pragma mark ------------- 私有方法 ---------------

- (void)show
{
    if (_dataSource == nil || _fromView == nil) {
        return;
    }
    UIViewController *controller = [self rootViewControllerOfWindos];
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    
    [self showAnimator];
}

/**
 *  根据数据源调整tableview的高度
 */
- (void)adjustViewFrame
{
    //根据来源的控件计算位置
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    CGRect rect = [window convertRect:_fromView.frame fromView:_fromView.superview];
    
    CGFloat y = rect.origin.y + rect.size.height;
    CGFloat x = 0.0;
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = [self getTableViewHeightWithTop:y];
    
    self.tableView.frame = CGRectMake(x, y, w, h);
    
    self.coverView.frame = CGRectMake(0, y, self.tableView.frame.size.width, self.view.bounds.size.height - y);
    
    _customerFootView.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.frame), _customerFootView.bounds.size.width, _customerFootView.bounds.size.height);
    
}
- (CGFloat)getTableViewHeightWithTop:(CGFloat)top
{
    CGFloat retHeight = 0;
    CGFloat H = self.view.bounds.size.height;
    CGFloat maxH = H - top - KbottomMagin; //最大的高度
    
    if (self.customerFootView) {
        
        maxH = maxH - self.customerFootView.bounds.size.height;
    }
    
    CGFloat dataH = _dataSource.count * Kheight; // 数据的高度
    
   
    
    if (dataH >= maxH) {
        
        retHeight = maxH;
    }
    else {
        
        retHeight = dataH ;
    }
    
    return retHeight;
    
}
/**
 *  获取根控制器
 *
 *  @return 跟控制器
 */
- (UIViewController *)rootViewControllerOfWindos
{
//    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
//    if (window) {
//        return window.rootViewController;
//    }
    return [self viewControllerOfView:_fromView];
}

/**
 *  根据view获取他的父控制器
 *
 *  @param view view
 *
 *  @return 父控制器
 */
- (UIViewController*)viewControllerOfView:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}




#pragma mark ------------- tableview delegate/ dataSource  ----------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Kheight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPopMenuCell *cell = [MCPopMenuCell cellWithTableView:tableView];
    cell.item = _dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCPopMenuItem *item = _dataSource[indexPath.row];
    if (item) {
        __weak typeof(self) weakSelf = self;
        
        [self dissmissAnimator];
        
        if (weakSelf.didSelectedItemBlock) {
            weakSelf.didSelectedItemBlock(item);
        }

    }
}

#pragma mark ----------------- private method ---------
- (void)showAnimator {
    
    // 添加动画
    CGRect rect = self.tableView.frame;
    
    CGRect tempF = self.tableView.frame;
    tempF.size.height = 0;
    self.tableView.frame = tempF;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)dissmissAnimator {
    
    
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect tempF = self.tableView.frame;
        tempF.size.height = 0;
        self.tableView.frame = tempF;
        
    } completion:^(BOOL finished) {
        
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
}
#pragma mark ----------------- 重写点击事件 -------------

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = touches.anyObject;
    
    //计算点击的区域
    CGPoint touchPoint = [touch locationInView:self.view];
    if (!CGRectContainsPoint(self.tableView.frame, touchPoint)) {
        
        __weak typeof(self) weakSelf = self;
        
         [self dissmissAnimator];
        
        if (weakSelf.dissBlock) {
            weakSelf.dissBlock(nil);
        }

    }
}


@end
