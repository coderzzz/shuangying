//
//  WeicoViewController.m
//  iwen
//
//  Created by Interest on 16/3/11.
//  Copyright © 2016年 Interest. All rights reserved.
//

#import "WeicoViewController.h"
#import "WeiCoCell.h"
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "SendWeicoViewController.h"
#import "UserListCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UserWeiCoViewController.h"
@interface WeicoViewController ()<UITableViewDelegate,UITableViewDataSource,MWPhotoBrowserDelegate,WeiCoCellDelegate>
@property (nonatomic, strong)MWPhotoBrowser *browser;
@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong)  UIBarButtonItem *settingItem;
@end

@implementation WeicoViewController
{
    NSMutableArray *list;
    NSMutableArray *userList;
    NSMutableArray *photos;
    AVAudioPlayer *player;
    PersonModel *userInfo;
}

- (MWPhotoBrowser *)browser{
    
    if (_browser == nil) {
        
        BOOL displayActionButton = NO;
        BOOL displaySelectionButtons = NO;
        BOOL displayNavArrows = NO;
        BOOL enableGrid = YES;
        BOOL startOnGrid = NO;
        
        enableGrid = NO;
        
        
        // Create browser
        _browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        _browser.displayActionButton = displayActionButton;//分享按钮,默认是
        _browser.displayNavArrows = displayNavArrows;//左右分页切换,默认否
        _browser.displaySelectionButtons = displaySelectionButtons;//是否显示选择按钮在图片上,默认否
        _browser.alwaysShowControls = displaySelectionButtons;//控制条件控件 是否显示,默认否
        _browser.zoomPhotosToFill = NO;//是否全屏,默认是
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        browser.wantsFullScreenLayout = YES;//是否全屏
#endif
       _browser.enableGrid = enableGrid;//是否允许用网格查看所有图片,默认是
        _browser.startOnGrid = startOnGrid;//是否第一张,默认否
        _browser.enableSwipeToDismiss = YES;
        [_browser showNextPhotoAnimated:YES];
        [_browser showPreviousPhotoAnimated:YES];
        [_browser setCurrentPhotoIndex:0];
    }
    
    return _browser;
}
- (UIBarButtonItem *)settingItem{
    
    if (_settingItem  == nil) {
        
        UIButton *blogItem         = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [blogItem setImage:[UIImage imageNamed:@"发表"] forState:UIControlStateNormal];
        [blogItem addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
        _settingItem = [[UIBarButtonItem alloc]initWithCustomView:blogItem];
        
        
    }
    
    return _settingItem;
}
-(MPMoviePlayerController *)moviePlayer{
    if (!_moviePlayer) {
//        NSURL *url=[NSURL URLWithString:model.video_info];
//        _moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:url];
//        _moviePlayer.view.frame=CGRectMake(15, 85, ScreenWidth-30, 225);
//        
//        _moviePlayer.shouldAutoplay= NO;
//        
//        _moviePlayer.scalingMode = MPMovieScalingModeFill;
//        
//        _moviePlayer.controlStyle = MPMovieControlStyleNone;
//        
//        self.controls.frame = _moviePlayer.view.bounds;
//        
//        [_moviePlayer.view addSubview:self.controls];
//        
//        [self.headview addSubview:_moviePlayer.view];
    }
    return _moviePlayer;
}
- (void)setting{

    SendWeicoViewController *vc = [[SendWeicoViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)segAction:(id)sender {
    
    UISegmentedControl *seg = (UISegmentedControl *)sender;
    if (seg.selectedSegmentIndex == 0) {
        
        self.tableview.hidden = YES;
        self.userTableView.hidden = NO;
    }
    else{
        
        self.tableview.hidden = NO;
        self.userTableView.hidden = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    userInfo = [[LoginService shareInstanced]getUserModel];
    
    
    self.navigationItem.titleView = self.segment;
    self.userTableView.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeight-64);
    self.tableview.frame =CGRectMake(0, 0, ScreenWidth, ScreenHeight-64);
   
    list = [NSMutableArray array];
    userList = [NSMutableArray array];
    [self.tableview registerNibWithName:@"WeiCoCell" reuseIdentifier:@"WeiCo"];
    
   [self.userTableView registerNibWithName:@"UserListCell" reuseIdentifier:@"UserCell"];
    [self config];
    
    NSString *ftokn = @"";
    
    if ([self.type isEqualToString:@"2"]) {
        
        ftokn = userInfo.use.ftoken;
        self.userTableView.hidden = YES;
    }
    else{
         self.tableview.hidden = YES;
        self.navigationItem.titleView = self.segment;
        self.navigationItem.rightBarButtonItem = self.settingItem;
    }
    
    self.tableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [[LearnService shareInstanced]getFirstCourseListWithType:ftokn];
    }];
    
    self.tableview.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        [[LearnService shareInstanced]getMoreCourseListWithType:ftokn];
    }];
    
    [self.tableview.header beginRefreshing];
    
    ///
    self.userTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [[LearnService shareInstanced]getFirstUserList];
    }];
    
    self.userTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        [[LearnService shareInstanced]getMoreUserList];
    }];
    [self.userTableView.header beginRefreshing];
}

