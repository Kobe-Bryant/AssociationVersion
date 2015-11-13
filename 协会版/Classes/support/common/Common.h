//
//  Common.h
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"
#import "DBOperate.h"
#import "base64.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <netdb.h>
#import <CoreLocation/CoreLocation.h>

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define VIEW_HEIGHT [UIScreen mainScreen].bounds.size.height

#define kPhoneNum @"12345678901"

/////////宏编译控制
#define IOS4 1
#define SHOW_NAV_TAB_BG 2
#define NAV_BG_PIC @"上bar.png"
#define IOS7_NAV_BG_PIC @"ios7上bar.png"
#define TAB_BG_PIC @"下bar.png"

#define CAT_HEIGHT 40

#define BTO_COLOR_RED 0.7
#define BTO_COLOR_GREEN 0
#define BTO_COLOR_BLUE 0

#define TAB_COLOR_RED 0.935
#define TAB_COLOR_GREEN 0.935
#define TAB_COLOR_BLUE  0.935

#define dataBaseFile @"profession.db"

#define DOWNLOAD_IMAGE_MAX_COUNT 3

#define SITE_ID  236

//http://202.104.149.214:8080/HY_APPInterfaceServer/recommend.do?param=eyJrZXl2YWx1ZSI6ImYzZDI3MmZjNjgyNjQ5MjAxZGEyYWNlMWZhMjk4NmExIiwidmVyX2Nh%0D%0AdHMiOiIwIiwic2l0ZV9pZCI6NSwiZWRpdGlvbiI6MSwidmVyX25ld3MiOiIwIiwidmVyX3No%0D%0Ab3BzIjowfQ%3D%3D

//http://202.104.149.214:8080/HY_APPInterfaceServer/recommend.do?param=eyJrZXl2YWx1ZSI6ImY5Y2I3ZDQ2MjJhOTk3Yzk5MzVmNzk1NzFkMjRiODJlIiwidmVyX2Nh%0D%0AdHMiOjAsInNpdGVfaWQiOjIzNiwiZWRpdGlvbiI6MSwidmVyX25ld3MiOjAsInZlcl9zaG9w%0D%0AcyI6MH0%3D

#define ACCESS_SERVER_LINK @"http://app.yunlai.cn:8080/HY_APPInterfaceServer/"
//#define ACCESS_SERVER_LINK @"http://202.104.149.214:8080/HY_APPInterfaceServer/"
//#define ACCESS_SERVER_LINK @"http://192.168.1.158:8081/HY_APPInterfaceServer/"

//首页第一个分类名称
#define HOME_CAT_NAME @"俱乐部动态"


#define SignSecureKey  @"HYAPP9I0I6IyunlaiINTERFACE"


#define NEED_UPDATE 1
#define NO_UPDATE 0

#define SINA @"sina"
#define TENCENT @"tencent"

//设置单位详情页面的企业App下载按钮是否显示 （0 不显示， 1 显示）
#define IS_SHOW_APP 0 

//了解企业移动APP的地址
#define SHOWAPP_URL @"http://mbsns.yunlai.cn/app/about"

