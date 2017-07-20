DBox[] dboxes = new DBox[2];

void setup() {
  size(640, 360);
  dboxes[0] = new DBox(width/2, height/2, 100, dboxes);
  dboxes[1] = new DBox(width/2 + 20, height/2 + 10, 100, dboxes);
}

void draw() {
  background(153);
  dboxes[0].update();
  dboxes[1].update();
  dboxes[0].display();
  dboxes[1].display();
}

void mouseReleased() {
  dboxes[0].releaseEvent();
  dboxes[1].releaseEvent();
}

