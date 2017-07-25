class Camera {
  //  SimpleOpenNI kin;                        // intepreter of kinect data
  int id;                                  // kinect custom id :  0, 1, 2 or 3
  float camX_init, camY_init, camang_init; // var from previous session
  float camX, camY, camang;                // real-time variables for cam coor     
  PImage view;                             // view for rendering depth map on screen
  PVector com = new PVector();             // var to store center of mass, reused for each user
  private Camera[] others;
  VCam vcam;

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
  Camera(int id, Camera[] others) {
    this.id = id;
    this.others = others;
    // read data from previous session
    camX_init =   data.getFloat("cam" + id + "X");  
    camY_init =   data.getFloat("cam" + id + "Y");
    camang_init = data.getFloat("cam" + id + "ang");

    VCam[] otherVCams = new VCam[N];
    for (int i=0; i<N; i++) {
      otherVCams[i] = others.getVCam();
    }
    // virtual camera initialization
    vcam = new VCam(id, camX_init, camY_init, camang_init, otherVCams);

    //    // kinect initialization
    //    kin = new SimpleOpenNI(id, TrackingV1.this);
    //    this.id = id;

    //    // initialization callback
    //    if (kin.isInit() == false) {
    //      println("Verify that you have connected camera n° " + id); 
    //      exit();
    //      return;
    //    } else {
    //      println("Kinect " + id + " : init OK");
    //    }
    //
    //    // set the camera generators 
    //    kin.enableDepth();
    //    kin.enableUser();
  }

  //  //-----------------------------------------------------------------------
  //  //                        DISPLAY VIEW 
  void displayView(float x, float y) {
    view = kin.userImage().get();   // get a copy of the depth image
    view.resize(viewWidth, viewHeight);          // resize it
    image(view, x, y);
  }


  //-----------------------------------------------------------------------
  //                        RENDER USER POSITIONS ON VIEWS
  // returns number of users with active center of mass
  void renderUserPos() {
    pushMatrix();

    vcam.update();
    vcam.display();

    // draw cam
    //    translate(camX, camY);
    //    rotate(camang);
    //    noStroke();
    //    fill(0);
    //    rect(0-20/2, 0-40/2, 20, 40);
    //    fill(255);
    //    textSize(10);
    //    text(id, 0, 0);
    //    println(id);
    //
    //    // draw arc field of view
    //    fill(255, 255, 255, 30);
    //    float Htemp = map(8000, 0, 8000, 20, roomWidth);
    //    float Htempmin = map(1000, 0, 8000, 20, roomWidth);
    //    float Htempmax = map(6000, 0, 8000, 20, roomWidth);
    //    arc(0, 0, Htemp, Htemp, -fieldOfView/2, fieldOfView/2);

    //    // draw users center of mass 
    //    int numberOfUsers = 0;
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
    popMatrix();
  }

  //-----------------------------------------------------------------------
  //                          GETTERS AND SETTERS
  VCam getVCam() {
    return vcam;
  }

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
  void releaseEvent() {
    vcam.releaseEvent();
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

/*******************************************************************************************
 *
 *                                   VCAM CLASS
 *
 *  VCam (Virtual Camera) is a custom class designed to represent a camera field of view
 *  in a virtual space, for people detection and tracking purpose.
 *  It uses the point2line library for polygone detection,
 *  (i.e. a tool to know if a point is inside a polygon)
 *  
 *******************************************************************************************/
import point2line.*;

class VCam {
  private int id;
  private float Ox, Oy;                        // initial position
  private float x, y, ang;                     // vcam real time position
  private float size = 20;                     // box size
  private float xs = 0;                        // movement variable
  private float ys = 0;                        // movement variable
  private boolean over;                        // handle mouse state
  private boolean press;                       // handle mouse state
  private boolean locked = false;              // handle mouse state
  private boolean otherslocked = false;        // true when at least one of the handles is locked
  private VCam[] others;                       // list of others virtual cameras
  private Vect2[] vertices = new Vect2[4];     // vertices
  private Vect2[] tVertices = new Vect2[4];    // translated vertices
  private Numberbox angNB;

  //-----------------------------------------------------------------------------
  //                      VCAM CONSTRUCTOR
  VCam(int id, float Ox, float Oy, float ang, VCam[] others) {
    this.id = id;
    this.Ox = Ox;
    this.Oy = Oy;
    this.ang = ang;
    this.others = others;
    x = Ox + xs - size/2;
    y = Oy + ys - size/2;

    vertices[0] = new Vect2(-size/2, - size);
    vertices[1] = new Vect2(size/2, -size);
    vertices[2] = new Vect2(size/2, size);
    vertices[3] = new Vect2(-size/2, size);

    angNB = cp5.addNumberbox("ang" + id)
      .setSize(35, 12)
        .setRange(-180, 180)
          .setValue(0)
            .setPosition(x, y)
              .setDirection(Controller.HORIZONTAL)
                ;
    makeEditable(angNB);
  }

  //-----------------------------------------------------------------------------
  //                      VCAM UPDATE

  void update() {
    // real-time var = origin + movement
    x = Ox+xs;
    y = Oy+ys;

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
      xs = mouseX-Ox;
      ys = mouseY-Oy;
    }

    angNB.setPosition(x-20, y-50);
    ang = radians(angNB.getValue()-90);
  }
  //-----------------------------------------------------------------------------
  //                       VCAM DISPLAY 
  void display() {
    pushMatrix();

    translate(x, y);
    tVertices = vTranslate(vertices, x, y);
    rotate(ang);

    noStroke();
    // draw field of view
    fill(155, 155, 155, 155);
    float Htemp = map(6000, 0, 8000, 20, width);
    arc(0, 0, Htemp, Htemp, -fieldOfView/2, fieldOfView/2);


    if (over || press) {
      fill(50);
    } else {
      fill(0);
    }
    beginShape();
    for (int i = 0; i < 4; i ++) {
      vertex(vertices[i].x, vertices[i].y);
    }
    endShape(CLOSE);
    popMatrix();
  }
  //-----------------------------------------------------------------------------
  //                      CONTROL

  //-----------------------------------------------------------------------------
  //                      MOUSE EVENTS
  void overEvent() {
    Vect2 mcoor = new Vect2(mouseX, mouseY);
    tVertices = vTranslate(vertices, x, y);
    if (Space2.insidePolygon(mcoor, tVertices)) {
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



  //-----------------------------------------------------------------------------
  //                      GETTERS AND SETTERS
  int getID() {
    return id;
  }
  float getX() {
    return x+size/2;
  }
  float getY() {
    return y+size/2;
  }

  void setAng(float v) {
    ang = v ;
  }


  //-----------------------------------------------------------------------------
  //                        TOOLBOX
  Vect2[] vTranslate(Vect2[] vSource, float dx, float dy) {
    Vect2[] vT = new Vect2[4];
    for (int i = 0; i < 4; i++) {
      vT[i] = new Vect2(vSource[i].x + dx, vSource[i].y + dy);
    }
    return vT;
  }

  // limits
  float lock(float val, float minv, float maxv) { 
    return  min(max(val, minv), maxv);
  }
}

