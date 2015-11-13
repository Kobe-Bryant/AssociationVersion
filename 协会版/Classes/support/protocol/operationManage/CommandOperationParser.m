//
//  CommonOperationParser.m
//  Profession
//
//  Created by MC374 on 12-8-9.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CommandOperationParser.h"
#import "DBOperate.h"
#import "Common.h"
#import "SBJson.h"
#import "NSObject+SBJson.h"
#import "FileManager.h"

@implementation CommandOperationParser

+(BOOL)updateVersion:(int)commanId versionID:(NSNumber*)versionid desc:(NSString*)describe{
	if (versionid==nil) {
		return NO;
	}
	NSArray *ar_ver = [NSArray arrayWithObjects:[NSNumber numberWithInt:commanId],versionid,describe,nil];
	[DBOperate deleteData:T_VERSION tableColumn:@"command_id" columnValue:[NSNumber numberWithInt:commanId]];
	[DBOperate insertDataWithnotAutoID:ar_ver tableName:T_VERSION];
	return YES;
}

+(BOOL)updateMemberVersion:(int)_commandId memberId:(int)_memberId versionID:(NSNumber*)versionid desc:(NSString*)describe{
	if (versionid == nil) {
		return NO;
	}
	NSArray *ar_ver = [NSArray arrayWithObjects:[NSNumber numberWithInt:_commandId],[NSNumber numberWithInt:_memberId],versionid,describe,nil];
	[DBOperate deleteDataWithTwoConditions:T_MEMBER_VERSION columnOne:@"commandId" valueOne:[NSString stringWithFormat:@"%d",_commandId] columnTwo:@"memberId" valueTwo:[NSString stringWithFormat:@"%d",_memberId]];
	[DBOperate insertDataWithnotAutoID:ar_ver tableName:T_MEMBER_VERSION];
	return YES;
}

+(BOOL)updateCommentListVersion:(int)_commandId typeId:(int)_typeId infoId:(int)_infoId versionID:(NSNumber*)versionid desc:(NSString*)describe{
	if (versionid == nil) {
		return NO;
	}
	NSArray *ar_ver = [NSArray arrayWithObjects:[NSNumber numberWithInt:_commandId],[NSNumber numberWithInt:_typeId],[NSNumber numberWithInt:_infoId],versionid,describe,nil];
	[DBOperate deleteDataWithTwoConditions:T_COMMENTLIST_VERSION columnOne:@"typeId" valueOne:[NSString stringWithFormat:@"%d",_typeId] columnTwo:@"infoId" valueTwo:[NSString stringWithFormat:@"%d",_infoId]];
	[DBOperate insertDataWithnotAutoID:ar_ver tableName:T_COMMENTLIST_VERSION];
	return YES;
}


+(NSMutableArray*)parseAdvertise:(NSString*)jsonResult getVersion:(int*)ver{
	NSDictionary *dic = [jsonResult JSONValue];
	NSArray *topsdArray = [dic objectForKey:@"tops"];
	NSArray *footsArray = [dic objectForKey:@"foots"];
	NSArray *publishedtopArray = [dic objectForKey:@"publishedtop"];
	NSArray *publishedfootArray = [dic objectForKey:@"publishedfoot"];
	*ver = NO_UPDATE;
	
	for (int i = 0;i < [publishedtopArray count] ;i++ ) {
		NSDictionary *dic = [publishedtopArray objectAtIndex:i];
		NSNumber *temp = [dic objectForKey:@"id"];
		[DBOperate deleteData:T_ADVERTISE_LIST tableColumn:@"imageid" columnValue:temp];
	}
	for (int i = 0;i < [publishedfootArray count] ;i++ ) {
		NSDictionary *dic = [publishedfootArray objectAtIndex:i];
		NSNumber *temp = [dic objectForKey:@"id"];
		[DBOperate deleteData:T_ADVERTISE_LIST tableColumn:@"imageid" columnValue:temp];
	}
	for(NSDictionary *topsdDic in topsdArray){
		NSMutableArray *ar_tops = [[NSMutableArray alloc]init];
		[ar_tops addObject:[topsdDic objectForKey:@"id"]];
        [ar_tops addObject:@"top"];
		[ar_tops addObject:[topsdDic objectForKey:@"img"]];
		[ar_tops addObject:[topsdDic objectForKey:@"desc"]];
		[ar_tops addObject:[topsdDic objectForKey:@"url"]];
		[ar_tops addObject:@""];
        [ar_tops addObject:[topsdDic objectForKey:@"order"]];
        if ([[topsdDic objectForKey:@"type"] intValue] == 3)
        {
            if ([[topsdDic objectForKey:@"info_id"] intValue] == 0)
            {
                [ar_tops addObject:@"-1"];
            }
            else
            {
                [ar_tops addObject:[topsdDic objectForKey:@"info_id"]];
            }
        }
        else
        {
            [ar_tops addObject:@"0"];
        }
		*ver = NEED_UPDATE;
		
		[DBOperate insertDataWithnotAutoID:ar_tops tableName:T_ADVERTISE_LIST];
		[ar_tops release];
	}
	for(NSDictionary *footsDic in footsArray){
		NSMutableArray *ar_foots = [[NSMutableArray alloc]init];
		[ar_foots addObject:[footsDic objectForKey:@"id"]];
		[ar_foots addObject:@"foot"];
		[ar_foots addObject:[footsDic objectForKey:@"img"]];
		[ar_foots addObject:@""];
		[ar_foots addObject:[footsDic objectForKey:@"url"]];
		[ar_foots addObject:@""];
        [ar_foots addObject:[footsDic objectForKey:@"order"]];
        [ar_foots addObject:@"0"];
		*ver = NEED_UPDATE;
		NSString *imageUrl = [footsDic objectForKey:@"url"];
		if (imageUrl.length > 0) {
			[DBOperate insertDataWithnotAutoID:ar_foots tableName:T_ADVERTISE_LIST];
		}		
		[ar_foots release];
	}	
	[self updateVersion:ACCESS_ADVERTISE_COMMAND_ID versionID:[dic objectForKey:@"ver"] desc:@""];
	return nil;
}

+(NSMutableArray*)parseRecommendAndCats:(NSString*)jsonResult getVersion:(int*)ver{
	NSDictionary *dic = [jsonResult JSONValue];
	NSArray *newsDelsArray = [dic objectForKey:@"news_dels"];
	NSArray *catsDelsArray = [dic objectForKey:@"cats_dels"];
	NSArray *newsArray = [dic objectForKey:@"news"];
	NSArray *catsArray = [dic objectForKey:@"cats"];
    
    NSArray *activeMemberArray = [dic objectForKey:@"mems"];
	
	//删除所有活跃会员
	
    [DBOperate deleteData:T_ACTIVE_MEMBER];
	
	//删除推荐新闻
	for (int i = 0;i < [newsDelsArray count] ;i++ ) {
		NSDictionary *dic = [newsDelsArray objectAtIndex:i];
		NSNumber *temp = [dic objectForKey:@"id"];
		[DBOperate deleteData:T_RECOMMEND_NEWS tableColumn:@"nid" columnValue:temp];
	}
	//删除资讯分类
	for (int i = 0;i < [catsDelsArray count] ;i++ ) {
		NSDictionary *dic = [catsDelsArray objectAtIndex:i];
		NSNumber *temp = [dic objectForKey:@"id"];
		[DBOperate deleteData:T_NEWS_CAT tableColumn:@"cid" columnValue:temp];
	}
	//解析推荐新闻
	for(NSDictionary *newsDic in newsArray){
		
		NSMutableArray *ar_news = [[NSMutableArray alloc]init];
		[ar_news addObject:[newsDic objectForKey:@"id"]];
		[ar_news addObject:@""];
		[ar_news addObject:[newsDic objectForKey:@"title"]];
		[ar_news addObject:[newsDic objectForKey:@"desc"]];
		[ar_news addObject:[newsDic objectForKey:@"companyname"]];
		
		NSArray *picArray = [newsDic objectForKey:@"pics"];
		for (NSDictionary *picDic in picArray ) {
			[ar_news addObject:[picDic objectForKey:@"pic1"]];
			[ar_news addObject:[picDic objectForKey:@"pic2"]];
		}
		[ar_news addObject:@""];
		[ar_news addObject:@""];
		[ar_news addObject:[newsDic objectForKey:@"created"]];
		[ar_news addObject:[newsDic objectForKey:@"updatetime"]];
        [ar_news addObject:[newsDic objectForKey:@"comment"]];
		
		[DBOperate insertDataWithnotAutoID:ar_news tableName:T_RECOMMEND_NEWS];
		[ar_news release];
	}
    
    
	int sort_order = 1;
	//解析活跃会员
	for(NSDictionary *activeMemberDic in activeMemberArray){
		
		NSMutableArray *infoArray = [[NSMutableArray alloc]init];
        [infoArray addObject:[activeMemberDic objectForKey:@"id"]];
        [infoArray addObject:[activeMemberDic objectForKey:@"user_id"]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"user_name"]]];
		[infoArray addObject:[activeMemberDic objectForKey:@"gender"]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"post"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"company_name"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"tel"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"mobile"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"fax"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"email"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"cat_name"]]];
        [infoArray addObject:[activeMemberDic objectForKey:@"cat_id"]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"province"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"city"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"district"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"addr"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"img"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"created"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[activeMemberDic objectForKey:@"url"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%d",sort_order]];
		[DBOperate insertDataWithnotAutoID:infoArray tableName:T_ACTIVE_MEMBER];
        //[DBOperate insertData:infoArray tableName:T_ACTIVE_MEMBER];
        
		[infoArray release];
        
        sort_order = sort_order + 1;
	}
	
	//解析资讯分类
	for(NSDictionary *catsDic in catsArray){
		
		NSMutableArray *ar_cats = [[NSMutableArray alloc]init];
		[ar_cats addObject:[catsDic objectForKey:@"id"]];
		[ar_cats addObject:[catsDic objectForKey:@"name"]];
		[ar_cats addObject:[catsDic objectForKey:@"order"]];
		[ar_cats addObject:@"0"];
		
		[DBOperate insertDataWithnotAutoID:ar_cats tableName:T_NEWS_CAT];
		[ar_cats release];
	}
	
	[self updateVersion:ACCESS_RECOMMEND_NEWS_COMMAND_ID versionID:[dic objectForKey:@"ver_news"] desc:@"推荐新闻版本"];
	[self updateVersion:ACCESS_RECOMMEND_SHOPS_COMMAND_ID versionID:[dic objectForKey:@"ver_shops"] desc:@"推荐单位版本"];
	[self updateVersion:ACCESS_NEWS_CATS_COMMAND_ID versionID:[dic objectForKey:@"ver_cats"] desc:@"新闻分类版本"];
	return nil;
}

+(NSMutableArray*)parseNews:(NSString*)jsonResult getVersion:(int*)ver catid:(NSNumber*)cid isLoadMore:(BOOL)loadMore{		
	//解析新闻列表
	NSDictionary *dic = [jsonResult JSONValue];
	NSArray *newsArray = [dic objectForKey:@"infos"];
	NSArray *delNewsArray = [dic objectForKey:@"dels"];
	NSMutableArray *resultArray = [[NSMutableArray alloc] init];
	*ver = NO_UPDATE;
    
	//cid=0，全部资讯，数据版本号加入版本号控制表
	if ([cid intValue] == 0) 
    {
		[self updateVersion:ACCESS_ALL_NEWS_COMMAND_ID versionID:[dic objectForKey:@"ver"] desc:@"全部新闻"];
	}
    else 
    {
        if (!loadMore)
        {
            //更新分类版本表的相应分类版本号
            [DBOperate updateData:T_NEWS_CAT
				  tableColumn:@"cat_version" columnValue:[dic objectForKey:@"ver"] 
              conditionColumn:@"cid" conditionColumnValue:[NSString stringWithFormat:@"%d",[cid intValue]]];
        }
	}
	//删除过期资讯数据
	if ([delNewsArray count] > 0)
	{
		for(NSDictionary *delDic in delNewsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
            
            [DBOperate deleteDataWithTwoConditions:T_NEWS_LIST 
                                         columnOne:@"nid"
                                          valueOne:[NSString stringWithFormat:@"%@",delID]
                                         columnTwo:@"catid"
                                          valueTwo:[NSString stringWithFormat:@"%d",[cid intValue]]];
		}
		*ver = NEED_UPDATE;
	}
	
	for(NSDictionary *newsDic in newsArray){
		
		NSMutableArray *ar_news = [[NSMutableArray alloc]init];
		[ar_news addObject:[newsDic objectForKey:@"id"]];
		[ar_news addObject:cid];
		[ar_news addObject:[newsDic objectForKey:@"title"]];
		[ar_news addObject:[newsDic objectForKey:@"desc"]];
		[ar_news addObject:[newsDic objectForKey:@"companyname"]];
		
		NSArray *picArray = [newsDic objectForKey:@"pics"];
		for (NSDictionary *picDic in picArray ) {
			[ar_news addObject:[picDic objectForKey:@"pic1"]];
			[ar_news addObject:[picDic objectForKey:@"pic2"]];
		}
		
		[ar_news addObject:@""];
		[ar_news addObject:@""];
		
		[ar_news addObject:[newsDic objectForKey:@"created"]];
		[ar_news addObject:[newsDic objectForKey:@"updatetime"]];
        
        [ar_news addObject:[newsDic objectForKey:@"recommend"]];
        [ar_news addObject:[newsDic objectForKey:@"push_time"]];
		[ar_news addObject:[newsDic objectForKey:@"comment"]];
        
		if (loadMore) {
			[resultArray addObject:ar_news];
		}else {
			[DBOperate insertDataWithnotAutoID:ar_news tableName:T_NEWS_LIST];
		}
		
		[ar_news release];
		*ver = NEED_UPDATE;
	}
	
	if(loadMore){
		return [resultArray autorelease];
	}else {
		[resultArray release];
	}
    
	
	//每个catid分类，数据库只保存20条最新资讯
	NSMutableArray *allNewsArray = (NSMutableArray *)[DBOperate 
													  queryData:T_NEWS_LIST 
                                                      theColumn:@"catid" 
                                                      theColumnValue:[NSString stringWithFormat:@"%@",cid] 
                                                      withAll:NO];
	//删除过于20条的资讯记录
	for (int i = [allNewsArray count] - 1; i > 19; i--)
	{
		NSArray *ay = [allNewsArray objectAtIndex:i];
		NSString *spicname = [ay objectAtIndex:newslist_spic];
		NSString *opicname = [ay objectAtIndex:newslist_opic];
		//删除对应的图片记录
		[FileManager removeFile:spicname];
		[FileManager removeFile:opicname];
		
		NSString *newId = [ay objectAtIndex:newslist_nid];
		[DBOperate deleteData:T_NEWS_LIST tableColumn:@"nid" columnValue:newId];
	}
	
	return nil;
}

