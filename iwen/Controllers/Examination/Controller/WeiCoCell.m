//
//  WeiCoCell.m
//  iwen
//
//  Created by Interest on 16/3/11.
//  Copyright © 2016年 Interest. All rights reserved.
//

#import "WeiCoCell.h"
#import <MediaPlayer/MPMoviePlayerController.h>
@implementation WeiCoCell
{
    
    NSMutableArray *btnArray;
    MPMoviePlayerController *player;
}
- (void)awakeFromNib {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.headview.layer.masksToBounds = YES;
    self.headview.layer.cornerRadius = self.headview.bounds.size.width/2;
    
    
    
    
    btnArray = [@[self.btn1,self.btn2,self.btn3,self.btn4,self.btn5,self.btn6,self.btn7,self.btn8,self.btn9]mutableCopy];
    
    for (UIButton *btn in btnArray) {
        
        btn.frame = CGRectZero;
        btn.contentMode = UIViewContentModeScaleAspectFit;
        [btn addTarget:self action:@selector(showPhoto) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.viderbtn.frame = CGRectZero;
}


- (void)showPhoto{
    
    if (self.delegate) {
        
        [self.delegate didShowPhotoWithModel:self.model];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(CourseListModel *)model{
    
    if (model) {
    
        _model = model;
        
        
        for (UIButton *btn in btnArray) {
            
            btn.frame = CGRectZero;
        }
        
        if ([model.my isEqualToString:@"1"]) {
            
            self.delbtn.frame = CGRectMake(ScreenWidth-30, 22, 19, 22);
            self.delbtn.hidden = NO;
        }
        else{
            self.delbtn.hidden = YES;
        }
        self.viderbtn.frame = CGRectZero;
        self.playview.frame = CGRectZero;
        long long time = [model.fcreateTime longLongValue]/1000;
        NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:time];
        
        self.datelab.text = [NSDate formatDateString:@"YYYY-MM-dd" withDate:date2];
        
        CGFloat h = [RTLabel getHightWithString:model.fcontent andSizeValue:14.0 andWidth:ScreenWidth-16.0];
        
        self.contenLab.text = model.fcontent;
        
        self.contenLab.frame = CGRectMake(8, 60, ScreenWidth-16, h);
        
        [self.headview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",User_Pic_URL,model.userImg]] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    
        self.namelab.text = model.fname;
        
        NSArray *ary = [model.fimgs componentsSeparatedByString:@","];
        
        NSMutableArray *temp = [NSMutableArray array];
        
        for (NSString *str in ary) {
            
            if (str.length>0) {
                
                [temp addObject:[NSString stringWithFormat:@"%@%@",China_Pic_URL,str]];
                
            }
            
        }
        
        if (temp.count>0) {

            int row =(int)ceil((double)(temp.count)/3);
            
            int count = 3;
            
            CGFloat btnw = 100;
            
            CGFloat  marnX = (ScreenWidth-btnw*count)/(count +1);
            
            CGFloat  KMarginY = 10;
            
            for (int currentRow = 0; currentRow<row; currentRow ++) {
                for (int currentCount = 0; currentCount <count; currentCount ++) {
                    if (currentCount+currentRow*count <temp.count) {
                        
                        UIButton *btn = btnArray[currentCount+currentRow*count];

                        btn.frame = CGRectMake(marnX *(1+currentCount)+currentCount*btnw, KMarginY*(2+currentRow)+currentRow*(btnw+20)+self.contenLab.frame.origin.y+self.contenLab.frame.size.height, btnw, btnw);
            

                        
                        [btn sd_setBackgroundImageWithURL:[NSURL URLWithString: temp[currentCount+currentRow*count]] forState:UIControlStateNormal];
                        
                        btn.tag =currentCount+currentRow*count;
             
                        
                    }
                    
                }
            }
            
            self.likeBtn.frame = CGRectMake(ScreenWidth-8-80, KMarginY*(2+row)+row*(btnw+20)+self.contenLab.frame.origin.y+self.contenLab.frame.size.height, 80, 20);
            
            [self.likeBtn setTitle:model.fclickCount forState:UIControlStateNormal];
            
            self.darkview.frame = CGRectMake(0, self.likeBtn.frame.origin.y+20, ScreenWidth, 15);
            
            
        }
        
        if (model.fvideo.length>0) {
            
            
            self.viderbtn.frame = CGRectMake(8, self.contenLab.frame.origin.y+self.contenLab.frame.size.height, ScreenWidth-16, 170);
            self.playview.frame =CGRectMake(8, self.contenLab.frame.origin.y+self.contenLab.frame.size.height, ScreenWidth-16, 170);
             self.likeBtn.frame = CGRectMake(ScreenWidth-8-80, self.viderbtn.frame.origin.y+170, 80, 20);
            //        这里利用MPMoviePlayerController来获取
 
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://120.76.112.202/uploadImg/video/%@",model.fvideo]];
            player = [[MPMoviePlayerController alloc]initWithContentURL:url] ;
            player.view.frame = CGRectMake(0, 0, ScreenWidth-16, 170);
            player.shouldAutoplay= NO;
            player.scalingMode =MPMovieScalingModeAspectFill;
            player.controlStyle = MPMovieControlStyleNone;
            [self.playview addSubview:player.view];
            [self.viderbtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
            UIImage  *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
           [self.viderbtn setBackgroundImage:thumbnail forState:UIControlStateNormal];

            
            
            
//            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//            dispatch_async(queue, ^{
//                
//                MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:url] ;
//                player.view.frame = CGRectMake(0, 0, ScreenWidth-16, 170);
//                player.shouldAutoplay= NO;
//                player.scalingMode = MPMovieScalingModeFill;
//                player.controlStyle = MPMovieControlStyleNone;
//
////                UIImage  *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                   
//                    [self.playview addSubview:player.view];
////                    [self.viderbtn setBackgroundImage:thumbnail forState:UIControlStateNormal];
//                });
//            });

            [self.likeBtn setTitle:model.fclickCount forState:UIControlStateNormal];
            
            self.darkview.frame = CGRectMake(0, self.likeBtn.frame.origin.y+20, ScreenWidth, 15);
        }
        
        
    }
    
}

+ (CGFloat )heihtForModel:(CourseListModel *)model{
    
    CGFloat allh =60;
    
    
    CGFloat contenh = [RTLabel getHightWithString:model.fcontent andSizeValue:14.0 andWidth:ScreenWidth-16.0];

    
    CGFloat libtnH =  20;
    
    CGFloat darkH = 15;
    
    NSArray *ary = [model.fimgs componentsSeparatedByString:@","];
    
    NSMutableArray *temp = [NSMutableArray array];
    
    for (NSString *str in ary) {
        
        if (str.length>0) {
            
            [temp addObject:[NSString stringWithFormat:@"%@%@",China_Pic_URL,str]];
            
        }
        
    }
    
    CGFloat imgh = 0;
    
    if (temp.count>0) {
        
        int row =(int)ceil((double)(temp.count)/3);
        
        CGFloat  KMarginY = 10;
        
        
         imgh =  KMarginY*(2+row)+row*(100+20);
        
 
    }
    
    CGFloat videoH  = 0;
    
    if (model.fvideo.length>0) {
        
        videoH = 170;
        
    }
    

    allh = allh + imgh + videoH + libtnH + darkH +contenh;

    return allh;
}




- (IBAction)play:(UIButton *)sender {
    
    if (self.delegate) {
        
//        - (void)didPlayWithModel:(CourseListModel *)model cell:(WeiCoCell *)cell
//       player.playbackState
         [self.viderbtn setBackgroundImage:nil forState:UIControlStateNormal];
        [self.viderbtn setImage:nil forState:UIControlStateNormal];
        [player play];
    
        [self.delegate didPlayWithModel:self.model cell:self];
    }
}


- (IBAction)deleAction:(UIButton *)sender {
    
    if (self.delegate) {
        
        [self.delegate didDelPhotoWithModel:self.model];
    }
}

- (IBAction)addLike:(id)sender {
    
    if (self.delegate) {
        
        [self.delegate didLikePhotoWithModel:self.model];
    }
}
@end
