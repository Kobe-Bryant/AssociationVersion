//
//  DBOperate.h
//  Shopping
//
//  Created by zhu zhu chao on 11-3-22.
//  Copyright 2011 sal. All rights reserved.
//

#import <Foundation/Foundation.h>
#define	WHOLE_COLUMN 0
#define T_SYSTEM_CONFIG @"t_system_config"
#define T_DEVTOKEN @"t_devtoken"
#define T_VERSION @"t_version"
#define T_SUPPLY @"t_supply"
#define T_SUPPLY_CAT @"t_supply_cat"
#define T_SUPPLY_PIC @"t_supply_pic"
#define T_SUPPLY_FAVORITE @"t_supply_favorite"
#define T_SUPPLY_PIC_FAVORITE @"t_supply_pic_favorite"
#define T_SUPPLY_RECOMMEND @"t_supply_recommend"
#define T_SUPPLY_PIC_RECOMMEND @"t_supply_pic_recommend"
#define T_DEMAND @"t_demand"
#define T_DEMAND_CAT @"t_demand_cat"
#define T_DEMAND_PIC @"t_demand_pic"
#define T_DEMAND_FAVORITE @"t_demand_favorite"
#define T_DEMAND_PIC_FAVORITE @"t_demand_pic_favorite"
#define T_DEMAND_RECOMMEND @"t_demand_recommend"
#define T_DEMAND_PIC_RECOMMEND @"t_demand_pic_recommend"
#define T_SHOP @"t_shop"
#define T_SHOP_CAT @"t_shop_cat"
#define T_SHOP_FAVORITE @"t_shop_favorite"
#define T_ABOUTUS_INFO @"t_aboutus_info"
#define T_WEIBO_USERINFO @"t_weibo_userinfo"
#define T_MEMBER_INFO @"t_member_info"
#define T_MEMBER_VERSION @"t_member_version"
#define T_COMMENTLIST_VERSION @"t_commentList_version"
#define T_COMMENTLIST @"t_commentList"
#define T_ADVERTISE_LIST @"t_advertise_list"
#define T_NEWS_LIST @"t_news_list"
#define T_NEWS_CAT @"t_news_cat"
#define T_ACTIVE_MEMBER @"t_active_member"
#define T_NEWEST_MEMBER @"t_newest_member"
#define T_CONTACTS_BOOK @"t_contacts_book"
#define T_CONTACTS_BOOK_CAT @"t_contacts_book_cat"
#define T_RECOMMEND_NEWS @"t_recommend_news"
#define T_FAVORITE_NEWS @"t_favorite_news"
#define T_SEARCH_RECORD @"t_search_record"
#define T_MORE_CAT @"t_more_cat"
#define T_MORE_CATINFO @"t_more_catinfo"
#define T_CONTACTSBOOK_FAVORITE @"t_contactsbook_favorite"
#define T_RECOMMEND_APP @"t_recommend_app"
#define T_PHONENUM @"t_phoneNum"

#define T_ACTIVITY @"t_activity"
#define T_ACTIVITY_PIC @"t_activity_pic"
#define T_ACTIVITY_USER_PIC @"t_activity_user_pic"
#define T_ACTIVITY_HISTORY @"t_activity_history"
#define T_ACTIVITY_HISTORY_PIC @"t_activity_history_pic"
#define T_ACTIVITY_HISTORY_USER_PIC @"t_activity_history_user_pic"

#define T_SYSTEMMESSAGE @"t_systemMessage"
#define T_APP_INFO @"t_app_info"

#define C_T_SYSTEM_CONFIG @"create table t_system_config\
(tag TEXT,\
value TEXT)"
enum system_config {
	system_config_tag,
    system_config_value
};

#define C_T_DEVTOKEN @"create table t_devtoken\
(id INTEGER PRIMARY KEY,\
token DOUBLE)"
enum devtoken {
	devtoken_id,
	devtoken_token
};

#define C_T_PHONENUM @"create table t_phoneNum\
(id INTEGER PRIMARY KEY,\
mobile TEXT)"
enum phoneNum {
	phoneNum_id,
    phoneNum_mobile
};

#define C_T_COMMENTLIST_VERSION @"create table t_commentList_version\
(command_id INTEGER,\
typeId INTEGER,\
infoId INTEGER,\
ver INTEGER,\
desc TEXT)"
enum list_version {
	version_list_command_id,
    version_list_typeId,
    version_list_infoId,
	version_list_ver,
	version_list_desc
};


#define C_T_VERSION @"create table t_version\
(command_id INTEGER,\
ver INTEGER,\
desc TEXT)"
enum version {
	version_command_id,
	version_ver,
	version_desc
};

#define C_T_SUPPLY @"create table t_supply\
(id INTEGER, \
cat_id INTEGER,\
title TEXT,\
desc TEXT,\
price TEXT,\
company_id INTEGER ,\
company_name TEXT,\
tel TEXT,\
pic TEXT,\
favorite INTEGER ,\
created INTEGER ,\
update_time INTEGER, \
pics TEXT, \
recommend INTEGER, \
commentTotal INTEGER \
)"
enum supply {
	supply_id,
	supply_catid,
	supply_title,
	supply_desc,
	supply_price,
	supply_company_id,
	supply_company_name,
	supply_tel,
	supply_pic,
	supply_favorite,
	supply_created,
	supply_update_time,
	supply_pics,
    supply_recommend,
    supply_commentTotal
};

