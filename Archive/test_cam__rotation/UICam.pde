class UICam {
  int x_init, y_init;           // initial position
  int boxx, boxy;               // box real time position
  int xs, ys;                   // movement
  int size;                     // box size
  boolean over;                 // handle mouse state
  boolean press;                // handle mouse state
  boolean locked = false;       // handle mouse state
  boolean otherslocked = false; // true when at least one of the handles is locked
  UICam[] others;              // list of handles
  Vect2[] vertices = new Vect2[4];
  Vect2[] tVertices = new Vect2[4]; //vertices translated

  UICam(int ix, int iy, int is, UICam[] o) {
    x_init = ix;
    y_init = iy;
    xs = 0;
    ys = 0;
    size = is;
    boxx = x_init+xs - size/2;
    boxy = y_init+ys - size/2;
    others = o;

    vertices[0] = new Vect2(-size/2, - size);
    vertices[1] = new Vect2(size/2, -size);
    vertices[2] = new Vect2(size/2, size);
    vertices[3] = new Vect2(-size/2, size);
  }

  void update() {
    boxx = x_init+xs, 20, width -20;
    boxy = y_init+ys, 20, height-20;

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

  void overEvent(tVertices) {
    Vect2 mcoor = new Vect2(mouseX, mouseY);
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

  void display(int i) {
    background(140, 140, 140);
    translate(x, y);
    tVertices = vTranslate(vertices, x, y);
    rotate(camang);

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
  }

  int getX() {
    return boxx+size/2;
  }

  int getY() {
    return boxy+size/2;
  }

  // limits
  int lock(int val, int minv, int maxv) { 
    return  min(max(val, minv), maxv);
  }



  Vect2[] vTranslate(Vect2[] vSource, int dx, int dy) {
    Vect2[] vT = new Vect2[4];
    for (int i = 0; i < 4; i++) {
      vT[i] = new Vect2(vSource[i].x + dx, vSource[i].y + dy);
    }
    return vT;
  }
}

