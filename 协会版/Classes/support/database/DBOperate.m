//
//  DBOperate.m
//  Shopping
//
//  Created by zhu zhu chao on 11-3-22.
//  Copyright 2011 sal. All rights reserved.
//

#import "DBOperate.h"
#import "FileManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Common.h"

@implementation DBOperate
+(BOOL)createTable{
	NSArray *tableListSql=[NSArray arrayWithObjects:C_T_VERSION,C_T_SYSTEM_CONFIG,C_T_SUPPLY,\
						   C_T_SUPPLY_CAT,C_T_SUPPLY_PIC,C_T_DEMAND,C_T_DEMAND_CAT,\
						   C_T_DEMAND_PIC,C_T_SUPPLY_FAVORITE,C_T_DEMAND_FAVORITE,\
						   C_T_SUPPLY_PIC_FAVORITE,C_T_DEMAND_PIC_FAVORITE,\
                           C_T_SUPPLY_RECOMMEND,C_T_SUPPLY_PIC_RECOMMEND,C_T_DEMAND_RECOMMEND,C_T_DEMAND_PIC_RECOMMEND,\
						   C_T_SHOP,C_T_SHOP_CAT,C_T_SHOP_FAVORITE,C_T_ABOUTUS_INFO,C_T_MEMBER_INFO,\
						   C_T_ADVERTISE_LIST,C_T_NEWS_LIST,C_T_NEWS_CAT,\
                           C_T_ACTIVE_MEMBER,C_T_NEWEST_MEMBER,C_T_CONTACTS_BOOK,C_T_CONTACTS_BOOK_CAT,\
						   C_T_RECOMMEND_NEWS,C_T_WEIBO_USERINFO,C_T_MEMBER_VERSION,\
						   C_T_FAVORITE_NEWS,C_T_SEARCH_RECORD,C_T_COMMENTLIST_VERSION,C_T_COMMENTLIST,C_T_MORE_CAT,C_T_MORE_CATINFO,C_T_CONTACTSBOOK_FAVORITE,C_T_RECOMMEND_APP,C_T_DEVTOKEN,C_T_PHONENUM,
                           C_T_ACTIVITY,C_T_ACTIVITY_PIC,C_T_ACTIVITY_USER_PIC,
                           C_T_ACTIVITY_HISTORY,C_T_ACTIVITY_HISTORY_PIC,C_T_ACTIVITY_HISTORY_USER_PIC,C_T_SYSTEMMESSAGE,C_T_APP_INFO,nil];
    
	NSArray *tableList=[NSArray arrayWithObjects:T_VERSION,T_SYSTEM_CONFIG,T_SUPPLY,T_SUPPLY_CAT,\
						T_SUPPLY_PIC,T_DEMAND,T_DEMAND_CAT,T_DEMAND_PIC,T_SUPPLY_FAVORITE,\
						T_DEMAND_FAVORITE, T_SUPPLY_PIC_FAVORITE,T_DEMAND_PIC_FAVORITE,\
                        T_SUPPLY_RECOMMEND,T_SUPPLY_PIC_RECOMMEND,T_DEMAND_RECOMMEND,T_DEMAND_PIC_RECOMMEND,\
						T_SHOP,T_SHOP_CAT,T_SHOP_FAVORITE,T_ABOUTUS_INFO,T_MEMBER_INFO,\
						T_ADVERTISE_LIST,T_NEWS_LIST,T_NEWS_CAT,\
                        T_ACTIVE_MEMBER,T_NEWEST_MEMBER,T_CONTACTS_BOOK,T_CONTACTS_BOOK_CAT,\
						T_RECOMMEND_NEWS,T_WEIBO_USERINFO,T_MEMBER_VERSION,\
						T_FAVORITE_NEWS,T_SEARCH_RECORD,T_COMMENTLIST_VERSION,T_COMMENTLIST,T_MORE_CAT,T_MORE_CATINFO,T_CONTACTSBOOK_FAVORITE,T_RECOMMEND_APP,T_DEVTOKEN,T_PHONENUM,
                        T_ACTIVITY,T_ACTIVITY_PIC,T_ACTIVITY_USER_PIC,
                        T_ACTIVITY_HISTORY,T_ACTIVITY_HISTORY_PIC,T_ACTIVITY_HISTORY_USER_PIC,T_SYSTEMMESSAGE,T_APP_INFO,nil];
	
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	NSLog(@"dbFilePath:---------------- %@",dbFilePath);
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	if ([db open]) {
		[db setShouldCacheStatements:YES];
		for (int i = 0 ;i <[tableList count];i++) {
			NSString *checkTableSQL = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",[tableList objectAtIndex:i]];
			FMResultSet *rs = [db executeQuery:checkTableSQL];
			if (![rs next]) {
				[db executeUpdate:[tableListSql objectAtIndex:i]];
			}
		}
		
	}
	[db close];
	return YES;
}
//////插入一整行，array数组元素个数需与该表列数一致  忽略第一个字段id 因为已经设着它为自增
+(BOOL)insertData:(NSArray *)data tableName:(NSString *)aName{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	NSUInteger columCount=[data count];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	NSString *colum=@",?";
	for (NSInteger i=0; i<columCount-1; i++) {
		colum=[colum stringByAppendingString:@",?"];
	}
	if ([db open]) {
		[db setShouldCacheStatements:YES];
		
		[db beginTransaction];
		
		[db executeUpdate:[NSString stringWithFormat:@"insert into %@ values(NULL%@)",aName,colum] withArgumentsInArray:data];
		
		if ([db hadError]) {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}else {
		NSLog(@"could not open dababase!");
		return NO;
	}
	
}
//插入一行不忽略第一个id字段
+(BOOL)insertDataWithnotAutoID:(NSArray *)data tableName:(NSString *)aName{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	NSUInteger columCount=[data count];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	NSString *colum=@"?";
	for (NSInteger i=0; i<columCount-1; i++) {
		colum=[colum stringByAppendingString:@",?"];
	}
	if ([db open]) {
		[db setShouldCacheStatements:YES];
		
		[db beginTransaction];
		
		[db executeUpdate:[NSString stringWithFormat:@"insert into %@ values(%@)",aName,colum] withArgumentsInArray:data];
		
		if ([db hadError]) {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			[db close];
			return NO;
		}
		
		[db commit];
		[db close];
		return YES;
	}else {
		NSLog(@"could not open dababase!");
		return NO;
	}
	
}





+(NSArray *)queryData:(NSString *)aName theColumn:(NSString *)aColumn equalValue:(id)aColumnValue theColumn:(NSString*)bColumn equalValue:(id)bColumnValue{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]){
		[db setShouldCacheStatements:YES];
		NSMutableArray *FinalArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs=nil;
		if ([aName isEqualToString:T_SEARCH_RECORD]) {
			NSString *searchInput = [NSString stringWithFormat:@"%@%%", bColumnValue];
			rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? and %@ like ?", aName,aColumn,bColumn],aColumnValue,searchInput];
		}else if ([aName isEqualToString:T_COMMENTLIST])
        {
            rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? and %@=? order by creatTime desc", aName,aColumn,bColumn],aColumnValue,bColumnValue];
        }else {
			rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? and %@=?", aName,aColumn,bColumn],aColumnValue,bColumnValue];
		}
		
		int col = sqlite3_column_count(rs.statement.statement); // sqlite3_column_count(rs.statement)
		while ([rs next]) {
			NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];
			for (int i=0; i<col; i++) {
				NSString *temp =[rs stringForColumnIndex:i];
				if (temp == nil) {
					[rsArray addObject:@""];
				}
				else {
					[rsArray addObject:temp];
				}
				
				
			}
			[FinalArray addObject:(NSMutableArray *)rsArray];
			//[rsArray removeAllObjects];
		}
		[rs close];
		[db close];
		return FinalArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
	
}

