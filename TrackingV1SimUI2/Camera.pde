import point2line.*

class Camera {
  //  SimpleOpenNI kin;                 // kinect data
  private int id;                       // id :  0, 1, 2 or 3
  private float Ox, Oy;                 // var from previous session
  private float x, y, ang;              // real-time variables for cam coor     
  private PImage view;                  // view for rendering depth map on screen
  private PVector com = new PVector();  // var to store center of mass, reused for each user
  
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
    Ox =   data.getFloat("cam" + id + "X");  
    Oy =   data.getFloat("cam" + id + "Y");
    ang = data.getFloat("cam" + id + "ang");

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
  //  void displayView(float x, float y) {
  //    view = kin.userImage().get();   // get a copy of the depth image
  //    view.resize(viewWidth, viewHeight);          // resize it
  //    image(view, x, y);
  //  }


  //-----------------------------------------------------------------------
  //                        RENDER USER POSITIONS ON VIEWS
  // returns number of users with active center of mass
  void renderUserPos() {
    pushMatrix();

    // draw cam
    translate(x, y);
    rotate(ang);
    noStroke();
    fill(0);
    rect(0-20/2, 0-40/2, 20, 40);
    fill(255);
    textSize(10);
    text(id, 0, 0);
    println(id);

    // draw arc field of view
    fill(255, 255, 255, 30);
    float Htemp = map(8000, 0, 8000, 20, roomWidth);
    float Htempmin = map(1000, 0, 8000, 20, roomWidth);
    float Htempmax = map(6000, 0, 8000, 20, roomWidth);
    arc(0, 0, Htemp, Htemp, -fieldOfView/2, fieldOfView/2);

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
  float getX() {
    return x;
  }
  float getY() {
    return y;
  }
  float getAng() {
    return ang;
  }
  void setX(float v) {
    x = v;
  }
  void setY(float v) {
    y = v;
  }
  void setAng(float v) {
    ang = v;
  }
  float getX_init() {
    return Ox;
  }
  float getY_init() {
    return Oy;
  }
  float getAng_init() {
    return ang;
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