//会员中心
+ (NSMutableArray*)parseLogin:(NSString*)jsonResult getVersion:(int*)ver
{ 
    NSDictionary *resultDic = [jsonResult JSONValue];
	//NSLog(@"resultDic===%@",resultDic);
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	NSMutableArray *strArray = [[NSMutableArray alloc] init];
	NSString *str = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"ret"]];
	[strArray addObject:str];
	[resultArray addObject:strArray];
    [strArray release];
    
	NSArray *infoArray = [resultDic objectForKey:@"infos"];
	if (infoArray != nil && [infoArray count] > 0) {
		for (NSDictionary *infoDic in infoArray) {
			NSMutableArray *infoList = [[NSMutableArray alloc]init];
            [infoList addObject:[infoDic objectForKey:@"user_id"]];
            [infoList addObject:@""];
            [infoList addObject:[infoDic objectForKey:@"user_name"]];
            [infoList addObject:@""];
            [infoList addObject:[infoDic objectForKey:@"img"]];
            [infoList addObject:@""];
            [infoList addObject:@""];
			[infoList addObject:[infoDic objectForKey:@"gender"]];
			[infoList addObject:[infoDic objectForKey:@"post"]];
            [infoList addObject:[infoDic objectForKey:@"company_name"]];
			[infoList addObject:[infoDic objectForKey:@"tel"]];
			[infoList addObject:[infoDic objectForKey:@"mobile"]];
			[infoList addObject:[infoDic objectForKey:@"cat_id"]];
			[infoList addObject:[infoDic objectForKey:@"cat_name"]];
            [infoList addObject:[infoDic objectForKey:@"province"]];
			[infoList addObject:[infoDic objectForKey:@"city"]];
            [infoList addObject:[infoDic objectForKey:@"district"]];
			[infoList addObject:[infoDic objectForKey:@"addr"]];
			[infoList addObject:[infoDic objectForKey:@"fax"]];
			[infoList addObject:[infoDic objectForKey:@"created"]];
			[infoList addObject:[infoDic objectForKey:@"email"]];
            [infoList addObject:[infoDic objectForKey:@"num"]];
            [infoList addObject:[infoDic objectForKey:@"url"]];
            [infoList addObject:[infoDic objectForKey:@"feedback_num"]];
            //[infoList addObject:@""];
			[resultArray addObject:infoList];
			[infoList release];
            
            [DBOperate deleteData:T_SYSTEM_CONFIG tableColumn:@"tag" columnValue:@"activityId"];
            
            NSMutableArray *idArray = [[NSMutableArray alloc]init];
            [idArray addObject:@"activityId"];
            [idArray addObject:[infoDic objectForKey:@"activitys_id"]];
            [DBOperate insertDataWithnotAutoID:idArray tableName:T_SYSTEM_CONFIG];
            [idArray release];
        }
	}else {
        NSMutableArray *infoList = [[NSMutableArray alloc]init];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [infoList addObject:@""];
        [resultArray addObject:infoList];
        [infoList release];
    }	
	return [resultArray autorelease];
}

+ (NSMutableArray*)parseRegist:(NSString*)jsonResult getVersion:(int*)ver
{ 
	NSDictionary *resultDic = [jsonResult JSONValue];
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	NSMutableArray *strArray = [[NSMutableArray alloc] init];
	NSString *str = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"ret"]];
	[strArray addObject:str];
	[resultArray addObject:strArray];
    
	if ([str isEqualToString:@"1"]) {
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
		[infoArray addObject:[resultDic objectForKey:@"id"]];
		[infoArray addObject:[resultDic objectForKey:@"name"]];
		[infoArray addObject:@""];
		[infoArray addObject:[resultDic objectForKey:@"img"]];
		[infoArray addObject:[resultDic objectForKey:@"level"]];
		[infoArray addObject:@""];
		[resultArray addObject:infoArray];
	}
    //NSLog(@"resultArray====%@",resultArray);
	return resultArray;
}

+ (NSMutableArray*)parseSinaWeibo:(NSString*)jsonResult getVersion:(int*)ver
{ 
	NSDictionary *resultDic = [jsonResult JSONValue];
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	NSMutableArray *strArray = [[NSMutableArray alloc] init];
	NSString *str = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"ret"]];
	[strArray addObject:str];
	[resultArray addObject:strArray];
	
	if ([str isEqualToString:@"1"] || [str isEqualToString:@"2"]) {
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
		[infoArray addObject:[resultDic objectForKey:@"id"]];
		[infoArray addObject:[resultDic objectForKey:@"name"]];
		[infoArray addObject:[resultDic objectForKey:@"pwd"]];
		[infoArray addObject:[resultDic objectForKey:@"img"]];
		[infoArray addObject:[resultDic objectForKey:@"level"]];
		[infoArray addObject:@""];
		
		[resultArray addObject:infoArray];
		
	}
    //NSLog(@"resultArray====%@",resultArray);
	[self updateVersion:SINAWEI_COMMAND_ID versionID:[resultDic objectForKey:@"ver"] desc:@""];
	//[self updateMemberVersion:SINAWEI_COMMAND_ID memberId:[resultDic objectForKey:@"id"] versionID:[resultDic objectForKey:@"ver"] desc:@""];
	return resultArray;
}

+ (NSMutableArray*)parseTencentWeibo:(NSString*)jsonResult getVersion:(int*)ver
{ 
	NSDictionary *resultDic = [jsonResult JSONValue];
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	NSMutableArray *strArray = [[NSMutableArray alloc] init];
	NSString *str = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"ret"]];
	[strArray addObject:str];
	[resultArray addObject:strArray];
	
	if ([str isEqualToString:@"1"] || [str isEqualToString:@"2"]) {
		NSMutableArray *infoArray = [[NSMutableArray alloc] init];
		[infoArray addObject:[resultDic objectForKey:@"id"]];
		[infoArray addObject:[resultDic objectForKey:@"name"]];
		[infoArray addObject:[resultDic objectForKey:@"pwd"]];
		[infoArray addObject:[resultDic objectForKey:@"img"]];
		[infoArray addObject:[resultDic objectForKey:@"level"]];
		[infoArray addObject:@""];
		
		[resultArray addObject:infoArray];
		
	}
    //NSLog(@"resultArray====%@",resultArray);
	[self updateVersion:TENCENTWEI_COMMAND_ID versionID:[resultDic objectForKey:@"ver"] desc:@""];
	return resultArray;
}

+ (NSMutableArray*)parseProductList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno
{ 
	NSDictionary *resultDic = [jsonResult JSONValue];
	//NSLog(@"resultDic===%@",resultDic);
	NSArray *infoArray = [resultDic objectForKey:@"infos"];
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	*ver = NEED_UPDATE;
	
	if (delsArray != nil) {
		for (int i = 0;i < [delsArray count] ;i++ ) {
			NSDictionary *dic = [delsArray objectAtIndex:i];
			NSNumber *temp = [dic objectForKey:@"id"];
			[DBOperate deleteData:T_SUPPLY_FAVORITE tableColumn:@"supply_id" columnValue:temp];
            
            //删除对应的图片
            [DBOperate deleteData:T_SUPPLY_PIC_FAVORITE tableColumn:@"supply_id" columnValue:temp];
            
		}
	}
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	if (infoArray != nil) {
		for (NSDictionary *infoDic in infoArray) {
			NSMutableArray *infoList = [[NSMutableArray alloc]init];
			[infoList addObject:[infoDic objectForKey:@"favoriteid"]];
			[infoList addObject:[infoDic objectForKey:@"id"]];
			[DBOperate deleteData:T_SUPPLY_FAVORITE tableColumn:@"supply_id" columnValue:[infoDic objectForKey:@"id"]];
            [DBOperate deleteData:T_SUPPLY_PIC_FAVORITE tableColumn:@"supply_id" columnValue:[infoDic objectForKey:@"id"]];
			[infoList addObject:[NSNumber numberWithInt:_memberId]];
			[infoList addObject:[infoDic objectForKey:@"catid"]];
			[infoList addObject:[infoDic objectForKey:@"title"]];
			[infoList addObject:[infoDic objectForKey:@"desc"]];
			[infoList addObject:[infoDic objectForKey:@"price"]];
			[infoList addObject:[infoDic objectForKey:@"companyid"]];
			[infoList addObject:[infoDic objectForKey:@"companyname"]];
			[infoList addObject:[infoDic objectForKey:@"tel"]];
			[infoList addObject:[infoDic objectForKey:@"pic"]];
			[infoList addObject:@""];
			[infoList addObject:[infoDic objectForKey:@"favorite"]];
			[infoList addObject:@""];
			[infoList addObject:[infoDic objectForKey:@"updatetime"]];
			[infoList addObject:[infoDic objectForKey:@"recommend"]];
            [infoList addObject:[infoDic objectForKey:@"comment"]];
			if (yesORno == YES) {
				[DBOperate insertData:infoList tableName:T_SUPPLY_FAVORITE];
			}
			[resultArray addObject:infoList];
			[infoList release];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (NSDictionary *picDic in picArray ) {
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:[infoDic objectForKey:@"id"]];
                //				[DBOperate deleteData:T_SUPPLY_PIC_FAVORITE tableColumn:@"supply_id" columnValue:[infoDic objectForKey:@"id"]];
				[pic addObject:[NSNumber numberWithInt:_memberId]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
				[DBOperate insertData:pic tableName:T_SUPPLY_PIC_FAVORITE];
				[pic release];
			}
		}
		
	}	
	[self updateMemberVersion:MEMBER_FAVRITEPRODUCTLIST_COMMAND_ID memberId:_memberId versionID:[resultDic objectForKey:@"ver"] desc:@""];
	return [resultArray autorelease];
}

