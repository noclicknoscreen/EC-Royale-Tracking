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

SimpleOpenNI  cam1;
SimpleOpenNI  cam2;

color[]       userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};
PVector com = new PVector();                                   
PVector com2d = new PVector();                                   

void setup()
{
  size(640*2, 480);
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
}

void draw()
{
  // update the cam
  SimpleOpenNI.updateAll();


  // draw depthImageMap
  //image(cam1.depthImage(),0,0);
  image(cam1.userImage(), 0, 0);

  pushMatrix();
  // shift to the cam2 area
  translate(cam1.depthWidth(), 0);


  // draw the depth map
  image(cam2.userImage(), 0, 0);
  
  popMatrix();

  //  // draw the skeleton if it's available
  //  int[] userList = cam1.getUsers();
  //  for (int i=0; i<userList.length; i++)
  //  {
  //    if (cam1.isTrackingSkeleton(userList[i]))
  //    {
  //      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
  //      drawSkeleton(userList[i]);
  //    }      
  //
  //    // draw the center of mass
  //    if (cam1.getCoM(userList[i], com))
  //    {
  //      cam1.convertRealWorldToProjective(com, com2d);
  //      stroke(100, 255, 0);
  //      strokeWeight(1);
  //      beginShape(LINES);
  //      vertex(com2d.x, com2d.y - 5);
  //      vertex(com2d.x, com2d.y + 5);
  //
  //      vertex(com2d.x - 5, com2d.y);
  //      vertex(com2d.x + 5, com2d.y);
  //      endShape();
  //
  //      fill(0, 255, 100);
  //      text(Integer.toString(userList[i]), com2d.x, com2d.y);
  //    }
  //  }
  
  fill(#FFFFFF);
  textSize(14);
  text(int(frameRate) + " fps", 10, 20);
}
//
//// draw the skeleton with the selected joints
//void drawSkeleton(int userId)
//{
//  // to get the 3d joint data
//  /*
//  PVector jointPos = new PVector();
//   cam1.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
//   println(jointPos);
//   */
//
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
//
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
//
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
//
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
//
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
//
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
//  cam1.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
//}

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


//void keyPressed()
//{
//  switch(key)
//  {
//  case ' ':
//    cam1.setMirror(!cam1.mirror());
//    break;
//  }
//}  