+(NSArray *)queryData:(NSString *)aName theColumn:(NSString *)aColumn noEqualValue:(id)aColumnValue theColumn:(NSString*)bColumn equalValue:(id)bColumnValue{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]){
		[db setShouldCacheStatements:YES];
		NSMutableArray *FinalArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs=nil;
        //		if ([aName isEqualToString:T_SEARCH_RECORD]) {
        //			NSString *searchInput = [NSString stringWithFormat:@"%@%%", bColumnValue];
        //			rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? and %@ like ?", aName,aColumn,bColumn],aColumnValue,searchInput];
        //		}else {
        rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@!=? and %@=?", aName,aColumn,bColumn],aColumnValue,bColumnValue];			
        //		}
        
		
		int col = sqlite3_column_count(rs.statement.statement); // sqlite3_column_count(rs.statement)
		while ([rs next]) {
			NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];
			for (int i=0; i<col; i++) {
				NSString *temp =[rs stringForColumnIndex:i];
				if (temp == nil) {
					[rsArray addObject:@""];
				}
				else {
					[rsArray addObject:temp];
				}
				
				
			}
			[FinalArray addObject:(NSMutableArray *)rsArray];
			//[rsArray removeAllObjects];
		}
		[rs close];
		[db close];
		return FinalArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
	
}


