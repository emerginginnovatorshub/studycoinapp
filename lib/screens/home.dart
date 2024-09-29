
import 'package:flutter/material.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

// import '../../../../../apps/splash.dart';
// import '../../../../../pages/chat/chat.dart';
// import '../../init_screen.dart';

class Drawer3D extends StatefulWidget {
  final Widget child;

  // const Drawer3D({this.child});
  const Drawer3D({super.key, this.child = const SizedBox.shrink()});

  @override
  Drawer3DState createState() => Drawer3DState();
}

class Drawer3DState extends State<Drawer3D>
    with SingleTickerProviderStateMixin {
  var _maxSlide = 0.75;
  var _extraHeight = 0.1;
  late double _startingPos;
  var _drawerVisible = false;
  late AnimationController _animationController;
  Size _screen = const Size(0, 0);
  late CurvedAnimation _animator;
  late CurvedAnimation _objAnimator;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animator = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuad,
      reverseCurve: Curves.easeInQuad,
    );
    _objAnimator = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void didChangeDependencies() {
    _screen = MediaQuery.of(context).size;
    _maxSlide *= _screen.width;
    _extraHeight *= _screen.height;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Stack(
          clipBehavior: Clip.none, children: <Widget>[
            //Space color - it also makes the empty space touchable
            Container(color: const Color(0xFF3AAA3A)),
            _buildBackground(),
            // _build3dObject(),
            _buildDrawer(),
            _buildHeader(),
            _buildOverlay(),
          ],
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _startingPos = details.globalPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final globalDelta = details.globalPosition.dx - _startingPos;
    if (globalDelta > 0) {
      final pos = globalDelta / _screen.width;
      if (_drawerVisible && pos <= 1.0) return;
      _animationController.value = pos;
    } else {
      final pos = 1 - (globalDelta.abs() / _screen.width);
      if (!_drawerVisible && pos >= 0.0) return;
      _animationController.value = pos;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx.abs() > 500) {
      if (details.velocity.pixelsPerSecond.dx > 0) {
        _animationController.forward(from: _animationController.value);
        _drawerVisible = true;
      } else {
        _animationController.reverse(from: _animationController.value);
        _drawerVisible = false;
      }
      return;
    }
    if (_animationController.value > 0.5) {
      {
        _animationController.forward(from: _animationController.value);
        _drawerVisible = true;
      }
    } else {
      {
        _animationController.reverse(from: _animationController.value);
        _drawerVisible = false;
      }
    }
  }

  void toggleDrawer() {
    if (_animationController.value < 0.5) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  _buildMenuItem(String s, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () {},
        child: Text(
          s.toUpperCase(),
          style: TextStyle(
            fontSize: 25,
            color: active ? const Color.fromARGB(255, 127, 56, 166) : null,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  _buildFooterMenuItem(String s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () {},
        child: Text(
          s.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
  
  Widget _buildBackground() {
    return Positioned.fill(
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(51.509364, -0.128928), // Center the map over London
          initialZoom: 9.2,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
            userAgentPackageName: 'com.emerginginnovatorshub.studycoin',
          ),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
              ),
              // Also add images...
            ],
          ),
        ],
      ),
    );
  }
  
  _buildDrawer() => Positioned.fill(
        top: -_extraHeight,
        bottom: -_extraHeight,
        left: 0,
        right: _screen.width - _maxSlide,
        child: AnimatedBuilder(
          animation: _animator,
          builder: (context, widget) {
            return Transform.translate(
              offset: Offset(_maxSlide * (_animator.value - 1), 0),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(pi * (1 - _animator.value) / 2),
                alignment: Alignment.centerRight,
                child: widget,
              ),
            );
          },
          child: Container(
            // color: const Color(0xff9c52b3),
            color: Colors.white,
            child: Stack(
              clipBehavior: Clip.none, children: <Widget>[
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 5,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black12],
                      ),
                    ),
                  ),
                ),


              Positioned.fill(
                top: _extraHeight,
                bottom: _extraHeight,
                child: SafeArea(
                  child: SizedBox(
                    width: _maxSlide,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Avatar and Vexeroo Services
                          Column(

                            children: [
                              // CircleAvatar(
                              //   backgroundImage: AssetImage('assets/vexeroo.png'), // Replace with your avatar image
                              //   radius: 40,
                              // ),
Container(
  // color: Colors.purple, // Set your desired background color here
  padding: const EdgeInsets.all(0), // Add padding to the container

  decoration: BoxDecoration(
    color: Colors.purple, // Set your desired background color here
    borderRadius: BorderRadius.circular(10), // Optional: Add rounded corners
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3), // Shadow color
        offset: const Offset(0, 8), // Horizontal and vertical offset
        blurRadius: 13, // Blur radius
        spreadRadius: 3, // Spread radius
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.1), // Additional shadow for more depth
        offset: const Offset(0, 2), // Slightly different offset
        blurRadius: 5, // Slightly different blur radius
        spreadRadius: 1, // Slightly different spread radius
      ),
    ],
  ),

  child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start, // Ensures the column's children are left-aligned
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const CircleAvatar(
                                        backgroundImage: AssetImage('assets/logo.png'), // Replace with your avatar image
                                        radius: 40,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.brightness_6), // Theme switcher icon
                                        onPressed: () {
                                          // Add your theme switcher logic here
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          " Studycoin ",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5), // Add some spacing between the texts
                                        Text(
                                          "@studycoin", // Replace with your desired text
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

),


                            ],




),







                          const SizedBox(height: 70),
                          // 3D-looking buttons
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green[900]!,
                                          offset: const Offset(0, 4),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                    child: const Text(
                                      "SEE MAPS",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),







                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () {



                                    // Navigator.push(
                                    //   // context,
                                    //   // MaterialPageRoute(builder: (context) => 
                                      
                                    //   // // SplashPage(

                                    //   // //   imagePath: 'assets/splash/Onboarding.png', // Provide the image path or set to null
                                    //   // //   color: null, // Provide the color or set to null
                                    //   // //   finalPage: ChatPage(), // Provide the final page

                                    //   // // )
                                      
                                      
                                      
                                    //   // ), // Replace FinalPage with your target page
                                    // );



                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green[900]!,
                                          offset: const Offset(0, 4),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                    child: const Text(
                                      "SCHOOLS",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),






                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () {

                                    // Navigator.push(
                                    //   // context,
                                    //   // MaterialPageRoute(builder: (context) => 
                                      
                                    //   // SplashPage(

                                    //   //   imagePath: 'assets/splash/Onboarding.png', // Provide the image path or set to null
                                    //   //   color: null, // Provide the color or set to null
                                    //   //   finalPage: InitScreen(), // Provide the final page

                                    //   // )
                                      
                                      
                                    //   // ), 
                                    //   // Replace FinalPage with your target page
                                    // );

                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green[900]!,
                                          offset: const Offset(0, 4),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                    child: const Text(
                                      "FUNDINGS",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),













                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green[900]!,
                                          offset: const Offset(0, 4),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                    child: const Text(
                                      "STUDENTS",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green[900]!,
                                          offset: const Offset(0, 4),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                    child: const Text(
                                      "HISTORY",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Footer items
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () {},
                                  child: const Row(
                                    children: [
                                      Icon(Icons.info, color: Colors.black),
                                      SizedBox(width: 10),
                                      Text(
                                        "ABOUT",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () {},
                                  child: const Row(
                                    children: [
                                      Icon(Icons.support, color: Colors.black),
                                      SizedBox(width: 10),
                                      Text(
                                        "SUPPORT",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: InkWell(
                                  onTap: () {},
                                  child: const Row(
                                    children: [
                                      Icon(Icons.logout, color: Colors.black),
                                      SizedBox(width: 10),
                                      Text(
                                        "LOGOUT",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],



                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),






                AnimatedBuilder(
                  animation: _animator,
                  builder: (_, __) => Container(
                    width: _maxSlide,
                    color: Colors.black.withAlpha(
                      (150 * (1 - _animator.value)).floor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  _build3dObject() => Positioned(
        top: 0.1 * _screen.height,
        bottom: 0.22 * _screen.height,
        left: _maxSlide - _screen.width * 0.5,
        right: _screen.width * 0.85 - _maxSlide,
        child: AnimatedBuilder(
          animation: _objAnimator,
          builder: (_, __) => const ImageSequenceAnimator(
            "assets/anime/output", //folderName
            "", //fileName
            1, //suffixStart
            4, //suffixCount
            "png", //fileFormat
            120, //frameCount
            fps: 60,
            isLooping: false,
            isBoomerang: true,
            isAutoPlay: false,
            // frame:
            // frame: (_objAnimator.value * 120).ceil(),
          ),
        ),
      );

  _buildHeader() => SafeArea(
        child: AnimatedBuilder(
            animation: _animator,
            builder: (_, __) {
              return Transform.translate(
                offset: Offset((_screen.width - 60) * _animator.value, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: InkWell(
                        // key: buttonKey, // Add a key to the target widget
                        onTap: toggleDrawer,
                        child: const Icon(Icons.menu),
                      ),
                    ),
                    Opacity(
                      opacity: 1 - _animator.value,
                      child: const Text(
                        " STUDYCOIN MAP",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 50, height: 50),
                  ],
                ),
              );
            }),
      );


  _buildOverlay() => Positioned(
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    child: AnimatedBuilder(
      animation: _animator,
      builder: (context, child) => Transform.translate(
        offset: Offset((_maxSlide + 50) * _animator.value, 0),
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((pi / 2 + 0.1) * -_animator.value),
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.25, // Initial height is 1/4 of the screen
        minChildSize: 0.25, // Minimum height is 1/4 of the screen
        maxChildSize: 0.5, // Maximum height is 1/2 of the screen
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ride Details
                    const Text(
                      ' Locations of schools for funding in Nigeria',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Driver Information
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage('assets/logo.png'), // Replace with driver's avatar image
                          radius: 30,
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(' Country: Nigeria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(' Chosen Location: ', style: TextStyle(fontSize: 14)),
                            Text('Fund urgency rating:', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const Spacer(),
                        Image.asset('assets/logo.png', width: 60, height: 60), // Replace with car image
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Method',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$100', // Replace with the actual amount
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),



                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2), // Highlight color
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/logo.png', width: 30, height: 30), // Replace with your Mastercard icon
                          const SizedBox(width: 10),
                          // Icon(Icons.credit_card, size: 30),
                          const SizedBox(width: 10),

                          const Column(
                            children: [
                              Text('**** **** **** 1234', style: TextStyle(fontSize: 16)),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Expires: 12/26', style: TextStyle(fontSize: 12)),
                              )                            ],
                          ),


                        ],
                      ),
                    ),




                    const SizedBox(height: 20),
                    // Additional Details (Visible when dragged up)
                    AnimatedOpacity(
                      opacity: 1.0, // Change this based on drag position
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,


                        children: [
                          const Divider(),
                          GestureDetector(
                            onTap: () {
                              // Handle call button tap
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 5),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center, // This line was added

                                children: [
                                  Icon(Icons.call, size: 30),
                                  SizedBox(width: 10),
                                  Text('Call', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              // Handle message button tap
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 5),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center, // This line was added

                                children: [

                                  Icon(Icons.message, size: 30, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text('Message', style: TextStyle(fontSize: 16, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],







                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );




















}













