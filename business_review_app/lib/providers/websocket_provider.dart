import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

/// Provider for managing WebSocket connection and notifications
class WebSocketProvider extends ChangeNotifier {
  WebSocketService? _wsService;
  String? _lastNotification;
  DateTime? _lastNotificationTime;
  Map<String, dynamic>? _lastReviewData;
  
  /// Get the last notification message
  String? get lastNotification => _lastNotification;
  
  /// Get the last notification time
  DateTime? get lastNotificationTime => _lastNotificationTime;
  
  /// Get the last review data from WebSocket
  Map<String, dynamic>? get lastReviewData => _lastReviewData;
  
  /// Check if WebSocket is connected
  bool get isConnected => _wsService?.isConnected ?? false;
  
  WebSocketProvider();
  
  /// Initialize WebSocket with business_id
  void initWithBusinessId(String businessId) {
    try {
      _wsService?.dispose();
      
      _wsService = WebSocketService(businessId: businessId);
      _wsService!.connect();
      
      _wsService!.messages.listen((message) {
        _handleWebSocketMessage(message);
      });
    } catch (e) {
      print('[WebSocketProvider] Failed to initialize: $e');
    }
  }
  
  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final type = message['type'] as String?;
    final messageText = message['message'] as String?;
    final data = message['data'] as Map<String, dynamic>?;
    
    if (type == 'new_review') {
      _lastNotification = messageText ?? 'New review received!';
      _lastNotificationTime = DateTime.now();
      _lastReviewData = data;
      notifyListeners();
    } else if (type == 'review_analyzed') {
      _lastNotification = messageText ?? 'Review analysis completed!';
      _lastNotificationTime = DateTime.now();
      _lastReviewData = data;
      notifyListeners();
    }
  }
  
  /// Clear the last notification
  void clearNotification() {
    _lastNotification = null;
    _lastNotificationTime = null;
    _lastReviewData = null;
    notifyListeners();
  }
  
  /// Reconnect to WebSocket
  void reconnect() {
    _wsService?.disconnect();
    _wsService?.connect();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _wsService?.dispose();
    super.dispose();
  }
}
