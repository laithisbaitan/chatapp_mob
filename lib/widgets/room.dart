import 'dart:convert';

import 'package:chatapp_mob/model/message.dart';
import 'package:chatapp_mob/utils/endpoints.dart';
import 'package:chatapp_mob/widgets/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:phoenix_socket/phoenix_socket.dart';

class WRoom extends StatefulWidget {
  final int roomId;
  const WRoom({super.key, required this.roomId});

  @override
  State<WRoom> createState() => _WRoomState();
}

class _WRoomState extends State<WRoom> {
  List<MMessage> _messages = [];
  PhoenixChannel? _channel;
  final TextEditingController _messageController = TextEditingController();
  late FocusNode _focusNode;
  ScrollController scrollController = ScrollController(keepScrollOffset: false);
  bool _scrollToEnd = false;

  void joinRoom() {
    var socket = PhoenixSocket(Endpoints.websocket)..connect();
    socket.openStream.listen((event) {
      print('socket connected');
      var channel = socket.addChannel(topic: 'room:${widget.roomId}');
      channel.join();
      setState(() {
        _channel = channel;
      });
    });
    socket.closeStream.listen((event) {
      print('socket disconnected');
    });
  }

  void getMessages() async {
    try {
      var res = await http
          .get(Uri.parse(Endpoints.getMessages(widget.roomId.toString())));
      var jsonBody = jsonDecode(res.body);
      if (jsonBody["success"] == true) {
        setState(() {
          _messages = (jsonBody["data"] as List)
              .map((el) => MMessage.fromJSON(el))
              .toList();
          _scrollToEnd = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void postMessage() {
    print('text=>');
    print(_messageController.text);
    if (_messageController.text.isEmpty) return;
    _channel?.push('new_message', {
      "payload": {"content": _messageController.text}
    });
    _focusNode.requestFocus();
    _messageController.clear();
  }

  @override
  void initState() {
    super.initState();
    getMessages();
    joinRoom();
    setState(() {
      _focusNode = FocusNode();
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(((_) {
      if (_scrollToEnd) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
    }));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Chatapp | Chat'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                  stream: _channel?.messages,
                  initialData: Message(
                    event: PhoenixChannelEvent.join,
                    joinRef: '',
                    payload: const {'times': 0},
                    ref: '',
                    topic: '',
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<Message?> snapshot) {
                    var newMessage =
                        snapshot.data?.payload?['payload']?['message'];
                    if (newMessage != null) {
                      _messages.add(MMessage.fromJSON(newMessage));
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 300),
                        );
                      });
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return WMessage(message: _messages[index]);
                      },
                    );
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                        hintText: 'Start Typing...',
                        hintStyle: TextStyle(color: Colors.white)),
                  ),
                ),
                Material(
                  child: MaterialButton(
                    onPressed: postMessage,
                    minWidth: 200,
                    elevation: 6.0,
                    color: Colors.blueGrey[900],
                    child: const Text(
                      'Send',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
