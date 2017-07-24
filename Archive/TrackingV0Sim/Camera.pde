import point2line.*;

class Camera {
  int id;                                  // kinect custom id :  0, 1, 2 or 3
  float camX_init, camY_init, camang_init; // var from previous session
  float camX, camY, camang;                // real-time variables for cam coor     
  PImage view;                             // view for rendering depth map on screen
  PVector com = new PVector();             // var to store center of mass, reused for each user
  int size;                                // size of the camera rectangle
  Vect2[] vertices = new Vect2[4];

  boolean over;                 // handle mouse state
  boolean press;                // handle mouse state
  boolean locked = false;       // handle mouse state

    color[] userClr = new color[] {    // custom user color list
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
    camX_init =   json.getFloat("cam" + id + "X");  
    camY_init =   json.getFloat("cam" + id + "Y");
    camang_init = json.getFloat("cam" + id + "ang");
    size = 20;
     rect(-size, -2*size, size, 2*size);
    vertices[0] = new Vect2(camX-size/2, camY - size);
    vertices[1] = new Vect2(camX + size/2, camY -size);
    vertices[2] = new Vect2(camX + size/2, camY + size);
    vertices[3] = new Vect2(camX - size/2, camY + size);
    this.id = id;
  }
  
  //-----------------------------------------------------------------------
  //                        UPDATE MOUSE EVENTS 

  void update() {
    overEvent();
    pressEvent();
    if (press) {
      xs = mouseX-x_init-size/2;
    }
  }

  //-----------------------------------------------------------------------
  //                        RENDER USER POSITIONS ON VIEWS
  // returns number of users with active center of mass
  void renderUserPos() {
    pushMatrix();

    // draw cam
    translate(camX, camY);
    rotate(camang);
    noStroke();
    fill(#000000);
    rect(-size, -2*size, size, 2*size);
    fill(#FFFFFF);
    textSize(10);
    text(id, 0, 0);

    // draw field of view
    fill(155, 155, 155, 155);
    float Htemp = map(6000, 0, 8000, 20, roomWidth);
    arc(0, 0, Htemp, Htemp, -fieldOfView/2, fieldOfView/2);

    // draw users center of mass 
    int numberOfUsers = 0;
    //    int[] userList1 = kin.getUsers();
    //    for (int i=0; i<userList1.length; i++) {   
    //      if (kin.getCoM(userList1[i], com) && com.z != 0) {
    //        numberOfUsers += 1;
    //        pushMatrix();
    //        stroke(userClr[i % userClr.length] );
    //        strokeWeight(20);
    //        float Zplan = map(com.z, 0, 8000, 0, Htemp);
    //        float Xplan = map(com.x, 3000, -3000, 0, Htemp*sin(fieldOfView));
    //        point(Zplan, Xplan - 180);
    //        popMatrix();
    //      }
    //    }    
    pushMatrix();
    t += v;
    r = r_ *( 1 + 0.4 * sin(t*8.15));
    stroke(255);
    strokeWeight(20);
    point(r*cos(t), r*sin(t));
    popMatrix();

    popMatrix();
  }

  void overEvent() {
    if (overRect(camX, camY, size, 2*size, camang)) {
      over = true;
    } else {
      over = false;
    }
  }

  void pressEvent() {
    if (over && mousePressed || locked) {
      press = true;
      locked = true;
    } else {
      press = false;
    }
  }

  void releaseEvent() {
    locked = false;
  }

  boolean overRect(int x, int y, int width, int height, float alpha) {
    pushMatrix();
    int mx = mouseX;
    int my = mouseY;
    rotate(alpha);
    if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
      return true;
    } else {
      return false;
    }
    popMatrix();
  }

  //-----------------------------------------------------------------------
  //                          GETTERS AND SETTERS
  float getX() {
    return camX;
  }
  float getY() {
    return camY;
  }
  float getAng() {
    return camang;
  }
  void setX(float v) {
    camX = v;
  }
  void setY(float v) {
    camY = v;
  }
  void setAng(float v) {
    camang = v;
  }
  float getX_init() {
    return camX_init;
  }
  float getY_init() {
    return camY_init;
  }
  float getAng_init() {
    return camang_init;
  }

  // -----------------------------------------------------------------
  //                       SIMPLE OPEN NI EVENTS

  void onNewUser(SimpleOpenNI kin, int userId)
  {
    println("onNewUser - userId: " + userId);
    //kin.startTrackingSkeleton(userId);
  }

  void onLostUser(SimpleOpenNI kin, int userId)
  {
    noFill(); // color display bug fix
    println("onLostUser - userId: " + userId);
  }

  void onVisibleUser(SimpleOpenNI kin, int userId)
  {
    println("onVisibleUser - userId: " + userId);
  }
}

