import 'package:flutter/material.dart';
import 'package:rental_manager/globals.dart' as globals;

Map<String, String> EnglishToSimplifiedChinese = {
  "Cancel Reservation": "取消预订",
  "Select a Location": "选择地点",
  "Category": "类别",
  "Category Selected: ": "选择类别为",
  "show all": "展示全部",
  "All Items": "全部物品",
  "Account Details": "详细",
  "loading...": "加载中...`",
  "Total amount:": "总计数量:",
  "Details of:": "物品详情",
  "Locations": "地点",
  "Loading...": "加载中",
  "Reservation": "预订",
  "Reservations": "预订",
  "Reservation Details": "预订明细",
  "item name:": "物品名称: ",
  "start time:" : "开始时间: ",
  "end time:" : "结束时间: ",
  "quantity:": "数量: ",
  "Reserved": "已预订",
  "item status:" : "物品状态: ",
  "Time Left To Pick Up:" : "剩余领取时间: ",
  "Minutes": "分钟",
  "Pick Up": "点击领取",
  "Cancel": "取消",
  "Reserve Now": "现在预订",
  "Remaining Amount:": "剩余数量",
  "Help": "帮助",
  "Chat": "聊天",
  "Track": "查看用量",
  "Bring us your ideas": "提供意见",
  "Lost And Found": "丢失物品",
  "Email" : "邮件",
  "Subject": "主题",
  "Text": "文本",
  "Please fill in the blank": "请完成填写所有空白处",
  "Please enter your valid email address": "请输入有效的邮箱地址",
  "Submit": "提交",
  "Dismiss": "隐藏",
  "Write down your ideas": "欢迎您提供任何您宝贵的意见",
  "Track you favor": "物品使用数据查询",
  "Usage Statistics:" : "使用统计:",
  "Morning Usage" : "早上使用情况",
  "Afternoon Usage": "下午使用情况",
  "Evening Usage": "晚上使用情况",
  "Feedback": "用户使用反馈",
  "Average Hour": "平均使用时间",
  "Preference": "预订量",
  "User Info": "我的",
  "Orders": "现存订单",
  "History": "历史订单",
  "Details & Password": "资料编辑",
  "Theme Color": "主题设置",
  "Log Out": "退出",
  "QR Code": "二维码",
  "History Reservation": "历史订单",
  "Username": "用户名",
  "Employer ID": "工作证件号码",
  "Phone": "手机号码",
  "Confirm" : "确认",
  "Language Setting": "语言设置",
  "By system Defaulting Setting": "根据系统设置",
  "Account": "我的",
  'Manager View' : "管理者视角",
  "Manage" : "管理",
  'Click Image to Change': '点击图片进行更改',
  'Use Image URL Instead': '使用图片超链接',
  'Item Name': '物品名称',
  'Item Amount': '物品数量',
  "Return Items": "归还",
  "Please Confirm": "请确认",
  'Manage': '管理',
  'Manage your Database': '编辑数据库',
  "Leave it empty if this is not used": '若不使用 请留空',
  "Amount:" : "数量: ",
  "Add items via a CSV file": "通过CSV文件添加物品",
  "Add items manually" : " 手动添加",
  "Delete": "删除",
  'Email': '电子邮件',
  'email': '电子邮件',
  'Forgot Password': '忘记密码',
  'Register': '注册',
  'New to Rental Manager?' : '新用户？',
  "Sign In With Scan" : '二维码扫码登录',
  "LOGIN With Google" : '谷歌登录',
  'Warning': '请注意',
  'Email Adress and Password Cannot be empty': '用户名和邮箱都不得为空',
  'ERROR Email NEED VERFIED': '请注意查收邮箱',
  'Verify Your Email Please': '请使用邮箱内的信息进行验证后登录',
  'First Name': '名',
  'Lastname': '姓氏',
  'Password': '密码',
  'Confirm Password': '请再次核对密码',
  'select an ogranization': '您所在机构?',
  'Click sign up after entering all of above': '完成填空请点击下方按钮',
  "SIGN UP": '注册',
  'Each Field should be filled in': '请检查有空余处并填写',
  'Your Password should be matched': '请您核对您所输入的密码',
  'LOGIN': '登录',
  'Enter your Email Address': '请输入邮箱地址',
  'Enter your Password': '请输入密码',
  "Send Verification Email": "发送确认短信",
  'Reset PassWord': '忘记密码',

};


Map<String, String> EnglishToTranditionalChinese = {
  "Select a Location": "选择地点",
};
Map <String, String> EnglishToSpanish = {};

String langaugeSetFunc(String text){

  if(globals.langaugeSet == "English"){
    return text;
  }else if(globals.langaugeSet == "SimplifiedChinese"){
    if(EnglishToSimplifiedChinese[text] == null){
      print("Fail to translate the word: " + text);
      return text;
    }

    return EnglishToSimplifiedChinese[text];
  }else if(globals.langaugeSet == "TranditionalChinese"){
    if(EnglishToTranditionalChinese[text] == null){
      return text;
    }
    return EnglishToTranditionalChinese[text];
  }else if(globals.langaugeSet == "Spanish"){
    if(EnglishToSpanish[text] == null){
      return text;
    }

    return EnglishToSpanish[text];
  }
}
