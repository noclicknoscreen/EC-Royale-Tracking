/* --------------------------------------------------------------------------
 * SimpleOpenNI User3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
SimpleOpenNI cam1;
SimpleOpenNI cam2;

float        zoomF =0.3f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);
boolean      autoCalib=true;

PVector      bodyCenter = new PVector();
PVector      bodyDir = new PVector();
PVector      com = new PVector();                                   
PVector      com2d = new PVector();                       

color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

void setup()
{
  size(640 * 2 + 10, 480, P3D);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem

  // start OpenNI, load the library
  SimpleOpenNI.start();

  // print all the cams 
  StrVector strList = new StrVector();
  SimpleOpenNI.deviceNames(strList);
  for (int i=0; i<strList.size (); i++) {
    println(i + ":" + strList.get(i));
  }

  // check if there are enough cams  
  if (strList.size() < 2) {
    println("only works with 2 cams");
    exit();
    return;
  }  

  // init the cameras
  cam1 = new SimpleOpenNI(0, this, SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  cam2 = new SimpleOpenNI(1, this, SimpleOpenNI.RUN_MODE_MULTI_THREADED);

  if (cam1.isInit() == false || cam2.isInit() == false)
  {
    println("Verify that you have two connected cameras on two different usb-busses!"); 
    exit();
    return;
  }


  cam1.setMirror(false); // disable mirror
  cam1.enableDepth();    // enable depthMap generation 
  cam1.enableUser();     // enable skeleton generation for all joints
  cam2.setMirror(false); // disable mirror
  cam2.enableDepth();    // enable depthMap generation 
  cam2.enableUser();     // enable skeleton generation for all joints

  stroke(255, 255, 255);
  smooth();
}

void draw()
{

  SimpleOpenNI.updateAll();       // update the cam

  background(0, 0, 0);
  drawUserImage(cam1);
  
  pushMatrix();                   // shift to the cam2 area
  translate(640 + 10, 0, 0);
  
  drawUserImage(cam2);

  popMatrix();

  fill(#FFFFFF);
  textSize(14);
  text(int(frameRate) + " fps", 100, 100);
  // draw the kinect cam
  //cam1.drawCamFrustum();
}
//
//// draw the skeleton with the selected joints
//void drawSkeleton(int userId)
//{
//  strokeWeight(3);
//
//  // to get the 3d joint data
//  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
//
//  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
//  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
//  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
//
//  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
//  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
//  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
//
//  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
//  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
//
//  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
//  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
//  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
//
//  drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
//  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
//  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
//
//  // draw body direction
//  getBodyDirection(userId, bodyCenter, bodyDir);
//
//  bodyDir.mult(200);  // 200mm length
//  bodyDir.add(bodyCenter);
//
//  stroke(255, 200, 200);
//  line(bodyCenter.x, bodyCenter.y, bodyCenter.z, 
//  bodyDir.x, bodyDir.y, bodyDir.z);
//
//  strokeWeight(1);
//}
//
//void drawLimb(int userId, int jointType1, int jointType2)
//{
//  PVector jointPos1 = new PVector();
//  PVector jointPos2 = new PVector();
//  float  confidence;
//
//  // draw the joint position
//  confidence = cam1.getJointPositionSkeleton(userId, jointType1, jointPos1);
//  confidence = cam1.getJointPositionSkeleton(userId, jointType2, jointPos2);
//
//  stroke(255, 0, 0, confidence * 200 + 55);
//  line(jointPos1.x, jointPos1.y, jointPos1.z, 
//  jointPos2.x, jointPos2.y, jointPos2.z);
//
//  drawJointOrientation(userId, jointType1, jointPos1, 50);
//}
//
//void drawJointOrientation(int userId, int jointType, PVector pos, float length)
//{
//  // draw the joint orientation  
//  PMatrix3D  orientation = new PMatrix3D();
//  float confidence = cam1.getJointOrientationSkeleton(userId, jointType, orientation);
//  if (confidence < 0.001f) 
//    // nothing to draw, orientation data is useless
//    return;
//
//  pushMatrix();
//  translate(pos.x, pos.y, pos.z);
//
//  // set the local coordsys
//  applyMatrix(orientation);
//
//  // coordsys lines are 100mm long
//  // x - r
//  stroke(255, 0, 0, confidence * 200 + 55);
//  line(0, 0, 0, 
//  length, 0, 0);
//  // y - g
//  stroke(0, 255, 0, confidence * 200 + 55);
//  line(0, 0, 0, 
//  0, length, 0);
//  // z - b    
//  stroke(0, 0, 255, confidence * 200 + 55);
//  line(0, 0, 0, 
//  0, 0, length);
//  popMatrix();
//}

// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curcam1, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  cam1.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curcam1, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curcam1, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


// -----------------------------------------------------------------
// Keyboard events

void keyPressed()
{
  switch(key)
  {
  case ' ':
    cam1.setMirror(!cam1.mirror());
    break;
  }

  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if (keyEvent.isShiftDown())
      zoomF += 0.01f;
    else
      rotX += 0.1f;
    break;
  case DOWN:
    if (keyEvent.isShiftDown())
    {
      zoomF -= 0.01f;
      if (zoomF < 0.01)
        zoomF = 0.01;
    } else
      rotX -= 0.1f;
    break;
  }
}

void getBodyDirection(int userId, PVector centerPoint, PVector dir)
{
  PVector jointL = new PVector();
  PVector jointH = new PVector();
  PVector jointR = new PVector();
  float  confidence;

  // draw the joint position
  confidence = cam1.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, jointL);
  confidence = cam1.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, jointH);
  confidence = cam1.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, jointR);

  // take the neck as the center point
  confidence = cam1.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, centerPoint);

  /*  // manually calc the centerPoint
   PVector shoulderDist = PVector.sub(jointL,jointR);
   centerPoint.set(PVector.mult(shoulderDist,.5));
   centerPoint.add(jointR);
   */

  PVector up = PVector.sub(jointH, centerPoint);
  PVector left = PVector.sub(jointR, centerPoint);

  dir.set(up.cross(left));
  dir.normalize();
}