+ (NSMutableArray*)parseBuyList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno
{
	NSDictionary *resultDic = [jsonResult JSONValue];
	//NSLog(@"resultDic===%@",resultDic);
	NSArray *infoArray = [resultDic objectForKey:@"infos"];
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	*ver = NEED_UPDATE;
	
	if (delsArray != nil) {
		for (int i = 0;i < [delsArray count] ;i++ ) {
			NSDictionary *dic = [delsArray objectAtIndex:i];
			NSNumber *temp = [dic objectForKey:@"id"];
			[DBOperate deleteData:T_DEMAND_FAVORITE tableColumn:@"demand_id" columnValue:temp];
            
            //删除对应的图片
            [DBOperate deleteData:T_DEMAND_PIC_FAVORITE tableColumn:@"demand_id" columnValue:temp];
		}
	}
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	if (infoArray != nil) {
		for (NSDictionary *infoDic in infoArray) {
			NSMutableArray *infoList = [[NSMutableArray alloc]init];
			[infoList addObject:[infoDic objectForKey:@"favoriteid"]];
			[infoList addObject:[infoDic objectForKey:@"id"]];
			[DBOperate deleteData:T_DEMAND_FAVORITE tableColumn:@"demand_id" columnValue:[infoDic objectForKey:@"id"]];
			[DBOperate deleteData:T_DEMAND_PIC_FAVORITE tableColumn:@"demand_id" columnValue:[infoDic objectForKey:@"id"]];
			[infoList addObject:[NSNumber numberWithInt:_memberId]];
			[infoList addObject:[infoDic objectForKey:@"catid"]];
			[infoList addObject:[infoDic objectForKey:@"title"]];
			[infoList addObject:[infoDic objectForKey:@"desc"]];
			[infoList addObject:[infoDic objectForKey:@"contact"]];
			[infoList addObject:[infoDic objectForKey:@"tel"]];
			[infoList addObject:[infoDic objectForKey:@"created"]];
			[infoList addObject:[infoDic objectForKey:@"updatetime"]];
			[infoList addObject:[infoDic objectForKey:@"recommend"]];
            [infoList addObject:[infoDic objectForKey:@"comment"]];
			if (yesORno == YES) {
				[DBOperate insertData:infoList tableName:T_DEMAND_FAVORITE];
			}
			[resultArray addObject:infoList];
			[infoList release];
			
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (NSDictionary *picDic in picArray ) {
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:[infoDic objectForKey:@"id"]];
                //				[DBOperate deleteData:T_SUPPLY_PIC_FAVORITE tableColumn:@"supply_id" columnValue:[infoDic objectForKey:@"id"]];
				
				[pic addObject:[NSNumber numberWithInt:_memberId]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
				[DBOperate insertData:pic tableName:T_DEMAND_PIC_FAVORITE];
				[pic release];
			}
		}
	}
	[self updateMemberVersion:MEMBER_FAVORITEBUYLIST_COMMAND_ID memberId:_memberId versionID:[resultDic objectForKey:@"ver"] desc:@""];
	return [resultArray autorelease];	
}

+ (NSMutableArray*)parseShopsList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno
{ 
	NSDictionary *resultDic = [jsonResult JSONValue];
	NSArray *infoArray = [resultDic objectForKey:@"infos"];
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	*ver = NEED_UPDATE;
	
	if (delsArray != nil) {
		for (int i = 0;i < [delsArray count] ;i++ ) {
			NSDictionary *dic = [delsArray objectAtIndex:i];
			NSNumber *temp = [dic objectForKey:@"id"];
			[DBOperate deleteData:T_SHOP_FAVORITE tableColumn:@"shop_id" columnValue:temp];
		}
	}
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	if (infoArray != nil) {
		for (NSDictionary *infoDic in infoArray) {
			NSMutableArray *infoList = [[NSMutableArray alloc]init];
			[infoList addObject:[infoDic objectForKey:@"favoriteid"]];
			[infoList addObject:[infoDic objectForKey:@"id"]];
			[DBOperate deleteData:T_SHOP_FAVORITE tableColumn:@"shop_id" columnValue:[infoDic objectForKey:@"id"]];
			
			[infoList addObject:[NSNumber numberWithInt:_memberId]];
			[infoList addObject:[infoDic objectForKey:@"uid"]];
			[infoList addObject:[infoDic objectForKey:@"level"]];
			[infoList addObject:[infoDic objectForKey:@"catid"]];
			[infoList addObject:[infoDic objectForKey:@"title"]];
			[infoList addObject:[infoDic objectForKey:@"desc"]];
			[infoList addObject:[infoDic objectForKey:@"tel"]];
			[infoList addObject:[infoDic objectForKey:@"pic"]];
			[infoList addObject:@""];
			[infoList addObject:[infoDic objectForKey:@"addr"]];
			[infoList addObject:[infoDic objectForKey:@"lng"]];
			[infoList addObject:[infoDic objectForKey:@"lat"]];
			[infoList addObject:[infoDic objectForKey:@"attestation"]];
			[infoList addObject:[infoDic objectForKey:@"updatetime"]];
            [infoList addObject:[infoDic objectForKey:@"about_us_title"]];
            [infoList addObject:[infoDic objectForKey:@"my_product_title"]];
            [infoList addObject:[infoDic objectForKey:@"app_name"]];
            [infoList addObject:[infoDic objectForKey:@"app_image"]];
            [infoList addObject:[infoDic objectForKey:@"iphone_url"]];
            
			if (yesORno == YES) {
				[DBOperate insertData:infoList tableName:T_SHOP_FAVORITE];
			}
			[resultArray addObject:infoList];
		    [infoList release];
			
		}		
	}	
	[self updateMemberVersion:MEMBER_FAVORITESHOPSLIST_COMMAND_ID memberId:_memberId versionID:[resultDic objectForKey:@"ver"] desc:@""];
	return [resultArray autorelease];
}

+ (NSMutableArray*)parseInfoList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno
{ 
	NSDictionary *resultDic = [jsonResult JSONValue];
	//NSLog(@"resultDic===%@",resultDic);
	NSArray *infoArray = [resultDic objectForKey:@"infos"];
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	*ver = NEED_UPDATE;
	
	if (delsArray != nil) {
		for (int i = 0;i < [delsArray count] ;i++ ) {
			NSDictionary *dic = [delsArray objectAtIndex:i];
			NSNumber *temp = [dic objectForKey:@"id"];
			[DBOperate deleteData:T_FAVORITE_NEWS tableColumn:@"nid" columnValue:temp];
		}
	}
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	if (infoArray != nil) {
		for (NSDictionary *infoDic in infoArray) {
			NSMutableArray *infoList = [[NSMutableArray alloc]init];
			[infoList addObject:[infoDic objectForKey:@"favoriteid"]];
			[infoList addObject:[infoDic objectForKey:@"id"]];
			[DBOperate deleteData:T_FAVORITE_NEWS tableColumn:@"nid" columnValue:[infoDic objectForKey:@"id"]];
			
			[infoList addObject:[NSNumber numberWithInt:_memberId]];
			[infoList addObject:[infoDic objectForKey:@"catid"]];
			[infoList addObject:[infoDic objectForKey:@"title"]];
			[infoList addObject:[infoDic objectForKey:@"desc"]];
			[infoList addObject:[infoDic objectForKey:@"companyname"]];
			[infoList addObject:[[[infoDic objectForKey:@"pics"] objectAtIndex:0] objectForKey:@"pic1"]];
			[infoList addObject:[[[infoDic objectForKey:@"pics"] objectAtIndex:0] objectForKey:@"pic2"]];
			[infoList addObject:@""];
			[infoList addObject:[infoDic objectForKey:@"created"]];
			[infoList addObject:[infoDic objectForKey:@"updatetime"]];
			[infoList addObject:[infoDic objectForKey:@"recommend"]];
			[infoList addObject:[infoDic objectForKey:@"push_time"]];
            [infoList addObject:[infoDic objectForKey:@"comment"]];
			if (yesORno == YES) {
				[DBOperate insertData:infoList tableName:T_FAVORITE_NEWS];
			}
			[resultArray addObject:infoList];
			[infoList release];
			
		}		
	}	
	[self updateMemberVersion:MEMBER_FAVORITEINFOLIST_COMMAND_ID memberId:_memberId versionID:[resultDic objectForKey:@"ver"] desc:@""];
	return [resultArray autorelease];
}

+ (NSMutableArray*)parseDelete:(NSString*)jsonResult getVersion:(int*)ver
{
	NSDictionary *resultDic = [jsonResult JSONValue];
	//NSLog(@"resultDic====%@",resultDic);
	*ver = NO_UPDATE;
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	NSMutableArray *strArray = [[NSMutableArray alloc] init];
	[strArray addObject:[NSString stringWithFormat:@"%@",[resultDic objectForKey:@"ret"]]];
	[resultArray addObject:strArray];
	return resultArray;
}

+ (NSMutableArray*)parseChangeImage:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId
{
	//NSDictionary *resultDic = [jsonResult JSONValue];
	return nil;
}

+ (NSMutableArray*)parseCommentList:(NSString*)jsonResult getVersion:(int*)ver withTypeId:(int)_typeId withInfoId:(int)_infoId isInsert:(BOOL)yesORno
{
    NSDictionary *resultDic = [jsonResult JSONValue];
	//NSLog(@"resultDic====%@",resultDic);
    NSArray *infoArray = [resultDic objectForKey:@"comments"];
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	*ver = NEED_UPDATE;
	
	if (delsArray != nil) {
		for (int i = 0;i < [delsArray count] ;i++ ) {
			NSDictionary *dic = [delsArray objectAtIndex:i];
			NSString *temp = [dic objectForKey:@"id"];
			//[DBOperate deleteData:T_FAVORITE_NEWS tableColumn:@"commentId" columnValue:temp];
            [DBOperate deleteDataWithTwoConditions:T_COMMENTLIST columnOne:@"commentId" valueOne:temp columnTwo:@"typeId" valueTwo:[NSString stringWithFormat:@"%d",_typeId]];
		}
	}
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	if (infoArray != nil) {
		for (NSDictionary *infoDic in infoArray) {
			NSMutableArray *infoList = [[NSMutableArray alloc]init];
			[infoList addObject:[infoDic objectForKey:@"id"]];
            [infoList addObject:[NSString stringWithFormat:@"%d",_typeId]];
            [DBOperate deleteDataWithTwoConditions:T_COMMENTLIST columnOne:@"commentId" valueOne:[infoDic objectForKey:@"id"] columnTwo:@"typeId" valueTwo:[NSString stringWithFormat:@"%d",_typeId]];
            [infoList addObject:[NSString stringWithFormat:@"%d",_infoId]];
			[infoList addObject:[infoDic objectForKey:@"username"]];
			[infoList addObject:[infoDic objectForKey:@"title"]];
			[infoList addObject:[infoDic objectForKey:@"content"]];
            [infoList addObject:[infoDic objectForKey:@"created"]];
			
			if (yesORno == YES) {
                [DBOperate insertDataWithnotAutoID:infoList tableName:T_COMMENTLIST];
			}
			[resultArray addObject:infoList];
			[infoList release];
		}		
	}
    
    //保证数据只有20条
	NSMutableArray *commentItems = (NSMutableArray *)[DBOperate queryData:T_COMMENTLIST theColumn:@"typeId" equalValue:[NSString stringWithFormat:@"%d",_typeId] theColumn:@"infoId" equalValue:[NSString stringWithFormat:@"%d",_infoId]];
	
	for (int i = [commentItems count] - 1; i > 19; i--)
	{
		NSArray *commentArray = [commentItems objectAtIndex:i];
		NSString *commentId = [commentArray objectAtIndex:comment_list_commentId];
		[DBOperate deleteData:T_COMMENTLIST tableColumn:@"commentId" columnValue:commentId];
	}
    
    [self updateCommentListVersion:COMMENTLIST_COMMAND_ID typeId:_typeId infoId:_infoId versionID:[resultDic objectForKey:@"ver"] desc:@""];
    
	return [resultArray autorelease];
}


//供应列表
+(NSMutableArray*)parseSuppyList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param
{
	*ver = NO_UPDATE;
	
	int catId = [[param objectForKey:@"cat_id"] intValue];
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
            
			//[DBOperate deleteData:T_SUPPLY 
			//		  tableColumn:@"id" 
			//		  columnValue:delID];
            
            [DBOperate deleteDataWithTwoConditions:T_SUPPLY 
                                         columnOne:@"id"
                                          valueOne:[NSString stringWithFormat:@"%@",delID]
                                         columnTwo:@"cat_id"
                                          valueTwo:[param objectForKey:@"cat_id"]];
			//删除对应的图片记录
            
			//[DBOperate deleteData:T_SUPPLY_PIC
			//		  tableColumn:@"supply_id" 
			//		  columnValue:delID];
            
            [DBOperate deleteDataWithTwoConditions:T_SUPPLY_PIC
                                         columnOne:@"supply_id" 
                                          valueOne:[NSString stringWithFormat:@"%@",delID] 
                                         columnTwo:@"cat_id"
                                          valueTwo:[NSString stringWithFormat:@"%d",catId]];
			
			//这里还要删除缓存图片 后面再做...
			
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			//[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[NSNumber numberWithInt: catId]];
			[infoArray addObject:[infoDic objectForKey:@"title"]];
			[infoArray addObject:[infoDic objectForKey:@"desc"]];
			[infoArray addObject:[infoDic objectForKey:@"price"]];
			[infoArray addObject:[infoDic objectForKey:@"companyid"]];
			[infoArray addObject:[infoDic objectForKey:@"companyname"]];
			[infoArray addObject:[infoDic objectForKey:@"tel"]];
			[infoArray addObject:[infoDic objectForKey:@"pic"]];
			[infoArray addObject:[infoDic objectForKey:@"favorite"]];
			[infoArray addObject:@""];
			[infoArray addObject:[infoDic objectForKey:@"updatetime"]];
			[infoArray addObject:@""];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
            [infoArray addObject:[infoDic objectForKey:@"comment"]];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_SUPPLY];
			
			//图片入库
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (NSDictionary *picDic in picArray ) 
			{
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
                [pic addObject:[NSNumber numberWithInt: catId]];
				[DBOperate insertData:pic tableName:T_SUPPLY_PIC];
				[pic release];
			}
			
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//保证数据只有20条
	NSMutableArray *supplyItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY theColumn:@"cat_id" theColumnValue:[NSString stringWithFormat:@"%d",catId] withAll:NO];
	
	for (int i = [supplyItems count] - 1; i > 19; i--)
	{
		NSArray *supplyArray = [supplyItems objectAtIndex:i];
		NSString *supplyId = [supplyArray objectAtIndex:supply_id];
		[DBOperate deleteData:T_SUPPLY tableColumn:@"id" columnValue:supplyId];
		
		//删除对应的图片记录
        
		//[DBOperate deleteData:T_SUPPLY_PIC
		//		  tableColumn:@"supply_id" 
		//		  columnValue:supplyId];
        
        [DBOperate deleteDataWithTwoConditions:T_SUPPLY_PIC
                                     columnOne:@"supply_id" 
                                      valueOne:[NSString stringWithFormat:@"%@",supplyId] 
                                     columnTwo:@"cat_id"
                                      valueTwo:[NSString stringWithFormat:@"%d",catId]];
        
        //这里还要删除缓存图片 后面再做...
	}
	
	
	//更新版本号
	if (catId == 0)
	{
		[self updateVersion:OPERAT_SUPPLY_REFRESH versionID:newVer desc:@"供应"];
	}
	else
	{
		[DBOperate updateData:T_SUPPLY_CAT 
				  tableColumn:@"version" 
				  columnValue:[NSString stringWithFormat:@"%@",newVer] 
			  conditionColumn:@"id"
		 conditionColumnValue:[NSString stringWithFormat:@"%d",catId]];
	}
	
	
	return nil;
}

