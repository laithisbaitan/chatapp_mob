import 'dart:convert';

import 'package:chatapp_mob/model/room.dart';
import 'package:chatapp_mob/utils/endpoints.dart';
import 'package:chatapp_mob/widgets/room.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WRooms extends StatefulWidget {
  const WRooms({super.key});
  static const id = 'ROOMS';

  @override
  State<WRooms> createState() => _WRoomsState();
}

class _WRoomsState extends State<WRooms> {
  List<MRoom> _rooms = [];
  int? _roomId;

  @override
  void initState() {
    super.initState();
    getRooms();
  }

  Future<void> getRooms() async {
    try {
      var res = await http.get(Uri.parse(Endpoints.rooms));
      var jsonBody = jsonDecode(res.body);
      if (jsonBody['success']) {
        setState(() {
          _rooms = (jsonBody['data'] as List)
              .map((el) => MRoom.fromJSON(el))
              .toList();
        });
      }
    } catch (e) {
      print("getrooms crashed **");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _roomId != null
        ? WRoom(roomId: _roomId!)
        : Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text('Chatapp | Rooms'),
              backgroundColor: Colors.red,
            ),
            body: ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                var room = _rooms[index];
                return ListTile(
                  title: Text(
                    room.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    print('${room.name} Tapped');
                    setState(() {
                      _roomId = room.id;
                    });
                  },
                );
              },
            ),
          );
  }
}