void drawUserImage(SimpleOpenNI cam) {
  pushMatrix();
  perspective(radians(45), 
  float(width)/float(height), 
  10, 150000);
  // set the scene pos
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);

  int[]   depthMap = cam1.depthMap();
  int[]   userMap = cam1.userMap();
  int     steps   = 8;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;

  translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera

  // draw the pointcloud
  beginShape(POINTS);
  for (int y=0; y < cam.depthHeight (); y+=steps)
  {
    for (int x=0; x < cam.depthWidth (); x+=steps)
    {
      index = x + y * cam.depthWidth();
      if (depthMap[index] > 0)
      { 
        // draw the projected point
        realWorldPoint = cam.depthMapRealWorld()[index];
        if (userMap[index] == 0)
          stroke(100); 
        else
          stroke(userClr[ (userMap[index] - 1) % userClr.length ]);        
        strokeWeight(2);
        point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
      }
    }
  } 
  endShape();

  // draw the skeleton if it's available
  int[] userList = cam.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    //    if (cam.isTrackingSkeleton(userList[i]))
    //      drawSkeleton(userList[i]);

    // draw the center of mass
    if (cam.getCoM(userList[i], com))
    {
      stroke(#FFFFFF);
      strokeWeight(5);
      beginShape(LINES);
      vertex(com.x - 15, com.y, com.z);
      vertex(com.x + 15, com.y, com.z);
      vertex(com.x, com.y - 15, com.z);
      vertex(com.x, com.y + 15, com.z);
      vertex(com.x, com.y, com.z - 15);
      vertex(com.x, com.y, com.z + 15);
      endShape();

      //      textSize(100);
      //      text(Integer.toString(userList[i]), com.x + 50, com.y, com.z);
    }
  }    
  popMatrix();
}