//供应分类
+(NSMutableArray*)parseSuppyCatList:(NSString*)jsonResult getVersion:(int*)ver
{
	*ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"cats"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_SUPPLY_CAT 
					  tableColumn:@"id" 
					  columnValue:delID];
			
			//删除对应的内容数据
			[DBOperate deleteData:T_SUPPLY
					  tableColumn:@"cat_id" 
					  columnValue:delID];
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			[infoArray addObject:[infoDic objectForKey:@"name"]];
			[infoArray addObject:[infoDic objectForKey:@"order"]];
			[infoArray addObject:@"0"];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_SUPPLY_CAT];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//更新版本号
	[self updateVersion:OPERAT_SUPPLY_CAT_REFRESH versionID:newVer desc:@"供应分类"];
	
	return nil;
}

//供应更多
+(NSMutableArray*)parseSupplyMoreList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param
{
	*ver = NO_UPDATE;
	
	int catId = [[param objectForKey:@"cat_id"] intValue];
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	
	//插入数据
	NSMutableArray *moreArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			//[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt: catId]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"price"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"companyid"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"companyname"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pic"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"favorite"]]];
			[infoArray addObject:@""];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"updatetime"]]];
			
			//保存图片数据
			NSMutableArray *morePicArray = [[NSMutableArray alloc]init];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (int j = 0; j < [picArray count]; j++ ) 
			{
				NSDictionary *picDic = [picArray objectAtIndex:j];
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:@""];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
                [pic addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt: catId]]];
				[morePicArray insertObject:pic atIndex:j];
				[pic release];
			}
			[infoArray addObject:morePicArray];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
			
			[moreArray insertObject:infoArray atIndex:i];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	return [moreArray autorelease];
	
}

//求购列表
+(NSMutableArray*)parseDemandList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param
{
	*ver = NO_UPDATE;
	
	int catId = [[param objectForKey:@"cat_id"] intValue];
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			
            //[DBOperate deleteData:T_DEMAND 
			//		  tableColumn:@"id" 
			//		  columnValue:delID];
            
            [DBOperate deleteDataWithTwoConditions:T_DEMAND 
                                         columnOne:@"id"
                                          valueOne:[NSString stringWithFormat:@"%@",delID]
                                         columnTwo:@"cat_id"
                                          valueTwo:[param objectForKey:@"cat_id"]];
			
			//删除对应的图片记录
            
			//[DBOperate deleteData:T_DEMAND_PIC
			//		  tableColumn:@"demand_id" 
			//		  columnValue:delID];
            
            [DBOperate deleteDataWithTwoConditions:T_DEMAND_PIC
                                         columnOne:@"demand_id" 
                                          valueOne:[NSString stringWithFormat:@"%@",delID] 
                                         columnTwo:@"cat_id"
                                          valueTwo:[NSString stringWithFormat:@"%d",catId]];
			
			//这里还要删除缓存图片 后面再做...
			
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			//[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[NSNumber numberWithInt: catId]];
			[infoArray addObject:[infoDic objectForKey:@"title"]];
			[infoArray addObject:[infoDic objectForKey:@"desc"]];
			[infoArray addObject:[infoDic objectForKey:@"contact"]];
			[infoArray addObject:[infoDic objectForKey:@"tel"]];
			[infoArray addObject:@""];
			[infoArray addObject:[infoDic objectForKey:@"updatetime"]];
			[infoArray addObject:@""];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
            [infoArray addObject:[infoDic objectForKey:@"comment"]];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_DEMAND];
			
			//图片入库
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (NSDictionary *picDic in picArray ) 
			{
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
                [pic addObject:[NSNumber numberWithInt: catId]];
				[DBOperate insertData:pic tableName:T_DEMAND_PIC];
				[pic release];
			}
			
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//保证数据只有20条
	NSMutableArray *demandItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND theColumn:@"cat_id" theColumnValue:[NSString stringWithFormat:@"%d",catId] withAll:NO];
	
	for (int i = [demandItems count] - 1; i > 19; i--)
	{
		NSArray *demandArray = [demandItems objectAtIndex:i];
		NSString *demandId = [demandArray objectAtIndex:demand_id];
		[DBOperate deleteData:T_DEMAND tableColumn:@"id" columnValue:demandId];
		
		//删除对应的图片记录
        
		//[DBOperate deleteData:T_DEMAND_PIC
		//		  tableColumn:@"demand_id" 
		//		  columnValue:demandId];
        
        [DBOperate deleteDataWithTwoConditions:T_DEMAND_PIC
                                     columnOne:@"demand_id" 
                                      valueOne:[NSString stringWithFormat:@"%@",demandId] 
                                     columnTwo:@"cat_id"
                                      valueTwo:[NSString stringWithFormat:@"%d",catId]];
        
        //这里还要删除缓存图片 后面再做...
	}
	
	
	//更新版本号
	if (catId == 0)
	{
		[self updateVersion:OPERAT_DEMAND_REFRESH versionID:newVer desc:@"求购"];
	}
	else
	{
		[DBOperate updateData:T_DEMAND_CAT 
				  tableColumn:@"version" 
				  columnValue:[NSString stringWithFormat:@"%@",newVer] 
			  conditionColumn:@"id"
		 conditionColumnValue:[NSString stringWithFormat:@"%d",catId]];
	}
	
	
	return nil;
}

//求购分类
+(NSMutableArray*)parseDemandCatList:(NSString*)jsonResult getVersion:(int*)ver
{
	*ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"cats"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_DEMAND_CAT 
					  tableColumn:@"id" 
					  columnValue:delID];
			
			//删除对应的内容数据
			[DBOperate deleteData:T_DEMAND
					  tableColumn:@"cat_id" 
					  columnValue:delID];
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			[infoArray addObject:[infoDic objectForKey:@"name"]];
			[infoArray addObject:[infoDic objectForKey:@"order"]];
			[infoArray addObject:@"0"];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_DEMAND_CAT];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//更新版本号
	[self updateVersion:OPERAT_DEMAND_CAT_REFRESH versionID:newVer desc:@"求购分类"];
	
	return nil;
}

//求购更多
+(NSMutableArray*)parseDemandMoreList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param
{
	*ver = NO_UPDATE;
	
	int catId = [[param objectForKey:@"cat_id"] intValue];
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	
	//插入数据
	NSMutableArray *moreArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			//[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt: catId]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"contact"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
			[infoArray addObject:@""];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"updatetime"]]];
			
			//保存图片数据
			NSMutableArray *morePicArray = [[NSMutableArray alloc]init];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (int j = 0; j < [picArray count]; j++ ) 
			{
				NSDictionary *picDic = [picArray objectAtIndex:j];
				NSMutableArray *pic = [[NSMutableArray alloc] init];
                [pic addObject:@""];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
                [pic addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt: catId]]];
				[morePicArray insertObject:pic atIndex:j];
				[pic release];
			}
			[infoArray addObject:morePicArray];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
			
			[moreArray insertObject:infoArray atIndex:i];
			[infoArray release];
			
		}
		*ver = NEED_UPDATE;
	}
	
	return [moreArray autorelease];
	
}

//商铺列表
+(NSMutableArray*)parseShopList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param
{
	*ver = NO_UPDATE;
	
	int catId = [[param objectForKey:@"cat_id"] intValue];
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			
            //[DBOperate deleteData:T_SHOP 
			//		  tableColumn:@"id" 
			//		  columnValue:delID];
            
            [DBOperate deleteDataWithTwoConditions:T_SHOP 
                                         columnOne:@"id"
                                          valueOne:[NSString stringWithFormat:@"%@",delID]
                                         columnTwo:@"cat_id"
                                          valueTwo:[param objectForKey:@"cat_id"]];
			
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			[infoArray addObject:[infoDic objectForKey:@"uid"]];
			[infoArray addObject:[infoDic objectForKey:@"level"]];
			//[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[NSNumber numberWithInt: catId]];
			[infoArray addObject:[infoDic objectForKey:@"title"]];
			[infoArray addObject:[infoDic objectForKey:@"desc"]];
			[infoArray addObject:[infoDic objectForKey:@"tel"]];
			[infoArray addObject:[infoDic objectForKey:@"pic"]];
			[infoArray addObject:@""];
			[infoArray addObject:[infoDic objectForKey:@"addr"]];
			[infoArray addObject:[infoDic objectForKey:@"lng"]];
			[infoArray addObject:[infoDic objectForKey:@"lat"]];
			[infoArray addObject:[infoDic objectForKey:@"attestation"]];
			[infoArray addObject:[infoDic objectForKey:@"updatetime"]];
            [infoArray addObject:[infoDic objectForKey:@"about_us_title"]];
            [infoArray addObject:[infoDic objectForKey:@"my_product_title"]];
            [infoArray addObject:[infoDic objectForKey:@"app_name"]];
            [infoArray addObject:[infoDic objectForKey:@"app_image"]];
            [infoArray addObject:[infoDic objectForKey:@"iphone_url"]];
//            [infoArray addObject:@"简介"];
//            [infoArray addObject:@"我的产品"];
//            [infoArray addObject:@"道森媒体"];
//            [infoArray addObject:@""];
//            [infoArray addObject:@"http://www.baidu.com"];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_SHOP];
			
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//保证数据只有20条
	NSMutableArray *shopItems = (NSMutableArray *)[DBOperate queryData:T_SHOP theColumn:@"cat_id" theColumnValue:[NSString stringWithFormat:@"%d",catId] withAll:NO];
	
	for (int i = [shopItems count] - 1; i > 19; i--)
	{
		NSArray *shopArray = [shopItems objectAtIndex:i];
		NSString *shopId = [shopArray objectAtIndex:shop_id];
		[DBOperate deleteData:T_SHOP tableColumn:@"id" columnValue:shopId];
	}
	
	//更新版本号
	if (catId == 0)
	{
		[self updateVersion:OPERAT_SHOP_REFRESH versionID:newVer desc:@"单位"];
	}
	else
	{
		[DBOperate updateData:T_SHOP_CAT 
				  tableColumn:@"version" 
				  columnValue:[NSString stringWithFormat:@"%@",newVer] 
			  conditionColumn:@"id"
		 conditionColumnValue:[NSString stringWithFormat:@"%d",catId]];
	}
	
	return nil;
}

//商铺分类
+(NSMutableArray*)parseShopCatList:(NSString*)jsonResult getVersion:(int*)ver
{
	*ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"cats"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_SHOP_CAT 
					  tableColumn:@"id" 
					  columnValue:delID];
			
			//删除对应的内容数据
			[DBOperate deleteData:T_SHOP
					  tableColumn:@"cat_id" 
					  columnValue:delID];
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			[infoArray addObject:[infoDic objectForKey:@"name"]];
			[infoArray addObject:[infoDic objectForKey:@"order"]];
			[infoArray addObject:@"0"];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_SHOP_CAT];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//更新版本号
	[self updateVersion:OPERAT_SHOP_CAT_REFRESH versionID:newVer desc:@"单位分类"];
	
	return nil;
}

//商铺更多
+(NSMutableArray*)parseShopMoreList:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param
{
	*ver = NO_UPDATE;
	
	int catId = [[param objectForKey:@"cat_id"] intValue];
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	
	//插入数据
	NSMutableArray *moreArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"uid"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"level"]]];
			//[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt: catId]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pic"]]];
			[infoArray addObject:@""];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"addr"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"lng"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"lat"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"attestation"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"updatetime"]]];
            
            // dufu add 2013.05.02
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"about_us_title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"my_product_title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"app_name"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"app_image"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"iphone_url"]]];
			
			[moreArray insertObject:infoArray atIndex:i];
			[infoArray release];
			
		}
		*ver = NEED_UPDATE;
	}
	
	return [moreArray autorelease];
	
}

