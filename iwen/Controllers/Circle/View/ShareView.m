//
//  ShareView.m
//  iwen
//
//  Created by Interest on 15/10/15.
//  Copyright (c) 2015年 Interest. All rights reserved.
//

#import "ShareView.h"

#define DarkColor    [UIColor colorWithWhite:0.3 alpha:0.4]

#define LabFont      [UIFont systemFontOfSize:15]

#define AnimateWithDuration  0.2

#define KButtonWidth 60

#define Spacing      15

#define LabHight     21


@implementation ShareView



- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = DarkColor;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        
        [self addGestureRecognizer:tap];
        
        
        [self addSubview:self.buttonView];
        
    }
    return self;
}

#pragma Action

- (void)showInView:(UIView *)view{
    
    [self removeFromSuperview];
    
    [view addSubview:self];
    
    [UIView animateWithDuration:AnimateWithDuration animations:^{
        
        self.buttonView.frame = CGRectMake(0, ScreenHeight-64-(Spacing * 2 + KButtonWidth * 1 + LabHight * 1), ScreenWidth, Spacing * 2 + KButtonWidth * 1 + LabHight * 1);
        
    }];
    
    self.isShowing = YES;
}


- (void)shareAction:(UIButton *)btn{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareView:clickedButtonAtIndex:)]) {
        
        [self.delegate shareView:self clickedButtonAtIndex:btn.tag];
        
    }
    
    [self dismiss];
}

- (void)dismiss{
    
    
    [UIView animateWithDuration:AnimateWithDuration animations:^{
        
        self.buttonView.frame = CGRectMake(0, ScreenHeight-64, ScreenWidth, Spacing * 2 + KButtonWidth * 1 + LabHight * 1);
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            self.isShowing = NO;
            
            [self removeFromSuperview];
        }
    }];
    
    
}

#pragma  mark getter

- (UIView *)buttonView{
    
    if (_buttonView == nil) {
        
        
        
        NSArray *imageArray = @[@"QQ好友",@"QQ空间",@"朋友圈",@"微信好友"];
        
        _buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight-64,ScreenWidth,Spacing * 2 + KButtonWidth * 1 + LabHight * 1)];
        
        _buttonView.backgroundColor = [UIColor whiteColor];
        
        CGFloat hSpace = (ScreenWidth-4*KButtonWidth)/5;
        
        for (int row = 0; row<2; row ++) {
            
            for (int a=1; a<5; a++) {
                
                int index = 4*row +a;
                
                if (index <=imageArray.count) {
                    
                    
                    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(a*hSpace +(a-1)*KButtonWidth, (row+1)*Spacing +row*(KButtonWidth+LabHight), KButtonWidth, KButtonWidth)];
                    btn.tag = index;
                    
                    [btn setBackgroundImage:[UIImage imageNamed:imageArray[index-1]] forState:UIControlStateNormal];
                    
                    [btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [_buttonView addSubview:btn];
                    
                    
                    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(btn.frame.origin.x, btn.frame.origin.y+KButtonWidth, KButtonWidth, LabHight)];
                    
                    lab.text          = imageArray[index-1];
                    lab.textAlignment = NSTextAlignmentCenter;
                    lab.textColor     = [UIColor darkGrayColor];
                    lab.font          = LabFont;
                    
                    [_buttonView addSubview:lab];
                    
                    
                }
 
            }
       
        }
        
    }
    
    return _buttonView;
}
@end
