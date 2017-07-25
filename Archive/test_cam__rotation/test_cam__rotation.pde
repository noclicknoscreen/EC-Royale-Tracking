import controlP5.*;

final static int n = 2;
final static float fieldOfView = 0.84823; // kinect v1 field of view angle in radians
VCam[] vcam = new VCam[n];  //virtual cam
ControlP5 cp5;

void setup() {
  size(640, 480);
  cp5 = new ControlP5(this);
  for (int i=0; i<n; i++) {
    vcam[i] = new VCam(i, 100 + 20*i, 100+ 20*i, i*PI/4, vcam);
  }
}

void draw() {
  background(140, 140, 140);
  for (int i=0; i<n; i++) {
    vcam[i].update();
  }
  for (int i=0; i<n; i++) {
    vcam[i].display();
  }
}

void mouseReleased() {
  for (int i=0; i<n; i++) {
    vcam[i].releaseEvent();
  }
}