#define C_T_SUPPLY_CAT @"create table t_supply_cat\
(id INTEGER PRIMARY KEY,\
name TEXT,\
sort_order INTEGER, \
version INTEGER \
)"
enum supply_cat {
	supply_cat_id,
	supply_cat_name,
	supply_cat_sort_order,
	supply_cat_version
};

#define C_T_SUPPLY_PIC @"create table t_supply_pic\
(id INTEGER PRIMARY KEY,\
supply_id INTEGER ,\
pic TEXT,\
pic_name TEXT,\
thumb_pic TEXT,\
thumb_pic_name TEXT,\
cat_id INTEGER \
)"
enum supply_pic {
	supply_pic_id,
	supply_pic_supply_id,
	supply_pic_pic,
	supply_pic_pic_name,
	supply_pic_thumb_pic,
	supply_pic_thumb_pic_name,
    supply_pic_cat_id
};

#define C_T_SUPPLY_FAVORITE @"create table t_supply_favorite\
(id INTEGER PRIMARY KEY,\
favoriteId INTEGER ,\
supply_id INTEGER ,\
user_id INTEGER ,\
cat_id INTEGER ,\
title TEXT,\
desc TEXT,\
price TEXT,\
company_id INTEGER ,\
company_name TEXT,\
tel TEXT,\
pic TEXT,\
picName TEXT,\
favorite INTEGER ,\
created INTEGER ,\
update_time INTEGER ,\
recommend INTEGER ,\
commentTotal INTEGER \
)"
enum supply_favorite {
	supply_favorite_id,
	supply_favorite_favoriteId,
	supply_favorite_supply_id,
	supply_favorite_user_id,
	supply_favorite_catid,
	supply_favorite_title,
	supply_favorite_desc,
	supply_favorite_price,
	supply_favorite_company_id,
	supply_favorite_company_name,
	supply_favorite_tel,
	supply_favorite_pic,
	supply_favorite_picName,
	supply_favorite_favorite,
	supply_favorite_created,
	supply_favorite_update_time,
	supply_favorite_recommend,
    supply_favorite_commentTotal
};

#define C_T_SUPPLY_PIC_FAVORITE @"create table t_supply_pic_favorite\
(id INTEGER PRIMARY KEY,\
supply_id INTEGER ,\
user_id INTEGER ,\
pic TEXT,\
pic_name TEXT,\
thumb_pic TEXT,\
thumb_pic_name TEXT\
)"
enum supply_pic_favorite {
	supply_pic_favorite_id,
	supply_pic_favorite_supply_id,
	supply_pic_favorite_user_id,
	supply_pic_favorite_pic,
	supply_pic_favorite_pic_name,
	supply_pic_favorite_thumb_pic,
	supply_pic_favorite_thumb_pic_name
};

#define C_T_SUPPLY_RECOMMEND @"create table t_supply_recommend\
(id INTEGER, \
cat_id INTEGER,\
title TEXT,\
desc TEXT,\
price TEXT,\
company_id INTEGER ,\
company_name TEXT,\
tel TEXT,\
pic TEXT,\
favorite INTEGER ,\
created INTEGER ,\
update_time INTEGER, \
pics TEXT, \
recommend INTEGER, \
commentTotal INTEGER \
)"
enum supply_recommend {
	supply_recommend_id,
	supply_recommend_catid,
	supply_recommend_title,
	supply_recommend_desc,
	supply_recommend_price,
	supply_recommend_company_id,
	supply_recommend_company_name,
	supply_recommend_tel,
	supply_recommend_pic,
	supply_recommend_favorite,
	supply_recommend_created,
	supply_recommend_update_time,
	supply_recommend_pics,
    supply_recommend_recommend,
    supply_recommend_commentTotal
};

#define C_T_SUPPLY_PIC_RECOMMEND @"create table t_supply_pic_recommend\
(id INTEGER PRIMARY KEY,\
supply_id INTEGER ,\
pic TEXT,\
pic_name TEXT,\
thumb_pic TEXT,\
thumb_pic_name TEXT,\
cat_id INTEGER \
)"
enum supply_pic_recommend {
	supply_pic_recommend_id,
	supply_pic_recommend_supply_id,
	supply_pic_recommend_pic,
	supply_pic_recommend_pic_name,
	supply_pic_recommend_thumb_pic,
	supply_pic_recommend_thumb_pic_name,
    supply_pic_recommend_cat_id
};

