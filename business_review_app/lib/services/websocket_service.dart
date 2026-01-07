import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

/// WebSocket service for real-time updates from the backend
class WebSocketService {
  static const String wsBaseUrl = 'wss://cricket-fun-polecat.ngrok-free.app/ws';
  
  final String? businessId;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  
  /// Stream of incoming WebSocket messages
  Stream<Map<String, dynamic>> get messages => _messageController!.stream;
  
  /// Check if WebSocket is currently connected
  bool get isConnected => _isConnected;
  
  WebSocketService({this.businessId}) {
    _messageController = StreamController<Map<String, dynamic>>.broadcast();
  }
  
  /// Connect to the WebSocket server
  void connect() {
    if (_isConnected) {
      debugPrint('[WebSocket] Already connected');
      return;
    }
    
    try {
      final wsUrl = businessId != null 
          ? '$wsBaseUrl/$businessId' 
          : wsBaseUrl;
      debugPrint('[WebSocket] Connecting to $wsUrl...');
      _shouldReconnect = true;
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (message) {
          _isConnected = true;
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('[WebSocket] Error: $error');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('[WebSocket] Connection closed');
          _handleDisconnect();
        },
      );
      
      _startPingTimer();
      
      debugPrint('[WebSocket] Connected successfully');
    } catch (e) {
      debugPrint('[WebSocket] Connection failed: $e');
      _handleDisconnect();
    }
  }
  
  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      if (message is String) {
        if (message == 'pong') {
          return;
        }
        
        try {
          final data = jsonDecode(message) as Map<String, dynamic>;
          _messageController?.add(data);
        } catch (e) {
          _messageController?.add({
            'type': 'text',
            'message': message,
          });
        }
      }
    } catch (e) {
      debugPrint('[WebSocket] Error handling message: $e');
    }
  }
  
  /// Start sending periodic pings to keep connection alive
  void _startPingTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add('ping');
        } catch (e) {
          debugPrint('[WebSocket] Error sending ping: $e');
          _handleDisconnect();
        }
      }
    });
  }
  
  /// Handle disconnection and attempt to reconnect
  void _handleDisconnect() {
    _isConnected = false;
    _reconnectTimer?.cancel();
    
    if (_shouldReconnect) {
      debugPrint('[WebSocket] Reconnecting in 5 seconds...');
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        connect();
      });
    }
  }
  
  /// Send a message through the WebSocket
  void send(String message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(message);
      } catch (e) {
        debugPrint('[WebSocket] Error sending message: $e');
      }
    } else {
      debugPrint('[WebSocket] Cannot send message - not connected');
    }
  }
  
  /// Disconnect from the WebSocket server
  void disconnect() {
    debugPrint('[WebSocket] Disconnecting...');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _isConnected = false;
    
    try {
      _channel?.sink.close();
    } catch (e) {
      debugPrint('[WebSocket] Error closing connection: $e');
    }
    
    _channel = null;
  }
  
  /// Clean up resources
  void dispose() {
    disconnect();
    _messageController?.close();
    _messageController = null;
  }
}
