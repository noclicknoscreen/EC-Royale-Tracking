float t, v, r, r_, s;

void setup() {
  size(640, 480);
  t = 0;    // time init
  v = 0.005; // rotation speed
  r_ = 150; // rotation radius
  s = 20;   // size of the ellipse
  smooth();
}

void draw() {
  t+= v;
  
  translate(width/2, height/2);
  background(0);
  fill(255);
  r = r_ + 0.4 * r_ * sin(t*8.15);
  ellipse(r*cos(t), r*sin(t), s, s);
}