- (void)config{
    
    [LearnService shareInstanced].getUserListSuccess = ^(id obj){
        
        [self.userTableView.header endRefreshing];
        [self.userTableView.footer endRefreshing];
        
        userList = [obj mutableCopy];
        [self.userTableView reloadData];
    };
    
    [LearnService shareInstanced].getUserListFailure = ^(id obj){
        
        [self.userTableView.header endRefreshing];
        [self.userTableView.footer endRefreshing];
        
    };
    
    
    
    [LearnService shareInstanced].getCourseListSuccess = ^(id obj){
        
        [self.tableview.header endRefreshing];
        [self.tableview.footer endRefreshing];
        
        list = [obj mutableCopy];
        [self.tableview reloadData];
    };
    
    [LearnService shareInstanced].getCourseListFailure = ^(id obj){
        
        [self.tableview.header endRefreshing];
        [self.tableview.footer endRefreshing];
        
    };
    
    
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.userTableView) {
        
        return 80;
    }
    CourseListModel *model = list[indexPath.row];
    
    return [WeiCoCell heihtForModel:model];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.userTableView) {
        return userList.count;
    }
    return list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.userTableView) {
        
        UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        UserListModel *model = userList[indexPath.row];
        cell.nameLab.text = model.frealName;
        cell.ageLab.text = [NSString stringWithFormat:@"%ld岁",(long)[model.fage integerValue]];
        if ([model.fsex isEqualToString:@"man"]) {
            
            cell.sexLab.text = @"男";
        }
        else{
            cell.sexLab.text = @"女";
        }
        cell.counLab.text = [NSString stringWithFormat:@"人气：%@",model.fscore];
        if (model.fsignature.length>0) {
    
            cell.sigLab.text = model.fsignature;
        }
        [cell.headImgv sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",User_Pic_URL,model.fheadImg]] placeholderImage:DefaultAvatar];
        return cell;
    }
    else{
     
        WeiCoCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"WeiCo"];
        
        CourseListModel *model = list[indexPath.row];
        
        cell.model = model;
        cell.delegate = self;
        
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView ==self.userTableView) {
        UserListModel *model = userList[indexPath.row];
        UserWeiCoViewController *vc = [[UserWeiCoViewController alloc]init];
        vc.userId =model.fid;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    
}

#pragma mark WeiCoCellDelegate
- (void)didPlayWithModel:(CourseListModel *)model cell:(WeiCoCell *)cell{
    
    
}
- (void)didShowPhotoWithModel:(CourseListModel *)model{
    
    
    NSArray *ary = [model.fimgs componentsSeparatedByString:@","];
    
    NSMutableArray *temp = [NSMutableArray array];
    
    for (NSString *str in ary) {
        
        if (str.length>0) {
            
            [temp addObject:[NSString stringWithFormat:@"%@%@",China_Pic_URL,str]];
            
        }
        
    }
    
    photos = [temp copy];

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.browser reloadData];
    
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)didDelPhotoWithModel:(CourseListModel *)model{
    
    
    [[ExamService shareInstenced]delErrorTitleWithUid:userInfo.use.ftoken tid:model.fid];
    
    [self showHud];
    [ExamService shareInstenced].delErrorSuccess = ^(id obj){
        
        [self hideHud];
        
        NSUInteger index = [list indexOfObject:model];
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
        [list removeObject:model];
        [self.tableview beginUpdates];
        [self.tableview deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableview endUpdates];
        
    };
    
    [ExamService shareInstenced].delErrorFailure = ^(id obj){
        
        [self hideHud];
        [self showHudWithString:obj];
    };
}

- (void)didLikePhotoWithModel:(CourseListModel *)model{
    
    [[ExamService shareInstenced]addExamLikeWithUid:userInfo.use.ftoken tid:model.fid];
    
    [self showHud];
    [ExamService shareInstenced].addExamLikeSuccess = ^(id obj){
        
        [self hideHud];
        
        NSUInteger index = [list indexOfObject:model];

        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"say_3q" ofType:@"mp3"]] error:nil];//使用本地URL创建

        
        
//        NSString *path = [[NSBundle mainBundle]pathForResource:@"say_3q" ofType:@"mp3"];
//        // 2 将路径字符串转换成url，从本地读取文件，需要使用fileURL
//        NSURL *url = [NSURL fileURLWithPath:path];
//        // 3 初始化音频播放器
//        AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [player play];
        model.fclickCount = [NSString stringWithFormat:@"%d",[model.fclickCount intValue] +1];
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableview beginUpdates];
        [self.tableview reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableview endUpdates];
        
    };
    
    [ExamService shareInstenced].addExamLikeFailure = ^(id obj){
        
        [self hideHud];
        [self showHudWithString:obj];
    };
    
}

#pragma mark MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    

    MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:photos[index]]];
    
    return photo;
    
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    //if (index < _thumbs.count)
    //return [_thumbs objectAtIndex:index];
    return nil;
}




- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