#define C_T_DEMAND @"create table t_demand\
(id INTEGER, \
cat_id INTEGER ,\
title TEXT,\
desc TEXT,\
contact TEXT,\
tel TEXT,\
created INTEGER, \
update_time INTEGER, \
pics EXT, \
recommend INTEGER, \
commentTotal INTEGER \
)"
enum demand {
	demand_id,
	demand_catid,
	demand_title,
	demand_desc,
	demand_contact,
	demand_tel,
	demand_created,
	demand_update_time,
	demand_pics,
    demand_recommend,
    demand_commentTotal
};

#define C_T_DEMAND_CAT @"create table t_demand_cat\
(id INTEGER PRIMARY KEY,\
name TEXT,\
sort_order INTEGER, \
version INTEGER \
)"
enum demand_cat {
	demand_cat_id,
	demand_cat_name,
	demand_cat_sort_order,
	demand_cat_version
};

#define C_T_DEMAND_PIC @"create table t_demand_pic\
(id INTEGER PRIMARY KEY,\
demand_id INTEGER ,\
pic TEXT,\
pic_name TEXT,\
thumb_pic TEXT,\
thumb_pic_name TEXT,\
cat_id INTEGER \
)"
enum demand_pic {
	demand_pic_id,
	demand_pic_demand_id,
	demand_pic_pic,
	demand_pic_pic_name,
	demand_pic_thumb_pic,
	demand_pic_thumb_pic_name,
    demand_pic_cat_id
};

#define C_T_DEMAND_FAVORITE @"create table t_demand_favorite\
(id INTEGER PRIMARY KEY,\
favoriteId INTEGER ,\
demand_id INTEGER ,\
user_id INTEGER ,\
cat_id INTEGER ,\
title TEXT,\
desc TEXT,\
contact TEXT,\
tel TEXT,\
created INTEGER, \
update_time INTEGER ,\
recommend INTEGER ,\
commentTotal INTEGER \
)"
enum demand_favorite {
	demand_favorite_id,
	demand_favorite_favoriteId,
	demand_favorite_demand_id,
	demand_favorite_user_id,
	demand_favorite_catid,
	demand_favorite_title,
	demand_favorite_desc,
	demand_favorite_contact,
	demand_favorite_tel,
	demand_favorite_created,
	demand_favorite_update_time,
	demand_favorite_recommend,
    demand_favorite_commentTotal
};

#define C_T_DEMAND_PIC_FAVORITE @"create table t_demand_pic_favorite\
(id INTEGER PRIMARY KEY,\
demand_id INTEGER ,\
user_id INTEGER ,\
pic TEXT,\
pic_name TEXT,\
thumb_pic TEXT,\
thumb_pic_name TEXT\
)"
enum demand_pic_favorite {
	demand_pic_favorite_id,
	demand_pic_favorite_demand_id,
	demand_pic_favorite_user_id,
	demand_pic_favorite_pic,
	demand_pic_favorite_pic_name,
	demand_pic_favorite_thumb_pic,
	demand_pic_favorite_thumb_pic_name
};

#define C_T_DEMAND_RECOMMEND @"create table t_demand_recommend\
(id INTEGER, \
cat_id INTEGER ,\
title TEXT,\
desc TEXT,\
contact TEXT,\
tel TEXT,\
created INTEGER, \
update_time INTEGER, \
pics EXT, \
recommend INTEGER, \
commentTotal INTEGER \
)"
enum demand_recommend {
	demand_recommend_id,
	demand_recommend_catid,
	demand_recommend_title,
	demand_recommend_desc,
	demand_recommend_contact,
	demand_recommend_tel,
	demand_recommend_created,
	demand_recommend_update_time,
	demand_recommend_pics,
    demand_recommend_recommend,
    demand_recommend_commentTotal
};

#define C_T_DEMAND_PIC_RECOMMEND @"create table t_demand_pic_recommend\
(id INTEGER PRIMARY KEY,\
demand_id INTEGER ,\
pic TEXT,\
pic_name TEXT,\
thumb_pic TEXT,\
thumb_pic_name TEXT,\
cat_id INTEGER \
)"
enum demand_pic_recommend {
	demand_pic_recommend_id,
	demand_pic_recommend_demand_id,
	demand_pic_recommend_pic,
	demand_pic_recommend_pic_name,
	demand_pic_recommend_thumb_pic,
	demand_pic_recommend_thumb_pic_name,
    demand_pic_recommend_cat_id
};

#define C_T_SHOP @"create table t_shop\
(id INTEGER, \
shop_uid INTEGER ,\
shop_ulevel INTEGER ,\
cat_id INTEGER ,\
title TEXT,\
desc TEXT,\
tel TEXT,\
pic TEXT,\
pic_name TEXT,\
address TEXT,\
lng INTEGER ,\
lat INTEGER ,\
attestation INTEGER ,\
update_time INTEGER ,\
aboutus_title TEXT,\
myproduct_title TEXT,\
app_name TEXT,\
app_image TEXT,\
iphone_url TEXT\
)"
enum shop {
	shop_id,
	shop_shop_uid,
	shop_shop_ulevel,
	shop_catid,
	shop_title,
	shop_desc,
	shop_tel,
	shop_pic,
	shop_pic_name,
	shop_address,
	shop_lng,
	shop_lat,
	shop_attestation,
	shop_update_time,
    shop_aboutus_title,
    shop_myproduct_title,
    shop_app_name,
    shop_app_image,
    shop_iphone_url
};

