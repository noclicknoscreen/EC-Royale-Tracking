import point2line.*;

UICam[] uicams = new UICam[1];
int camX = 100;
int camY = 100;
int size = 20;
float camang = PI/4;
final static float fieldOfView = 0.84823; // kinect v1 field of view angle in radians


void setup() {
  size(640, 480);
  uicams[0] = new UICam(camX, camY, size, uicams);
}

void draw() {
  background(140, 140, 140);
  uicams[0].update();
  uicams[
  
}


