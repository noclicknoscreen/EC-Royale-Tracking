DBox d1, d2;

void setup() {
  size(640, 360);
  d1 = new DBox(width/2, height/2, 100);
  d2 = new DBox(width/2 + 20, height/2 + 10, 100);
}

void draw() {
  background(153);
  d1.display();
  d2.display();
}

void mouseReleased() {
  d1.releaseEvent();
  d2.releaseEvent();
}