////////查询整个表，或是查询某个条件下的一整行
////select * from aName
////select * from aName where aColumn=aColumnValue
+(NSArray *)queryData:(NSString *)aName theColumn:(NSString *)aColumn theColumnValue:(NSString *)aColumnValue  withAll:(BOOL)yesNO{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	if ([db open]){
		[db setShouldCacheStatements:YES];
		NSMutableArray *FinalArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs=nil;
		if (yesNO) 
		{
			if ([aName isEqualToString:T_SUPPLY_CAT] || [aName isEqualToString:T_DEMAND_CAT] || [aName isEqualToString:T_SHOP_CAT] || [aName isEqualToString:T_NEWS_CAT] || [aName isEqualToString:T_ACTIVE_MEMBER])
            {
				rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by sort_order asc", aName]];
			}
            else if ([aName isEqualToString:T_ADVERTISE_LIST])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by sort_order asc,imageid desc", aName]];
            }
            else if ([aName isEqualToString:T_SUPPLY] || [aName isEqualToString:T_DEMAND] || [aName isEqualToString:T_SHOP])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by update_time desc,id desc", aName]];
            }
            else if ([aName isEqualToString:T_SUPPLY_RECOMMEND] || [aName isEqualToString:T_DEMAND_RECOMMEND])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by update_time asc,id asc", aName]];
            }
            else if ([aName isEqualToString:T_NEWS_LIST] || [aName isEqualToString:T_RECOMMEND_NEWS])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by updatetime desc", aName]];
            }
            else if ([aName isEqualToString:T_NEWEST_MEMBER])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by created desc", aName]];
            }
            else if ([aName isEqualToString:T_CONTACTS_BOOK])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by letter asc", aName]];
            }
            else if ([aName isEqualToString:T_RECOMMEND_APP])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by sort_order desc", aName]];
            }
            else if ([aName isEqualToString:T_MORE_CAT])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by catId asc", aName]];
            }
            else if ([aName isEqualToString:T_SUPPLY_FAVORITE] || [aName isEqualToString:T_DEMAND_FAVORITE] || [aName isEqualToString:T_SHOP_FAVORITE] || [aName isEqualToString:T_FAVORITE_NEWS])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by favoriteId desc", aName]];
            }
            else
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ ", aName]];
            }
		}
		else
		{
			if ([aName isEqualToString:T_SEARCH_RECORD]) {
                //				rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ ", aName]];
				NSString *searchInput = [NSString stringWithFormat:@"%@%%", aColumnValue];
				rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ like ?", aName,aColumn],searchInput];
			}
            else if ([aName isEqualToString:T_SUPPLY_CAT] || [aName isEqualToString:T_DEMAND_CAT] || [aName isEqualToString:T_SHOP_CAT] || [aName isEqualToString:T_NEWS_CAT] || [aName isEqualToString:T_ACTIVE_MEMBER])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by sort_order asc", aName,aColumn],aColumnValue];
			}
            else if ([aName isEqualToString:T_ADVERTISE_LIST])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by sort_order asc,imageid desc", aName,aColumn],aColumnValue];
			}
            else if ([aName isEqualToString:T_SUPPLY] || [aName isEqualToString:T_DEMAND] || [aName isEqualToString:T_SHOP])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by update_time desc,id desc", aName,aColumn],aColumnValue];
            }
            else if ([aName isEqualToString:T_SUPPLY_RECOMMEND] || [aName isEqualToString:T_DEMAND_RECOMMEND])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by update_time asc,id asc", aName,aColumn],aColumnValue];
            }
            else if ([aName isEqualToString:T_NEWS_LIST] || [aName isEqualToString:T_RECOMMEND_NEWS])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by updatetime desc", aName,aColumn],aColumnValue];
            }
            else if ([aName isEqualToString:T_NEWEST_MEMBER])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by created desc", aName,aColumn],aColumnValue];
            }
            else if ([aName isEqualToString:T_CONTACTS_BOOK])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by letter asc", aName,aColumn],aColumnValue];
            }
            else if ([aName isEqualToString:T_RECOMMEND_APP])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by sort_order desc", aName,aColumn],aColumnValue];
            }
            else if ([aName isEqualToString:T_MORE_CATINFO])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by sort asc", aName,aColumn],aColumnValue];
            }
            else if ([aName isEqualToString:T_SUPPLY_FAVORITE] || [aName isEqualToString:T_DEMAND_FAVORITE] || [aName isEqualToString:T_SHOP_FAVORITE] || [aName isEqualToString:T_FAVORITE_NEWS])
            {
                rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by favoriteId desc", aName,aColumn],aColumnValue];
            }
            else 
            {
				rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=?", aName,aColumn],aColumnValue];
			}
		}
		
		int col = sqlite3_column_count(rs.statement.statement); // sqlite3_column_count(rs.statement)
		while ([rs next]) {
			NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];
			for (int i=0; i<col; i++) {
				NSString *temp =[rs stringForColumnIndex:i];
				if (temp == nil) {
					[rsArray addObject:@""];
				}
				else {
					[rsArray addObject:temp];
				}
				
				
			}
			[FinalArray addObject:(NSMutableArray *)rsArray];
			//[rsArray removeAllObjects];
		}
		[rs close];
		[db close];
		return FinalArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
	
}