//设置commadid
#define OPERAT_SUPPLY_REFRESH 1
#define OPERAT_SUPPLY_CAT_REFRESH 2
#define OPERAT_SUPPLY_MORE 3
#define OPERAT_DEMAND_REFRESH 4
#define OPERAT_DEMAND_CAT_REFRESH 5
#define OPERAT_DEMAND_MORE 6
#define OPERAT_SHOP_REFRESH 7
#define OPERAT_SHOP_CAT_REFRESH 8
#define OPERAT_SHOP_MORE 9
#define OPERAT_ABOUTUS_INFO 10
#define OPERAT_SEND_SUPPLY_COMMENT 11
#define OPERAT_SEND_DEMAND_COMMENT 12
#define OPERAT_SEND_SUPPLY_FAVORITE 13
#define OPERAT_SEND_DEMAND_FAVORITE 14
#define OPERAT_SEND_SHOP_FAVORITE 15
#define OPERAT_SEND_FEEDBACK 16
#define OPERAT_SHOP_INFO 17
#define OPERAT_SHOP_SUPPLY_REFRESH 18
#define OPERAT_SHOP_SUPPLY_MORE 19
#define OPERAT_SHOP_DEMAND_REFRESH 20
#define OPERAT_SHOP_DEMAND_MORE 21
#define OPERAT_SUPPLY_RECOMMEND_REFRESH 22
#define OPERAT_SUPPLY_RECOMMEND_MORE 23
#define OPERAT_DEMAND_RECOMMEND_REFRESH 24
#define OPERAT_DEMAND_RECOMMEND_MORE 25
#define OPERAT_SEARCH_SUPPLY 26
#define OPERAT_SEARCH_SUPPLY_MORE 27
#define OPERAT_SEARCH_SHOP 28
#define OPERAT_SEARCH_SHOP_MORE 29

#define OPERAT_NEWEST_MEMBER_REFRESH 30
#define OPERAT_CONTACTS_BOOK_REFRESH 31
#define OPERAT_SEARCH_MEMBER 32
#define OPERAT_SEARCH_MEMBER_MORE 33

#define OPERAT_CARDDETAIL_REFRESH 34

#define OPERAT_RECOMMEND_APP_REFRESH 35
#define OPERAT_RECOMMEND_APP_MORE 36

#define OPERAT_ACTIVITY_REFRESH 37
#define OPERAT_ACTIVITY_MORE 38
#define OPERAT_ACTIVITY_HISTORY_REFRESH 39
#define OPERAT_ACTIVITY_HISTORY_MORE 40
#define OPERAT_ACTIVITY_USER_PIC_MORE 41
#define OPERAT_SEND_ACTIVITY_INTERESTING 42
#define OPERAT_SEND_ACTIVITY_JOIN 43
#define OPERAT_CONTACTS_BOOK_CAT_REFRESH 44


#define ACCESS_ADVERTISE_COMMAND_ID 100
#define ACCESS_RCM_CATS_COMMAND_ID 101
#define ACCESS_NEWS_CATS_COMMAND_ID 102
#define ACCESS_RECOMMEND_NEWS_COMMAND_ID 103
#define ACCESS_RECOMMEND_SHOPS_COMMAND_ID 104
#define ACCESS_NEWS_COMMAND_ID 105
#define ACCESS_SEARCH_PRODUCT_COMMAND_ID 106
#define ACCESS_SEARCH_SHOP_COMMAND_ID 107
#define ACCESS_COMMENT_NEWS_COMMAND_ID 108
#define ACCESS_FAVORITE_NEWS_COMMAND_ID 109
#define ACCESS_ALL_NEWS_COMMAND_ID 110

//会员中心
#define MEMBER_LOGIN_COMMAND_ID     200
#define MEMBER_REGIST_COMMAND_ID    201
#define MEMBER_INFO_COMMAND_ID      202  
#define SINAWEI_COMMAND_ID          203
#define TENCENTWEI_COMMAND_ID       204
#define MEMBER_FAVRITEPRODUCTLIST_COMMAND_ID     205
#define MEMBER_FAVORITEBUYLIST_COMMAND_ID        206
#define MEMBER_FAVORITESHOPSLIST_COMMAND_ID      207
#define MEMBER_FAVORITEINFOLIST_COMMAND_ID       208
#define MEMBER_FAVORITEDELETE_COMMAND_ID         209
#define MEMBER_FAVRITEPRODUCTMORELIST_COMMAND_ID     210
#define MEMBER_FAVORITEBUYMORELIST_COMMAND_ID        211
#define MEMBER_FAVORITESHOPSMORELIST_COMMAND_ID      212
#define MEMBER_FAVORITEINFOMORELIST_COMMAND_ID       213
#define MEMBER_CHANGEIMAGE_COMMAND_ID 214
#define COMMENTLIST_COMMAND_ID        217
#define COMMENTLIST_MORE_COMMAND_ID   218
#define MEMBER_EDIT_COMMAND_ID  219
#define MESSAGE_LIST_COMMAND_ID 220
#define MESSAGE_DETAIL_COMMAND_ID 221
#define MESSAGE_LIST_DELETE_COMMAND_ID 222  //消息中心 删除
#define MESSAGE_SEND_COMMAND_ID 223
#define MESSAGE_DETAILMORE_COMMAND_ID 224
#define MEMBER_FAVRITEBOOKLIST_COMMAND_ID 225
#define OPERAT_SEND_CONTACTSBOOK_FAVORITE 226
//设备令牌
#define APNS_COMMAND_ID 215
//PV接口
#define PV_COMMAND_ID 216