#define C_T_SHOP_CAT @"create table t_shop_cat\
(id INTEGER PRIMARY KEY,\
name TEXT,\
sort_order INTEGER, \
version INTEGER \
)"
enum shop_cat {
	shop_cat_id,
	shop_cat_name,
	shop_cat_sort_order,
	shop_cat_version
};

#define C_T_SHOP_FAVORITE @"create table t_shop_favorite\
(id INTEGER PRIMARY KEY,\
favoriteId INTEGER ,\
shop_id INTEGER ,\
user_id INTEGER ,\
shop_uid INTEGER ,\
shop_ulevel INTEGER ,\
cat_id INTEGER ,\
title TEXT,\
desc TEXT,\
tel TEXT,\
pic TEXT,\
pic_name TEXT,\
address TEXT,\
lng INTEGER ,\
lat INTEGER ,\
attestation INTEGER ,\
update_time INTEGER ,\
aboutus_title TEXT,\
myproduct_title TEXT,\
app_name TEXT,\
app_image TEXT,\
iphone_url TEXT \
)"
enum shop_favorite {
	shop_favorite_id,
	shop_favorite_favoriteId,
	shop_favorite_shop_id,
	shop_favorite_user_id,
	shop_favorite_shop_uid,
	shop_favorite_shop_ulevel,
	shop_favorite_catid,
	shop_favorite_title,
	shop_favorite_desc,
	shop_favorite_tel,
	shop_favorite_pic,
	shop_favorite_pic_name,
	shop_favorite_address,
	shop_favorite_lng,
	shop_favorite_lat,
	shop_favorite_attestation,
	shop_favorite_update_time,
    shop_favorite_aboutus_title,
    shop_favorite_myproduct_title,
    shop_favorite_app_name,
    shop_favorite_app_image,
    shop_favorite_iphone_url
};

#define C_T_ABOUTUS_INFO @"create table t_aboutus_info\
(id INTEGER PRIMARY KEY,\
name TEXT,\
url TEXT,\
address TEXT,\
content TEXT,\
logo TEXT,\
logo_name TEXT,\
contact TEXT,\
tel TEXT,\
mobile TEXT,\
fax TEXT,\
mail TEXT,\
lng TEXT,\
lat TEXT,\
weibo TEXT\
)"  
enum aboutus_info {
	aboutus_info_id,
	aboutus_info_name,
	aboutus_info_url,
	aboutus_info_address,
	aboutus_info_content,
	aboutus_info_logo,
	aboutus_info_logo_name,
	aboutus_info_contact,
	aboutus_info_tel,
	aboutus_info_mobile,
	aboutus_info_fax,
	aboutus_info_mail,
    aboutus_info_lng,
    aboutus_info_lat,
    aboutus_info_weibo // dufu add 2013.05.02
};

#define C_T_WEIBO_USERINFO @"create table t_weibo_userinfo\
(weiboType TEXT,weiboUserName TEXT,uid TEXT,\
userProfileImage TEXT,oauthToken TEXT,oauthTokenSecret TEXT,\
accessToken TEXT,expiresTime INTEGER,status INTEGER,oauthTime INTEGER,openId TEXT,openKey TEXT)"
enum weiboinfo {
	weibo_type,
	weibo_user_name,
	weibo_user_id,
	weibo_profile_image,
	weibo_oauth_token,
	weibo_oauth_token_secret,
	weibo_access_token,
	weibo_expires_time,
	weibo_status,
	weibo_oauth_time,
	weibo_open_id,
	weibo_open_key
};

#define C_T_MEMBER_VERSION @"create table t_member_version\
(commandId INTEGER,\
memberId INTEGER ,\
ver INTEGER,\
desc TEXT)"
enum member_version {
	member_commandId,
	member_id,
	member_ver,
	member_desc
};

#define C_T_MEMBER_INFO @"create table t_member_info\
(id INTEGER PRIMARY KEY,\
memberId INTEGER ,\
memberName TEXT ,\
memberFirstName TEXT ,\
memberPassword TEXT ,\
image TEXT,\
level INTEGER, \
imageName TEXT,\
sex INTEGER,\
post TEXT,\
companyName TEXT,\
tel TEXT,\
mobile TEXT,\
catId INTEGER,\
catName TEXT,\
province TEXT,\
city TEXT,\
district TEXT,\
addr TEXT,\
fax TEXT,\
created INTEGER,\
email TEXT,\
newMessageNum INTEGER,\
url TEXT,\
feedbackNum INTEGER)"

enum member_info {
	member_info_id,
	member_info_memberId,
	member_info_name,
    member_info_memberFirstName,
	member_info_password,
	member_info_image,
	member_info_level,
	member_info_imageName,
    member_info_sex,
    member_info_post,
    member_info_companyName,
    member_info_tel,
    member_info_mobile,
    member_info_catId,
    member_info_catName,
    member_info_province,
    member_info_city,
    member_info_district,
    member_info_addr,
    member_info_fax,
    member_info_created,
    member_info_email,
    member_info_newMessageNum,
    member_info_url,
    member_info_feedbackNum
};

