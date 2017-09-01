import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 
import oscP5.*; 
import netP5.*; 
import controlP5.*; 
import point2line.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TrackingV2Proto extends PApplet {

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
 * prog:  St\u00e9phane GARTI 
 * date:  July 2017
 * organisation: MEDEN AGAN
 * ----------------------------------------------------------------------------
 */








Camera[] cam = new Camera[3];     // cameras
DBox[] dbox = new DBox[3];        // detection box
Dudley[] dud = new Dudley[3];     // Dudleys for simulation
OscP5 oscP5;                      // open sound control : send data
NetAddress destination;           // ip adress for osc communication
ControlP5 cp5;                    // UI Control
ArrayList<PVector> cam0UserPos, cam1UserPos, cam2UserPos;
int[] populations = new int[4];
float[] distances = new float[4];

final static float fieldOfView = 0.84823f; // kinect v1 field of view angle in radians
final static int roomWidth = 800;         // room  width and height 
final static int roomHeight = 600;        // TODO : custom coor sys to have real dimensions    
final static int viewWidth = 640/2;       // view width scaling for rendering on screen
final static int viewHeight = 480/2;      
JSONObject data;                          // data stored from previous session

public void setup() {
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


  // Camera objects store metadata on cameras, like position, etc
  cam[0] = new Camera(0);
  cam[1] = new Camera(1);
  cam[2] = new Camera(2);

  //-------------------------------------------------------------
  //                     SETUP DETECTION BOX
  dbox[0] = new DBox(0, 20);
  dbox[1] = new DBox(1, 20);
  dbox[2] = new DBox(2, 20);

  //-------------------------------------------------------------
  //                     SET UP DUDLEYS
  //  dud[0] = new Dudley(0, 300, 500, 100, 0.005);
  //  dud[1] = new Dudley(1, 300, 300, 40, 0.008);
  //  dud[2] = new Dudley(2, 300, 400, 70, 0.010);


  //-------------------------------------------------------------
  //                      SETUP OSC COMMUNICATION
  // RECEIVING : Start oscP5, listening for incoming messages at port 12000
  oscP5 = new OscP5(this, 12001);
  // SENDING : NetAdress : ip adress and port number for sending data
  // 127.0.0.1    to loop home              (send on home reception port)
  // 192.168.X.X  for external destination  (port should be different from home reception)
//  destination = new NetAddress("192.168.2.130", 12000);
  destination = new NetAddress("127.0.0.1", 12000);
 //-------------------------------------------------------------
  //                      SET UP USER INTERFACE
  // controlP5 lib for controllers : buttons, sliders, etc
  cp5 = new ControlP5(this);
  setupControl();
}

public void draw() { 
  background(140, 140, 140);

  //-------------------------------------------------------------
  //                        UPDATE CAMERAS
  // update all cams
  SimpleOpenNI.updateAll();


  //-------------------------------------------------------------
  //                      DISPLAY DASHBOARD


  // display all cams depth view
  cam[0].displayView(width-viewWidth, 0);
  cam[1].displayView(width-viewWidth, viewHeight);
  cam[2].displayView(width-viewWidth, 2*viewHeight);


  // shift to virtual room area
  pushMatrix();
  translate(0, 200);
  fill(0xffAAAAAA);
  noStroke();
  rect(20, 0, roomWidth, roomHeight);
  // get position on plan and render it
  cam0UserPos = cam[0].renderUserPos();
  cam1UserPos = cam[1].renderUserPos();
  cam2UserPos = cam[2].renderUserPos();
  popMatrix();

  // Display framerate (style in Toolbox)
  displayFramerate();


  //-------------------------------------------------------------
  //                       DBOX RENDERING

  dbox[0].update();
  populations[0] = dbox[0].countPopulation(cam0UserPos);  
  distances[0] = dbox[0].closestDistance(cam0UserPos);
//  distances[0] = dbox[0].mouseDistance(); 
  //  populations[0] += dbox[0].countPopulation(dud); 
  //  distances[0] = max(distances[0], dbox[0].closestDistance(dud));
  dbox[0].display();
  dbox[1].update();
  populations[1] = dbox[1].countPopulation(cam1UserPos);
  distances[1] = dbox[1].closestDistance(cam1UserPos);
//  distances[0] = dbox[1].mouseDistance();
  //  populations[1] += dbox[1].countPopulation(dud); 
  //  distances[1] = max(distances[1], dbox[1].closestDistance(dud));
  dbox[1].display();
  dbox[2].update();
  populations[2] = dbox[2].countPopulation(cam2UserPos);
  distances[2] = dbox[2].closestDistance(cam2UserPos);
//  distances[2] = dbox[1].mouseDistance();

  //  populations[2] += dbox[2].countPopulation(dud); 
  //  distances[2] = max(distances[2], dbox[2].closestDistance(dud));
  dbox[2].display();


  //-------------------------------------------------------------
  //                      DUDLEY RENDERING
  //  for (int i = 0; i < dud.length; i++) {
  //    dud[i].display();
  //  }

  //-------------------------------------------------------------
  //                         OUTPUT OSC
  sendOSC("/North/population", populations[1]);
  sendOSC("/North/distance", distances[1]);
  sendOSC("/West/population", populations[0]);
  sendOSC("/West/distance", distances[0]);
  sendOSC("/South/population", populations[2]);
  sendOSC("/South/distance", distances[2]);
//  println("OSC sent at frame " + frameCount);
}

public void sendOSC(String title, float value) {
  OscMessage msg = new OscMessage(title);
  msg.add(value);
  oscP5.send(msg, destination);
}
public void sendOSC(String title, int value) {
  OscMessage msg = new OscMessage(title);
  msg.add(value);
  oscP5.send(msg, destination);
}
//-------------------------------------------------------------
//                  RECEIVING CLIENT : listen to osc 
public void oscEvent(OscMessage msg) {
  print("### OSC message at ");
  print(millis() + " ms");
  print(" addrpattern: "+msg.addrPattern());
  println(" typetag: "+msg.typetag());
  //  println("### " + msg.get(0).intValue()+", "+ msg.get(1).intValue());
}


public void mouseReleased() {
  for (int id = 0; id<dbox.length; id++) {
    dbox[id].releaseEvent();
  }
}

class Camera {
  SimpleOpenNI kin;                        // intepreter of kinect data
  int id;                                  // kinect custom id :  0, 1, 2 or 3
  float camX_init, camY_init, camang_init; // var from previous session
  float camX, camY, camang;                // real-time variables for cam coor     
  PImage view;                             // view for rendering depth map on screen
  PVector com = new PVector();             // var to store center of mass, reused for each user
  ArrayList<PVector> comUsers; 

  int[] userClr = new int[] {    // custom user color list
    color(0, 0, 255), 
    color(0, 255, 0), 
    color(255, 255, 0), 
    color(255, 0, 0), 
    color(255, 0, 255), 
    color(0, 255, 255)
  };


  //-----------------------------------------------------------------------
  //                        CONSTRUCTOR
  Camera(int id) {
    // read data from previous session
    camX_init =   data.getFloat("cam" + id + "X");  
    camY_init =   data.getFloat("cam" + id + "Y");
    camang_init = data.getFloat("cam" + id + "ang");

    //    // kinect initialization
    kin = new SimpleOpenNI(id, TrackingV2Proto.this);
    this.id = id;

    // initialization callback
    if (kin.isInit() == false) {
      println("Verify that you have connected camera n\u00b0 " + id); 
      exit();
      return;
    } else {
      println("Kinect " + id + " : init OK");
    }

    // set the camera generators 
    kin.enableDepth();
    kin.enableUser();
  }

  //-----------------------------------------------------------------------
  //                        DISPLAY VIEW 
  public void displayView(float x_, float y_) {
    view = kin.userImage().get();   // get a copy of the depth image
    view.resize(viewWidth, viewHeight);          // resize it
    image(view, x_, y_);
  }


  //-----------------------------------------------------------------------
  //                        RENDER USER POSITIONS ON VIEWS
  // returns number of users with active center of mass
  public ArrayList<PVector> renderUserPos() {
    pushMatrix();

    // draw cam
    translate(camX, camY);
    rotate(camang);
    noStroke();
    fill(0);
    rect(0-20/2, 0-40/2, 20, 40);
    fill(255);
    textSize(10);
    text(id, 0, 0);

    rotate(-fieldOfView/2);
    // draw arc field of view
    fill(255, 255, 255, 30);
    float Htemp = map(8000, 0, 8000, 20, 700);
    float Htempmin = map(1000, 0, 8000, 20, 700);
    float Htempmax = map(6000, 0, 8000, 20, 700);
    arc(0, 0, Htemp, Htemp, 0, fieldOfView);

    // draw users center of mass 
    int[] userList1 = kin.getUsers();
    comUsers = new ArrayList<PVector>(); 
    for (int i=0; i<userList1.length; i++) {   
      if (kin.getCoM(userList1[i], com) && com.z != 0) {
        pushMatrix();
        //stroke(userClr[i % userClr.length] 
        stroke(255);
        strokeWeight(20);
        float Zplan = map(com.z, 0, 8000, 0, Htemp);
        float Xplan = map(com.x, 3000, -3000, 0, Htemp*sin(fieldOfView));
        PVector potentialUser =new PVector(screenX(Zplan, Xplan-180), screenY(Zplan, Xplan-180));
        if (dbox[id].isInside(potentialUser)) {
          comUsers.add(potentialUser);
          point(Zplan, Xplan - 180);
        }
        popMatrix();
      }
    }    
    popMatrix();
    // all transformations are cleared out now
    // store absolute coordinates

    return comUsers;
  }

  //-----------------------------------------------------------------------
  //                          GETTERS AND SETTERS
  public float getX() {
    return camX;
  }
  public float getY() {
    return camY;
  }
  public float getAng() {
    return camang;
  }
  public void setX(float v) {
    camX = v;
  }
  public void setY(float v) {
    camY = v;
  }
  public void setAng(float v) {
    camang = v;
  }
  public float getX_init() {
    return camX_init;
  }
  public float getY_init() {
    return camY_init;
  }
  public float getAng_init() {
    return camang_init;
  }

  // -----------------------------------------------------------------
  //                       SIMPLE OPEN NI EVENTS

  public void onNewUser(SimpleOpenNI kin, int userId)
  {
    println("onNewUser - userId: " + userId);
    //kin.startTrackingSkeleton(userId);
  }

  public void onLostUser(SimpleOpenNI kin, int userId)
  {
    noFill(); // color display bug fix
    println("onLostUser - userId: " + userId);
  }

  public void onVisibleUser(SimpleOpenNI kin, int userId)
  {
    println("onVisibleUser - userId: " + userId);
  }
}

/*******************************************************************************************
 *
 *                                   DBOX CLASS
 *
 *  DBox or Detection Box is a custom class used to have a specific editable area
 *  where users are detected. It uses the point2line library for polygone detection,
 *  i.e. a tool to know if a point is inside a polygon
 *
 *  relies on Handle class (see below)
 *******************************************************************************************/


class DBox {
  int id;                             // dbox id
  int opacity = 50;                   // display opacity
  int population = 0;                 // detection state
  float distance = -1;
  float hsize = 10;                   // handle size
  Handle[] handles = new Handle[4];   // handles declaration
  Vect2[] vertices = new Vect2[4];    // vertices for polygon detection

  //-----------------------------------------------------------------------------
  //                      DBOX CONSTRUCTOR
  DBox(int id, float dsize) {
    this.id = id;

    // read data from previous session
    handles[0] = new Handle(getDBoxDataCoor(id, 0).x, getDBoxDataCoor(id, 0).y, 0, 0, hsize, handles);
    handles[1] = new Handle(getDBoxDataCoor(id, 1).x, getDBoxDataCoor(id, 1).y, 0, 0, hsize, handles);
    handles[2] = new Handle(getDBoxDataCoor(id, 2).x, getDBoxDataCoor(id, 2).y, 0, 0, hsize, handles);
    handles[3] = new Handle(getDBoxDataCoor(id, 3).x, getDBoxDataCoor(id, 3).y, 0, 0, hsize, handles);

    // define vertices for polygon detection
    for (int i = 0; i < handles.length; i++) {
      vertices[i] = new Vect2(handles[i].getX(), handles[i].getY());
    }
  }

  // read database (roomProfile.json)
  public PVector getDBoxDataCoor(int id, int ihandle) {
    return new PVector(data.getJSONArray("dbox").getJSONObject(id).getJSONArray("handlesCoor").getJSONObject(ihandle).getFloat("x"), 
    data.getJSONArray("dbox").getJSONObject(id).getJSONArray("handlesCoor").getJSONObject(ihandle).getFloat("y"));
  }


  //---------------------------------------------------------------------------
  //                      OUTPUT FUNCTIONS

  public float mouseDistance() {
    Vect2 linePoint1 = new Vect2(handles[0].getX(), handles[0].getY());
    Vect2 linePoint2 = new Vect2(handles[1].getX(), handles[1].getY());
    Vect2 mouseVect = new Vect2(mouseX, mouseY);
    if (Space2.insidePolygon(mouseVect, vertices)) {
      distance = Space2.pointToLineDistance(mouseVect, linePoint1, linePoint2);
      distance = map(distance, -5, 400, 1, 0);
    } else {
      return 0;
    }
    return distance;
  }


  public float closestDistance(ArrayList<PVector> userPosCam) {
    Vect2 linePoint1 = new Vect2(handles[0].getX(), handles[0].getY());
    Vect2 linePoint2 = new Vect2(handles[1].getX(), handles[1].getY());
    int n = userPosCam.size();
    if (n>0) {
      Vect2[] testPoints = new Vect2[n];
      for (int i=0; i<n; i++) {
        testPoints[i] = new Vect2(userPosCam.get(i).x, userPosCam.get(i).y);
      }
      int closestPointIndex = Space2.closestPointToLine(testPoints, linePoint1, linePoint2);
      Vect2 closestPoint = testPoints[closestPointIndex];
      distance = Space2.pointToLineDistance(closestPoint, linePoint1, linePoint2);
      distance = map(distance, -5, 200, 1, 0);
      return distance;
    } else {
      distance = 0;
      return distance;
    }
  }

  public boolean isInside(PVector user) {
    Vect2 coor = new Vect2(user.x, user.y);
    return Space2.insidePolygon(coor, vertices);
  }

  public int countPopulation(ArrayList<PVector> userPosCam) {
    population = 0;
    for (int k=0; k<userPosCam.size (); k++) {
      Vect2 coor = new Vect2(userPosCam.get(k).x, userPosCam.get(k).y);
      if (Space2.insidePolygon(coor, vertices)) {
        population += 1;
      };
    }
    if (population > 0) {
      opacity = 60;
    } else {
      opacity = 5;
    }
    return population;
  }

  public int countPopulation(Dudley[] dud) {
    population = 0;
    for (int k=0; k<dud.length; k++) {
      Vect2 coor = new Vect2(dud[k].getX(), dud[k].getY());
      if (Space2.insidePolygon(coor, vertices)) {
        dud[k].setZone(id);
        population += 1;
      };
    }
    if (population > 0) {
      opacity = 60;
    } else {
      opacity = 5;
    }
    return population;
  }

  public float closestDistance(Dudley[] dud) {
    Vect2 linePoint1 = new Vect2(handles[0].getX(), handles[0].getY());
    Vect2 linePoint2 = new Vect2(handles[1].getX(), handles[1].getY());
    int n = dud.length;
    if (n>0) {
      Vect2[] testPoints = new Vect2[n];
      for (int i=0; i<n; i++) {
        testPoints[i] = new Vect2(dud[i].getX(), dud[i].getY());
      }
      int closestPointIndex = Space2.closestPointToLine(testPoints, linePoint1, linePoint2);
      Vect2 closestPoint = testPoints[closestPointIndex];
      distance = Space2.pointToLineDistance(closestPoint, linePoint1, linePoint2);
      distance = map(distance, 0, 200, 1, 0);
      return distance;
    } else {
      distance = 0;
      return distance;
    }
  }
  //----------------------------------------------------------------------------
  //                       DBOX UPDATE 
  public void update() {
    for (int i = 0; i < handles.length; i++) {
      handles[i].update();
    }
  }

  //---------------------------------------------------------------------------
  //                      DBOX DISPLAY
  public void display() {

    // vertex for polygon shape
    fill(255, 255, 255, opacity);
    stroke(0);
    strokeWeight(1);
    beginShape();
    for (int i = 0; i < handles.length; i++) {
      vertex(handles[i].getX(), handles[i].getY());
      vertices [i] = new Vect2(handles[i].getX(), handles[i].getY());
    }
    endShape(CLOSE);

    stroke(255, 0, 0);
    strokeWeight(2);
    beginShape();
    vertex(handles[0].getX(), handles[0].getY());
    vertex(handles[1].getX(), handles[1].getY());
    endShape();

    // display handles
    for (int i = 0; i < handles.length; i++) {
      handles[i].display(i);
    }

    // display dbox id
    fill(255);
    textSize(70);
    //    float tempX = handles[0].getX();
    //    float tempY = handles[0].getY();
    text("ID "+ id + " / population: " + population + " / distance: " + distance, 30, height-250 +80*id);
  }

  //---------------------------------------------------------------------------
  //                      MOUSE EVENT
  public void releaseEvent() {
    for (int i = 0; i < handles.length; i++) {
      handles[i].releaseEvent();
    }
  }

  // TO-DO
  public int numberOfDetections() {
    return 0;
  }
  public float nearestDetection() {
    return 0;
  }
  //coordinates of people in DBox
  public float[] getCoordinates() {
    return new float[0];
  }

  //--------------------------------------------------------------------------
  //                      GETTERS AND SETTERS
  public Handle[] getHandles() {
    return handles;
  }
}

/*******************************************************************************************
 *
 *                                   HANDLE CLASS
 *
 *******************************************************************************************/
class Handle {
  float x_init, y_init;         // initial position
  float boxx, boxy;             // box real time position
  float xs, ys;                 // movement
  float size;                   // box size
  boolean over;                 // handle mouse state
  boolean press;                // handle mouse state
  boolean locked = false;       // handle mouse state
  boolean otherslocked = false; // true when at least one of the handles is locked
  Handle[] others;              // list of handles

    Handle(float ix, float iy, float il, float ih, float is, Handle[] o) {
    x_init = ix;
    y_init = iy;
    xs = il;
    ys = ih;
    size = is;
    boxx = x_init+xs - size/2;
    boxy = y_init+ys - size/2;
    others = o;
  }

  //-----------------------------------------------------------------
  //                          UPDATE
  public void update() {
    boxx = lock(x_init+xs, 20, width -20);
    boxy = lock(y_init+ys, 20, height-20);

    // othersLocked is true when at least one of the handles is locked
    for (int i=0; i<others.length; i++) {
      if (others[i].locked == true) {
        otherslocked = true;
        break;
      } else {
        otherslocked = false;
      }
    }

    // if no handles is locked, see if a handle is clicked
    if (otherslocked == false) {
      overEvent();
      pressEvent();
    }
    if (press) {
      xs = mouseX-x_init-size/2;
      ys = mouseY-y_init-size/2;
    }
  }


  //-----------------------------------------------------------------
  //                          DISPLAY
  public void display(int i) {

    // display handle
    fill(255);
    stroke(0);
    strokeWeight(1);
    rect(boxx, boxy, size, size);

    //display number
    fill(0xff000000);
    textSize(8);
    text(i, boxx, boxy);

    // display a cross when pressed
    fill(0xffFFFFFF);
    if (over || press) {
      line(boxx, boxy, boxx+size, boxy+size);
      line(boxx, boxy+size, boxx+size, boxy);
    }
  }


  //---------------------------------------------------------------------------
  //                      MOUSE EVENT

  public void overEvent() {
    if (overRect(boxx, boxy, size, size)) {
      over = true;
    } else {
      over = false;
    }
  }

  public void pressEvent() {
    if (over && mousePressed || locked) {
      press = true;
      locked = true;
    } else {
      press = false;
    }
  }

  public void releaseEvent() {
    locked = false;
  }


  public boolean overRect(float x, float y, float w, float h) {
    if (mouseX >= x && mouseX <= x+w && 
      mouseY >= y && mouseY <= y+h) {
      return true;
    } else {
      return false;
    }
  }

  //---------------------------------------------------------------------------
  //                      GETTERS & SETTERS

  public float getX() {
    return boxx+size/2;
  }

  public float getY() {
    return boxy+size/2;
  }

  //---------------------------------------------------------------------------
  //                      MATH FUNCTIONS

  // limits
  public float lock(float val, float minv, float maxv) { 
    return  min(max(val, minv), maxv);
  }
}

/*******************************************************************************************
 *
 *                                   DUDLEY CLASS
 *
 *  Dudley is a custom class to simulate users for dev interface without kinects.
 *  Dudleys are generated with their position and speed, and they wander around 
 *  in the virtual room.
 *
 *******************************************************************************************/

class Dudley {
  int id;
  float Ox, Oy, x, y;
  float  v;         // rotation speed
  float  r_;        // rotation radius before sin
  float  r;         // rotation radius after sin 
  float  s = 20;    // size of dudley
  float  t = 0;     // time init
  int zone = -1;    // zone where dudley is : -1 if not detected

  Dudley(int id, float Ox, float Oy, float r_, float v) {
    this.id = id;
    this.Ox = Ox;
    this.Oy = Oy;
    this.r_ = r_;
    this.v = v;
  }

  public void display() {
    pushMatrix();
    t += v;
    r = r_ *( 1 + 0.1f* sin(t*8.15f));
    stroke(255);
    strokeWeight(20);
    x = Ox + r*cos(t);
    y = Oy + r*sin(t);
    point(x, y);
    popMatrix();
  }

  public float getX() {
    return x;
  }
  public float getY() {
    return y;
  }
  public void setZone(int i) {
    zone = i;
  }
}

/*******************************************************************************************
 *
 *                                  TOOLBOX
 *                        MISCELLANEOUS FUNCTIONS FOR VARIOUS PURPOSES
 *
 *   Index :
 *
 *
 *******************************************************************************************/

public void displayFramerate() {
  pushMatrix();
  fill(0xffFFFFFF);
  textSize(14);
  text(PApplet.parseInt(frameRate) + " fps", 10, 20);
  popMatrix();
}


Numberbox ang0;
Numberbox pos0x;
Numberbox pos0y;
Numberbox ang1;
Numberbox pos1x;
Numberbox pos1y;
Numberbox ang2;
Numberbox pos2x;
Numberbox pos2y;


public void setupControl() {
  pos0x = cp5.addNumberbox("pos0x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(30 + 70 + 30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(PApplet.parseInt(cam[0].getX_init()))
              ;
  pos0y = cp5.addNumberbox("pos0y")
    .setSize(70, 20)
      .setRange(0, roomHeight+200)
        .setPosition(30+ 70 +30 +70 +30, 40)
          .setValue(PApplet.parseInt(cam[0].getY_init()))
            ;
  ang0 = cp5.addNumberbox("ang0")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(PApplet.parseInt(degrees(cam[0].getAng_init())))
              ;
  makeEditable(pos0x);
  makeEditable(pos0y);
  makeEditable(ang0);
  ang0.getValueLabel().setText(str(PApplet.parseInt(degrees(cam[0].getAng()))));


  pos1x = cp5.addNumberbox("pos1x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(640/2+30 + 70 + 30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(PApplet.parseInt(cam[1].getX_init()))
              ;
  pos1y = cp5.addNumberbox("pos1y")
    .setSize(70, 20)
      .setRange(0, roomHeight+200)
        .setPosition(640/2+30+ 70 +30 +70 +30, 40)
          .setValue(PApplet.parseInt(cam[1].getY_init()))
            ;
  ang1 = cp5.addNumberbox("ang1")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(640/2 + 30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(PApplet.parseInt(degrees(cam[1].getAng_init())))
              ;
  makeEditable(pos1x);
  makeEditable(pos1y);
  makeEditable(ang1);
  ang1.getValueLabel().setText(str(PApplet.parseInt(degrees(cam[1].getAng()))));
  pos2x = cp5.addNumberbox("pos2x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(30 + 70 + 30, 2*40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(PApplet.parseInt(cam[2].getX_init()))
              ;
  pos2y = cp5.addNumberbox("pos2y")
    .setSize(70, 20)
      .setRange(0, roomHeight+200)
        .setPosition(30+ 70 +30 +70 +30, 2* 40)
          .setValue(PApplet.parseInt(cam[2].getY_init()))
            ;
  ang2 = cp5.addNumberbox("ang2")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(30, 2* 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(PApplet.parseInt(degrees(cam[2].getAng_init())))
              ;
  makeEditable(pos2x);
  makeEditable(pos2y);
  makeEditable(ang2);
  ang2.getValueLabel().setText(str(PApplet.parseInt(degrees(cam[2].getAng()))));


  cp5.addButton("save")
    .setPosition(width - 60, height - 40)
      .setSize(50, 20)
        ;
}


public void pos0x(int v) {
  cam[0].setX(v);
}
public void pos0y(int v) {
  cam[0].setY(v);
}
public void ang0(int v) {
  cam[0].setAng(radians(v));
}
public void pos1x(int v) {
  cam[1].setX(v);
}
public void pos1y(int v) {
  cam[1].setY(v);
}
public void ang1(int v) {
  cam[1].setAng(radians(v));
}
public void pos2x(int v) {
  cam[2].setX(v);
}
public void pos2y(int v) {
  cam[2].setY(v);
}
public void ang2(int v) {
  cam[2].setAng(radians(v));
}



public void save(int v) {
  data.setFloat("cam0X", cam[0].getX());
  data.setFloat("cam0Y", cam[0].getY());
  data.setFloat("cam0ang", cam[0].getAng());
  data.setFloat("cam1X", cam[1].getX());
  data.setFloat("cam1Y", cam[1].getY());
  data.setFloat("cam1ang", cam[1].getAng());
  data.setFloat("cam2X", cam[2].getX());
  data.setFloat("cam2Y", cam[2].getY());
  data.setFloat("cam2ang", cam[2].getAng());
  for (int id = 0; id < dbox.length; id ++) {
    for (int ihandle = 0; ihandle < 4; ihandle++) {
      saveDBoxHandle(id, ihandle);
    }
  }

  saveJSONObject(data, "data/roomProfile.json");
}

public void saveDBoxHandle(int id, int ihandle) {
  data.getJSONArray("dbox")
    .getJSONObject(id)
      .getJSONArray("handlesCoor")
        .getJSONObject(ihandle)
          .setFloat("x", dbox[id].getHandles()[ihandle].getX());
  data.getJSONArray("dbox")
    .getJSONObject(id)
      .getJSONArray("handlesCoor")
        .getJSONObject(ihandle)
          .setFloat("y", dbox[id].getHandles()[ihandle].getY());
}

// function that will be called when controller 'numbers' changes
public void numbers(float f) {
  println("received "+f+" from Numberbox numbers ");
}

public void makeEditable( Numberbox n ) {
  // allows the user to click a numberbox and type in a number which is confirmed with RETURN
  final NumberboxInput nin = new NumberboxInput( n ); // custom input handler for the numberbox
  // control the active-status of the input handler when releasing the mouse button inside 
  // the numberbox. deactivate input handler when mouse leaves.
  n.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( true );
    }
  }
  ).onLeave(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( false ); 
      nin.submit();
    }
  }
  );
}


// input handler for a Numberbox that allows the user to 
// key in numbers with the keyboard to change the value of the numberbox

public class NumberboxInput {

  String text = "";
  Numberbox n;
  boolean active;


  NumberboxInput(Numberbox theNumberbox) {
    n = theNumberbox;
    registerMethod("keyEvent", this );
  }

  public void keyEvent(KeyEvent k) {
    // only process key event if input is active 
    if (k.getAction()==KeyEvent.PRESS && active) {
      if (k.getKey()=='\n') { // confirm input with enter
        submit();
        return;
      } else if (k.getKeyCode()==BACKSPACE) { 
        text = text.isEmpty() ? "":text.substring(0, text.length()-1);
        //text = ""; // clear all text with backspace
      } else if (k.getKey()<255) {
        // check if the input is a valid (decimal) number
        final String regex = "\\d+([.]\\d{0,2})?";
        String s = text + k.getKey();
        if ( java.util.regex.Pattern.matches(regex, s ) ) {
          text += k.getKey();
        }
      }
      n.getValueLabel().setText(this.text);
    }
  }

  public void setActive(boolean b) {
    active = b;
    if (active) {
      n.getValueLabel().setText("");
      text = "";
    }
  }

  public void submit() {
    if (!text.isEmpty()) {
      n.setValue( PApplet.parseFloat( text ) );
      text = "";
    } else {
      n.getValueLabel().setText(""+n.getValue());
    }
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TrackingV2Proto" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