//更多
#define MORE_CAT_COMMAND_ID   230
#define MORE_CAT_INFO_COMMAND_ID 231

#define SENDMESSAGE_COMMAND_ID   232  //无企业APP下载时发送请求
#define FEEDBACK_LIST_COMMAND_ID 233  //留言反馈列表
#define FEEDBACK_LIST_MORE_COMMAND_ID 234 //留言反馈列表 more
#define SYSTEM_MESSAGE_COMMAND_ID     235 //小秘书列表
#define SYSTEM_MESSAGE_MORE_COMMAND_ID 236 //小秘书列表 more
#define MYACTIVITY_LIST_COMMAND_ID  237 //我的活动列表
#define MYACTIVITY_LIST_MORE_COMMAND_ID 238 //我的活动列表 more
#define MEMBER_CANCEL_COMMAND_ID   239 //注销

#define MEMBER_PASSWORD_COMMAND_ID   250 //密码修改

// dufu add 2013.06.14
// 版本ID KEY
#define APP_SOFTWARE_VER_KEY    @"app_ver"
// 版本ID 当前版本号,只要有版本改动，按值一直上升的
#define CURRENT_APP_VERSION     1

//微博接口
#define SINA @"sina"
#define TENCENT @"tencent"
#define SinaAppKey @"3071963749"
#define SinaAppSecret @"7b88ecfeeabc6e9ed240be9daf3f1f90"
#define QQAppKey @"801106679"
#define QQAppSecret @"14e3e1188d69231e59f6c98d4a9a5527"
#define redirectUrl @"http://our.3g.yunlai.cn"

//微信接口
#define WEICHATID @"wx0ab121f6e3c1f843"    // dufu add 2013.04.24

//loading提示
#define LOADING_TIPS @"云端同步中..."

#define kAPPName @"华中企业家俱乐部"

//分享
#define DETAIL_SHARE_LINK @"http://huazhong.hytest.yunlai.cn/"   //app/jump
#define SHARE_CONTENTS [NSString stringWithFormat:@"(分享来自@%@)",kAPPName]


//新增可配置项目 chenxj 2013.06.19

/* ======================================================================================= */

//底部bar 配置
#define ARRAYS_TAB_BAR [NSArray arrayWithObjects:@"首页",@"通讯录",@"单位",@"我",@"百宝箱",nil];
#define ARRAYS_SELECTED_TAB_BAR [NSArray arrayWithObjects:@"首页选中",@"通讯录选中",@"单位选中",@"我选中",@"百宝箱选中",nil];

//下bar 文字未选中颜色
#define COLOR_UNSELECTED_TAB_BAR [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0];

//下bar 文字选中颜色
#define COLOR_SELECTED_TAB_BAR [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0];

//首页/单位 模块下没有分类时候的提示语
#define TIPS_NONE_CAT @"没有找到分类内容";

//分类下没有内容提示语
#define TIPS_NONE_CAT_CONTENT @"没有找到该分类的内容哦";

