import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:timeline/cn/wendx/repo/impl/sqlite_timeline_repository.dart';
import 'package:timeline/cn/wendx/repo/timeline_reporitory.dart';
import 'package:timelines/timelines.dart';

class ContentAreaComp extends StatefulWidget {
  OrderInfo _orderInfo;

  Function? listen;

  ContentAreaComp(this._orderInfo,{this.listen});

  @override
  State<StatefulWidget> createState() {
    return ContentAreaState();
  }
}

class ContentAreaState extends State<ContentAreaComp> {
  final ScrollController _scrollController = ScrollController();
  Function? listen;
  @override
  void initState() {
    super.initState();
    listen = widget.listen;
  }

  void scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut); // 动画滚动到底部
  }

  @override
  Widget build(BuildContext context) {
    final data = widget._orderInfo;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
    return Card(
        margin: const EdgeInsets.all(15),
        child: Container(
          margin: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _OrderTitle(
                  orderInfo: data,
                ),
              ),
              const Divider(height: 1.0),
              Expanded(
                  flex: 1,
                  child: ListView(controller: _scrollController, children: [
                    _DeliveryProcesses(processes: data.deliveryProcesses,listen: listen)
                  ])),
            ],
          ),
        ));
  }
}

class _OrderTitle extends StatelessWidget {
  const _OrderTitle({
    Key? key,
    required this.orderInfo,
  }) : super(key: key);

  final OrderInfo orderInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '日期：${orderInfo.date.year}/${orderInfo.date.month}/${orderInfo.date.day}',
          // style: const TextStyle(
          //   color: Color(0xffb6b2b2),
          // ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _InnerTimeline extends StatelessWidget {
  _InnerTimeline({
    required this.messages,
    this.listen
  });
  Function? listen;
  final List<DeliveryMessage> messages;

  @override
  Widget build(BuildContext context) {
    bool isEdgeIndex(int index) {
      return index == 0 || index == messages.length + 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FixedTimeline.tileBuilder(
        theme: TimelineTheme.of(context).copyWith(
          nodePosition: 0,
          connectorTheme: TimelineTheme.of(context).connectorTheme.copyWith(
                thickness: 1.0,
              ),
          indicatorTheme: TimelineTheme.of(context).indicatorTheme.copyWith(
                size: 10.0,
                position: 0.5,
              ),
        ),
        builder: TimelineTileBuilder(
          indicatorBuilder: (_, index) =>
              !isEdgeIndex(index) ? Indicator.outlined(borderWidth: 1.0) : null,
          startConnectorBuilder: (_, index) => Connector.solidLine(),
          endConnectorBuilder: (_, index) => Connector.solidLine(),
          contentsBuilder: (_, index) {
            if (isEdgeIndex(index)) {
              return null;
            }

            return _ContentItem(messages[index - 1],listen: listen,);
          },
          itemExtentBuilder: (_, index) => isEdgeIndex(index) ? 10.0 : 30.0,
          nodeItemOverlapBuilder: (_, index) =>
              isEdgeIndex(index) ? true : null,
          itemCount: messages.length + 2,
        ),
      ),
    );
  }
}

class _ContentItem extends StatelessWidget {
  DeliveryMessage deliveryMessage;

  late TimelineRepository repo;

  Function? listen;

  bool changeFlag = false;

  _ContentItem(this.deliveryMessage,{this.listen});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (PointerUpEvent event) {
        repo = GetIt.instance.get<TimelineRepository>();
        repo.readByDataTime(deliveryMessage.dateTime).then((content) {
          var size = MediaQuery.of(context).size;
          var height = size.height;
          var width = size.width;
          TextEditingController contentController = TextEditingController();
          contentController.text = content;
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: Text("修改内容"),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            showDeleteTip(
                                deliveryMessage.dateTime, repo, context)
                                .then((value) {
                              if (value == "ok") {
                                Navigator.of(context).pop();
                                if(listen != null){
                                  listen!();
                                }
                              }
                            });
                          },
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(Colors.grey)),
                          child: Text("删除")),
                      ElevatedButton(
                          onPressed: () {
                            if(changeFlag && listen != null){
                              listen!();
                            }
                            Navigator.of(context).pop();
                          },
                          child: Text("取消")),
                      ElevatedButton(
                          onPressed: () {
                            if (contentController.text.isEmpty &&
                                contentController.text == content) {
                              showTip("内容未发生变更", context);
                              return;
                            }
                            showChangeTip(deliveryMessage.dateTime,
                                contentController.text, repo, context).then((value) {
                              if(value == "ok"){
                                changeFlag = true;
                              }
                            });
                          },
                          child: Text("保存")),
                    ],
                    content: Container(
                      width: width * 0.8,
                      // height: height *0.8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("创建时间：${deliveryMessage.dateTime}"),
                          ),
                          SizedBox(height: 10),
                          Divider(
                            height: 2,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("内容:"),
                          ),
                          Container(
                            width: double.infinity,
                            child: Card(
                              margin: EdgeInsets.all(10),
                              child: TextField(
                                autofocus: true,
                                controller: contentController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 8,
                                maxLength: 4000,
                              ),
                            ),
                          )
                        ],
                      ),
                    ));
              });
        });
      },
      child: Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: deliveryMessage.display(context)
      ),
    );
  }

  Future showDeleteTip(DateTime dDateTime, TimelineRepository repository,
      BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("警告"),
            content: Text("确认删除数据？删除后将无法恢复"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  repository.deleteByDateTime(dDateTime).then((r) {
                    Navigator.of(context).pop("ok");
                  });
                },
                child: Text("删除"),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey)),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop("cancel");
                  },
                  child: Text("取消")),
            ],
          );
        });
  }

  Future showChangeTip(DateTime dDateTime, String content,
      TimelineRepository repository, BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("确认修改数据？修改后旧数据将被覆盖"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop("cancel");
                  },
                  child: Text("取消")),
              ElevatedButton(
                onPressed: () {
                  repository.updateByDateTime(dDateTime, content).then((r) {
                    Navigator.of(context).pop("ok");
                  });
                },
                child: Text("修改"),
              ),
            ],
          );
        });
  }

  Future showTip(String tip, BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text(tip),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("确认")),
            ],
          );
        });
  }
}