//////查询某列一个值或是返回一整列的值
//select theColumn from aTableName where aColumn＝aColumnValue
//select theColumn from aTableName
+(NSArray *)selectColumn:(NSString *)theColumn 
			   tableName:(NSString *)aTableName 
			   conColumn:(NSString *)aColumn 
		  conColumnValue:(NSString *)aColumnValue 
		 withWholeColumn:(BOOL)yesNO
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]){
		[db setShouldCacheStatements:YES];
		FMResultSet *rs=nil;
		if (yesNO) {
			rs=[db executeQuery:[NSString stringWithFormat:@"select %@ from %@ ",theColumn, aTableName]];
		}else {
			rs=[db executeQuery:[NSString stringWithFormat:@"select %@ from %@ where %@=?", theColumn,aTableName,aColumn],aColumnValue];
		}
		NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];		
		while ([rs next]) {
			NSString *temp =[rs stringForColumn:theColumn];
			[rsArray addObject:temp];
		}
		[rs close];
		[db close];
		return rsArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
}

+(BOOL)deleteALLData:(NSString *)tableName{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]) {
		[db setShouldCacheStatements:YES];		
		[db beginTransaction];
		[db executeUpdate:[NSString stringWithFormat:@"delete from %@",tableName]];		
		if ([db hadError]) {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}else {
		NSLog(@"could not open dababase!");
		return NO;
	}
}

