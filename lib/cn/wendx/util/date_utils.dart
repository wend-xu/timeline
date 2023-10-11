import 'package:date_format/date_format.dart';

Function formatDate_yyyy_mm_dd = (DateTime dateTime){
  return formatDate(dateTime,[yyyy,"-",mm,"-",dd]);
};

Function formatDate_yyyy_mm_hh_mm_ss = (DateTime dateTime){
  return formatDate(dateTime,[yyyy,"-",mm,"-",dd," ",hh,":",mm,":",ss]);
};

// 秒级时间戳长度为 10位
Function timestamp_is_second = (int timestamp) => timestamp.toString().length == 10;

// 秒级时间戳补 0 转毫秒
Function timestamp_second_to_milli = (int timestamp) => timestamp*1000;
