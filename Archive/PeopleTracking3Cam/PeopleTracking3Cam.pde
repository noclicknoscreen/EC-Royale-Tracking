/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import controlP5.*;

Camera cam0, cam1, cam2;    // cameras                 
ControlP5 cp5;              // UI Control
JSONObject json;            // data stored from previous session

final static float fieldOfView = 0.84823; // kinect v1 field of view angle in radians
final static int roomWidth = 600;         // room (real) width and height in millimeters 
final static int roomHeight = 480;        // TODO : custom coor sys to have real dimensions
final static int viewWidth = 640/2;       // view width scaling for rendering on screen
final static int viewHeight = 480/2;

void setup() {
  size(640 + 50, 480*2);

  // load data from previous session
  json = loadJSONObject("data/roomProfile.json");

  // start OpenNI, load the library
  SimpleOpenNI.start();

  // print all the cams 
  StrVector strList = new StrVector();
  SimpleOpenNI.deviceNames(strList);
  println(strList.size() + " kinect detected");


  // check if there are enough cams  
  if (strList.size() < 3)
  {
    println("only works with 2 cams");
    exit();
    return;
  }  

  // Camera objects store metadata on cameras, like position, etc
  cam0 = new Camera(0);
  cam1 = new Camera(1);
  cam2 = new Camera(2);

  // setup style
  background(140, 140, 140);
  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();

  // controlP5 lib for controllers : buttons, sliders, etc
  cp5 = new ControlP5(this);
  setupControl();
}

void draw() { 
  background(140, 140, 140);

  // update all cams
  SimpleOpenNI.updateAll();


  // display all cams depth view
  cam0.displayView(0, 0);
  cam1.displayView(viewWidth, 0);
  cam2.displayView(0, viewHeight);

  // shift to virtual room area
  pushMatrix();
  translate(0, height- roomHeight);
  fill(#DDDDDD);
  noStroke();
  rect(20, 0, roomWidth, roomHeight-20);
  // get position on plan and render it
  cam0.renderUserPos();
  cam1.renderUserPos();
  cam2.renderUserPos();
  popMatrix();

  // display frameRate
  pushMatrix();
  fill(#FFFFFF);
  textSize(14);
  text(int(frameRate) + " fps", 10, 20);
  popMatrix();
}