//关于我们
+(NSMutableArray*)parseAboutUsList:(NSString*)jsonResult getVersion:(int*)ver
{
	*ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
    
    //版本号
	NSNumber *newVer;
	
	//关于我们数据
	NSDictionary *shopDic = [resultDic objectForKey:@"body"];
	
	if (shopDic != nil && [shopDic count] > 0)
	{
		if ([shopDic objectForKey:@"id"] != nil) 
		{
			//删除原来数据
			[DBOperate deleteData:T_ABOUTUS_INFO];
			
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[shopDic objectForKey:@"id"]];
			[infoArray addObject:[shopDic objectForKey:@"companyname"]];
			[infoArray addObject:[shopDic objectForKey:@"url"]];
			[infoArray addObject:[shopDic objectForKey:@"addr"]];
			[infoArray addObject:[shopDic objectForKey:@"content"]];
			[infoArray addObject:[shopDic objectForKey:@"logo"]];
			[infoArray addObject:@""];
			[infoArray addObject:[shopDic objectForKey:@"contact"]];
			[infoArray addObject:[shopDic objectForKey:@"tel"]];
			[infoArray addObject:[shopDic objectForKey:@"mobile"]];
			[infoArray addObject:[shopDic objectForKey:@"fax"]];
			[infoArray addObject:[shopDic objectForKey:@"mail"]];
            [infoArray addObject:[shopDic objectForKey:@"lng"]];
            [infoArray addObject:[shopDic objectForKey:@"lat"]];
            
            // dufu add 2013.05.02
            [infoArray addObject:[shopDic objectForKey:@"weibo"]];
            
			
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_ABOUTUS_INFO];
			
			[infoArray release];
			
			*ver = NEED_UPDATE;
		}
		
		//更新版本号
		newVer = [shopDic objectForKey:@"ver"];
		[self updateVersion:OPERAT_ABOUTUS_INFO versionID:newVer desc:@"关于我们"];
	}
	
	return nil;
}

//发送评论 以及收藏 
+(NSMutableArray*)parseSendCommentAndFavorite:(NSString*)jsonResult getVersion:(int*)ver
{
	*ver = NEED_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	NSString *numStr = [resultDic objectForKey:@"num"];
	NSMutableArray *array = [[NSMutableArray alloc]init];
	[array addObject:[resultDic objectForKey:@"ret"]];
    if (numStr != nil) {
        [array addObject:numStr];
    }
	return array;
	
}

//商铺信息
+(NSMutableArray*)parseShopInfo:(NSString*)jsonResult getVersion:(int*)ver
{
	*ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//关于我们数据
	NSDictionary *shopDic = [resultDic objectForKey:@"body"];
	
	NSMutableArray *shopArray = [[NSMutableArray alloc]init];
	
	if (shopDic != nil && [shopDic count] > 0)
	{
		
		NSMutableArray *infoArray = [[NSMutableArray alloc]init];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"id"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"uid"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"level"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"catid"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"title"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"desc"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"tel"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"pic"]]];
		[infoArray addObject:@""];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"addr"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"lng"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"lat"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"attestation"]]];
		[infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"updatetime"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"about_us_title"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"my_product_title"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"app_name"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"app_image"]]];
        [infoArray addObject:[NSString stringWithFormat:@"%@",[shopDic objectForKey:@"iphone_url"]]];
		
		[shopArray addObject:infoArray];
		[infoArray release];
		
		*ver = NEED_UPDATE;
		
	}
	
	return [shopArray autorelease];
}

//商铺供应
+(NSMutableArray*)parseShopSupply:(NSString*)jsonResult getVersion:(int*)ver
{
	*ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//插入数据
	NSMutableArray *supplyArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"catid"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"price"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"companyid"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"companyname"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pic"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"favorite"]]];
			[infoArray addObject:@""];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"updatetime"]]];
			
			//保存图片数据
			NSMutableArray *supplyPicArray = [[NSMutableArray alloc]init];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (int j = 0; j < [picArray count]; j++ ) 
			{
				NSDictionary *picDic = [picArray objectAtIndex:j];
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:@""];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
				[supplyPicArray insertObject:pic atIndex:j];
				[pic release];
			}
			[infoArray addObject:supplyPicArray];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
            [infoArray addObject:[infoDic objectForKey:@"comment"]];
			
			[supplyArray insertObject:infoArray atIndex:i];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	return [supplyArray autorelease];
	
}

//商铺求购
+(NSMutableArray*)parseShopDemand:(NSString*)jsonResult getVersion:(int*)ver
{
	*ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//插入数据
	NSMutableArray *demandArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"catid"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"contact"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
			[infoArray addObject:@""];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"updatetime"]]];
			
			//保存图片数据
			NSMutableArray *demandPicArray = [[NSMutableArray alloc]init];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (int j = 0; j < [picArray count]; j++ ) 
			{
				NSDictionary *picDic = [picArray objectAtIndex:j];
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
				[demandPicArray insertObject:pic atIndex:j];
				[pic release];
			}
			[infoArray addObject:demandPicArray];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
            [infoArray addObject:[infoDic objectForKey:@"comment"]];
			
			[demandArray insertObject:infoArray atIndex:i];
			[infoArray release];
			
		}
		*ver = NEED_UPDATE;
	}
	
	return [demandArray autorelease];
	
}

//推荐供应
+(NSMutableArray*)parseSupplyRecommendList:(NSString*)jsonResult getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_SUPPLY_RECOMMEND
					  tableColumn:@"id" 
					  columnValue:delID];
			
			//删除对应的图片记录
			[DBOperate deleteData:T_SUPPLY_PIC_RECOMMEND
					  tableColumn:@"supply_id" 
					  columnValue:delID];
			
			//这里还要删除缓存图片 后面再做...
			
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[infoDic objectForKey:@"title"]];
			[infoArray addObject:[infoDic objectForKey:@"desc"]];
			[infoArray addObject:[infoDic objectForKey:@"price"]];
			[infoArray addObject:[infoDic objectForKey:@"companyid"]];
			[infoArray addObject:[infoDic objectForKey:@"companyname"]];
			[infoArray addObject:[infoDic objectForKey:@"tel"]];
			[infoArray addObject:[infoDic objectForKey:@"pic"]];
			[infoArray addObject:[infoDic objectForKey:@"favorite"]];
			[infoArray addObject:@""];
			[infoArray addObject:[infoDic objectForKey:@"updatetime"]];
			[infoArray addObject:@""];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
            [infoArray addObject:[infoDic objectForKey:@"comment"]];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_SUPPLY_RECOMMEND];
			
			//图片入库
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (NSDictionary *picDic in picArray ) 
			{
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
                [pic addObject:[infoDic objectForKey:@"catid"]];
				[DBOperate insertData:pic tableName:T_SUPPLY_PIC_RECOMMEND];
				[pic release];
			}
			
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//保证数据只有20条
	NSMutableArray *supplyItems = (NSMutableArray *)[DBOperate queryData:T_SUPPLY_RECOMMEND theColumn:@"" theColumnValue:@"" withAll:YES];
	
	for (int i = [supplyItems count] - 1; i > 19; i--)
	{
		NSArray *supplyArray = [supplyItems objectAtIndex:i];
		NSString *supplyId = [supplyArray objectAtIndex:supply_id];
		[DBOperate deleteData:T_SUPPLY_RECOMMEND tableColumn:@"id" columnValue:supplyId];
		
		//删除对应的图片记录
		[DBOperate deleteData:T_SUPPLY_PIC_RECOMMEND
				  tableColumn:@"supply_id" 
				  columnValue:supplyId];
        
        //这里还要删除缓存图片 后面再做...
	}
	
	
	//更新版本号
    [self updateVersion:OPERAT_SUPPLY_RECOMMEND_REFRESH versionID:newVer desc:@"推荐供应"];
	
	return nil;
}

//推荐供应更多
+(NSMutableArray*)parseSupplyRecommendMoreList:(NSString*)jsonResult getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	
	//插入数据
	NSMutableArray *moreArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"price"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"companyid"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"companyname"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pic"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"favorite"]]];
			[infoArray addObject:@""];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"updatetime"]]];
			
			//保存图片数据
			NSMutableArray *morePicArray = [[NSMutableArray alloc]init];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (int j = 0; j < [picArray count]; j++ ) 
			{
				NSDictionary *picDic = [picArray objectAtIndex:j];
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:@""];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
                [pic addObject:[infoDic objectForKey:@"catid"]];
				[morePicArray insertObject:pic atIndex:j];
				[pic release];
			}
			[infoArray addObject:morePicArray];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
			
			[moreArray insertObject:infoArray atIndex:i];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	return [moreArray autorelease];
	
}

//推荐求购
+(NSMutableArray*)parseDemandRecommendList:(NSString*)jsonResult getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_DEMAND_RECOMMEND
					  tableColumn:@"id" 
					  columnValue:delID];
			
			//删除对应的图片记录
			[DBOperate deleteData:T_DEMAND_PIC_RECOMMEND
					  tableColumn:@"demand_id" 
					  columnValue:delID];
			
			//这里还要删除缓存图片 后面再做...
			
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[infoDic objectForKey:@"title"]];
			[infoArray addObject:[infoDic objectForKey:@"desc"]];
			[infoArray addObject:[infoDic objectForKey:@"contact"]];
			[infoArray addObject:[infoDic objectForKey:@"tel"]];
			[infoArray addObject:@""];
			[infoArray addObject:[infoDic objectForKey:@"updatetime"]];
			[infoArray addObject:@""];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
            [infoArray addObject:[infoDic objectForKey:@"comment"]];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_DEMAND_RECOMMEND];
			
			//图片入库
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (NSDictionary *picDic in picArray ) 
			{
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
                [pic addObject:[infoDic objectForKey:@"catid"]];
				[DBOperate insertData:pic tableName:T_DEMAND_PIC_RECOMMEND];
				[pic release];
			}
			
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//保证数据只有20条
	NSMutableArray *demandItems = (NSMutableArray *)[DBOperate queryData:T_DEMAND_RECOMMEND theColumn:@"" theColumnValue:@"" withAll:YES];
	
	for (int i = [demandItems count] - 1; i > 19; i--)
	{
		NSArray *demandArray = [demandItems objectAtIndex:i];
		NSString *demandId = [demandArray objectAtIndex:demand_id];
		[DBOperate deleteData:T_DEMAND_RECOMMEND tableColumn:@"id" columnValue:demandId];
		
		//删除对应的图片记录
		[DBOperate deleteData:T_DEMAND_PIC_RECOMMEND
				  tableColumn:@"demand_id" 
				  columnValue:demandId];
	}
	
	
	//更新版本号
    [self updateVersion:OPERAT_DEMAND_RECOMMEND_REFRESH versionID:newVer desc:@"推荐求购"];
	
	return nil;
}

//推荐求购更多
+(NSMutableArray*)parseDemandRecommendMoreList:(NSString*)jsonResult getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	
	//插入数据
	NSMutableArray *moreArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"contact"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
			[infoArray addObject:@""];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"updatetime"]]];
			
			//保存图片数据
			NSMutableArray *morePicArray = [[NSMutableArray alloc]init];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (int j = 0; j < [picArray count]; j++ ) 
			{
				NSDictionary *picDic = [picArray objectAtIndex:j];
				NSMutableArray *pic = [[NSMutableArray alloc] init];
                [pic addObject:@""];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
                [pic addObject:[infoDic objectForKey:@"catid"]];
				[morePicArray insertObject:pic atIndex:j];
				[pic release];
			}
			[infoArray addObject:morePicArray];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
			
			[moreArray insertObject:infoArray atIndex:i];
			[infoArray release];
			
		}
		*ver = NEED_UPDATE;
	}
	
	return [moreArray autorelease];
    
}

//搜索供应
+(NSMutableArray*)parseSearchSupply:(NSString*)jsonResult getVersion:(int*)ver{
	*ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//插入数据
	NSMutableArray *supplyArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"catid"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"price"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"companyid"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"companyname"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pic"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"favorite"]]];
			[infoArray addObject:@""];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"updatetime"]]];
			
			//保存图片数据
			NSMutableArray *supplyPicArray = [[NSMutableArray alloc]init];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (int j = 0; j < [picArray count]; j++ ) 
			{
				NSDictionary *picDic = [picArray objectAtIndex:j];
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:@""];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"pic1"]];
				[pic addObject:@""];
				[pic addObject:[picDic objectForKey:@"pic2"]];
				[pic addObject:@""];
				[supplyPicArray insertObject:pic atIndex:j];
				[pic release];
			}
			[infoArray addObject:supplyPicArray];
            [infoArray addObject:[infoDic objectForKey:@"recommend"]];
			
			[supplyArray insertObject:infoArray atIndex:i];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	return [supplyArray autorelease];
	
}

