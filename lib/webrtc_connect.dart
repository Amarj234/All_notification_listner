import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCConnection {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;

  WebRTCConnection({required this.localRenderer, required this.remoteRenderer});

  Future<void> initConnection() async {
    _localStream = await navigator.mediaDevices.getDisplayMedia({'video': true});
    localRenderer.srcObject = _localStream;

    _peerConnection = await createPeerConnection({'iceServers': []});
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onTrack = (event) {
      remoteRenderer.srcObject = event.streams[0];
    };
  }

  Future<RTCSessionDescription> createOffer() async {
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer() async {
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(Map<String, dynamic> description) async {
    RTCSessionDescription sd = RTCSessionDescription(description['sdp'], description['type']);
    await _peerConnection!.setRemoteDescription(sd);
  }

  Future<void> addCandidate(Map<String, dynamic> candidate) async {
    RTCIceCandidate iceCandidate = RTCIceCandidate(
      candidate['candidate'],
      candidate['sdpMid'],
      candidate['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(iceCandidate);
  }

  void dispose() {
    _localStream?.dispose();
    _peerConnection?.close();
  }
}