////////////删除某个条件下的某一行 如 delete from tableName where colunm=aValue
+(BOOL)deleteData:(NSString *)tableName tableColumn:(NSString *)column columnValue:(id)aValue{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]) {
		[db setShouldCacheStatements:YES];		
		[db beginTransaction];
		[db executeUpdate:[NSString stringWithFormat:@"delete from %@ where %@=?",tableName,column],aValue];		
		if ([db hadError]) {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}else {
		NSLog(@"could not open dababase!");
		return NO;
	}
}
/*+(BOOL)deleteData:(NSString *)tableName tableColumn:(NSString *)column columnNumberValue:(NSNumber*)aValue{
 NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
 FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
 
 if ([db open]) {
 [db setShouldCacheStatements:YES];		
 [db beginTransaction];
 [db executeUpdate:[NSString stringWithFormat:@"delete from %@ where %@=?",tableName,column],aValue];		
 if ([db hadError]) {
 NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
 [db rollback];
 return NO;
 }
 [db commit];
 [db close];
 return YES;
 }else {
 NSLog(@"could not open dababase!");
 return NO;
 }
 }*/

//+(BOOL)deleteData:(NSString *)tableName condition:(NSString *)con {
//	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
//	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
//	
//	if ([db open]) {
//		[db setShouldCacheStatements:YES];		
//		[db beginTransaction];
//		[db executeUpdate:[NSString stringWithFormat:@"delete from %@ where %@",tableName,con]];		
//		if ([db hadError]) {
//			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
//			[db rollback];
//			return NO;
//		}
//		[db commit];
//		[db close];
//		return YES;
//	}else {
//		NSLog(@"could not open dababase!");
//		return NO;
//	}
//}

+(BOOL)deleteData:(NSString *)tableName {
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]) {
		[db setShouldCacheStatements:YES];		
		[db beginTransaction];
		[db executeUpdate:[NSString stringWithFormat:@"delete from %@ ",tableName]];		
		if ([db hadError]) {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}else {
		NSLog(@"could not open dababase!");
		return NO;
	}
}


+(BOOL)updateData:(NSString *)tableName tableColumn:(NSString *)column columnValue:(NSString *)aValue 
  conditionColumn:(NSString *)conColumn conditionColumnValue:(id)conValue
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]) {
		[db setShouldCacheStatements:YES];		
		[db beginTransaction];
		[db executeUpdate:[NSString stringWithFormat:@"update %@ set %@=? where %@=?",tableName,column,conColumn],aValue,conValue];
		if ([db hadError]) {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}else {
		NSLog(@"could not open dababase!");
		return NO;
	}
}

+(BOOL)updateData:(NSString *)tableName tableColumn:(NSString *)column columnValue:(NSString *)aValue 
 conditionColumn1:(NSString *)conColumn1 conditionColumnValue1:(id)conValue1
 conditionColumn2:(NSString *)conColumn2 conditionColumnValue2:(id)conValue2
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]) {
		[db setShouldCacheStatements:YES];		
		[db beginTransaction];
		//	NSLog([NSString stringWithFormat:@"update %@ set %@=%@ where %@=%@",tableName,column,aValue,conColumn,conValue]);
		//	[db executeUpdate:@"update ? set ?=? where ?=?",tableName,column,aValue,conColumn,conValue];
		//NSLog(@"sql %@",[NSString stringWithFormat:@"update %@ set %@=? where %@=?",tableName,column,conColumn]);
		[db executeUpdate:[NSString stringWithFormat:@"update %@ set %@=? where %@=? and %@=?",tableName,column,conColumn1,conColumn2],aValue,conValue1,conValue2];
		if ([db hadError]) {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}else {
		NSLog(@"could not open dababase!");
		return NO;
	}
}

