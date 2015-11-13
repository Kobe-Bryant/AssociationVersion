//
//  CommonOperation.m
//  Profession
//
//  Created by MC374 on 12-8-9.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CommandOperation.h"
#import "Common.h"
#import "CommandOperationParser.h"

#import "ProfessionAppDelegate.h"
#import "NetPopupWindow.h"

Class object_getClass(id object);

@implementation CommandOperation
@synthesize reqStr;
@synthesize delegate;
@synthesize requestParam;
@synthesize commandid;

- (id)initWithReqStr:(NSString*)rstr command:(int)cmd delegate:(id <CommandOperationDelegate>)theDelegate params:(NSMutableDictionary*)param{
	
	self = [super init];
	if (self != nil)
	{
		self.reqStr = rstr;
		self.delegate = theDelegate;
        _originalClass = object_getClass(theDelegate);
		commandid = cmd;
		self.requestParam = param;
	}
    return self;
}
-(NSMutableArray*)parseJsonandGetVersion:(int*)ver{
	NSString *resultStr = [[NSString alloc]initWithData:[self AccessService] encoding: NSUTF8StringEncoding];
	NSLog(@"data from server result %@",resultStr);
    
	NSMutableArray *resultArray = nil;
	
    if ([resultStr isEqualToString:@"{}"] || [resultStr isEqualToString:@"{\"Error\":\"4001\"}"] || [resultStr isEqualToString:@"{\"Error\":\"4002\"}"] || [resultStr isEqualToString:@"{\"Error\":\"4003\"}"])
    {
        *ver = NO_UPDATE;
        NSLog(@"------数据为空或请求发生错误 结果: %@",resultStr);
    }
    else
    {
        switch (commandid) {
            case ACCESS_ADVERTISE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseAdvertise:resultStr getVersion:ver];
                break;
            }
            case ACCESS_RCM_CATS_COMMAND_ID:{
                resultArray = [CommandOperationParser parseRecommendAndCats:resultStr getVersion:ver];
            }
                break;
            case ACCESS_NEWS_COMMAND_ID:{
                NSNumber *cid = [requestParam objectForKey:@"cats_id"];
                NSString *verinfo = [requestParam objectForKey:@"ver"];
                BOOL loadMore = NO;
                if ([verinfo intValue] == -1) {
                    loadMore = YES;
                }
                resultArray = [CommandOperationParser parseNews:resultStr getVersion:ver catid:cid isLoadMore:loadMore];
                
            }
                break;
            case ACCESS_COMMENT_NEWS_COMMAND_ID:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
            case ACCESS_FAVORITE_NEWS_COMMAND_ID:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
            case MEMBER_LOGIN_COMMAND_ID:{
                resultArray = [CommandOperationParser parseLogin:resultStr getVersion:ver];
                break;
            }
            case MEMBER_REGIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseRegist:resultStr getVersion:ver];
            }
                break;
            case SINAWEI_COMMAND_ID:{
                resultArray = [CommandOperationParser parseSinaWeibo:resultStr getVersion:ver];
            }
                break;
            case TENCENTWEI_COMMAND_ID:{
                resultArray = [CommandOperationParser parseTencentWeibo:resultStr getVersion:ver];
            }
                break;
            case MEMBER_FAVRITEPRODUCTLIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseProductList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:YES];
            }
                break;
            case MEMBER_FAVORITEBUYLIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseBuyList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:YES];
            }
                break;
                
            case MEMBER_FAVORITESHOPSLIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseShopsList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:YES];
            }
                break;
            case MEMBER_FAVORITEINFOLIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseInfoList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:YES];
            }
                break;
            case MEMBER_FAVORITEDELETE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseDelete:resultStr getVersion:ver];
            }
                break;
            case MEMBER_FAVRITEPRODUCTMORELIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseProductList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:NO];
            }	break;
            case MEMBER_FAVORITEBUYMORELIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseBuyList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:NO];
            }	break;
            case MEMBER_FAVORITESHOPSMORELIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseShopsList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:NO];
            }	break;
            case MEMBER_FAVORITEINFOMORELIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseInfoList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:NO];
            }	break;
            case MEMBER_CHANGEIMAGE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseChangeImage:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue]];
            }   break;
            case COMMENTLIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseCommentList:resultStr getVersion:ver withTypeId:[[requestParam objectForKey:@"type"] intValue] withInfoId:[[requestParam objectForKey:@"info_id"] intValue] isInsert:YES];
                
            }   break;
            case COMMENTLIST_MORE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseCommentList:resultStr getVersion:ver withTypeId:[[requestParam objectForKey:@"type"] intValue] withInfoId:[[requestParam objectForKey:@"info_id"] intValue] isInsert:NO];
                
            }   break;
            case MEMBER_EDIT_COMMAND_ID:{
                resultArray = [CommandOperationParser parseLogin:resultStr getVersion:ver];
            }   break;
                
                //////////
            case OPERAT_SUPPLY_REFRESH:{
                resultArray = [CommandOperationParser parseSuppyList:resultStr getVersion:ver withParam:self.requestParam];
            }
                break;
            case OPERAT_SUPPLY_CAT_REFRESH:{
                resultArray = [CommandOperationParser parseSuppyCatList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SUPPLY_MORE:{
                resultArray = [CommandOperationParser parseSupplyMoreList:resultStr getVersion:ver withParam:self.requestParam];
            }
                break;
            case OPERAT_DEMAND_REFRESH:{
                resultArray = [CommandOperationParser parseDemandList:resultStr getVersion:ver withParam:self.requestParam];
            }
                break;
            case OPERAT_DEMAND_CAT_REFRESH:{
                resultArray = [CommandOperationParser parseDemandCatList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_DEMAND_MORE:{
                resultArray = [CommandOperationParser parseDemandMoreList:resultStr getVersion:ver withParam:self.requestParam];
            }
                break;
            case OPERAT_SHOP_REFRESH:{
                resultArray = [CommandOperationParser parseShopList:resultStr getVersion:ver withParam:self.requestParam];
            }
                break;
            case OPERAT_SHOP_CAT_REFRESH:{
                resultArray = [CommandOperationParser parseShopCatList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SHOP_MORE:{
                resultArray = [CommandOperationParser parseShopMoreList:resultStr getVersion:ver withParam:self.requestParam];
            }
                break;
            case OPERAT_ABOUTUS_INFO:{
                resultArray = [CommandOperationParser parseAboutUsList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEND_SUPPLY_COMMENT:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEND_DEMAND_COMMENT:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEND_SUPPLY_FAVORITE:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEND_DEMAND_FAVORITE:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEND_SHOP_FAVORITE:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEND_FEEDBACK:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SHOP_INFO:{
                resultArray = [CommandOperationParser parseShopInfo:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SHOP_SUPPLY_REFRESH:{
                resultArray = [CommandOperationParser parseShopSupply:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SHOP_SUPPLY_MORE:{
                resultArray = [CommandOperationParser parseShopSupply:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SHOP_DEMAND_REFRESH:{
                resultArray = [CommandOperationParser parseShopDemand:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SHOP_DEMAND_MORE:{
                resultArray = [CommandOperationParser parseShopDemand:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SUPPLY_RECOMMEND_REFRESH:{
                resultArray = [CommandOperationParser parseSupplyRecommendList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SUPPLY_RECOMMEND_MORE:{
                resultArray = [CommandOperationParser parseSupplyRecommendMoreList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_DEMAND_RECOMMEND_REFRESH:{
                resultArray = [CommandOperationParser parseDemandRecommendList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_DEMAND_RECOMMEND_MORE:{
                resultArray = [CommandOperationParser parseDemandRecommendMoreList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEARCH_SUPPLY:{
                resultArray = [CommandOperationParser parseSearchSupply:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEARCH_SUPPLY_MORE:{
                resultArray = [CommandOperationParser parseSearchSupply:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEARCH_SHOP:{
                resultArray = [CommandOperationParser parseSearchShop:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEARCH_SHOP_MORE:{
                resultArray = [CommandOperationParser parseSearchShop:resultStr getVersion:ver];
            }
                break;
            case APNS_COMMAND_ID:{
                resultArray = [CommandOperationParser parseAPNS:resultStr];
            }
                break;
            case PV_COMMAND_ID:{
                resultArray = [CommandOperationParser parsePV:resultStr];
            }
                break;
            case OPERAT_NEWEST_MEMBER_REFRESH:{
                resultArray = [CommandOperationParser parseNewestMemberList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_CONTACTS_BOOK_REFRESH:{
                resultArray = [CommandOperationParser parseContactsBookList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_CONTACTS_BOOK_CAT_REFRESH:{
                resultArray = [CommandOperationParser parseContactsBookCatList:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEARCH_MEMBER:{
                resultArray = [CommandOperationParser parseSearchMember:resultStr getVersion:ver];
            }
                break;
            case OPERAT_SEARCH_MEMBER_MORE:{
                resultArray = [CommandOperationParser parseSearchMember:resultStr getVersion:ver];
            }
                break;
            case OPERAT_CARDDETAIL_REFRESH:{
                resultArray = [CommandOperationParser parseCardDetail:resultStr getVersion:ver];
            }
                break;
                
                //更多
            case MORE_CAT_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMoreCat:resultStr getVersion:ver];
            }
                break;
            case MORE_CAT_INFO_COMMAND_ID:{
                int catId = [[requestParam objectForKey:@"cats_id"] intValue];
                resultArray = [CommandOperationParser parseMoreCatInfo:resultStr getVersion:ver withCatId:catId];
            }
                break;
                //留言
            case MESSAGE_LIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMessageList:resultStr getVersion:ver];
            }
                break;
            case MESSAGE_DETAIL_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMessageDetail:resultStr getVersion:ver];
            }
                break;
            case MESSAGE_LIST_DELETE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMessageSend:resultStr getVersion:ver];
            }
                break;
            case MESSAGE_DETAILMORE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMessageDetail:resultStr getVersion:ver];
            }
                break;
                
            case MESSAGE_SEND_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMessageSend:resultStr getVersion:ver];
            }
                break;
                //我的名片夹
            case MEMBER_FAVRITEBOOKLIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseFavoriteBooksList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue]];
            }   break;
            case OPERAT_SEND_CONTACTSBOOK_FAVORITE:{
                resultArray = [CommandOperationParser parseContactBooksFavorite:resultStr getVersion:ver];
            }   break;
                
                //推荐应用
            case OPERAT_RECOMMEND_APP_REFRESH:{
                resultArray = [CommandOperationParser parseRecommendApp:resultStr getVersion:ver];
            }
                break;
                
                //推荐应用更多
            case OPERAT_RECOMMEND_APP_MORE:{
                resultArray = [CommandOperationParser parseRecommendAppMore:resultStr getVersion:ver];
            }
                break;
                
                //近期活动
            case OPERAT_ACTIVITY_REFRESH:{
                resultArray = [CommandOperationParser parseActivity:resultStr getVersion:ver];
            }
                break;
                
                //近期活动更多
            case OPERAT_ACTIVITY_MORE:{
                resultArray = [CommandOperationParser parseActivityMore:resultStr getVersion:ver];
            }
                break;
                
                //往期活动
            case OPERAT_ACTIVITY_HISTORY_REFRESH:{
                resultArray = [CommandOperationParser parseActivityHistory:resultStr getVersion:ver];
            }
                break;
                
                //往期活动更多
            case OPERAT_ACTIVITY_HISTORY_MORE:{
                resultArray = [CommandOperationParser parseActivityHistoryMore:resultStr getVersion:ver];
            }
                break;
                
                //活动详情获取更多用户图片
            case OPERAT_ACTIVITY_USER_PIC_MORE:{
                resultArray = [CommandOperationParser parseActivityUserPicMore:resultStr getVersion:ver withParam:self.requestParam];
            }
                break;
                
                //感兴趣
            case OPERAT_SEND_ACTIVITY_INTERESTING:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
                
                //参加
            case OPERAT_SEND_ACTIVITY_JOIN:{
                resultArray = [CommandOperationParser parseSendCommentAndFavorite:resultStr getVersion:ver];
            }
                break;
                
                
                //发送站内信
            case SENDMESSAGE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMessageSend:resultStr getVersion:ver];
            }
                break;
                //留言反馈
            case FEEDBACK_LIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseFeedbackList:resultStr getVersion:ver];
            }
                break;
                //留言反馈 more
            case FEEDBACK_LIST_MORE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseFeedbackList:resultStr getVersion:ver];
            }
                break;
                //小秘书列表
            case SYSTEM_MESSAGE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseSystemMessageList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:YES];
            }
                break;
                //小秘书列表 more
            case SYSTEM_MESSAGE_MORE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseSystemMessageList:resultStr getVersion:ver withMemberId:[[requestParam objectForKey:@"user_id"] intValue] isInsert:NO];
            }
                break;
                //退出登录
            case MEMBER_CANCEL_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMessageSend:resultStr getVersion:ver];
            }
                break;
                //我参与的活动
            case MYACTIVITY_LIST_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMyActivityList:resultStr];
            }
                break;
                //我参与的活动 more
            case MYACTIVITY_LIST_MORE_COMMAND_ID:{
                resultArray = [CommandOperationParser parseMyActivityList:resultStr];
            }
                break;
                // 密码修改
            case MEMBER_PASSWORD_COMMAND_ID:{
                resultArray = [CommandOperationParser parsePasswordModif:resultStr];
            }
                break;
            default:
                break;
        }

    }
    
	[resultStr release];
	return resultArray;
}

-(NSData*)AccessService{
	
	NSURL *url;
    url = [NSURL URLWithString:reqStr];
	NSLog(@"url:%@",url);
    
	//NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                          timeoutInterval:15];


	NSURLResponse *response;
	NSError *error = nil;
	NSData* dataReply = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	if(error != nil)
	{
		NSException *exception =[NSException exceptionWithName:@"网络异常"
								 
														reason:[error  localizedDescription]
								 
													  userInfo:[error userInfo]];
		
		@throw exception;
		NSLog(@"NSURLConnection error %@",[error  localizedDescription]);
	}
	return dataReply;
}

- (void)show
{
    ProfessionAppDelegate *app = (ProfessionAppDelegate *)[UIApplication sharedApplication].delegate;
    [[NetPopupWindow defaultExample] showCustemAlertViewIninView:app.window];
}

- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray* result;
	int ver;
	NSLog(@"star thread");
	@try {
		result =[self parseJsonandGetVersion:&ver];
	}
	@catch (NSException *exception) {
		NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
        //网络异常
		if (![self isCancelled]&& delegate != nil)
		{
			Class currentClass = object_getClass(delegate);
            if  (currentClass == _originalClass)
            {
                [delegate didFinishCommand:nil cmd:commandid withVersion:0];
            }
		}
        [netWorkQueueArray removeObject:self.reqStr];
		self.reqStr = nil;
		[pool release];
        
        //if (![Common connectedToNetwork])
        {
            [self performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
        
		return;
	}
    if (![self isCancelled]&& delegate != nil)
	{
		//NSLog(@"deleget result  %@",result);
        Class currentClass = object_getClass(delegate);
        if  (currentClass == _originalClass)
        {
            [delegate didFinishCommand:result cmd:commandid withVersion:ver];
        }
		
	}
    [netWorkQueueArray removeObject:self.reqStr];
	self.reqStr = nil;
	[pool release];
    
    
}

-(void)dealloc{
	delegate = nil;
	self.reqStr = nil;
	self.requestParam = nil;
	[super dealloc];
}
@end
