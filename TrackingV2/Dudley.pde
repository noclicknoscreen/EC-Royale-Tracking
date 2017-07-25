/*******************************************************************************************
 *
 *                                   DUDLEY CLASS
 *
 *  Dudley is a custom class to simulate users for dev interface without kinects.
 *  Dudleys are generated with their position and speed, and they wander around 
 *  in the virtual room.
 *
 *******************************************************************************************/

class Dudley {
  int id;
  float Ox, Oy, x, y;
  float  v;         // rotation speed
  float  r_;        // rotation radius before sin
  float  r;         // rotation radius after sin 
  float  s = 20;    // size of dudley
  float  t = 0;     // time init
  int zone = -1;    // zone where dudley is : -1 if not detected

  Dudley(int id, float Ox, float Oy, float r_, float v) {
    this.id = id;
    this.Ox = Ox;
    this.Oy = Oy;
    this.r_ = r_;
    this.v = v;
  }

  void display() {
    pushMatrix();
    t += v;
    r = r_ *( 1 + 0.4 * sin(t*8.15));
    stroke(255);
    strokeWeight(20);
    x = Ox + r*cos(t);
    y = Oy + r*sin(t);
    point(x, y);
    popMatrix();
  }

  float getX() {
    return x;
  }
  float getY() {
    return y;
  }
  void setZone(int i) {
    zone = i;
  }
}

