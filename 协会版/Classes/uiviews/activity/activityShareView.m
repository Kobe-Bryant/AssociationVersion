//
//  activityShareView.m
//  xieHui
//
//  Created by yunlai on 13-5-3.
//
//

#import "activityShareView.h"

@implementation activityShareView

@synthesize noneImage;    
@synthesize selectImage;
@synthesize channelImage;
@synthesize selectIndex;
@synthesize delegate;
@synthesize callbackObject;
@synthesize callbackFunction;

- (void)dealloc
{
    [noneImage release], noneImage = nil;
    [selectImage release], selectImage = nil;
    [channelImage release], channelImage = nil;
    delegate = nil;
    [super dealloc];
}

// 手势
- (void)handleSingleTapFrom:(UITapGestureRecognizer *)single
{
    SEL func_selector = NSSelectorFromString(callbackFunction);
    if ([callbackObject respondsToSelector:func_selector]) {
        if ([callbackObject performSelector:func_selector]) {
            if (selectIndex == 0 || selectIndex == 2) {
                self.selectIndex = 1;
            } else if (selectIndex == 1) {
                self.selectIndex = 2;
            }
        }
    }
}

- (id)initWithFrame:(CGRect)frame nonepath:(NSString *)path1 selectpath:(NSString *)path2
{
    self = [super initWithFrame:frame];
    if (self) {
        // 未授权
        noneImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, frame.size.height)];
        noneImage.image = [UIImage imageWithContentsOfFile:path1];
        noneImage.hidden = NO;
        noneImage.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *noneRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
        noneRecognizer.numberOfTapsRequired = 1; // 单击
        [noneImage addGestureRecognizer:noneRecognizer];
        [noneRecognizer release];
        
        [self addSubview:noneImage];
        
        // 授权
        selectImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, frame.size.height)];
        selectImage.image = [UIImage imageWithContentsOfFile:path2];
        selectImage.hidden = YES;
        selectImage.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *selectRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
        selectRecognizer.numberOfTapsRequired = 1; // 单击
        [selectImage addGestureRecognizer:selectRecognizer];
        [selectRecognizer release];
        
        [self addSubview:selectImage];
        
        // 对勾
        channelImage = [[UIImageView alloc]initWithFrame:CGRectMake(2*frame.size.width/3, 0.f, frame.size.width/3, frame.size.height/3)];
        channelImage.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_分享_selected" ofType:@"png"]];
        channelImage.hidden = YES;
        [selectImage addSubview:channelImage];
    }
    return self;
}
- (void)setImage
{
    if (selectIndex == 1) {
        noneImage.hidden = YES;
        selectImage.hidden = NO;
        channelImage.hidden = YES;
    } else if (selectIndex == 2){
        noneImage.hidden = YES;
        selectImage.hidden = NO;
        channelImage.hidden = NO;
    } else {
        noneImage.hidden = NO;
        selectImage.hidden = YES;
        channelImage.hidden = YES;
    }
}

- (void)setSelectIndex:(NSInteger)aselectIndex
{
    selectIndex = aselectIndex;
    
    [self setImage];
}

- (void)setDelegateObject:(id)cbobject setBackFunctionName:(NSString *)selectorName
{
    callbackObject = cbobject;
    callbackFunction = selectorName;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
