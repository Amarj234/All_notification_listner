import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'signaling.dart';

class VideoCallPage extends StatefulWidget {
  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  Signaling? signaling;
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  Map<String, RTCVideoRenderer> remoteRenderers = {};
  bool inCalling = false;
  String? roomId;
  late TextEditingController _joinRoomTextEditingController;

  @override
  void initState() {
    super.initState();
    _joinRoomTextEditingController = TextEditingController();
    _initializeRenderers();
    _connect();
  }
  late Future<void> Function(String id, MediaStream stream) onAddRemoteStream;
  late void Function(String id) onRemoveRemoteStream;

  Future<void> _initializeRenderers() async {
    await localRenderer.initialize();
  }

  void _connect() {
    signaling = Signaling();

    signaling?.onLocalStream = (stream) {
      localRenderer.srcObject = stream;
      setState(() {});
    };

    onAddRemoteStream = (String id, MediaStream stream) async {
      RTCVideoRenderer renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = stream;
      setState(() {
        remoteRenderers[id] = renderer;
      });
    };

    onRemoveRemoteStream = (id) {
      setState(() {
        remoteRenderers[id]?.dispose();
        remoteRenderers.remove(id);
      });
    };

    signaling?.onDisconnect = () {
      setState(() {
        inCalling = false;
        roomId = null;
        remoteRenderers.forEach((key, renderer) {
          renderer.dispose();
        });
        remoteRenderers.clear();
      });
    };
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderers.forEach((key, renderer) {
      renderer.dispose();
    });
    _joinRoomTextEditingController.dispose();
    super.dispose();
  }

  Widget _buildVideoViews() {
    List<Widget> views = [
      RTCVideoView(localRenderer, mirror: true),
      ...remoteRenderers.values.map((renderer) => RTCVideoView(renderer)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      children: views,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter WebRTC Multi-User'),
      ),
      body: inCalling ? _buildVideoViews() : _buildJoinCreateButtons(),
      floatingActionButton: inCalling
          ? FloatingActionButton(
        onPressed: () async{
        await  signaling?.hungUp();
          setState(() {
            inCalling = false;
            roomId = null;
          });
        },
        child: Icon(Icons.call_end),
        backgroundColor: Colors.red,
      )
          : null,
    );
  }

  Widget _buildJoinCreateButtons() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: Text('Create Room'),
            onPressed: () async {
              String? id = await signaling?.createRoom();
              if (id != null) {
                setState(() {
                  roomId = id;
                  inCalling = true;
                });
              }
            },
          ),
          ElevatedButton(
            child: Text('Join Room'),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Join Room'),
                  content: TextField(
                    controller: _joinRoomTextEditingController,
                    decoration: InputDecoration(hintText: 'Enter Room ID'),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text('Join'),
                      onPressed: () async {
                        Navigator.pop(context);
                        String id = _joinRoomTextEditingController.text;
                        if (id.isNotEmpty) {
                          await signaling?.joinRoomById(id);
                          setState(() {
                            roomId = id;
                            inCalling = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
