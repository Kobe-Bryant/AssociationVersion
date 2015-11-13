//
//  activityShareView.h
//  xieHui
//
//  Created by yunlai on 13-5-3.
//
//

#import <UIKit/UIKit.h>

@protocol activityShareViewDelegate <NSObject>

@optional
// 判断微博是否授权成功
- (BOOL)activityShareViewAuthorization;

@end

@interface activityShareView : UIView
{
    id callbackObject;          // 回调类
    NSString *callbackFunction; // 回调函数
}

@property (retain, nonatomic) id callbackObject;          // 回调类
@property (retain, nonatomic) NSString *callbackFunction; // 回调函数

@property (retain, nonatomic) UIImageView *noneImage;
@property (retain, nonatomic) UIImageView *selectImage;
@property (retain, nonatomic) UIImageView *channelImage;

@property (assign, nonatomic) NSInteger selectIndex;
// activityShareViewDelegate 委托
@property (assign, nonatomic) id <activityShareViewDelegate> delegate;

// 初始化
- (id)initWithFrame:(CGRect)frame nonepath:(NSString *)path1 selectpath:(NSString *)path2;

// 回调函数
- (void)setDelegateObject:(id)cbobject setBackFunctionName:(NSString *)selectorName;

@end