//+(BOOL)updateData:(NSString *)tableName tableColumn:(NSString *)column columnValue:(NSString *)aValue 
//{
//	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
//	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
//	
//	if ([db open]) {
//		[db setShouldCacheStatements:YES];		
//		[db beginTransaction];
//		//	NSLog([NSString stringWithFormat:@"update %@ set %@=%@ where %@=%@",tableName,column,aValue,conColumn,conValue]);
//		//	[db executeUpdate:@"update ? set ?=? where ?=?",tableName,column,aValue,conColumn,conValue];		
//		[db executeUpdate:[NSString stringWithFormat:@"update %@ set %@=? ",tableName,column],aValue];
//		if ([db hadError]) {
//			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
//			[db rollback];
//			return NO;
//		}
//		[db commit];
//		[db close];
//		return YES;
//	}else {
//		NSLog(@"could not open dababase!");
//		return NO;
//	}
//}

///////按正序或倒序查询某表的某列前n条记录
+(NSArray *)selectTopNColumn:(NSString *)theColumn tableName:(NSString *)aTableName rowNum:(NSInteger)n 
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]){
		[db setShouldCacheStatements:YES];
		FMResultSet *rs=nil;
		if (n==WHOLE_COLUMN) {
			rs=[db executeQuery:[NSString stringWithFormat:@"select %@ from %@ ORDER BY id DESC  ",theColumn, aTableName]];
		}else {
			NSLog(@"%@",[NSString stringWithFormat:@"select %@ from %@ ORDER BY id DESC limit 0,%d ",theColumn, aTableName,n]);
			rs=[db executeQuery:[NSString stringWithFormat:@"select %@ from %@ ORDER BY id DESC limit 0,%d ",theColumn, aTableName,n]];
		}
		NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];		
		while ([rs next]) {
			NSString *temp =[rs stringForColumn:theColumn];
			[rsArray addObject:temp];
		}
		[rs close];
		[db close];
		return rsArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
	
}
///倒序或是正序查询一列
//select theColumn from aTableName where aColumn=aColumnValue order by ID descOrAsc
+(NSArray *)selectColumnWithOrder:(NSString *)theColumn 
						tableName:(NSString *)aTableName 
						conColumn:(NSString *)aColumn 
				   conColumnValue:(NSString *)aColumnValue 
						  orderBy:(NSString *)descOrAsc
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]){
		[db setShouldCacheStatements:YES];
		FMResultSet *rs=[db executeQuery:[NSString stringWithFormat:@"select %@ from %@ where %@ = '%@' order by ID %@",theColumn, aTableName,aColumn,aColumnValue,descOrAsc]];
		NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];		
		while ([rs next]) {
			NSString *temp =[rs stringForColumn:theColumn];
			[rsArray addObject:temp];
		}
		[rs close];
		[db close];
		return rsArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
}



//add by zhanghao
+(NSArray *)getSearchIndex:(NSString *)tableName;
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];	
	if ([db open]){
		[db setShouldCacheStatements:YES];
		NSString *string;
		NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs=nil;
		rs=[db executeQuery:[NSString stringWithFormat:@"select distinct(searchIndex) from %@",tableName]];
		while ([rs next]) {			
			string=[rs stringForColumnIndex:0];
			[rsArray addObject:string];
		}
		[rs close];
		[db close];
		return rsArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
	
}
+(NSArray *)getContentForIndex:(NSString *)index InTable:(NSString *)tableName{
	
	return [self queryData:tableName theColumn:@"searchIndex" theColumnValue:index withAll:NO];
}
//======