#define C_T_COMMENTLIST @"create table t_commentList\
(commentId INTEGER,\
typeId INTEGER ,\
infoId INTEGER,\
username TEXT,\
title TEXT,\
content TEXT,\
creatTime TEXT)"
enum comment_list {
	comment_list_commentId,
	comment_list_typeId,
	comment_list_infoId,
	comment_list_userName,
    comment_list_title,
    comment_list_content,
    comment_list_creatTime
};

#define C_T_ADVERTISE_LIST @"create table t_advertise_list\
(imageid INTEGER,adType TEXT,image TEXT, desc TEXT,url TEXT,imageName TEXT,sort_order INTEGER,info_id INTEGER)"
enum advertiselist {
	advertiselist_imageid,
	advertiselist_ad_type,
	advertiselist_image,
	advertiselist_desc,
	advertiselist_url,
	advertiselist_image_name,
    advertiselist_sort_order,
    advertiselist_info_id
};

#define C_T_NEWS_LIST @"create table t_news_list\
(nid INTEGER,catid INTEGER,title TEXT, desc TEXT,companyname TEXT,\
opic TEXT,spic TEXT,opicname TEXT,spicname TEXT,created INTEGER,updatetime INTEGER,recommend INTEGER,push_time INTEGER,commentTotal INTEGER)"
enum newslist {
	newslist_nid,
	newslist_catid,
	newslist_title,
	newslist_desc,
	newslist_companyname,
	newslist_opic,
	newslist_spic,
	newslist_opic_name,
	newslist_spic_name,
	newslist_created,
	newslist_updatetime,
    newslist_recommend,
    newslist_push_time,
    newslist_commentTotal
};

#define C_T_NEWS_CAT @"create table t_news_cat\
(cid INTEGER,\
name TEXT,\
sort_order INTEGER, \
cat_version INTEGER)"
enum newscat {
	newscat_cid,
	newscat_name,
	newscat_sort_order,
	newscat_version
};

#define C_T_FAVORITE_NEWS @"create table t_favorite_news\
(id INTEGER PRIMARY KEY,favoriteId INTEGER ,nid INTEGER ,user_id INTEGER ,catid INTEGER,title TEXT, desc TEXT,companyname TEXT,\
opic TEXT,spic TEXT,picName TEXT,created INTEGER,updatetime INTEGER,recommend INTEGER,push_time INTEGER,commentTotal INTEGER)"
enum favoritenews {
	favoritenews_id,
	favoriyenews_favoriteId,
	favoritenews_nid,
	favoritenews_memberId,
	favoritenews_catid,
	favoritenews_title,
	favoritenews_desc,
	favoritenews_companyname,
	favoritenews_opic,
	favoritenews_spic,
	favoritenews_picName,
	favoritenews_created,
	favoritenews_updatetime,
	favoritenews_recommend,
	favoritenews_push_time,
    favoritenews_commentTotal
};


#define C_T_ACTIVE_MEMBER @"create table t_active_member\
(id INTEGER PRIMARY KEY,\
user_id INTEGER ,\
user_name TEXT,\
gender INTEGER,\
post TEXT,\
company_name TEXT,\
tel TEXT,\
mobile TEXT,\
fax TEXT,\
email TEXT,\
cat_name TEXT,\
cat_id INTEGER ,\
province TEXT,\
city TEXT,\
district TEXT,\
address TEXT,\
img TEXT,\
created INTEGER,\
url TEXT,\
sort_order INTEGER\
)"
enum active_member {
	active_member_id,
    active_member_user_id,
	active_member_user_name,
	active_member_gender,
	active_member_post,
	active_member_company_name,
	active_member_tel,
	active_member_mobile,
    active_member_fax,
    active_member_email,
	active_member_cat_name,
	active_member_cat_id,
	active_member_province,
    active_member_city,
    active_member_district,
	active_member_address,
	active_member_img,
    active_member_created,
    active_member_url,
    active_member_sort_order
};

#define C_T_NEWEST_MEMBER @"create table t_newest_member\
(id INTEGER PRIMARY KEY,\
user_id INTEGER ,\
user_name TEXT,\
gender INTEGER,\
post TEXT,\
company_name TEXT,\
tel TEXT,\
mobile TEXT,\
fax TEXT,\
email TEXT,\
cat_name TEXT,\
cat_id INTEGER ,\
province TEXT,\
city TEXT,\
district TEXT,\
address TEXT,\
img TEXT,\
created INTEGER,\
url TEXT\
)"
enum newest_member {
	newest_member_id,
    newest_member_user_id,
	newest_member_user_name,
	newest_member_gender,
	newest_member_post,
	newest_member_company_name,
	newest_member_tel,
	newest_member_mobile,
    newest_member_fax,
    newest_member_email,
	newest_member_cat_name,
	newest_member_cat_id,
	newest_member_province,
    newest_member_city,
    newest_member_district,
	newest_member_address,
	newest_member_img,
    newest_member_created,
    newest_member_url
};