/* ======================================================================================= */

//产品收藏 名称 标题
#define FAVORITE_SUPPLY_NAME @"产品收藏";
//产品收藏 无收藏提示语
#define TIPS_NONE_FAVORITE_SUPPLY_CONTENT @"没有找到任何内容哦";

//单位收藏 名称 标题
#define FAVORITE_SHOP_NAME @"单位收藏";
//单位收藏 无收藏提示语
#define TIPS_NONE_FAVORITE_SHOP_CONTENT @"没有找到任何内容哦";

//资讯收藏 名称 标题
#define FAVORITE_NEWS_NAME @"资讯收藏";
//资讯收藏 无收藏提示语
#define TIPS_NONE_FAVORITE_NEWS_CONTENT @"没有找到任何内容哦";

/* ======================================================================================= */

//会员搜索 名称
#define SEARCH_MEMBER_NAME @"搜索会员";

//会员搜索结果 标题
#define SEARCH_MEMBER_TITLE @"会员搜索结果";

//会员搜索 无内容提示语
#define TIPS_NONE_SEARCH_MEMBER_CONTENT @"没有找到任何内容哦";

//单位搜索 名称
#define SEARCH_SHOP_NAME @"搜索单位";

//单位搜索结果 标题
#define SEARCH_SHOP_TITLE @"单位搜索结果";

//单位搜索 无内容提示语
#define TIPS_NONE_SEARCH_SHOP_CONTENT @"没有找到任何内容哦";

/* ======================================================================================= */

//首页/单位 导航栏 未选中颜色
#define COLOR_UNSELECTED_CAT_TITLE [UIColor colorWithRed:0.1 green: 0.1 blue: 0.1 alpha:1.0];

//首页/单位 导航栏 选中颜色
#define COLOR_SELECTED_CAT_TITLE [UIColor colorWithRed:0.1 green: 0.1 blue: 0.1 alpha:1.0];

//上bar按钮颜色
#define COLOR_BAR_BUTTON [UIColor colorWithRed:0.1 green: 0.1 blue: 0.1 alpha:1.0];

//app背景图片
#define BG_IMAGE @"背景.png"

/* ======================================================================================= */

//快递获取账号内容
#define TIPS_REG_CONTENT1 @"您好！欢迎使用";
#define TIPS_REG_CONTENT2 @"当前版块仅用于内部交流，不对外开放,";
#define TIPS_REG_CONTENT3 @"如果您想进入：";

//新版本提示语
#define TIPS_NEWVERSION @"发现新版本"
/* ======================================================================================= */

int currentSelectingIndex;

//定位
CLLocationManager *locManager;
CLLocationCoordinate2D myLocation;
NSOperationQueue *netWorkQueue;
NSMutableArray *netWorkQueueArray;

BOOL _isLogin;
BOOL _isChangedImage;

//是否已经获取完通讯录
BOOL is_get_contacts_book_done;

//是否打开消息中心
BOOL is_push_with_msg;

@interface Common : NSObject {

}

+(BOOL)connectedToNetwork;
+(NSString*)TransformJson:(NSMutableDictionary*)sourceDic withLinkStr:(NSString*)strurl;
+(NSString*)encodeBase64:(NSMutableData*)data;
+(NSString*)URLEncodedString:(NSString*)input;
+(NSString*)URLDecodedString:(NSString*)input;
+(NSNumber*)getVersion:(int)commandId;
+ (NSNumber*)getMemberVersion:(int)memberId commandID:(int)_commandId;
+(NSString*)getSecureString;
+ (NSString*)getMacAddress;
+ (NSNumber*)getCommentListVersion:(int)_typeId withInfoID:(int)_infoId;

//判断是否为新会员 前7天到现在注册的会员
+(BOOL)isNewMember:(int)time;

//转换友好的时间格式
+(NSString *)getFriendDate:(int)startTime eTime:(int)endTime;

@end