+(NSArray *)qureyWithTwoConditions:(NSString *)tabelName 
						 ColumnOne:(NSString *)columnOne 
						  valueOne:(NSString *)valueOne 
						 columnTwo:(NSString *)columnTwo
						  valueTwo:(NSString *)valueTwo
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]){
		[db setShouldCacheStatements:YES];
		NSMutableArray *FinalArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs=nil;
		rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? and %@=?", tabelName,columnOne,columnTwo],valueOne,valueTwo];
		int col = sqlite3_column_count(rs.statement.statement); // sqlite3_column_count(rs.statement)
		while ([rs next]) {
			NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];
			for (int i=0; i<col; i++) {
				NSString *temp =[rs stringForColumnIndex:i];
				[rsArray addObject:temp];
			}
			[FinalArray addObject:(NSMutableArray *)rsArray];
		}
		[rs close];
		[db close];
		return FinalArray;
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
	
	
	
	
}


+(BOOL)updateWithTwoConditions:(NSString *)tabelName 
					 theColumn:(NSString *)Column 
				theColumnValue:(NSString *)aValue 
					 ColumnOne:(NSString *)columnOne 
					  valueOne:(NSString *)valueOne 
					 columnTwo:(NSString *)columnTwo 
					  valueTwo:(NSString *)valueTwo;
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]) {
		[db setShouldCacheStatements:YES];		
		[db beginTransaction];	
		[db executeUpdate:[NSString stringWithFormat:@"update %@ set %@=? where %@=? and %@=?",tabelName,Column,columnOne,columnTwo],aValue,valueOne,valueTwo];
		if ([db hadError]) {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}else {
		NSLog(@"could not open dababase!");
		return NO;
	}
	
	
}



+(BOOL)deleteDataWithTwoConditions:(NSString *)tableName 
						 columnOne:(NSString *)columnOne 
						  valueOne:(NSString *)valueOne 
						 columnTwo:(NSString *)columnTwo
						  valueTwo:(NSString *)valueTwo
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	
	if ([db open]) {
		[db setShouldCacheStatements:YES];		
		[db beginTransaction];
		[db executeUpdate:[NSString stringWithFormat:@"delete from %@ where %@=? and %@=?",tableName,columnOne,columnTwo],valueOne,valueTwo];		
		if ([db hadError]) {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}else {
		NSLog(@"could not open dababase!");
		return NO;
	}
	
}

//查询整个表 支持一个条件跟排序
+(NSMutableArray *)queryData:(NSString *)aName theColumn:(NSString *)aColumn theColumnValue:(NSString *)aColumnValue orderBy:(NSString *)orderByString orderType:(NSString *)orderTypeString withAll:(BOOL)yesNO
{
    NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	if ([db open]){
		[db setShouldCacheStatements:YES];
		NSMutableArray *FinalArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs=nil;
		if (yesNO)
		{
            rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by %@ %@", aName,orderByString,orderTypeString]];
		}
		else
		{
			rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by %@ %@", aName,aColumn,orderByString,orderTypeString],aColumnValue];
		}
		
		int col = sqlite3_column_count(rs.statement.statement); // sqlite3_column_count(rs.statement)
		while ([rs next]) {
			NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];
			for (int i=0; i<col; i++) {
				NSString *temp =[rs stringForColumnIndex:i];
				if (temp == nil) {
					[rsArray addObject:@""];
				}
				else {
					[rsArray addObject:temp];
				}
				
				
			}
			[FinalArray addObject:(NSMutableArray *)rsArray];
			//[rsArray removeAllObjects];
		}
		[rs close];
		[db close];
		return FinalArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
}

