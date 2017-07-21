/* --------------------------------------------------------------------------
 * People Tracking with Multiple Kinect Cameras, sending OSC Data 
 * --------------------------------------------------------------------------
 * Get started: 
 *  - Please make sure that you have a compatible configuration and that all 
 *    the following dependencies are installed.
 *  - Each kinect must have its own USB 2.0 or USB 3.0 port on the computer.
 *
 * Configuration : 
 *   -  Developped and tested on Windows 10 64 bits ands Kinects v1 (Xbox 360)
 *   -  Processing 2.2.1
 *   -  SimpleOpenNI 1.96
 *   -  Kinect SDK 1.8
 *
 * Dependencies : 
 *   -  Simple OpenNI :  Processing Wrapper for the OpenNI/Kinect 2 library
 *      http://code.google.com/p/simple-openni
 *      Please note that adapted drivers are needed to have the Kinect working.
 *   -  controlP5 : UI library for Processing
 *   -  oscP5 : Processing library for OSC communication
 *   -  netP5 : Processing library for 
 *   
 * --------------------------------------------------------------------------
 * prog:  Stéphane GARTI 
 * date:  July 2017
 * organisation: MEDEN AGAN
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import oscP5.*;
import netP5.*;
import controlP5.*;

Camera cam0, cam1;     // cameras 
//Camera cam2;
int cam0N, cam1N;
OscP5 oscP5;                 // open sound control : send data
NetAddress destination; // ip adresse for osc communication
ControlP5 cp5;               // UI Control

final static float fieldOfView = 0.84823; // kinect v1 field of view angle in radians
final static int roomWidth = 600;         // room (real) width and height in millimeters 
final static int roomHeight = 480;        // TODO : custom coor sys to have real dimensions
final static int viewWidth = 640/2;       // view width scaling for rendering on screen
final static int viewHeight = 480/2;      
JSONObject json;             // data stored from previous session

void setup() {
  size(640 + 50, 480*2);
  frameRate(25);

  //-------------------------------------------------------------
  //                   SETUP DATABASE
  // load data from previous session
  json = loadJSONObject("data/roomProfile.json");

  //-------------------------------------------------------------
  //                   SET UP SIMPLE OPEN NI
  // start OpenNI, load the library
  SimpleOpenNI.start();

  // print all the cams 
  StrVector strList = new StrVector();
  SimpleOpenNI.deviceNames(strList);
  println(strList.size() + " kinect detected");

  // Camera objects store metadata on cameras, like position, etc
  cam0 = new Camera(0);
  cam1 = new Camera(1);
  //  cam2 = new Camera(2);

  //-------------------------------------------------------------
  //                       SET UP OSC COMMUNICATION
  // RECEIVING : Start oscP5, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12000);
  // SENDING : NetAdress : ip adress and port number for sending data
  // 127.0.0.1    to loop home              (send on home reception port)
  // 192.168.X.X  for external destination  (port should be different from home reception)
  destination = new NetAddress("127.0.0.1", 12000);


  //-------------------------------------------------------------
  //                    SET UP USER INTERFACE
  // controlP5 lib for controllers : buttons, sliders, etc
  cp5 = new ControlP5(this);
  setupControl();
}

void draw() { 
  background(140, 140, 140);

  //-------------------------------------------------------------
  //                        UPDATE CAMERAS
  // update all cams
  SimpleOpenNI.updateAll();

  //-------------------------------------------------------------
  //                      DISPLAY DASHBOARD

  // display all cams depth view
  cam0.displayView(0, 0);
  cam1.displayView(viewWidth, 0);
  //  cam2.displayView(0, viewHeight);

  // shift to virtual room area
  pushMatrix();
  translate(0, height- roomHeight);
  fill(#DDDDDD);
  noStroke();
  rect(20, 0, roomWidth, roomHeight-20);
  // get position on plan and render it
  // returns number of users
  cam0N = cam0.renderUserPos();
  cam1N = cam1.renderUserPos();
  //  cam2.renderUserPos();
  popMatrix();

  // display Framerate (style in SetupControl)
  displayFramerate();

  //-------------------------------------------------------------
  //                         OUTPUT OSC
  OscMessage msg = new OscMessage("/camNumberOfUsers");
  msg.add(cam0N);
  msg.add(cam1N);
  oscP5.send(msg, destination);
}

//-------------------------------------------------------------
//                  RECEIVING CLIENT : listen to osc 
void oscEvent(OscMessage msg) {
  print("### RECEIVED");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
  println("### " + msg.get(0).intValue()+", "+ msg.get(1).intValue());
}