#define C_T_CONTACTSBOOK_FAVORITE @"create table t_contactsbook_favorite\
(id INTEGER PRIMARY KEY,\
user_id INTEGER ,\
user_name TEXT,\
gender INTEGER,\
post TEXT,\
company_name TEXT,\
tel TEXT,\
mobile TEXT,\
fax TEXT,\
email TEXT,\
cat_name TEXT,\
cat_id INTEGER ,\
province TEXT,\
city TEXT,\
district TEXT,\
address TEXT,\
img TEXT,\
created INTEGER,\
url TEXT,\
letter TEXT,\
memberId INTEGER\
)"
enum contactsbook_favorite {
	contactsbook_favorite_id,
    contactsbook_favorite_user_id,
	contactsbook_favorite_user_name,
	contactsbook_favorite_gender,
	contactsbook_favorite_post,
	contactsbook_favorite_company_name,
	contactsbook_favorite_tel,
	contactsbook_favorite_mobile,
    contactsbook_favorite_fax,
    contactsbook_favorite_email,
	contactsbook_favorite_cat_name,
	contactsbook_favorite_cat_id,
	contactsbook_favorite_province,
    contactsbook_favorite_city,
    contactsbook_favorite_district,
	contactsbook_favorite_address,
	contactsbook_favorite_img,
    contactsbook_favorite_created,
    contactsbook_favorite_url,
    contactsbook_favorite_letter,
    contactsbook_favorite_memberId
};

#define C_T_CONTACTS_BOOK @"create table t_contacts_book\
(id INTEGER PRIMARY KEY,\
user_id INTEGER ,\
user_name TEXT,\
gender INTEGER,\
post TEXT,\
company_name TEXT,\
tel TEXT,\
mobile TEXT,\
fax TEXT,\
email TEXT,\
cat_name TEXT,\
cat_id INTEGER ,\
province TEXT,\
city TEXT,\
district TEXT,\
address TEXT,\
img TEXT,\
created INTEGER,\
url TEXT,\
letter TEXT\
)"
enum contacts_book {
	contacts_book_id,
    contacts_book_user_id,
	contacts_book_user_name,
	contacts_book_gender,
	contacts_book_post,
	contacts_book_company_name,
	contacts_book_tel,
	contacts_book_mobile,
    contacts_book_fax,
    contacts_book_email,
	contacts_book_cat_name,
	contacts_book_cat_id,
	contacts_book_province,
    contacts_book_city,
    contacts_book_district,
	contacts_book_address,
	contacts_book_img,
    contacts_book_created,
    contacts_book_url,
    contacts_book_letter
};

#define C_T_CONTACTS_BOOK_CAT @"create table t_contacts_book_cat\
(id INTEGER PRIMARY KEY,\
name TEXT,\
parent_id INTEGER, \
sort_order INTEGER, \
version INTEGER \
)"
enum c_b_cat {
	c_b_cat_id,
	c_b_cat_name,
    c_b_cat_parent_id,
	c_b_cat_sort_order,
	c_b_cat_version
};

#define C_T_RECOMMEND_NEWS @"create table t_recommend_news\
(nid INTEGER,catid INTEGER,title TEXT, desc TEXT,companyname TEXT,\
opic TEXT,spic TEXT,opicname TEXT,spicname TEXT,created INTEGER,updatetime TEXT,commentTotal INTEGER)"
enum recommendnews {
	recommend_news_nid,
	recommend_news_catid,
	recommend_news_title,
	recommend_news_desc,
	recommend_news_companyname,
	recommend_news_opic,
	recommend_news_spic,
	recommend_news_opic_name,
	recommend_news_spic_name,
	recommend_news_created,
	recommend_news_updatetime,
    recommend_news_commentTotal
};

#define C_T_SEARCH_RECORD @"create table t_search_record\
(id INTEGER PRIMARY KEY,type INTEGER,content TEXT)"
enum searchrecord {
	searchrecord_id,
	searchrecord_type,
	searchrecord_content
};

//更多分类
#define C_T_MORE_CAT @"create table t_more_cat\
(id INTEGER PRIMARY KEY,catId INTEGER,name TEXT,imageurl TEXT,imagename TEXT,version INTEGER)"
enum morecat {
    morecat_id,
	morecat_catId,
	morecat_catName,
	morecat_catImageurl,
    morecat_catImagename,
    morecat_version
};

#define C_T_MORE_CATINFO @"create table t_more_catinfo\
(id INTEGER PRIMARY KEY,cat_Id INTEGER,catId INTEGER,imageurl TEXT,imagename TEXT,desc TEXT,sort TEXT,updatetime INTEGER)"
enum morecatinfo {
    morecatinfo_id,
    morecatinfo_cat_Id,
	morecatinfo_catId,
	morecatinfo_catImageurl,
    morecatinfo_catImagename,
    morecatinfo_desc,
    morecatinfo_sort,
    morecatinfo_updatetime
};

