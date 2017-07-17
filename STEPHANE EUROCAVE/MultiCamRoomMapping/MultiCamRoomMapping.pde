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

final static int IDLE = 0;
final static int CALIB1 = 1;
int state = IDLE;

SimpleOpenNI  cam1;
SimpleOpenNI  cam2;
float fieldOfView = 0.84823;
PImage view1;
PImage view2;

//room width and height in millimeters
int roomWidth = 600;
int roomHeight = 480;
float cam1X = roomWidth/2 - 20;
float cam1Y = roomHeight/2-80;
float cam1ang = PI;
float cam2X = roomWidth/2 + 30;
float cam2Y = roomHeight/2-30;
float cam2ang = HALF_PI;


color[]       userClr = new color[] { 
  color(0, 0, 255), 
  color(0, 255, 0), 
  color(255, 255, 0), 
  color(255, 0, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

PVector com = new PVector();                                   
PVector com2d = new PVector();                                   

ControlP5 cp5;

void setup()
{
  size(640, 480*2);

  // start OpenNI, load the library
  SimpleOpenNI.start();

  // print all the cams 
  StrVector strList = new StrVector();
  SimpleOpenNI.deviceNames(strList);
  for (int i=0; i<strList.size (); i++)
    println(i + ":" + strList.get(i));

  // check if there are enough cams  
  if (strList.size() < 2)
  {
    println("only works with 2 cams");
    exit();
    return;
  }  

  // init the cameras
  cam1 = new SimpleOpenNI(0, this);
  cam2 = new SimpleOpenNI(1, this);
  /*
  cam1 = new SimpleOpenNI(0,this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
   cam2 = new SimpleOpenNI(1,this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
   */
  if (cam1.isInit() == false || cam2.isInit() == false)
  {
    println("Verify that you have two connected cameras on two different usb-busses!"); 
    exit();
    return;
  }

  // set the camera generators
  // enable depthMap generation 
  cam1.enableDepth();
  cam1.enableUser();

  // enable depthMap generation 
  cam2.enableDepth();
  cam2.enableUser();

  background(100, 100, 100);
  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();

  cp5 = new ControlP5(this);
  cp5.addButton("calib1")
    .setValue(0)
      .setPosition(0, 480/2 - 20)
        .setSize(640/2, 20)
          ;
}




void draw()
{ 

  // update the cam
  SimpleOpenNI.updateAll();

  // draw depthImageMap
  view1 = cam1.userImage().get();   // get a copy of the depth image
  view1.resize(640/2, 0);           // resize it
  image(view1, 0, 0);               // display it

  // shift to the cam2 area
  pushMatrix();
  translate(view1.width, 0);
  view2 = cam2.userImage().get();
  view2.resize(640/2, 0);
  image(view2, 0, 0);
  popMatrix();

  pushMatrix();
  // display virtual room
  translate(0, height- roomHeight);
  fill(#DDDDDD);
  noStroke();
  rect(20, 0, roomWidth, roomHeight-20);

  // get position on plan and render it
  renderUserPos(cam1, cam1X, cam1Y, cam1ang);
  renderUserPos(cam2, cam2X, cam2Y, cam2ang);
  popMatrix();

  
  pushMatrix();
  fill(#FFFFFF);
  textSize(14);
  text(int(frameRate) + " fps", 10, 20);
  popMatrix();
}
// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curcam1, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curcam1.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curcam1, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curcam1, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void renderUserPos(SimpleOpenNI cam, float camX, float camY, float camang) {
  pushMatrix();
  translate(camX, camY);
  rotate(camang);
  fill(#000000);
  rect(0-20/2, 0-40/2, 20, 40);
  fill(155, 155, 155);
  float Htemp = map(6000, 0, 8000, 20, roomWidth);
  arc(0, 0, Htemp, Htemp, -fieldOfView/2, fieldOfView/2);

  int[] userList1 = cam.getUsers();
  for (int i=0; i<userList1.length; i++)
  {   
    // draw the center of mass on 2D plane
    if (cam.getCoM(userList1[i], com) && com.z != 0) {
      //      context.convertRealWorldToProjective(com, com2d);
      pushMatrix();
      stroke(userClr[i % userClr.length] );
      strokeWeight(20);
      float Zplan = map(com.z, 0, 8000, 0, Htemp);
      float Xplan = map(com.x, 3000, -3000, 0, Htemp*sin(fieldOfView));
      point(Zplan, Xplan - 180);
      popMatrix();
    }
  }    
  popMatrix();
}

