// detection box

import point2line.*;

class DBox {
  int id;
  int n = 4;                        // number of handles
  Handle[] handles = new Handle[n];
  Vect2[] vertices = new Vect2[n];
  float hsize = 10;

  DBox(int id, float dsize) {
    this.id = id;
    //read data from previous session
    handles[0] = new Handle(getDBoxDataCoor(id, 0).x - dsize/2, getDBoxDataCoor(id, 0).y - dsize/2, 0, 0, hsize, handles);
    handles[1] = new Handle(getDBoxDataCoor(id, 1).x + dsize/2, getDBoxDataCoor(id, 1).y - dsize/2, 0, 0, hsize, handles);
    handles[2] = new Handle(getDBoxDataCoor(id, 2).x + dsize/2, getDBoxDataCoor(id, 2).y + dsize/2, 0, 0, hsize, handles);
    handles[3] = new Handle(getDBoxDataCoor(id, 3).x - dsize/2, getDBoxDataCoor(id, 3).y + dsize/2, 0, 0, hsize, handles);

    for (int i = 0; i < handles.length; i++) {
      vertices[i] = new Vect2(handles[i].getX(), handles[i].getY());
    }
  }

  PVector getDBoxDataCoor(int id, int ihandle) {
    return new PVector(data.getJSONArray("dbox").getJSONObject(id).getJSONArray("handlesCoor").getJSONObject(ihandle).getFloat("x"), 
    data.getJSONArray("dbox").getJSONObject(id).getJSONArray("handlesCoor").getJSONObject(ihandle).getFloat("y"));
  }

  DBox(int xpos, int ypos, int dsize, DBox[] o) {
    handles[0] = new Handle(xpos - dsize/2, ypos - dsize/2, 0, 0, hsize, handles);
    handles[1] = new Handle(xpos + dsize/2, ypos - dsize/2, 0, 0, hsize, handles);
    handles[2] = new Handle(xpos + dsize/2, ypos + dsize/2, 0, 0, hsize, handles);
    handles[3] = new Handle(xpos - dsize/2, ypos + dsize/2, 0, 0, hsize, handles);

    for (int i = 0; i < handles.length; i++) {
      vertices[i] = new Vect2(handles[i].getX(), handles[i].getY());
    }
  }

  void update() {
    for (int i = 0; i < handles.length; i++) {
      handles[i].update();
    }
  }

  void display() {
    fill(255, 255, 255, 50);
    stroke(0);
    strokeWeight(1);
    beginShape();
    for (int i = 0; i < handles.length; i++) {
      vertex(handles[i].getX(), handles[i].getY());
      vertices [i] = new Vect2(handles[i].getX(), handles[i].getY());
    }
    endShape(CLOSE);
    for (int i = 0; i < handles.length; i++) {
      handles[i].display(i);
    }
    fill(0, 0, 0, 50);
    textSize(46);
    text(id, handles[0].getX() + 10, handles[0].getY() + 40);
    
  }

  void releaseEvent() {
    for (int i = 0; i < handles.length; i++) {
      handles[i].releaseEvent();
    }
  }

  boolean detect(float x, float y) {
    Vect2 coor = new Vect2(x, y);
    return Space2.insidePolygon(coor, vertices);
  }

  // TO-DO
  int numberOfDetections() {
    return 0;
  }
  float nearestDetection() {
    return 0;
  }
  //coordinates of people in DBox
  float[] getCoordinates() {
    return new float[0];
  }
}


class Handle {
  float x_init, y_init;                     // initial position
  float boxx, boxy;               // box real time position
  float xs, ys;                   // movement
  float size;                     // box size
  boolean over;                 // handle mouse state
  boolean press;                // handle mouse state
  boolean locked = false;       // handle mouse state
  boolean otherslocked = false; // true when at least one of the handles is locked
  Handle[] others;              // list of handles

    Handle(float ix, float iy, float il, float ih, float is, Handle[] o) {
    x_init = ix;
    y_init = iy;
    xs = il;
    ys = ih;
    size = is;
    boxx = x_init+xs - size/2;
    boxy = y_init+ys - size/2;
    others = o;
  }

  void update() {
    boxx = lock(x_init+xs, 20, width -20);
    boxy = lock(y_init+ys, 20, height-20);

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
  
  
  void display(int i) {
    fill(255);
    stroke(0);
    strokeWeight(1);
    // display handle
    rect(boxx, boxy, size, size);
    fill(#000000);
    textSize(8);
    text(i, boxx, boxy);
    fill(#FFFFFF);
    // display a cross when pressed
    if (over || press) {
      line(boxx, boxy, boxx+size, boxy+size);
      line(boxx, boxy+size, boxx+size, boxy);
    }
  }



  void overEvent() {
    if (overRect(boxx, boxy, size, size)) {
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


  float getX() {
    return boxx+size/2;
  }

  float getY() {
    return boxy+size/2;
  }


  boolean overRect(float x, float y, float w, float h) {
    if (mouseX >= x && mouseX <= x+w && 
      mouseY >= y && mouseY <= y+h) {
      return true;
    } else {
      return false;
    }
  }


  // limits
  float lock(float val, float minv, float maxv) { 
    return  min(max(val, minv), maxv);
  }
}


