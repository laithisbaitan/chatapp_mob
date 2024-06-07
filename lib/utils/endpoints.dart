class Endpoints {
  static const base = 'laith-chatapp.gigalixirapp.com/api';
  static const httpProtocol = 'https';
  static const rooms = '$httpProtocol://$base/rooms';
  static String getMessages(String roomId) =>
      '$httpProtocol://$base/rooms/$roomId/chat';
  static const websocket =
      'ws://laith-chatapp.gigalixirapp.com/socket/websocket';
}
