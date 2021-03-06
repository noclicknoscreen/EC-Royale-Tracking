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

