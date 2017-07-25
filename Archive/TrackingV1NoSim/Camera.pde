class Camera {
  SimpleOpenNI kin;                        // intepreter of kinect data
  int id;                                  // kinect custom id :  0, 1, 2 or 3
  float camX_init, camY_init, camang_init; // var from previous session
  float camX, camY, camang;                // real-time variables for cam coor     
  PImage view;                             // view for rendering depth map on screen
  PVector com = new PVector();             // var to store center of mass, reused for each user
  ArrayList<PVector> comUsers; 

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
    camX_init =   data.getFloat("cam" + id + "X");  
    camY_init =   data.getFloat("cam" + id + "Y");
    camang_init = data.getFloat("cam" + id + "ang");

    //    // kinect initialization
    kin = new SimpleOpenNI(id, TrackingV1NoSim.this);
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
  //                        DISPLAY VIEW 
  void displayView(float x_, float y_) {
    view = kin.userImage().get();   // get a copy of the depth image
    view.resize(viewWidth, viewHeight);          // resize it
    image(view, x_, y_);
  }


  //-----------------------------------------------------------------------
  //                        RENDER USER POSITIONS ON VIEWS
  // returns number of users with active center of mass
  ArrayList<PVector> renderUserPos() {
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

