class Camera {
  SimpleOpenNI kin;                        // intepreter of kinect data
  int id;                                  // kinect custom id :  0, 1, 2 or 3
  float camX_init, camY_init, camang_init; // var from previous session
  float camX, camY, camang;                // real-time variables for cam coor     
  PImage view;                             // view for rendering depth map on screen
  PVector com = new PVector();             // var to store center of mass, reused for each user

    color[]       userClr = new color[] {    // custom user color list
    color(0, 0, 255), 
    color(0, 255, 0), 
    color(255, 255, 0), 
    color(255, 0, 0), 
    color(255, 0, 255), 
    color(0, 255, 255)
  };


  //-----------------------------------------------------------------------
  //                         CONSTRUCTOR
  Camera(int id) {
    // read data from previous session
    camX_init =   json.getFloat("cam" + id + "X");  
    camY_init =   json.getFloat("cam" + id + "Y");
    camang_init = json.getFloat("cam" + id + "ang");
    
    // kinect initialization
    kin = new SimpleOpenNI(id, MultiCamClassRoomMapping.this);
    this.id = id;

    // initialization callback
    if (kin.isInit() == false) {
      println("Verify that you have connected camera n° " + id); 
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
  //                              UPDATE
//  void update() {
//    kin.update();                    // SimpleOpenNI update
//  }

  //-----------------------------------------------------------------------
  //                              DISPLAY VIEW 
  void displayView(float x, float y) {
    view = kin.userImage().get();   // get a copy of the depth image
    view.resize(viewWidth, viewHeight);          // resize it
    image(view, x, y);
  }


  //-----------------------------------------------------------------------
  //                        RENDER USER POSITIONS ON VIEWS
  void renderUserPos() {
    pushMatrix();

    // draw cam
    translate(camX, camY);
    rotate(camang);
    noStroke();
    fill(#000000);
    rect(0-20/2, 0-40/2, 20, 40);

    // draw field of view
    fill(155, 155, 155, 155);
    float Htemp = map(6000, 0, 8000, 20, roomWidth);
    arc(0, 0, Htemp, Htemp, -fieldOfView/2, fieldOfView/2);

    // draw users center of mass 
    int[] userList1 = kin.getUsers();
    for (int i=0; i<userList1.length; i++) {   
      if (kin.getCoM(userList1[i], com) && com.z != 0) {
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
  //                     SIMPLE OPEN NI EVENTS

  void onNewUser(SimpleOpenNI curkin1, int userId)
  {
    println("onNewUser - userId: " + userId);
    println("\tstart tracking skeleton");

    curkin1.startTrackingSkeleton(userId);
  }

  void onLostUser(SimpleOpenNI curkin1, int userId)
  {
    noFill(); // color display bug fix
    println("onLostUser - userId: " + userId);
  }

  void onVisibleUser(SimpleOpenNI curkin1, int userId)
  {
    //println("onVisibleUser - userId: " + userId);
  }
}
