
class Handle {
  int x_init, y_init;                     // initial position
  int boxx, boxy;               // box real time position
  int xs, ys;                   // movement
  int size;                     // box size
  boolean over;                 // handle mouse state
  boolean press;                // handle mouse state
  boolean locked = false;       // handle mouse state
  boolean otherslocked = false; // true when at least one of the handles is locked
  Handle[] others;              // list of handles

    Handle(int ix, int iy, int il, int ih, int is, Handle[] o) {
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

  void display() {
    fill(255);
    stroke(0);
    // display handle
    rect(boxx, boxy, size, size);
    // display a cross when pressed
    if (over || press) {
      line(boxx, boxy, boxx+size, boxy+size);
      line(boxx, boxy+size, boxx+size, boxy);
    }
  }

  int getX() {
    return boxx+size/2;
  }

  int getY() {
    return boxy+size/2;
  }


  boolean overRect(int x, int y, int width, int height) {
    if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
      return true;
    } else {
      return false;
    }
  }


  // limits
  int lock(int val, int minv, int maxv) { 
    return  min(max(val, minv), maxv);
  }
}

