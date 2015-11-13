//
//  CommonOperationParser.h
//  Profession
//
//  Created by MC374 on 12-8-9.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommandOperationParser : NSObject {
	
}
+(BOOL)updateVersion:(int)commanId versionID:(NSNumber*)versionid desc:(NSString*)describe;
+(BOOL)updateMemberVersion:(int)_commandId memberId:(int)_memberId versionID:(NSNumber*)versionid desc:(NSString*)describe;
+(BOOL)updateCommentListVersion:(int)_commandId typeId:(int)_typeId infoId:(int)_infoId versionID:(NSNumber*)versionid desc:(NSString*)describe;
+(NSMutableArray*)parseAdvertise:(NSString*)jsonResult getVersion:(int*)ver;
+(NSMutableArray*)parseRecommendAndCats:(NSString*)jsonResult getVersion:(int*)ver;
+(NSMutableArray*)parseNews:(NSString*)jsonResult getVersion:(int*)ver catid:(NSNumber*)cid isLoadMore:(BOOL)loadMore;

+(NSMutableArray*)parseLogin:(NSString*)jsonResult getVersion:(int*)ver;
+(NSMutableArray*)parseRegist:(NSString*)jsonResult getVersion:(int*)ver;
+(NSMutableArray*)parseSinaWeibo:(NSString*)jsonResult getVersion:(int*)ver;
+(NSMutableArray*)parseTencentWeibo:(NSString*)jsonResult getVersion:(int*)ver;
+ (NSMutableArray*)parseProductList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno;
+ (NSMutableArray*)parseBuyList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno;
+ (NSMutableArray*)parseShopsList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno;
+ (NSMutableArray*)parseInfoList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno;
+ (NSMutableArray*)parseDelete:(NSString*)jsonResult getVersion:(int*)ver;
+ (NSMutableArray*)parseChangeImage:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId;
+ (NSMutableArray*)parseCommentList:(NSString*)jsonResult getVersion:(int*)ver withTypeId:(int)_typeId withInfoId:(int)_infoId isInsert:(BOOL)yesORno;

//供应列表
+(NSMutableArray*)parseSuppyList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param;

//供应分类
+(NSMutableArray*)parseSuppyCatList:(NSString*)jsonResult getVersion:(int*)ver;

//供应更多
+(NSMutableArray*)parseSupplyMoreList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param;

//求购列表
+(NSMutableArray*)parseDemandList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param;

//求购分类
+(NSMutableArray*)parseDemandCatList:(NSString*)jsonResult getVersion:(int*)ver;

//求购更多
+(NSMutableArray*)parseDemandMoreList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param;

//商铺列表
+(NSMutableArray*)parseShopList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param;
//商铺分类
+(NSMutableArray*)parseShopCatList:(NSString*)jsonResult getVersion:(int*)ver;

//商铺更多
+(NSMutableArray*)parseShopMoreList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param;

//关于我们
+(NSMutableArray*)parseAboutUsList:(NSString*)jsonResult getVersion:(int*)ver;

//发送评论 以及收藏 
+(NSMutableArray*)parseSendCommentAndFavorite:(NSString*)jsonResult getVersion:(int*)ver;

//商铺信息
+(NSMutableArray*)parseShopInfo:(NSString*)jsonResult getVersion:(int*)ver;

//商铺供应
+(NSMutableArray*)parseShopSupply:(NSString*)jsonResult getVersion:(int*)ver;

//商铺求购
+(NSMutableArray*)parseShopDemand:(NSString*)jsonResult getVersion:(int*)ver;

//推荐供应
+(NSMutableArray*)parseSupplyRecommendList:(NSString*)jsonResult getVersion:(int*)ver;

//推荐供应更多
+(NSMutableArray*)parseSupplyRecommendMoreList:(NSString*)jsonResult getVersion:(int*)ver;

//推荐求购
+(NSMutableArray*)parseDemandRecommendList:(NSString*)jsonResult getVersion:(int*)ver;

//推荐求购更多
+(NSMutableArray*)parseDemandRecommendMoreList:(NSString*)jsonResult getVersion:(int*)ver;

//搜索供应
+(NSMutableArray*)parseSearchSupply:(NSString*)jsonResult getVersion:(int*)ver;

//搜索商铺
+(NSMutableArray*)parseSearchShop:(NSString*)jsonResult getVersion:(int*)ver;

//推送  设备令牌
+(NSMutableArray*)parseAPNS:(NSString*)jsonResult ;

//PV 接口
+(NSMutableArray*)parsePV:(NSString*)jsonResult;

//最新会员
+(NSMutableArray*)parseNewestMemberList:(NSString*)jsonResult getVersion:(int*)ver;

//通讯录
+(NSMutableArray*)parseContactsBookList:(NSString*)jsonResult getVersion:(int*)ver;

//通讯录分类
+(NSMutableArray*)parseContactsBookCatList:(NSString*)jsonResult getVersion:(int*)ver;

//搜索会员
+(NSMutableArray*)parseSearchMember:(NSString*)jsonResult getVersion:(int*)ver;

//会员详情
+(NSMutableArray*)parseCardDetail:(NSString*)jsonResult getVersion:(int*)ver;

//更多
+ (NSMutableArray*)parseMoreCat:(NSString*)jsonResult getVersion:(int*)ver;
+ (NSMutableArray*)parseMoreCatInfo:(NSString*)jsonResult getVersion:(int*)ver withCatId:(int)_catId;

//留言
+ (NSMutableArray*)parseMessageList:(NSString*)jsonResult getVersion:(int*)ver;
+ (NSMutableArray*)parseMessageDetail:(NSString*)jsonResult getVersion:(int*)ver;
+ (NSMutableArray*)parseMessageSend:(NSString*)jsonResult getVersion:(int*)ver;

//我的名片夹
+ (NSMutableArray*)parseFavoriteBooksList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId;
//收藏名片
+ (NSMutableArray*)parseContactBooksFavorite:(NSString*)jsonResult getVersion:(int*)ver;

//推荐应用
+ (NSMutableArray*)parseRecommendApp:(NSString*)jsonResult getVersion:(int*)ver;

//推荐应用更多
+ (NSMutableArray*)parseRecommendAppMore:(NSString*)jsonResult getVersion:(int*)ver;

//近期活动
+ (NSMutableArray*)parseActivity:(NSString*)jsonResult getVersion:(int*)ver;

//近期活动更多
+ (NSMutableArray*)parseActivityMore:(NSString*)jsonResult getVersion:(int*)ver;

//往期活动
+ (NSMutableArray*)parseActivityHistory:(NSString*)jsonResult getVersion:(int*)ver;

//往期活动更多
+ (NSMutableArray*)parseActivityHistoryMore:(NSString*)jsonResult getVersion:(int*)ver;

//活动现场图片更多
+ (NSMutableArray*)parseActivityUserPicMore:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param;

//留言反馈
+ (NSMutableArray*)parseFeedbackList:(NSString*)jsonResult getVersion:(int*)ver;
//小秘书列表
+ (NSMutableArray*)parseSystemMessageList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno;
//我参与的活动
+ (NSMutableArray*)parseMyActivityList:(NSString*)jsonResult;

// 修改密码
+ (NSMutableArray*)parsePasswordModif:(NSString*)jsonResult;

@end
