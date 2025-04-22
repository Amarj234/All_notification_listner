import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_database/firebase_database.dart';

class ScreenSharePage extends StatefulWidget {
  @override
  _ScreenSharePageState createState() => _ScreenSharePageState();
}

class _ScreenSharePageState extends State<ScreenSharePage> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  final databaseReference = FirebaseDatabase.instance;

  late RTCVideoRenderer localRenderer;
  late RTCVideoRenderer remoteRenderer;

  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  String? _roomId;

  @override
  void initState() {
    super.initState();
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();
    localRenderer.initialize();
    remoteRenderer.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    localRenderer.dispose();
    remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
  }

  Future<void> _startScreenShare() async {
    try {
      // Request screen capture
      MediaStream stream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'mediaSource': 'screen',
        },
      });

      _localStream = stream;
      localRenderer.srcObject = stream;

      // Send the screen-sharing stream to the remote peer
      _peerConnection?.addStream(stream);

      // Once stream is added, update Firebase signaling with the offer
      await _sendOffer();
    } catch (e) {
      print("Error starting screen share: $e");
    }
  }

  Future<void> _sendOffer() async {
    final RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    // Send the offer to Firebase (to the remote user)
    databaseReference.ref("test").child('signaling').child('offer').set({
      'from': 'user1',
      'to': 'user2',
      'sdp': offer.sdp,
    });
  }

  Future<void> _startCall() async {
    // Set up peer connection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': 'stun:stun.l.google.com:19302', // Example STUN server
        }
      ],
    });

    _peerConnection!.onIceCandidate = (candidate) {
      // Send ICE candidates to Firebase
      databaseReference.ref("test").child('signaling').child('candidates').push().set({
        'candidate': candidate.candidate,
      });
    };

    // Create offer and send it to the other peer
    await _sendOffer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Share App'),
      ),
      body: Column(
        children: [
          RTCVideoView(localRenderer),
          RTCVideoView(remoteRenderer),
          ElevatedButton(
            onPressed: _startScreenShare,
            child: Text('Start Screen Share'),
          ),
        ],
      ),
    );
  }
}
