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

final static int ncam = 4;                // number of kinect cameras
final static float fieldOfView = 0.84823; // kinect v1 field of view angle in radians
final static int roomWidth = 800;         // room  width and height 
final static int roomHeight = 600;        // TODO : custom coor sys to have real dimensions    
final static int viewWidth = 640/2;       // view width scaling for rendering on screen
final static int viewHeight = 480/2;     

Camera[] cam = new Camera[ncam];     // cameras
DBox[] dbox = new DBox[ncam];        // detection box
Dudley[] dud = new Dudley[ncam];     // Dudleys for simulation
OscP5 oscP5;                         // open sound control : send data
NetAddress destination;              // ip adress for osc communication
ControlP5 cp5;                       // UI Control
int[] populations = new int[ncam];   // population for each detection zone
float[] distances = new float[ncam]; // population for each detection zone 

// array list of users positions for each camera
ArrayList<ArrayList<PVector>> camUserPos = new ArrayList<ArrayList<PVector>>();     

JSONObject data;                          // data stored from previous session

void setup() {
  size(1500, 1000);
  frameRate(30);

  //-------------------------------------------------------------
  //                   SETUP DATABASE
  // load data from previous session
  data = loadJSONObject("data/roomProfile.json");

  //-------------------------------------------------------------
  //                   SET UP SIMPLE OPEN NI
  // start OpenNI, load the library
  SimpleOpenNI.start();

  // print all the cams 
  StrVector strList = new StrVector();
  SimpleOpenNI.deviceNames(strList);
  println(strList.size() + " kinect detected");

  // Init Camera and DBox objects
  for (int i=0; i<ncam; i++) {
    cam[i] = new Camera(i);
    dbox[i] = new DBox(i, 20);
  }

  //-------------------------------------------------------------
  //               SET UP DUDLEYS FOR PEOPLE SIMULATION
  //  dud[0] = new Dudley(0, 300, 500, 100, 0.005);
  //  dud[1] = new Dudley(1, 300, 300, 40, 0.008);
  //  dud[2] = new Dudley(2, 300, 400, 70, 0.010);


  //-------------------------------------------------------------
  //                      SETUP OSC COMMUNICATION
  // RECEIVING : Start oscP5, listening for incoming messages at port 12001
  oscP5 = new OscP5(this, 12001);
  // SENDING : NetAdress : ip adress and port number for sending data
  // 127.0.0.1    to loop home              (send on home reception port for testing purposes)
  // 192.168.X.X  for external destination  (port should be different from home reception)
  // destination = new NetAddress("192.168.2.130", 12000);
  destination = new NetAddress("127.0.0.1", 12000);
  //-------------------------------------------------------------
  //                      SET UP USER INTERFACE
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
  for (int i=0; i<ncam; i++) {
    cam[i].displayView(width-viewWidth, i*viewHeight);
  }

  // shift to virtual room area
  pushMatrix();
  translate(0, 200);
  fill(#AAAAAA);
  noStroke();
  rect(20, 0, roomWidth, roomHeight);
  // get position on plan and render it
  for (int i=0; i<ncam; i++) {
    camUserPos.add(cam[i].renderUserPos());
  }
  popMatrix();

  // Display framerate (style in Toolbox)
  displayFramerate();


  //-------------------------------------------------------------
  //                       DBOX RENDERING

  for (int i=0; i<ncam; i++) {
    dbox[i].update();
    populations[i] = dbox[i].countPopulation(camUserPos.get(i));  
    distances[i] = dbox[i].closestDistance(camUserPos.get(i));
    //  distances[i] = dbox[i].mouseDistance();                      // mouse Simulation
    //  populations[i] += dbox[i].countPopulation(dud); 
    //  distances[i] = max(distances[i], dbox[i].closestDistance(dud));
    dbox[i].display();
  }

  //-------------------------------------------------------------
  //                      DUDLEY RENDERING
  //  for (int i = 0; i < dud.length; i++) {
  //    dud[i].display();
  //  }

  //-------------------------------------------------------------
  //                         OUTPUT OSC

  sendOSC("/West/population", populations[0]);
  sendOSC("/West/distance", distances[0]);
  if (ncam>1) {
    sendOSC("/North/population", populations[1]);
    sendOSC("/North/distance", distances[1]);
  }
  if (ncam>2) {
    sendOSC("/South/population", populations[2]);
    sendOSC("/South/distance", distances[2]);
  }
  if (ncam>3) {
    sendOSC("/East/population", populations[3]);
    sendOSC("/East/distance", distances[3]);
  }
  //  println("OSC sent at frame " + frameCount);
}

// send OSC for float and int type of value
void sendOSC(String title, float value) {
  OscMessage msg = new OscMessage(title);
  msg.add(value);
  oscP5.send(msg, destination);
}
void sendOSC(String title, int value) {
  OscMessage msg = new OscMessage(title);
  msg.add(value);
  oscP5.send(msg, destination);
}


//-------------------------------------------------------------
//                  RECEIVING CLIENT : listen to osc  (testing purpose)
void oscEvent(OscMessage msg) {
  print("### OSC message at ");
  print(millis() + " ms");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
  //  println("### " + msg.get(0).intValue()+", "+ msg.get(1).intValue());
}


void mouseReleased() {
  for (int id = 0; id<dbox.length; id++) {
    dbox[id].releaseEvent();
  }
}

