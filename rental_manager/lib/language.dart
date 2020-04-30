import 'package:flutter/material.dart';
import 'package:rental_manager/globals.dart' as globals;

Map<String, String> EnglishToSimplifiedChinese = {
  "Select a Location": "选择地点",
  "Category": "类别",
  "Category Selected: ": "选择类别为",
  "show all": "展示全部",
  "All Items": "全部物品",
  "Details": "详细",
  "loading...": "加载中...`",
  "Total amount:": "总计数量:",
  "Details of:": "物品详情",
  "Locations": "地点",
  "Loading...": "加载中",
  "Reservation": "预订",
  "Reservations": "预订",
  "Reservation Details": "预订明细",
  "item name:": "物品名称: ",
  "start time:": "开始时间: ",
  "end time:": "结束时间: ",
  "quantity:": "数量: ",
  "Reserved": "已预订",
  "item status:": "物品状态: ",
  "Time Left To Pick Up:": "剩余领取时间: ",
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
  "Email": "邮件",
  "Subject": "主题",
  "Text": "文本",
  "Please fill in the blank": "请完成填写所有空白处",
  "Please enter your valid email address": "请输入有效的邮箱地址",
  "Submit": "提交",
  "Dismiss": "隐藏",
  "Write down your ideas": "欢迎您提供任何您宝贵的意见",
  "Track you favor": "物品使用数据查询",
  "Usage Statistics:": "使用统计:",
  "Morning Usage": "早上使用情况",
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
  "Confirm": "确认",
  "Language Setting": "语言设置",
  "By system Defaulting Setting": "根据系统设置",
  "Account": "我的",
};

Map<String, String> EnglishToTranditionalChinese = {
  "Select a Location": "选择地点",
};
Map<String, String> EnglishToSpanish = {};

String langaugeSetFunc(String text) {
  if (globals.langaugeSet == "English") {
    return text;
  } else if (globals.langaugeSet == "SimplifiedChinese") {
    if (EnglishToSimplifiedChinese[text] == null) {
      print("Fail to translate the word: " + text);
      return text;
    }

    return EnglishToSimplifiedChinese[text];
  } else if (globals.langaugeSet == "TranditionalChinese") {
    if (EnglishToTranditionalChinese[text] == null) {
      return text;
    }
    return EnglishToTranditionalChinese[text];
  } else if (globals.langaugeSet == "Spanish") {
    if (EnglishToSpanish[text] == null) {
      return text;
    }

    return EnglishToSpanish[text];
  }
}
