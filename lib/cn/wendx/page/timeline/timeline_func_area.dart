
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

class TimelineFuncArea extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child:Column(
        children: [
          SearchArea(),
          SizedBox(height: 5,),
          Divider(height: 5,),
          SizedBox(height: 5,),
          Center(child: Text("这里还可以放很多东西,之后在放进来"),),
        ],
      )
    );
  }

}

class SearchArea extends StatelessWidget{
  final TextEditingController _content = TextEditingController();
  final TextEditingController _pickDateRange = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            icon: Icon(
              Icons.content_paste_search,
            ),
            labelText: "搜索内容",
          ),
          // controller: _content,
        ),
        TextField(
          decoration: const InputDecoration(
              hintText: "点击选择时间", icon: Icon(Icons.timer)),
          controller: _pickDateRange,
          onTap: () {
            showCalendarDatePicker2Dialog(
              context: context,
              config:
              CalendarDatePicker2WithActionButtonsConfig(
                calendarType: CalendarDatePicker2Type.range,
                okButton: const Text("选择"),
                cancelButton: const Text("取消"),
              ),
              dialogSize: const Size(325, 400),
              value: [DateTime.now()],
              borderRadius: BorderRadius.circular(15),
            ).then((date) {
              print(date.toString());

            });
          },
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
                onPressed: () {

                },
                icon: const Icon(Icons.lock_reset,size: 15,),
                label: const Text("重置",style: TextStyle(fontSize: 12),)),
            SizedBox(width: 10,),
            ElevatedButton.icon(
                onPressed: () {

                },
                icon: const Icon(Icons.send,size: 15,),
                label: const Text("搜索",style: TextStyle(fontSize: 12),)),
          ],
        )
      ],
    );
  }
}