#define C_T_RECOMMEND_APP @"create table t_recommend_app\
(id INTEGER PRIMARY KEY,\
name TEXT,\
url TEXT,\
icon TEXT,\
`desc` TEXT,\
sort_order INTEGER\
)"
enum recommand_app {
	recommand_app_id,
    recommand_app_name,
	recommand_app_url,
	recommand_app_icon,
	recommand_app_desc,
	recommand_app_sort_order
};

#define C_T_ACTIVITY @"create table t_activity\
(id INTEGER, \
title TEXT,\
organizer TEXT,\
address TEXT,\
point_lng TEXT,\
point_lat TEXT,\
reg_end_time INTEGER ,\
begin_time INTEGER ,\
end_time INTEGER ,\
activity_img_num INTEGER ,\
desc TEXT ,\
phone TEXT, \
report_url TEXT, \
sum INTEGER, \
interests INTEGER, \
pic TEXT,\
pics TEXT, \
user_pics TEXT\
)"
enum activity {
	activity_id,
    activity_title,
    activity_organizer,
    activity_address,
    activity_point_lng,
    activity_point_lat,
    activity_reg_end_time,
    activity_begin_time,
    activity_end_time,
    activity_activity_img_num,
    activity_desc,
    activity_phone,
    activity_report_url,
    activity_sum,
    activity_interests,
    activity_pic,
    activity_pics,
    activity_user_pics
};

#define C_T_ACTIVITY_PIC @"create table t_activity_pic\
(id INTEGER PRIMARY KEY,\
activity_id INTEGER ,\
pic TEXT,\
thumb_pic TEXT\
)"
enum activity_pic {
	activity_pic_id,
	activity_pic_activity_id,
	activity_pic_pic,
	activity_pic_thumb_pic
};

#define C_T_ACTIVITY_USER_PIC @"create table t_activity_user_pic\
(id INTEGER PRIMARY KEY,\
activity_id INTEGER ,\
pic TEXT,\
thumb_pic TEXT,\
desc TEXT\
)"
enum activity_user_pic {
	activity_user_pic_id,
	activity_user_pic_activity_id,
	activity_user_pic_pic,
	activity_user_pic_thumb_pic,
    activity_user_pic_desc
};

#define C_T_ACTIVITY_HISTORY @"create table t_activity_history\
(id INTEGER, \
title TEXT,\
organizer TEXT,\
address TEXT,\
point_lng TEXT,\
point_lat TEXT,\
reg_end_time INTEGER ,\
begin_time INTEGER ,\
end_time INTEGER ,\
activity_img_num INTEGER ,\
desc TEXT ,\
phone TEXT, \
report_url TEXT, \
sum INTEGER, \
interests INTEGER, \
pic TEXT,\
pics TEXT, \
user_pics TEXT\
)"
enum activity_history {
	activity_history_id,
    activity_history_title,
    activity_history_organizer,
    activity_history_address,
    activity_history_point_lng,
    activity_history_point_lat,
    activity_history_reg_end_time,
    activity_history_begin_time,
    activity_history_end_time,
    activity_history_activity_img_num,
    activity_history_desc,
    activity_history_phone,
    activity_history_report_url,
    activity_history_sum,
    activity_history_interests,
    activity_history_pic,
    activity_history_pics,
    activity_history_user_pics
};

#define C_T_ACTIVITY_HISTORY_PIC @"create table t_activity_history_pic\
(id INTEGER PRIMARY KEY,\
activity_id INTEGER ,\
pic TEXT,\
thumb_pic TEXT\
)"
enum activity_history_pic {
	activity_history_pic_id,
	activity_history_pic_activity_id,
	activity_history_pic_pic,
	activity_history_pic_thumb_pic
};

#define C_T_ACTIVITY_HISTORY_USER_PIC @"create table t_activity_history_user_pic\
(id INTEGER PRIMARY KEY,\
activity_id INTEGER ,\
pic TEXT,\
thumb_pic TEXT,\
desc TEXT\
)"
enum activity_history_user_pic {
	activity_history_user_pic_id,
	activity_history_user_pic_activity_id,
	activity_history_user_pic_pic,
	activity_history_user_pic_thumb_pic,
    activity_history_user_pic_desc
};

#define C_T_SYSTEMMESSAGE @"create table t_systemMessage\
(id INTEGER PRIMARY KEY,user_id INTEGER,content TEXT,url TEXT,created INTEGER)"
enum systemMessage {
	systemMessage_id,
    systemMessage_memberId,
	systemMessage_content,
	systemMessage_url,
	systemMessage_created
};

// tpye=0 自动升级  ；  tpye=1 评分提醒
#define C_T_APP_INFO @"create table t_app_info(type INTEGER, ver INTEGER, url TEXT,remide INTEGER ,remark TEXT)"
enum app_info {
	app_info_type,
	app_info_ver,
	app_info_url,
	app_info_remide,
    app_info_remark
};