//搜索商铺
+(NSMutableArray*)parseSearchShop:(NSString*)jsonResult getVersion:(int*)ver{		
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	
	//插入数据
	NSMutableArray *shopArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"uid"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"level"]]];
			[infoArray addObject:[infoDic objectForKey:@"catid"]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pic"]]];
			[infoArray addObject:@""];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"addr"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"lng"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"lat"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"attestation"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"updatetime"]]];
            
            // dufu add 2013.05.06
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"about_us_title"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"my_product_title"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"app_name"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"app_image"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"iphone_url"]]];
			
			[shopArray insertObject:infoArray atIndex:i];
			[infoArray release];
			
		}
		*ver = NEED_UPDATE;
	}
	
	return [shopArray autorelease];
}

+(NSMutableArray*)parseAPNS:(NSString*)jsonResult 
{
	NSDictionary *resultDic = [jsonResult JSONValue];
	//NSLog(@"resultDic====%@",resultDic);
	NSMutableArray *resultArray = [[NSMutableArray alloc] init];
	[resultArray addObject:[resultDic objectForKey:@"isSuccess"]];
	[resultArray addObject:[resultDic objectForKey:@"info"]];
    NSString *mobile = [resultDic objectForKey:@"mobile"];
    if (mobile != nil) {
        [resultArray addObject:mobile];
        
        NSArray *arr = [[NSArray alloc] initWithObjects:mobile, nil];
        [DBOperate deleteData:T_PHONENUM];
        [DBOperate insertData:arr tableName:T_PHONENUM];
    }
    
    NSDictionary *appVerDic = [resultDic objectForKey:@"autopromotion"];
	NSDictionary *appVerGradeDic = [resultDic objectForKey:@"grade"];
	if (appVerDic != nil && [appVerDic count] > 0) {
		[DBOperate deleteData:T_APP_INFO tableColumn:@"type" columnValue:[NSNumber numberWithInt:0]];
		
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[array addObject:[NSNumber numberWithInt:0]];
		[array addObject:[appVerDic objectForKey:@"promote_ver"]];
		[array addObject:[appVerDic objectForKey:@"url"]];
		[array addObject:[NSNumber numberWithInt:0]];
        [array addObject:[appVerDic objectForKey:@"remark"]];
		[DBOperate insertDataWithnotAutoID:array tableName:T_APP_INFO];
		[array release];
	}
	if (appVerGradeDic != nil && [appVerGradeDic count] > 0) {
		[DBOperate deleteData:T_APP_INFO tableColumn:@"type" columnValue:[NSNumber numberWithInt:1]];
		
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[array addObject:[NSNumber numberWithInt:1]];
		[array addObject:[appVerGradeDic objectForKey:@"grade_ver"]];
		[array addObject:[appVerGradeDic objectForKey:@"url"]];
		[array addObject:[NSNumber numberWithInt:0]];
        [array addObject:@""];
		[DBOperate insertDataWithnotAutoID:array tableName:T_APP_INFO];
	}

	return [resultArray autorelease];
}

+(NSMutableArray*)parsePV:(NSString*)jsonResult 
{
	NSDictionary *resultDic = [jsonResult JSONValue];
	//NSLog(@"resultDic====%@",resultDic);
	
	return nil;
}

//最新会员
+(NSMutableArray*)parseNewestMemberList:(NSString*)jsonResult getVersion:(int*)ver;
{
    *ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_NEWEST_MEMBER
					  tableColumn:@"id" 
					  columnValue:delID];
			
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
            
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[infoDic objectForKey:@"id"]];
            [infoArray addObject:[infoDic objectForKey:@"user_id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"user_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"gender"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"post"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"company_name"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"mobile"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"fax"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"email"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"cat_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"cat_id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"province"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"city"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"district"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"addr"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"img"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"created"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"url"]]];
			
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_NEWEST_MEMBER];
			
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//保证数据只有20条
	NSMutableArray *memberItems = (NSMutableArray *)[DBOperate queryData:T_NEWEST_MEMBER theColumn:@"" theColumnValue:@"" withAll:YES];
	
	for (int i = [memberItems count] - 1; i > 19; i--)
	{
		NSArray *memberArray = [memberItems objectAtIndex:i];
		NSString *memberId = [memberArray objectAtIndex:newest_member_id];
		[DBOperate deleteData:T_NEWEST_MEMBER tableColumn:@"id" columnValue:memberId];
	}
	
	//更新版本号
    [self updateVersion:OPERAT_NEWEST_MEMBER_REFRESH versionID:newVer desc:@"最新会员"];
	
	return nil;
}

//通讯录
+(NSMutableArray*)parseContactsBookList:(NSString*)jsonResult getVersion:(int*)ver
{	
    *ver = 0;
    
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
    
    //数据是否已经load完
	NSNumber *complete = [resultDic objectForKey:@"complete"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_CONTACTS_BOOK
					  tableColumn:@"id" 
					  columnValue:delID];
			
		}
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
            
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[infoDic objectForKey:@"id"]];
            [infoArray addObject:[infoDic objectForKey:@"user_id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"user_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"gender"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"post"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"company_name"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"mobile"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"fax"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"email"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"cat_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"cat_id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"province"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"city"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"district"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"addr"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"img"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"created"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"url"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pinyin"]]];
			
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_CONTACTS_BOOK];
			
			[infoArray release];
		}
        
        if ([complete intValue] == 0) 
        {
            *ver = 0;
        }
        else 
        {
            //最后一条记录ID
            NSDictionary *lastInfoDic = [listArray objectAtIndex:[listArray count]-1];
            *ver = [[lastInfoDic objectForKey:@"id"] intValue];
        }
	}
	
	//更新版本号
    [self updateVersion:OPERAT_CONTACTS_BOOK_REFRESH versionID:newVer desc:@"通讯录"];
	
	return nil;
}

//通讯录分类
+(NSMutableArray*)parseContactsBookCatList:(NSString*)jsonResult getVersion:(int*)ver
{
	*ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"cats"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_CONTACTS_BOOK_CAT
					  tableColumn:@"id"
					  columnValue:delID];
			
			//删除对应的内容数据
            /*
			[DBOperate deleteData:T_CONTACTS_BOOK
					  tableColumn:@"cat_id"
					  columnValue:delID];
             */
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0)
	{
		for (int i = 0; i < [listArray count];i++ )
		{
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			[infoArray addObject:[infoDic objectForKey:@"name"]];
            [infoArray addObject:[infoDic objectForKey:@"parent_id"]];
			[infoArray addObject:[infoDic objectForKey:@"order"]];
			[infoArray addObject:@"0"];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_CONTACTS_BOOK_CAT];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//更新版本号
	[self updateVersion:OPERAT_CONTACTS_BOOK_CAT_REFRESH versionID:newVer desc:@"通讯录分类"];
	
	return nil;
}


//搜索会员
+(NSMutableArray*)parseSearchMember:(NSString*)jsonResult getVersion:(int*)ver;
{
    
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	
	//插入数据
	NSMutableArray *memberArray = [[NSMutableArray alloc] init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[infoDic objectForKey:@"id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"user_id"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"user_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"gender"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"post"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"company_name"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"mobile"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"fax"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"email"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"cat_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"cat_id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"province"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"city"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"district"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"addr"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"img"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"created"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"url"]]];
			
			[memberArray insertObject:infoArray atIndex:i];
			[infoArray release];
			
		}
		*ver = NEED_UPDATE;
	}
	
	return [memberArray autorelease];
}

//会员详情
+(NSMutableArray*)parseCardDetail:(NSString*)jsonResult getVersion:(int*)ver
{
    
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//插入数据
	NSMutableArray *memberArray = [[NSMutableArray alloc] init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[infoDic objectForKey:@"id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"user_id"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"user_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"gender"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"post"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"company_name"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"mobile"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"fax"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"email"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"cat_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"cat_id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"province"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"city"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"district"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"addr"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"img"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"created"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"url"]]];
			
			[memberArray insertObject:infoArray atIndex:i];
			[infoArray release];
			
		}
		*ver = NEED_UPDATE;
        return [memberArray autorelease];
	}
    else 
    {
        return nil;
    }
    
}

//更多
+ (NSMutableArray*)parseMoreCat:(NSString*)jsonResult getVersion:(int*)ver
{
    NSDictionary *resultDic = [jsonResult JSONValue];
    //NSLog(@"resultDic===%@",resultDic);
    
    NSArray *infoArray = [resultDic objectForKey:@"cats"];
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	*ver = NEED_UPDATE;
	
	if (delsArray != nil) {
		for (int i = 0;i < [delsArray count] ;i++ ) {
			NSDictionary *dic = [delsArray objectAtIndex:i];
			NSNumber *temp = [dic objectForKey:@"id"];
			[DBOperate deleteData:T_MORE_CAT tableColumn:@"catId" columnValue:temp];
		}
	}
    
	NSMutableArray *resultArray =[[NSMutableArray alloc] init];
	if (infoArray != nil) {
		for (NSDictionary *infoDic in infoArray) {
			NSMutableArray *infoList = [[NSMutableArray alloc]init];
			//[infoList addObject:@""];
			[infoList addObject:[infoDic objectForKey:@"id"]];
			[DBOperate deleteData:T_MORE_CAT tableColumn:@"catId" columnValue:[infoDic objectForKey:@"id"]];
			[infoList addObject:[infoDic objectForKey:@"name"]];
			[infoList addObject:[infoDic objectForKey:@"img"]];
			[infoList addObject:@""];
            [infoList addObject:@"0"];
            
			[resultArray addObject:infoList];
            //[DBOperate insertDataWithnotAutoID:infoList tableName:T_MORE_CAT];
            [DBOperate insertData:infoList tableName:T_MORE_CAT];
			[infoList release];
        }
	}	
    
    [self updateVersion:MORE_CAT_COMMAND_ID versionID:[resultDic objectForKey:@"ver"] desc:@"更多"];
    
    return [resultArray autorelease];
}

+ (NSMutableArray*)parseMoreCatInfo:(NSString*)jsonResult getVersion:(int*)ver withCatId:(int)_catId
{
    NSDictionary *resultDic = [jsonResult JSONValue];
    
    NSArray *infoArray = [resultDic objectForKey:@"infos"];
    NSArray *delsArray = [resultDic objectForKey:@"dels"];
    *ver = NEED_UPDATE;
    
    if (delsArray != nil) {
        for (int i = 0;i < [delsArray count] ;i++ ) {
            NSDictionary *dic = [delsArray objectAtIndex:i];
            NSNumber *temp = [dic objectForKey:@"id"];
            [DBOperate deleteData:T_MORE_CATINFO tableColumn:@"cat_Id" columnValue:temp];
        }
    }
    
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    if (infoArray != nil) {
        for (NSDictionary *infoDic in infoArray) {
            NSMutableArray *infoList = [[NSMutableArray alloc]init];
            [infoList addObject:[infoDic objectForKey:@"id"]];
            [DBOperate deleteData:T_MORE_CATINFO tableColumn:@"cat_Id" columnValue:[infoDic objectForKey:@"id"]];
            [infoList addObject:[infoDic objectForKey:@"cat_id"]];
            [infoList addObject:[infoDic objectForKey:@"img"]];
            [infoList addObject:@""];
            [infoList addObject:[infoDic objectForKey:@"desc"]];
            [infoList addObject:[infoDic objectForKey:@"sort_order"]];
            [infoList addObject:[infoDic objectForKey:@"updatetime"]];
            
            [resultArray addObject:infoList];
            //[DBOperate insertDataWithnotAutoID:infoList tableName:T_MORE_CAT];
            [DBOperate insertData:infoList tableName:T_MORE_CATINFO];
            [infoList release];
        }
    }	
    
    [DBOperate updateData:T_MORE_CAT tableColumn:@"version" columnValue:[resultDic objectForKey:@"ver"] conditionColumn:@"catId" conditionColumnValue:[NSString stringWithFormat:@"%d",_catId]];
    return [resultArray autorelease];
}

//留言人员列表
+ (NSMutableArray*)parseMessageList:(NSString*)jsonResult getVersion:(int*)ver
{
    NSDictionary *resultDic = [jsonResult JSONValue];
    //NSLog(@"resultDic===%@",resultDic);
    
    NSArray *infoArray = [resultDic objectForKey:@"infos"];
    *ver = NEED_UPDATE;
    
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    if (infoArray != nil) {
        for (NSDictionary *infoDic in infoArray) {
            NSMutableArray *infoList = [[NSMutableArray alloc]init];
            //[infoList addObject:@""];
            [infoList addObject:[infoDic objectForKey:@"source"]];
            [infoList addObject:[infoDic objectForKey:@"img"]];
            [infoList addObject:[infoDic objectForKey:@"name"]];
            [infoList addObject:[infoDic objectForKey:@"content"]];
            [infoList addObject:[infoDic objectForKey:@"created"]];
            [infoList addObject:[infoDic objectForKey:@"num"]];
            
            [resultArray addObject:infoList];
            [infoList release];
        }
    }	
    
    //[self updateVersion:MORE_CAT_INFO_COMMAND_ID versionID:[resultDic objectForKey:@"ver"] desc:@"更多 info"];
    return [resultArray autorelease];
}

