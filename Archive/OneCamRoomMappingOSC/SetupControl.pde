Numberbox ang1;
Numberbox pos1x;
Numberbox pos1y;
Numberbox ang2;
Numberbox pos2x;
Numberbox pos2y;
Numberbox ang3;
Numberbox pos3x;
Numberbox pos3y;

void setupControl() {
  ang1 = cp5.addNumberbox("ang1")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(30, 480/2 - 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(180)
              ;
  pos1x = cp5.addNumberbox("pos1x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(30 + 70 + 30, 480/2 - 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(roomWidth/2 - 20)
              ;
  pos1y = cp5.addNumberbox("pos1y")
    .setSize(70, 20)
      .setRange(0, roomHeight)
        .setPosition(30+ 70 +30 +70 +30, 480/2 - 40)
          .setValue(roomHeight/2-80)
            ;
  makeEditable(ang1);
  makeEditable(pos1x);
  makeEditable(pos1y);
  ang2 = cp5.addNumberbox("ang2")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(640/2 + 30, 480/2 - 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(90)
              ;
  pos2x = cp5.addNumberbox("pos2x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(640/2+30 + 70 + 30, 480/2 - 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(roomWidth/2 + 30)
              ;
  pos2y = cp5.addNumberbox("pos2y")
    .setSize(70, 20)
      .setRange(0, roomHeight)
        .setPosition(640/2+30+ 70 +30 +70 +30, 480/2 - 40)
          .setValue(roomHeight/2-30)
            ;
  makeEditable(ang2);
  makeEditable(pos2x);
  makeEditable(pos2y);
  ang3 = cp5.addNumberbox("ang3")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(30, 2*480/2 - 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(0)
              ;
  pos3x = cp5.addNumberbox("pos3x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(30 + 70 + 30, 2*480/2 - 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(roomWidth/2 + 50)
              ;
  pos3y = cp5.addNumberbox("pos3y")
    .setSize(70, 20)
      .setRange(0, roomHeight)
        .setPosition(30+ 70 +30 +70 +30, 2*480/2 - 40)
          .setValue(roomHeight/2-80)
            ;
  makeEditable(ang3);
  makeEditable(pos3x);
  makeEditable(pos3y);
}


void ang1(int v) {
  cam1ang = radians(v);
}
void pos1x(int v) {
  cam1X = v;
}
void pos1y(int v) {
  cam1Y = v;
}
//void ang2(int v) {
//  cam2ang = radians(v);
//}
//void pos2x(int v) {
//  cam2X = v;
//}
//void pos2y(int v) {
//  cam2Y = v;
//}
//void ang3(int v) {
//  cam3ang = radians(v);
//}
//void pos3x(int v) {
//  cam3X = v;
//}
//void pos3y(int v) {
//  cam3Y = v;
//}


// function that will be called when controller 'numbers' changes
public void numbers(float f) {
  println("received "+f+" from Numberbox numbers ");
}

void makeEditable( Numberbox n ) {
  // allows the user to click a numberbox and type in a number which is confirmed with RETURN


  final NumberboxInput nin = new NumberboxInput( n ); // custom input handler for the numberbox

  // control the active-status of the input handler when releasing the mouse button inside 
  // the numberbox. deactivate input handler when mouse leaves.
  n.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( true );
    }
  }
  ).onLeave(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      nin.setActive( false ); 
      nin.submit();
    }
  }
  );
}

