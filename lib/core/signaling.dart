import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;

  Function(Map<String, dynamic>)? onMessageReceived;
  Function()? onUserJoined;
  Function(bool)? onSpeakingDetected;

  // Simplified room management without Firebase
  Map<String, Map<String, dynamic>> _rooms = {};
  Map<String, List<Map<String, dynamic>>> _messages = {};

  Future<String> createRoom(RTCVideoRenderer remoteRenderer) async {
    // Generate a simple room ID
    roomId = DateTime.now().millisecondsSinceEpoch.toString();
    
    print('Create PeerConnection with configuration: $configuration');

    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    // Simplified ICE candidate handling
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      // Store locally instead of Firebase
      if (!_rooms.containsKey(roomId)) {
        _rooms[roomId!] = {};
      }
      if (!_rooms[roomId!]!.containsKey('callerCandidates')) {
        _rooms[roomId!]!['callerCandidates'] = [];
      }
      _rooms[roomId!]!['callerCandidates'].add(candidate.toMap());
    };

    // Add code for creating a room
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};
    _rooms[roomId!] = roomWithOffer;
    
    print('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    return roomId!;
  }

  Future<void> joinRoom(String roomId, RTCVideoRenderer remoteVideo) async {
    print(roomId);
    
    if (_rooms.containsKey(roomId)) {
      print('Create PeerConnection with configuration: $configuration');
      peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      // Simplified ICE candidate handling
      peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate == null) {
          print('onIceCandidate: complete!');
          return;
        }
        print('onIceCandidate: ${candidate.toMap()}');
        if (!_rooms[roomId]!.containsKey('calleeCandidates')) {
          _rooms[roomId]!['calleeCandidates'] = [];
        }
        _rooms[roomId]!['calleeCandidates'].add(candidate.toMap());
      };

      peerConnection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };

      // Code for creating SDP answer
      var data = _rooms[roomId]!;
      print('Got offer $data');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();
      print('Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      _rooms[roomId]!.addAll(roomWithAnswer);
    }
  }

  Future<void> openUserMedia(RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer, bool audio) async {
    try {
      var stream = await navigator.mediaDevices.getUserMedia({
        'audio': audio,
        'video': false, // Add 'video': true if video is also required
      });

      localRenderer.srcObject = stream;
      localStream = stream;

      remoteRenderer.srcObject = await createLocalMediaStream('key');

    } catch (e) {
      print("Error accessing media: $e");
    }
  }

  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
    for (var track in tracks) {
      track.stop();
    }

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();

    if (roomId != null) {
      // Clean up local room data
      _rooms.remove(roomId);
      _messages.remove(roomId);
    }

    localStream!.dispose();
    remoteStream?.dispose();
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }

  void detectSpeaking() async {
    if (peerConnection != null) {
      var stats = await peerConnection!.getStats();
      for (var report in stats) {
        if (report.type == 'inbound-rtp' && report.values['kind'] == 'audio') {
          var audioLevel = report.values['audioLevel'] ?? 0.0;
          print("Audio level: $audioLevel");  // Log audio levels for debugging
          if (audioLevel > 0.0) {
            onSpeakingDetected?.call(true);
          } else {
            onSpeakingDetected?.call(false);
          }
        }
      }
    }
  }

  Future<void> sendMessage(String roomId, String message, String role) async {
    if (!_messages.containsKey(roomId)) {
      _messages[roomId] = [];
    }
    
    _messages[roomId]!.add({
      'sender': role,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void listenForMessages(String roomId) {
    // Simplified message listening - you might want to implement a timer-based approach
    // or use a different real-time solution if needed
    if (_messages.containsKey(roomId)) {
      for (var message in _messages[roomId]!) {
        onMessageReceived?.call(message);
      }
    }
  }
}