class _DeliveryProcesses extends StatelessWidget {
  _DeliveryProcesses({Key? key, required this.processes,this.listen}) : super(key: key);

  final List<DeliveryProcess> processes;
  Function? listen;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Color(0xff9b9b9b),
        fontSize: 16.5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FixedTimeline.tileBuilder(
          theme: TimelineThemeData(
            nodePosition: 0,
            color: Color(0xff989898),
            indicatorTheme: IndicatorThemeData(
              position: 0,
              size: 20.0,
            ),
            connectorTheme: ConnectorThemeData(
              thickness: 2.5,
            ),
          ),
          builder: TimelineTileBuilder.connected(
            connectionDirection: ConnectionDirection.before,
            itemCount: processes.length,
            contentsBuilder: (_, index) {
              List<Widget> innerTimeline = [
                Text(
                  processes[index].name,
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 24.0,
                      ),
                ),
              ];
              if (!processes[index].isCompleted) {
                innerTimeline
                    .add(_InnerTimeline(messages: processes[index].messages,listen: listen,));
              }

              return Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: innerTimeline,
                ),
              );
            },
            indicatorBuilder: (_, index) {
              if (processes[index].isCompleted) {
                return DotIndicator(
                  color: Colors.blue,
                  child: Icon(
                    Icons.arrow_right,
                    color: Colors.white,
                    size: 12.0,
                  ),
                );
              } else {
                return OutlinedDotIndicator(
                  borderWidth: 2.5,
                );
              }
            },
            connectorBuilder: (_, index, ___) => SolidLineConnector(
              color: processes[index].isCompleted ? Colors.blue : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _OnTimeBar extends StatelessWidget {
  _OnTimeBar({Key? key, required this.driver}) : super(key: key);

  final DriverInfo driver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MaterialButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('On-time!'),
              ),
            );
          },
          elevation: 0,
          shape: StadiumBorder(),
          color: Color(0xff66c97f),
          textColor: Colors.white,
          child: Text('On-time'),
        ),
        Spacer(),
        Text(
          'Driver\n${driver.name}',
          textAlign: TextAlign.center,
        ),
        SizedBox(width: 12.0),
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              image: NetworkImage(
                driver.thumbnailUrl,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OrderInfo {
  OrderInfo({
    required this.id,
    required this.date,
    required this.driverInfo,
    required this.deliveryProcesses,
  });

  final int id;
  final DateTime date;
  final DriverInfo driverInfo;
  final List<DeliveryProcess> deliveryProcesses;
}

class DriverInfo {
  const DriverInfo({
    required this.name,
    required this.thumbnailUrl,
  });

  final String name;
  final String thumbnailUrl;
}

class DeliveryProcess {
  DeliveryProcess(
    this.name, {
    this.completed = false,
    List<DeliveryMessage>? deliveryMessageList,
  }) : this.messages = deliveryMessageList ?? [];

  DeliveryProcess.complete(this.name)
      : this.messages = [],
        this.completed = true;

  final String name;
  final List<DeliveryMessage> messages;
  final bool completed;

  bool get isCompleted => completed;
}

class DeliveryMessage {
  DeliveryMessage(this.dateTime, this.createdAt, this.message);

  final DateTime dateTime;
  final String createdAt; // final DateTime createdAt;
  final String message;

  @override
  String toString() {
    return '$createdAt  $message';
  }

  Widget display(BuildContext context){
    var split = message.split("\n");
    //return Text('$createdAt  ${split[0]} ${split.length> 01?'...':""}');
    List<Widget> wl = [
      Text('$createdAt  ${split[0]} ${split.length> 01?'...':""}')
    ];
    if(split.length > 1){
      wl.add(Icon(Icons.unfold_more,color: Theme.of(context).colorScheme.secondary,));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: wl,
    );
  }
}