//留言详情
+ (NSMutableArray*)parseMessageDetail:(NSString*)jsonResult getVersion:(int*)ver
{
    NSDictionary *resultDic = [jsonResult JSONValue];
    //NSLog(@"resultDic===%@",resultDic);
    
    NSArray *infoArray = [resultDic objectForKey:@"infos"];
    *ver = NEED_UPDATE;
    
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    if (infoArray != nil) {
        for (NSDictionary *infoDic in infoArray) {
            NSMutableArray *infoList = [[NSMutableArray alloc]init];
            [infoList addObject:[infoDic objectForKey:@"id"]];
            [infoList addObject:[infoDic objectForKey:@"source"]];
            [infoList addObject:[infoDic objectForKey:@"destination"]];
            [infoList addObject:[infoDic objectForKey:@"content"]];
            [infoList addObject:[infoDic objectForKey:@"created"]];
            
            [resultArray insertObject:infoList atIndex:0];
            [infoList release];
        }
    }	
    
    //[self updateVersion:MORE_CAT_INFO_COMMAND_ID versionID:[resultDic objectForKey:@"ver"] desc:@"更多 info"];
    return [resultArray autorelease];
}
//发送留言
+ (NSMutableArray*)parseMessageSend:(NSString*)jsonResult getVersion:(int*)ver
{
    NSDictionary *resultDic = [jsonResult JSONValue];
    //NSLog(@"resultDic===%@",resultDic);
    NSString *retStr = [resultDic objectForKey:@"ret"];
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    [resultArray addObject:retStr];
    return [resultArray autorelease];
}

//我的名片夹
+ (NSMutableArray*)parseFavoriteBooksList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId
{	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
    
    //数据是否已经load完
	NSNumber *complete = [resultDic objectForKey:@"complete"];
    *ver = [complete intValue];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_CONTACTSBOOK_FAVORITE
					  tableColumn:@"id" 
					  columnValue:delID];
			
		}
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[infoDic objectForKey:@"id"]];
            //[DBOperate deleteData:T_CONTACTSBOOK_FAVORITE tableColumn:@"id" columnValue:[infoDic objectForKey:@"id"]];
            [DBOperate deleteDataWithTwoConditions:T_CONTACTSBOOK_FAVORITE columnOne:@"id" valueOne:[infoDic objectForKey:@"id"] columnTwo:@"memberId" valueTwo:[NSString stringWithFormat:@"%d",_memberId]];
            
            [infoArray addObject:[infoDic objectForKey:@"user_id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"user_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"gender"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"post"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"company_name"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"tel"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"mobile"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"fax"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"email"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"cat_name"]]];
            [infoArray addObject:[infoDic objectForKey:@"cat_id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"province"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"city"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"district"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"addr"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"img"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"created"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"url"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pinyin"]]];
            [infoArray addObject:[NSNumber numberWithInt:_memberId]];
			
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_CONTACTSBOOK_FAVORITE];
			
			[infoArray release];
		}
	}
	//更新版本号
	[self updateMemberVersion:MEMBER_FAVRITEBOOKLIST_COMMAND_ID memberId:_memberId versionID:newVer desc:@"我的名片夹"];
	return nil;
}

//推荐应用
+ (NSMutableArray*)parseRecommendApp:(NSString*)jsonResult getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
			[DBOperate deleteData:T_RECOMMEND_APP
					  tableColumn:@"id" 
					  columnValue:delID];
			
		}
		*ver = NEED_UPDATE;
	}
	
	//保存数据
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count];i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
            
            NSDictionary *infoDic = [listArray objectAtIndex:i];
            NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[infoDic objectForKey:@"id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"name"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"url"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"icon"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
            [infoArray addObject:[infoDic objectForKey:@"order"]];
            
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_RECOMMEND_APP];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//保证数据只有20条
	NSMutableArray *recommendAppItems = (NSMutableArray *)[DBOperate queryData:T_RECOMMEND_APP theColumn:@"" theColumnValue:@"" withAll:YES];
	
	for (int i = [recommendAppItems count] - 1; i > 19; i--)
	{
		NSArray *recommendAppArray = [recommendAppItems objectAtIndex:i];
		NSString *recommendAppId = [recommendAppArray objectAtIndex:recommand_app_id];
		[DBOperate deleteData:T_RECOMMEND_APP tableColumn:@"id" columnValue:recommendAppId];
	}
	
	//更新版本号
    [self updateVersion:OPERAT_RECOMMEND_APP_REFRESH versionID:newVer desc:@"推荐应用"];
	
	return nil;
}

//推荐应用更多
+ (NSMutableArray*)parseRecommendAppMore:(NSString*)jsonResult getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	
	//插入数据
	NSMutableArray *moreArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0) 
	{
		for (int i = 0; i < [listArray count]; i++ ) 
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[infoDic objectForKey:@"id"]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"name"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"url"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"icon"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
            [infoArray addObject:[infoDic objectForKey:@"order"]];
			[moreArray insertObject:infoArray atIndex:i];
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	return [moreArray autorelease];
	
}

//近期活动
+ (NSMutableArray*)parseActivity:(NSString*)jsonResult getVersion:(int*)ver
{
    *ver = NO_UPDATE;

	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
            
			[DBOperate deleteData:T_ACTIVITY
					  tableColumn:@"id"
					  columnValue:delID];

			//删除对应的图片记录
			[DBOperate deleteData:T_ACTIVITY_PIC
					  tableColumn:@"activity_id"
					  columnValue:delID];
            
            //删除对应的用户上传图片记录
			[DBOperate deleteData:T_ACTIVITY_USER_PIC
					  tableColumn:@"activity_id"
					  columnValue:delID];
			
			//这里还要删除缓存图片 后面再做...
            
            [DBOperate deleteData:T_ACTIVITY_HISTORY
                      tableColumn:@"id"
                      columnValue:delID];
            
            //删除对应的图片记录
			[DBOperate deleteData:T_ACTIVITY_HISTORY_PIC
					  tableColumn:@"activity_id"
					  columnValue:delID];
            
            //删除对应的用户上传图片记录
			[DBOperate deleteData:T_ACTIVITY_HISTORY_USER_PIC
					  tableColumn:@"activity_id"
					  columnValue:delID];
			
		}
		*ver = NEED_UPDATE;
	}
    
    //删除过期数据
    NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
    long long int currentTime = (long long int)cTime;
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where end_time < %lld",T_ACTIVITY,currentTime];
    [DBOperate querySql:sql];
    
    //删除过期图片数据数据,暂不做
	
	//保存数据
	if ([listArray count] > 0)
	{
		for (int i = 0; i < [listArray count];i++ )
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			[infoArray addObject:[infoDic objectForKey:@"title"]];
			[infoArray addObject:[infoDic objectForKey:@"organizer"]];
			[infoArray addObject:[infoDic objectForKey:@"address"]];
			[infoArray addObject:[infoDic objectForKey:@"point_lng"]];
			[infoArray addObject:[infoDic objectForKey:@"point_lat"]];
			[infoArray addObject:[infoDic objectForKey:@"reg_end_time"]];
			[infoArray addObject:[infoDic objectForKey:@"begin_time"]];
			[infoArray addObject:[infoDic objectForKey:@"end_time"]];
			[infoArray addObject:[infoDic objectForKey:@"activity_img_num"]];
			[infoArray addObject:[infoDic objectForKey:@"desc"]];
			[infoArray addObject:[infoDic objectForKey:@"phone"]];
            [infoArray addObject:[infoDic objectForKey:@"report_url"]];
            [infoArray addObject:[infoDic objectForKey:@"sum"]];
            [infoArray addObject:[infoDic objectForKey:@"interests"]];
            [infoArray addObject:[infoDic objectForKey:@"pic"]];
            [infoArray addObject:@""];
            [infoArray addObject:@""];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_ACTIVITY];
            
			
			//活动图片入库
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (NSDictionary *picDic in picArray )
			{
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"img_path"]];
				[pic addObject:[picDic objectForKey:@"thumb_pic"]];
				[DBOperate insertData:pic tableName:T_ACTIVITY_PIC];
				[pic release];
			}
            
            //用户上传图片入库
			NSArray *userPicArray = [infoDic objectForKey:@"activity_img"];
			for (NSDictionary *userPicDic in userPicArray)
			{
				NSMutableArray *userPic = [[NSMutableArray alloc] init];
                [userPic addObject:[userPicDic objectForKey:@"id"]];
				[userPic addObject:[infoDic objectForKey:@"id"]];
				[userPic addObject:[userPicDic objectForKey:@"img_path"]];
				[userPic addObject:[userPicDic objectForKey:@"thumb_pic"]];
                [userPic addObject:[userPicDic objectForKey:@"desc"]];
				[DBOperate insertDataWithnotAutoID:userPic tableName:T_ACTIVITY_USER_PIC];
				[userPic release];
			}
			
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//保证数据只有20条
	NSMutableArray *activityItems = [DBOperate queryData:T_ACTIVITY
                                                                  theColumn:@"" theColumnValue:@"" orderBy:@"id" orderType:@"desc" withAll:YES];
	
	for (int i = [activityItems count] - 1; i > 19; i--)
	{
		NSArray *activityArray = [activityItems objectAtIndex:i];
		NSString *activityId = [activityArray objectAtIndex:activity_id];
		[DBOperate deleteData:T_ACTIVITY tableColumn:@"id" columnValue:activityId];
		
		//删除对应的图片记录
		[DBOperate deleteData:T_ACTIVITY_PIC
				  tableColumn:@"activity_id"
				  columnValue:activityId];
        
        //删除对应用户上传的图片记录
		[DBOperate deleteData:T_ACTIVITY_USER_PIC
				  tableColumn:@"activity_id"
				  columnValue:activityId];
        
        //这里还要删除缓存图片 后面再做...
        
	}
	
	//更新版本号
    [self updateVersion:OPERAT_ACTIVITY_REFRESH versionID:newVer desc:@"近期活动"];
	
	return nil;
}

//近期活动更多
+ (NSMutableArray*)parseActivityMore:(NSString*)jsonResult getVersion:(int*)ver
{
    return nil;
}

//往期活动
+ (NSMutableArray*)parseActivityHistory:(NSString*)jsonResult getVersion:(int*)ver
{
    *ver = NO_UPDATE;
    
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//删除的数据
	NSArray *delsArray = [resultDic objectForKey:@"dels"];
	
	//删除数据
	if ([delsArray count] > 0)
	{
		for(NSDictionary *delDic in delsArray)
		{
			NSNumber *delID = [NSNumber numberWithInteger:[[delDic objectForKey:@"id"] intValue]];
            
			[DBOperate deleteData:T_ACTIVITY_HISTORY
					  tableColumn:@"id"
					  columnValue:delID];

			//删除对应的图片记录
			[DBOperate deleteData:T_ACTIVITY_HISTORY_PIC
					  tableColumn:@"activity_id"
					  columnValue:delID];
            
            //删除对应的用户上传图片记录
			[DBOperate deleteData:T_ACTIVITY_HISTORY_USER_PIC
					  tableColumn:@"activity_id"
					  columnValue:delID];
			
			//这里还要删除缓存图片 后面再做...
            
            [DBOperate deleteData:T_ACTIVITY
					  tableColumn:@"id"
					  columnValue:delID];
            
			//删除对应的图片记录
			[DBOperate deleteData:T_ACTIVITY_PIC
					  tableColumn:@"activity_id"
					  columnValue:delID];
            
            //删除对应的用户上传图片记录
			[DBOperate deleteData:T_ACTIVITY_USER_PIC
					  tableColumn:@"activity_id"
					  columnValue:delID];
			
		}
		*ver = NEED_UPDATE;
	} else {
        
    }
	
	//保存数据
	if ([listArray count] > 0)
	{
		for (int i = 0; i < [listArray count];i++ )
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
			[infoArray addObject:[infoDic objectForKey:@"id"]];
			[infoArray addObject:[infoDic objectForKey:@"title"]];
			[infoArray addObject:[infoDic objectForKey:@"organizer"]];
			[infoArray addObject:[infoDic objectForKey:@"address"]];
			[infoArray addObject:[infoDic objectForKey:@"point_lng"]];
			[infoArray addObject:[infoDic objectForKey:@"point_lat"]];
			[infoArray addObject:[infoDic objectForKey:@"reg_end_time"]];
			[infoArray addObject:[infoDic objectForKey:@"begin_time"]];
			[infoArray addObject:[infoDic objectForKey:@"end_time"]];
			[infoArray addObject:[infoDic objectForKey:@"activity_img_num"]];
			[infoArray addObject:[infoDic objectForKey:@"desc"]];
			[infoArray addObject:[infoDic objectForKey:@"phone"]];
            [infoArray addObject:[infoDic objectForKey:@"report_url"]];
            [infoArray addObject:[infoDic objectForKey:@"sum"]];
            [infoArray addObject:[infoDic objectForKey:@"interests"]];
            [infoArray addObject:[infoDic objectForKey:@"pic"]];
            [infoArray addObject:@""];
            [infoArray addObject:@""];
			//插入数据库
			[DBOperate insertDataWithnotAutoID:infoArray tableName:T_ACTIVITY_HISTORY];
            
			
			//活动图片入库
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (NSDictionary *picDic in picArray )
			{
				NSMutableArray *pic = [[NSMutableArray alloc] init];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"img_path"]];
				[pic addObject:[picDic objectForKey:@"thumb_pic"]];
				[DBOperate insertData:pic tableName:T_ACTIVITY_HISTORY_PIC];
				[pic release];
			}
            
            //用户上传图片入库
			NSArray *userPicArray = [infoDic objectForKey:@"activity_img"];
			for (NSDictionary *userPicDic in userPicArray)
			{
				NSMutableArray *userPic = [[NSMutableArray alloc] init];
                [userPic addObject:[userPicDic objectForKey:@"id"]];
				[userPic addObject:[infoDic objectForKey:@"id"]];
				[userPic addObject:[userPicDic objectForKey:@"img_path"]];
				[userPic addObject:[userPicDic objectForKey:@"thumb_pic"]];
                [userPic addObject:[userPicDic objectForKey:@"desc"]];
				[DBOperate insertDataWithnotAutoID:userPic tableName:T_ACTIVITY_HISTORY_USER_PIC];
				[userPic release];
			}
			
			[infoArray release];
		}
		*ver = NEED_UPDATE;
	}
	
	//保证数据只有20条
	NSMutableArray *activityItems = [DBOperate queryData:T_ACTIVITY_HISTORY
                                               theColumn:@"" theColumnValue:@"" orderBy:@"end_time" orderType:@"desc" withAll:YES];
	
	for (int i = [activityItems count] - 1; i > 19; i--)
	{
		NSArray *activityArray = [activityItems objectAtIndex:i];
		NSString *activityId = [activityArray objectAtIndex:activity_id];
		[DBOperate deleteData:T_ACTIVITY_HISTORY tableColumn:@"id" columnValue:activityId];
		
		//删除对应的图片记录
		[DBOperate deleteData:T_ACTIVITY_HISTORY_PIC
				  tableColumn:@"activity_id"
				  columnValue:activityId];
        
        //删除对应用户上传的图片记录
		[DBOperate deleteData:T_ACTIVITY_HISTORY_USER_PIC
				  tableColumn:@"activity_id"
				  columnValue:activityId];
        
        //这里还要删除缓存图片 后面再做...
        
	}
	
	//更新版本号
    [self updateVersion:OPERAT_ACTIVITY_HISTORY_REFRESH versionID:newVer desc:@"往期活动"];
	
	return nil;
}

