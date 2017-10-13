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

Camera[] cam = new Camera[4];     // cameras
DBox[] dbox = new DBox[4];        // detection box
Dudley[] dud = new Dudley[4];     // Dudleys for simulation

OscP5 oscP5;                      // open sound control : send data
NetAddress destination;           // ip adress for osc communication
ControlP5 cp5;                    // UI Control
ArrayList<PVector> cam0UserPos, cam1UserPos, cam2UserPos, cam3UserPos;
int[] populations = new int[4];
float[] distances = new float[4];

boolean displayRGB = true;

final static float fieldOfView = 0.84823; // kinect v1 field of view angle in radians
final static int roomWidth = 800;         // room  width and height 
final static int roomHeight = 600;        // TODO : custom coor sys to have real dimensions    
final static int viewWidth = 640/2;       // view width scaling for rendering on screen
final static int viewHeight = 480/2;      
JSONObject data;                          // data stored from previous session

void setup() {
  size(1500, 1000);
  frameRate(20);
  background(0, 0, 0);

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


  // Camera objects store metadata on cameras, like position, etc
  cam[0] = new Camera(0);
  cam[1] = new Camera(1);
  cam[2] = new Camera(2);
  cam[3] = new Camera(3);

  //-------------------------------------------------------------
  //                     SETUP DETECTION BOX
  dbox[0] = new DBox(0, 20);
  dbox[1] = new DBox(1, 20);
  dbox[2] = new DBox(2, 20);
  dbox[3] = new DBox(3, 20);

  //-------------------------------------------------------------
  //                     SET UP DUDLEYS
  //  dud[0] = new Dudley(0, 300, 500, 100, 0.005);
  //  dud[1] = new Dudley(1, 300, 300, 40, 0.008);
  //  dud[2] = new Dudley(2, 300, 400, 70, 0.010);


  //-------------------------------------------------------------
  //                      SETUP OSC COMMUNICATION
  println("Setup OSC");
  // RECEIVING : Start oscP5, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 10001);
  // SENDING : NetAdress : ip adress and port number for sending data
  // 127.0.0.1    to loop home              (send on //home reception port)
  // 192.168.X.X  for external destination  (port should be different from home reception)
  //  destination = new NetAddress("192.168.2.130", 12000);
  destination = new NetAddress("127.0.0.1", 10000);

  //-------------------------------------------------------------
  //                      SET UP USER INTERFACE
  // controlP5 lib for controllers : buttons, sliders, etc
  println("Setup UI");
  cp5 = new ControlP5(this);
  setupControl();
}

void draw() { 

  background(140, 140, 140);

  //-------------------------------------------------------------
  //                        UPDATE CAMERAS
  // update all cams
  //if(frameCount % 2 == 0){
  SimpleOpenNI.updateAll();
  //}

  //-------------------------------------------------------------
  //                      DISPLAY DASHBOARD
  if (displayRGB == true) {
  // display all cams depth view
  cam[0].displayDepth(width-viewWidth, 0);
  cam[1].displayDepth(width-viewWidth, viewHeight);
  cam[2].displayDepth(width-viewWidth, 2*viewHeight);
  cam[3].displayDepth(width-viewWidth, 3*viewHeight);
  }
  // display all cams RGB
  /*
  if (displayRGB == true) {
    cam[0].displayRGB(width-2*viewWidth, 0);
    cam[1].displayRGB(width-2*viewWidth, viewHeight);
    cam[2].displayRGB(width-2*viewWidth, 2*viewHeight);
    cam[3].displayRGB(width-2*viewWidth, 3*viewHeight);
  }else{
    //
  }
  */
  // shift to virtual room area
  pushMatrix();
  translate(0, 200);
  fill(#AAAAAA);
  noStroke();
  rect(20, 0, roomWidth, roomHeight);
  // get position on plan and render it
  cam0UserPos = cam[0].renderUserPos();
  cam1UserPos = cam[1].renderUserPos();
  cam2UserPos = cam[2].renderUserPos();
  cam3UserPos = cam[3].renderUserPos();
  popMatrix();

  // Display framerate (style in Toolbox)
  displayFramerate();

  //-------------------------------------------------------------
  //                       DBOX RENDERING
  // dbox 0 -------------------------------------------------------------
  dbox[0].update();
  populations[0] = dbox[0].countPopulation(cam0UserPos);  
  distances[0] = dbox[0].closestDistance(cam0UserPos);
  //  distances[0] = dbox[0].mouseDistance(); 
  //  populations[0] += dbox[0].countPopulation(dud); 
  //  distances[0] = max(distances[0], dbox[0].closestDistance(dud));
  dbox[0].display();

  // dbox 1 -------------------------------------------------------------
  dbox[1].update();
  populations[1] = dbox[1].countPopulation(cam1UserPos);
  distances[1] = dbox[1].closestDistance(cam1UserPos);
  //  distances[0] = dbox[1].mouseDistance();
  //  populations[1] += dbox[1].countPopulation(dud); 
  //  distances[1] = max(distances[1], dbox[1].closestDistance(dud));
  dbox[1].display();

  // dbox 2 -------------------------------------------------------------
  dbox[2].update();
  populations[2] = dbox[2].countPopulation(cam2UserPos);
  distances[2] = dbox[2].closestDistance(cam2UserPos);
  //  distances[2] = dbox[1].mouseDistance();

  //  populations[2] += dbox[2].countPopulation(dud); 
  //  distances[2] = max(distances[2], dbox[2].closestDistance(dud));
  dbox[2].display();


  // dbox 3 -------------------------------------------------------------
  dbox[3].update();
  populations[3] = dbox[3].countPopulation(cam3UserPos);
  distances[3] = dbox[3].closestDistance(cam3UserPos);
  //  distances[2] = dbox[1].mouseDistance();

  //  populations[2] += dbox[2].countPopulation(dud); 
  //  distances[2] = max(distances[2], dbox[2].closestDistance(dud));
  dbox[3].display();

  //-------------------------------------------------------------
  //                      DUDLEY RENDERING
  //  for (int i = 0; i < dud.length; i++) {
  //    dud[i].display();
  //  }

  //-------------------------------------------------------------
  //                         OUTPUT OSC
  sendOSC("/kin00/population", populations[0]);
  sendOSC("/kin00/distance", distances[0]);
  
  sendOSC("/kin01/population", populations[1]);
  sendOSC("/kin01/distance", distances[1]);
  
  sendOSC("/kin02/population", populations[2]);
  sendOSC("/kin02/distance", distances[2]);
  
  sendOSC("/kin03/population", populations[3]);
  sendOSC("/kin03/distance", distances[3]);

  //  println("OSC sent at frame " + frameCount);
}

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
//                  RECEIVING CLIENT : listen to osc 
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

