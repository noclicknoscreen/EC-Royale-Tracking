void displayFramerate() {
  pushMatrix();
  fill(#FFFFFF);
  textSize(14);
  text(int(frameRate) + " fps", 10, 20);
  popMatrix();
}


Numberbox ang0;
Numberbox pos0x;
Numberbox pos0y;
Numberbox ang1;
Numberbox pos1x;
Numberbox pos1y;
Numberbox ang2;
Numberbox pos2x;
Numberbox pos2y;


void setupControl() {
  pos0x = cp5.addNumberbox("pos0x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(30 + 70 + 30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(int(cam[0].getX_init()))
              ;
  pos0y = cp5.addNumberbox("pos0y")
    .setSize(70, 20)
      .setRange(0, roomHeight)
        .setPosition(30+ 70 +30 +70 +30, 40)
          .setValue(int(cam[0].getY_init()))
            ;
  ang0 = cp5.addNumberbox("ang0")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(int(degrees(cam[0].getAng_init())))
              ;
  makeEditable(pos0x);
  makeEditable(pos0y);
  makeEditable(ang0);
  ang0.getValueLabel().setText(str(int(degrees(cam[0].getAng()))));


  pos1x = cp5.addNumberbox("pos1x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(640/2+30 + 70 + 30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(int(cam[1].getX_init()))
              ;
  pos1y = cp5.addNumberbox("pos1y")
    .setSize(70, 20)
      .setRange(0, roomHeight)
        .setPosition(640/2+30+ 70 +30 +70 +30, 40)
          .setValue(int(cam[1].getY_init()))
            ;
  ang1 = cp5.addNumberbox("ang1")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(640/2 + 30, 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(int(degrees(cam[1].getAng_init())))
              ;
  makeEditable(pos1x);
  makeEditable(pos1y);
  makeEditable(ang1);
  ang1.getValueLabel().setText(str(int(degrees(cam[1].getAng()))));
  pos2x = cp5.addNumberbox("pos2x")
    .setSize(70, 20)
      .setRange(0, roomWidth)
        .setPosition(30 + 70 + 30, 2*40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(int(cam[2].getX_init()))
              ;
  pos2y = cp5.addNumberbox("pos2y")
    .setSize(70, 20)
      .setRange(0, roomHeight)
        .setPosition(30+ 70 +30 +70 +30, 2* 40)
          .setValue(int(cam[2].getY_init()))
            ;
  ang2 = cp5.addNumberbox("ang2")
    .setSize(70, 20)
      .setRange(0, 360)
        .setPosition(30, 2* 40)
          .setDirection(Controller.HORIZONTAL)
            .setValue(int(degrees(cam[2].getAng_init())))
              ;
  makeEditable(pos2x);
  makeEditable(pos2y);
  makeEditable(ang2);
  ang2.getValueLabel().setText(str(int(degrees(cam[2].getAng()))));


  cp5.addButton("save")
    .setPosition(width - 60, height - 40)
      .setSize(50, 20)
        ;
}


void pos0x(int v) {
  cam[0].setX(v);
}
void pos0y(int v) {
  cam[0].setY(v);
}
void ang0(int v) {
  cam[0].setAng(radians(v));
}
void pos1x(int v) {
  cam[1].setX(v);
}
void pos1y(int v) {
  cam[1].setY(v);
}
void ang1(int v) {
  cam[1].setAng(radians(v));
}
void pos2x(int v) {
  cam[2].setX(v);
}
void pos2y(int v) {
  cam[2].setY(v);
}
void ang2(int v) {
  cam[2].setAng(radians(v));
}



void save(int v) {
  data.setFloat("cam[0]X", cam[0].getX());
  data.setFloat("cam[0]Y", cam[0].getY());
  data.setFloat("cam[0]ang", cam[0].getAng());
  data.setFloat("cam[1]X", cam[1].getX());
  data.setFloat("cam[1]Y", cam[1].getY());
  data.setFloat("cam[1]ang", cam[1].getAng());
  data.setFloat("cam[2]X", cam[2].getX());
  data.setFloat("cam[2]Y", cam[2].getY());
  data.setFloat("cam[2]ang", cam[2].getAng());
  for (int id = 0; id < dbox.length; id ++) {
    for (int ihandle = 0; ihandle < 4; ihandle++) {
      saveDBoxHandle(id, ihandle);
    }
  }

  saveJSONObject(data, "data/roomProfile.json");
}

void saveDBoxHandle(int id, int ihandle) {
  data.getJSONArray("dbox")
    .getJSONObject(id)
      .getJSONArray("handlesCoor")
        .getJSONObject(ihandle)
          .setFloat("x", dbox[id].getHandles()[ihandle].getX());
  data.getJSONArray("dbox")
    .getJSONObject(id)
      .getJSONArray("handlesCoor")
        .getJSONObject(ihandle)
          .setFloat("y", dbox[id].getHandles()[ihandle].getY());
}

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

