import controlP5.*;

VCam[] vcam = new VCam[1];  //virtual cam
ControlP5 cp5;
final static float fieldOfView = 0.84823; // kinect v1 field of view angle in radians


void setup() {
  size(640, 480);
  cp5 = new ControlP5(this);
  vcam[0] = new VCam(0, 100, 100, PI/4, vcam);
}

void draw() {
  background(140, 140, 140);
  vcam[0].update();
  vcam[0].display();
}

void mouseReleased() {
  vcam[0].releaseEvent();
} 