//往期活动更多
+ (NSMutableArray*)parseActivityHistoryMore:(NSString*)jsonResult getVersion:(int*)ver
{
    *ver = NO_UPDATE;
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//插入数据
	NSMutableArray *moreArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0)
	{
		for (int i = 0; i < [listArray count]; i++ )
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"organizer"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"address"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"point_lng"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"point_lat"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"reg_end_time"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"begin_time"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"end_time"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"activity_img_num"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"phone"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"report_url"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"sum"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"interests"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pic"]]];
            
            //活动图片
            NSMutableArray *morePicArray = [[NSMutableArray alloc]init];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (int j = 0; j < [picArray count]; j++ )
			{
                NSDictionary *picDic = [picArray objectAtIndex:j];
				NSMutableArray *pic = [[NSMutableArray alloc] init];
                [pic addObject:@""];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"img_path"]];
				[pic addObject:[picDic objectForKey:@"thumb_pic"]];
				[morePicArray insertObject:pic atIndex:j];
				[pic release];
			}
            
            [infoArray addObject:morePicArray];
			
            
            //用户上传图片
            NSMutableArray *moreUserPicArray = [[NSMutableArray alloc]init];
			NSArray *userPicArray = [infoDic objectForKey:@"activity_img"];
            for (int k = 0; k < [userPicArray count]; k++)
			{
                NSDictionary *userPicDic = [userPicArray objectAtIndex:k];
				NSMutableArray *userPic = [[NSMutableArray alloc] init];
                [userPic addObject:[userPicDic objectForKey:@"id"]];
				[userPic addObject:[infoDic objectForKey:@"id"]];
				[userPic addObject:[userPicDic objectForKey:@"img_path"]];
				[userPic addObject:[userPicDic objectForKey:@"thumb_pic"]];
                [userPic addObject:[userPicDic objectForKey:@"desc"]];
				[moreUserPicArray insertObject:userPic atIndex:k];
				[userPic release];
			}
            
            [infoArray addObject:moreUserPicArray];
			
            [moreArray insertObject:infoArray atIndex:i];
			[infoArray release];
            
		}
		*ver = NEED_UPDATE;
	}
	
	return [moreArray autorelease];
	
}

//活动现场图片更多
+ (NSMutableArray*)parseActivityUserPicMore:(NSString*)jsonResult getVersion:(int*)ver withParam:(NSMutableDictionary*)param
{
    *ver = NO_UPDATE;
    
    NSString *activityId = [param objectForKey:@"activityId"];
	
	NSDictionary *resultDic = [jsonResult JSONValue];
	
	//版本号
	//NSNumber *newVer = [resultDic objectForKey:@"ver"];
	
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"activity_img"];
	
	//插入数据
	NSMutableArray *moreArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0)
	{
		for (int i = 0; i < [listArray count]; i++ )
		{
			//非空判断 例子
			//[infoArray addObject:[infoDic objectForKey:@"xxx"] == [NSNull null] ? @"" : [infoDic objectForKey:@"xxx"]];
			
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
            [infoArray addObject:activityId];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"img_path"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"thumb_pic"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
            [moreArray insertObject:infoArray atIndex:i];
			[infoArray release];
            
		}
		*ver = NEED_UPDATE;
	}
	
	return [moreArray autorelease];
}

//收藏名片
+ (NSMutableArray*)parseContactBooksFavorite:(NSString*)jsonResult getVersion:(int*)ver
{
    NSDictionary *resultDic = [jsonResult JSONValue];
    //NSLog(@"resultDic===%@",resultDic);
    NSString *retStr = [resultDic objectForKey:@"ret"];
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    [resultArray addObject:retStr];
    return [resultArray autorelease];
}

//留言反馈列表
+ (NSMutableArray*)parseFeedbackList:(NSString*)jsonResult getVersion:(int*)ver
{
    NSDictionary *resultDic = [jsonResult JSONValue];
    //NSLog(@"resultDic===%@",resultDic);
    
    NSArray *infoArray = [resultDic objectForKey:@"infos"];
    *ver = NEED_UPDATE;
    
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    if (infoArray != nil) {
        for (NSDictionary *infoDic in infoArray) {
            NSMutableArray *infoList = [[NSMutableArray alloc]init];
            [infoList addObject:[infoDic objectForKey:@"id"]];
            [infoList addObject:[infoDic objectForKey:@"source"]];
            [infoList addObject:[infoDic objectForKey:@"content"]];
            [infoList addObject:[infoDic objectForKey:@"created"]];
            
            //[resultArray insertObject:infoList atIndex:0];
            [resultArray addObject:infoList];
            [infoList release];
        }
    }
    
    return [resultArray autorelease];
}

//小秘书列表
+ (NSMutableArray*)parseSystemMessageList:(NSString*)jsonResult getVersion:(int*)ver withMemberId:(int)_memberId isInsert:(BOOL)yesORno
{
    NSDictionary *resultDic = [jsonResult JSONValue];
    //NSLog(@"resultDic===%@",resultDic);
    
    NSArray *infoArray = [resultDic objectForKey:@"infos"];
    NSArray *delsArray = [resultDic objectForKey:@"dels"];
	*ver = NEED_UPDATE;
	
	if (delsArray != nil) {
		for (int i = 0;i < [delsArray count] ;i++ ) {
			NSDictionary *dic = [delsArray objectAtIndex:i];
			NSNumber *temp = [dic objectForKey:@"id"];
			[DBOperate deleteData:T_SYSTEMMESSAGE tableColumn:@"id" columnValue:temp];
		}
	}
    
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    if (infoArray != nil) {
        for (NSDictionary *infoDic in infoArray) {
            NSMutableArray *infoList = [[NSMutableArray alloc]init];
            [infoList addObject:[infoDic objectForKey:@"id"]];
            [DBOperate deleteData:T_SYSTEMMESSAGE tableColumn:@"id" columnValue:[infoDic objectForKey:@"id"]];
            [infoList addObject:[NSNumber numberWithInt:_memberId]];
            [infoList addObject:[infoDic objectForKey:@"content"]];
            [infoList addObject:[infoDic objectForKey:@"url"]];
            [infoList addObject:[infoDic objectForKey:@"created"]];
            if (yesORno == YES) {
                [DBOperate insertDataWithnotAutoID:infoList tableName:T_SYSTEMMESSAGE];
            }
            [resultArray addObject:infoList];
            [infoList release];
        }
    }
    
    //保证数据只有20条
	NSMutableArray *items = (NSMutableArray *)[DBOperate queryData:T_SYSTEMMESSAGE theColumn:@"user_id" theColumnValue:[NSString stringWithFormat:@"%d",_memberId] withAll:NO];
	
	for (int i = [items count] - 1; i > 19; i--)
	{
		NSArray *itemArray = [items objectAtIndex:i];
		NSString *itemId = [itemArray objectAtIndex:systemMessage_id];
		[DBOperate deleteData:T_SYSTEMMESSAGE tableColumn:@"id" columnValue:itemId];
	}
    
    [self updateMemberVersion:SYSTEM_MESSAGE_COMMAND_ID memberId:_memberId versionID:[resultDic objectForKey:@"ver"] desc:@"小秘书列表 info"];
    return [resultArray autorelease];
}

//我参与的活动
+ (NSMutableArray*)parseMyActivityList:(NSString*)jsonResult
{
	NSDictionary *resultDic = [jsonResult JSONValue];
	//更新数据
	NSArray *listArray = [resultDic objectForKey:@"infos"];
	
	//插入数据
	NSMutableArray *moreArray = [[NSMutableArray alloc]init];
	
	if ([listArray count] > 0)
	{
		for (int i = 0; i < [listArray count]; i++ )
		{
			NSDictionary *infoDic = [listArray objectAtIndex:i];
			NSMutableArray *infoArray = [[NSMutableArray alloc]init];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"id"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"title"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"organizer"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"address"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"point_lng"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"point_lat"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"reg_end_time"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"begin_time"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"end_time"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"activity_img_num"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"desc"]]];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"phone"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"report_url"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"sum"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"interests"]]];
            [infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"pic"]]];
            
            //活动图片
            NSMutableArray *morePicArray = [[NSMutableArray alloc]init];
			NSArray *picArray = [infoDic objectForKey:@"pics"];
			for (int j = 0; j < [picArray count]; j++ )
			{
                NSDictionary *picDic = [picArray objectAtIndex:j];
				NSMutableArray *pic = [[NSMutableArray alloc] init];
                [pic addObject:@""];
				[pic addObject:[infoDic objectForKey:@"id"]];
				[pic addObject:[picDic objectForKey:@"img_path"]];
				[pic addObject:[picDic objectForKey:@"thumb_pic"]];
				[morePicArray insertObject:pic atIndex:j];
				[pic release];
			}
            
            [infoArray addObject:morePicArray];
            
            //用户上传图片
            NSMutableArray *moreUserPicArray = [[NSMutableArray alloc]init];
			NSArray *userPicArray = [infoDic objectForKey:@"activity_img"];
            for (int k = 0; k < [userPicArray count]; k++)
			{
                NSDictionary *userPicDic = [userPicArray objectAtIndex:k];
				NSMutableArray *userPic = [[NSMutableArray alloc] init];
                [userPic addObject:[userPicDic objectForKey:@"id"]];
				[userPic addObject:[infoDic objectForKey:@"id"]];
				[userPic addObject:[userPicDic objectForKey:@"img_path"]];
				[userPic addObject:[userPicDic objectForKey:@"thumb_pic"]];
                [userPic addObject:[userPicDic objectForKey:@"desc"]];
				[moreUserPicArray insertObject:userPic atIndex:k];
				[userPic release];
			}
            
            [infoArray addObject:moreUserPicArray];
			[infoArray addObject:[NSString stringWithFormat:@"%@",[infoDic objectForKey:@"join_time"]]];
            [moreArray insertObject:infoArray atIndex:i];
            
			[infoArray release];
		}
	}
	return [moreArray autorelease];
}

// 修改密码
+ (NSMutableArray*)parsePasswordModif:(NSString*)jsonResult
{
    NSDictionary *resultDic = [jsonResult JSONValue];
    NSLog(@"parsePasswordModif resultDic===%@",resultDic);
    
    NSString *ret = [resultDic objectForKey:@"ret"];
    
    NSMutableArray *resultArray =[[NSMutableArray alloc] init];
    [resultArray addObject:ret];
    
    return [resultArray autorelease];
}


@end
