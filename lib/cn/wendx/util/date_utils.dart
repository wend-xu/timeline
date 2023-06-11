import 'package:date_format/date_format.dart';

Function formatDate_yyyy_mm_dd = (DateTime dateTime){
  return formatDate(dateTime,[yyyy,"-",mm,"-",dd]);
};

Function formatDate_yyyy_mm_hh_mm_ss = (DateTime dateTime){
  return formatDate(dateTime,[yyyy,"-",mm,"-",dd," ",hh,":",mm,":",ss]);
};