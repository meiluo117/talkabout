//
//  CXPHttpUrl.h
//  talkabout
//
//  Created by 于波 on 15/12/18.
//  Copyright © 2015年 于波. All rights reserved.
//
//http://192.168.171.225:13088/api/login/login?password=123456&username=18640418564&source=1

#ifndef CXPHttpUrl_h
#define CXPHttpUrl_h

/**登录*/
//#define URL_LOGIN @"http://192.168.171.225:13088/api/login/login"
#define URL_LOGIN @"http://bp.chuangxp.com/api/login/login"

/**首页bp列表*/
#define URL_BPHOME @"http://bp.chuangxp.com/api/bp/list"
//#define URL_BPHOME @"http://192.168.171.225:13088/api/bp/list?token=%@&page=%d"

/**修改bp名称，时间，进度的三合一接口*/
#define URL_BPChangeNameTimeStatus @"http://bp.chuangxp.com/api/bp/editBpInfo"
//http://localhost:8083/chxp-bp/api/bp/eidtBpInfo?bpId=38&token=665f644e43731ff9db3d341da5c827e1&name=shahade&status=1&source=1&time=2015-12-28

/**bp删除*/
//http://localhost:8083/chxp-bp/api/bp/delete?bpId=38&token=665f644e43731ff9db3d341da5c827e1
#define URL_BPDelete @"http://bp.chuangxp.com/api/bp/delete"

/**bp已读未读状态*/
//http://bp.chuangxp.com/api/bp/read?bpId=38&token=665f644e43731ff9db3d341da5c827e1&read=1&source=1
#define URL_BPReadOrUnread @"http://bp.chuangxp.com/api/bp/read"

/**bp备注*/
#define URL_BPComment @"http://bp.chuangxp.com/api/bp/remark"
//http://localhost:8083/chxp-bp/api/bp/remark?bpId=38&token=665f644e43731ff9db3d341da5c827e1&content=shahade

/**bp分享纪录*/
#define URL_BPSharedRecord @"http://bp.chuangxp.com/api/bp/share"

/**bp文件上传*/
#define URL_BPUpload @"http://bp.chuangxp.com/api/upload/file"
//http://localhost:8083/chxp-bp/api/upload/file?token=665f644e43731ff9db3d341da5c827e1

/**我的*/
#define URL_BPMe @"http://bp.chuangxp.com/api/user/info"

/**bp搜索*/
#define URL_BPSearch @"http://bp.chuangxp.com/api/bp/list?token=%@&page=1&name=%@"

/**短信验证手机*/
#define URL_VERIFICATION_PHONE @"http://bp.chuangxp.com/api/login/getcode"

/**注册*/
#define URL_REGISTER @"http://bp.chuangxp.com/api/login/regist"

/**上传图片 头像/名片*/
#define URL_SEND_IMAGE @"http://bp.chuangxp.com/api/upload/image_file"

/**注册我的页*/
#define URL_ABOUTME @"http://bp.chuangxp.com/api/user/update"
//http://localhost:8083/chxp-bp/api/user/update?realName=真实名&mobile=18640418564&company=公司&position=职位&headImg=http://7xovgk.com2.z0.glb.qiniucdn.com/9ff20fa59204c27a5d513bf9ccc9a173fe0be2959d4ffef2e198cd056a6075e0&wechat=微信号&card=http://7xovgk.com2.z0.glb.qiniucdn.com/62490ebd57a89a003e6649b6c93ffc018057ea21d7741d81e8cdf22de8b4fede&token=665f644e43731ff9db3d341da5c827e1…&source=1

/**修改密码*/
#define URL_CHANGE_PASSWORD @"http://bp.chuangxp.com/api/user/reset/pwd"

/**忘记密码*/
#define URL_FORGET_PASSWORD @"http://bp.chuangxp.com/api/user/forget/pwdbymobile"

/**已注册用户需要发送手机短信验证码的接口*/
#define URL_ALREADY_REGISTER @"http://bp.chuangxp.com/api/login/getcodeforuser"

/**忘记密码 点击确定 发送验证码和手机号*/
#define URL_SEND_CODE @"http://bp.chuangxp.com/api/login/validCode"

/**微信三方登陆*/
#define URL_WECHAT_LOGIN @"http://bp.chuangxp.com/api/login/wechatLogin"
/**qq三方登陆*/
#define URL_QQ_LOGIN @"http://bp.chuangxp.com/api/login/tencentLogin"
/**微博三方登陆*/
#define URL_WEIBO_LOGIN @"http://bp.chuangxp.com/api/login/sinaLogin"

#endif /* CXPHttpUrl_h */