@interface DBOperate : NSObject {
    
}
+(BOOL)createTable;
+(BOOL)insertData:(NSArray *)data tableName:(NSString *)aName;
+(BOOL)deleteData:(NSString *)tableName tableColumn:(NSString *)column columnValue:(id)aValue;
+(BOOL)deleteALLData:(NSString *)tableName;
+(BOOL)updateData:(NSString *)tableName tableColumn:(NSString *)column columnValue:(NSString *)aValue conditionColumn:(NSString *)conColumn conditionColumnValue:(id)conValue;
+(NSArray *)queryData:(NSString *)aName theColumn:(NSString *)aColumn theColumnValue:(NSString *)aColumnValue  withAll:(BOOL)yesNO;
+(NSArray *)queryData:(NSString *)aName theColumn:(NSString *)aColumn equalValue:(id)aColumnValue theColumn:(NSString*)bColumn equalValue:(id)bColumnValue;

+(NSArray *)selectColumn:(NSString *)theColumn tableName:(NSString *)aTableName conColumn:(NSString *)aColumn conColumnValue:(NSString *)aColumnValue withWholeColumn:(BOOL)yesNO;
+(NSArray *)selectTopNColumn:(NSString *)theColumn tableName:(NSString *)aTableName rowNum:(NSInteger)n;
+(NSArray *)selectColumnWithOrder:(NSString *)theColumn tableName:(NSString *)aTableName conColumn:(NSString *)aColumn conColumnValue:(NSString *)aColumnValue orderBy:(NSString *)descOrAsc;
+(BOOL)insertDataWithnotAutoID:(NSArray *)data tableName:(NSString *)aName;
//get goodsclass 
+(NSArray *)getGoodsClassfromBaseGoodsClass:(NSString *)aColumn conColumnValue:(NSString *)aValue;
+(NSArray *)getGoodsClassfromTopics:(NSString *)aColumn conColumnValue:(NSString *)aValue;
+(NSMutableArray *)getVIPCardArrayWithConditionColumn:(NSString *)aColumn coColumnValue:(NSString *)aValue;
+(NSMutableArray *)getBankCardArrayWithConditionColumn:(NSString *)aColumn coColumnValue:(NSString *)aValue;
//get Notes class 便签
+(NSMutableArray *)getNotesClass;
//得到指定行数的Notes记录,n为0则选择所有行
+(NSMutableArray *)getNotesClassSpecifyRowAmount:(NSInteger)n withOrder:(NSString *)order;

//ADD BY MIAOYUNZ
+(BOOL)deleteData:(NSString *)tableName;
//+(BOOL)updateData:(NSString *)tableName tableColumn:(NSString *)column columnValue:(NSString *)aValue 
//		condition:(NSString *)con;
//+(BOOL)deleteData:(NSString *)tableName condition:(NSString *)con;
+(NSArray *)getShoppingCartWithConditions:(NSString *)aColumn  columnValue:(NSString *)aValue;
//------
//add by zhanghao
//查询购物车中所有商品的总数
+(NSString *)getTotalCountOfCartGoods:(NSString *)VIPID;


//两个查询条件 select * from tabelName where columnOne=valueOne and columnTow=calueTwo
+(NSArray *)qureyWithTwoConditions:(NSString *)tabelName ColumnOne:(NSString *)columnOne valueOne:(NSString *)valueOne columnTwo:(NSString *)columnTwo valueTwo:(NSString *)valueTwo;
//带两个条件的更新
//update tabelName set Column=aValue where columnOne=valueOne and columnTwo=valueTwo
+(BOOL)updateWithTwoConditions:(NSString *)tabelName theColumn:(NSString *)Column theColumnValue:(NSString *)aValue ColumnOne:(NSString *)columnOne valueOne:(NSString *)valueOne columnTwo:(NSString *)columnTwo valueTwo:(NSString *)valueTwo;
//带两个条件的删除 
//delete from tablename where columnOnew=columnOne and columnTwo=colunmTwo
+(BOOL)deleteDataWithTwoConditions:(NSString *)tableName columnOne:(NSString *)columnOne valueOne:(NSString *)valueOne columnTwo:(NSString *)columnTwo  valueTwo:(NSString *)valueTwo;

//查询整个表 支持一个条件跟排序
+(NSMutableArray *)queryData:(NSString *)aName theColumn:(NSString *)aColumn theColumnValue:(NSString *)aColumnValue orderBy:(NSString *)orderByString orderType:(NSString *)orderTypeString withAll:(BOOL)yesNO;

//查询整个表 支持多个条件跟排序
+(NSMutableArray *)queryData:(NSString *)aName theColumn:(NSString *)aColumn theColumnValue:(NSString *)aColumnValue orderByOne:(NSString *)orderByStringOne orderTypeOne:(NSString *)orderTypeStringOne orderByTwo:(NSString *)orderByStringTwo orderTypeTwo:(NSString *)orderTypeStringTwo withAll:(BOOL)yesNO;

//query 主要用户更新 删除
+(BOOL)querySql:(NSString *)sql;

//获取所有活跃会员ID
+(NSArray *)selectActiveMember;


//查询全国省市区
+ (NSMutableArray *)getAllIDFromPri:(NSString *)selectContent  whereContent:(NSString *)whereContent;

@end
