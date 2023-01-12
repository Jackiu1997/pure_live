import 'package:flutter/material.dart';
import 'package:flutter_barrage/flutter_barrage.dart';
import 'package:hot_live/model/danmaku.dart';
import 'package:hot_live/model/liveroom.dart';
import 'package:hot_live/provider/settings_provider.dart';
import 'package:hot_live/utils/danmaku/danmaku_stream.dart';
import 'package:provider/provider.dart';

class DanmakuListView extends StatefulWidget {
  final RoomInfo room;
  final DanmakuStream danmakuStream;
  final BarrageWallController barrageWallController;

  const DanmakuListView({
    Key? key,
    required this.room,
    required this.danmakuStream,
    required this.barrageWallController,
  }) : super(key: key);

  @override
  State<DanmakuListView> createState() => _DanmakuListViewState();
}

class _DanmakuListViewState extends State<DanmakuListView>
    with AutomaticKeepAliveClientMixin<DanmakuListView> {
  final List<DanmakuInfo> _danmakuList = [];
  final ScrollController _scrollController = ScrollController();

  _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    widget.danmakuStream.setDanmakuListener((info) {
      widget.barrageWallController
          .send([Bullet(child: DanmakuText(message: info.msg))]);
      setState(() {
        _danmakuList.add(info);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView.builder(
      controller: _scrollController,
      itemCount: _danmakuList.length,
      padding: const EdgeInsets.only(left: 5, top: 2, right: 5),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final danmaku = _danmakuList[index];
        return Container(
          padding: const EdgeInsets.all(5),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: " ${danmaku.name} : ",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: danmaku.action.isEmpty
                      ? danmaku.msg
                      : "${danmaku.action} ${danmaku.count} 个 ${danmaku.msg}",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DanmakuText extends StatelessWidget {
  const DanmakuText({Key? key, required this.message}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    SettingsProvider settings = Provider.of<SettingsProvider>(context);

    return Text(
      message,
      style: TextStyle(
        fontSize: settings.danmakuFontSize,
        fontWeight: FontWeight.w400,
        color: Colors.white.withOpacity(settings.danmakuOpcity),
      ),
    );
  }
}