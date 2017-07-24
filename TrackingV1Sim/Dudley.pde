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
  float x, y;
  float  t = 0;     // time init
  float  v;         // rotation speed
  float  r_;        // rotation radius before sin
  float  r;         // rotation radius after sin 
  float  s = 20;    // size of dudley


  Dudley(float x, float y, float r_, float v) {
    this.x = x;
    this.y = y;
    this.r_ = r_;
    this.v = v;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    t += v;
    r = r_ *( 1 + 0.4 * sin(t*8.15));
    stroke(255);
    strokeWeight(20);
    point(r*cos(t), r*sin(t));
    popMatrix();
  }
}