//查询整个表 支持多个条件跟排序
+(NSMutableArray *)queryData:(NSString *)aName theColumn:(NSString *)aColumn theColumnValue:(NSString *)aColumnValue orderByOne:(NSString *)orderByStringOne orderTypeOne:(NSString *)orderTypeStringOne orderByTwo:(NSString *)orderByStringTwo orderTypeTwo:(NSString *)orderTypeStringTwo withAll:(BOOL)yesNO
{
    NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	if ([db open]){
		[db setShouldCacheStatements:YES];
		NSMutableArray *FinalArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs=nil;
		if (yesNO)
		{
            rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ order by %@ %@,%@ %@", aName,orderByStringOne,orderTypeStringOne,orderByStringTwo,orderTypeStringTwo]];
		}
		else
		{
			rs=[db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@=? order by %@ %@,%@ %@", aName,aColumn,orderByStringOne,orderTypeStringOne,orderByStringTwo,orderTypeStringTwo],aColumnValue];
		}
		
		int col = sqlite3_column_count(rs.statement.statement); // sqlite3_column_count(rs.statement)
		while ([rs next]) {
			NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];
			for (int i=0; i<col; i++) {
				NSString *temp =[rs stringForColumnIndex:i];
				if (temp == nil) {
					[rsArray addObject:@""];
				}
				else {
					[rsArray addObject:temp];
				}
				
				
			}
			[FinalArray addObject:(NSMutableArray *)rsArray];
			//[rsArray removeAllObjects];
		}
		[rs close];
		[db close];
		return FinalArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
}

//query 主要用户更新 删除
+(BOOL)querySql:(NSString *)sql
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	if ([db open])
    {
		[db setShouldCacheStatements:YES];
		[db beginTransaction];
		[db executeUpdate:sql];
		if ([db hadError])
        {
			NSLog(@"Err %d %@",[db lastErrorCode],[db lastErrorMessage]);
			[db rollback];
			return NO;
		}
		[db commit];
		[db close];
		return YES;
	}
    else
    {
		NSLog(@"could not open dababase!");
		return NO;
	}
}

//获取所有活跃会员ID
+(NSArray *)selectActiveMember
{
	NSString *dbFilePath=[FileManager getFilePath:dataBaseFile];
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
	if ([db open]){
		[db setShouldCacheStatements:YES];
		NSMutableArray *FinalArray=[NSMutableArray arrayWithCapacity:0];
		FMResultSet *rs=nil;
        
		rs=[db executeQuery:@"select user_id from t_active_member order by created desc"];
		
		int col = sqlite3_column_count(rs.statement.statement); // sqlite3_column_count(rs.statement)
		while ([rs next]) {
			NSMutableArray *rsArray=[NSMutableArray arrayWithCapacity:0];
			for (int i=0; i<col; i++) {
				NSString *temp =[rs stringForColumnIndex:i];
				if (temp == nil) {
					[rsArray addObject:@""];
				}
				else {
					[rsArray addObject:temp];
				}
				
				
			}
			[FinalArray addObject:(NSMutableArray *)rsArray];
			//[rsArray removeAllObjects];
		}
		[rs close];
		[db close];
		return FinalArray;
		
	}else {
		NSLog(@"could not open dababase!");
		return nil;
	}
	
}

+ (NSMutableArray *)getAllIDFromPri:(NSString *)selectContent  whereContent:(NSString *)whereContent

{
    NSString *dbFilePath=[[NSBundle mainBundle] pathForResource:@"region" ofType:@"db"];
    
	NSLog(@"region.db   FilePath:---------------- %@",dbFilePath);
	FMDatabase *db=[FMDatabase databaseWithPath:dbFilePath];
    NSMutableArray *rsArray=[[NSMutableArray alloc]init ];
    
	if ([db open]) {
		[db setShouldCacheStatements:YES];
        FMResultSet *rs = nil;
        rs = [db executeQuery:[NSString stringWithFormat:@"select %@ from t_d_region where pid = %@",selectContent,whereContent]];
        int col = sqlite3_column_count(rs.statement.statement); // sqlite3_column_count(rs.statement)
        
		while ([rs next]) {
			
			for (int i=0; i<col; i++) {
				NSString *temp =[rs stringForColumnIndex:i];
				if (temp == nil) {
					[rsArray addObject:@" "];
				}
				else {
					[rsArray addObject:temp];
				}
			}
        }
        [db close];
        //NSLog(@"pri%@",rsArray);
    }
    return rsArray;  
}



@end
