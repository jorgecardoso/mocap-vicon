import oscP5.*;
import netP5.*;
import controlP5.*;

ControlP5 cp5;

float playFrameRate = 30;
OscP5 oscP5;
NetAddress myRemoteLocation; 
Sequence seq;
Saver saver;
Player player;
String sequenceFile;
Frame currentFrame;

int frameNumber;
boolean saving = false;
boolean playing = false;

float rotX, rotY;
float zoom;

boolean bundleOSCMessages = true;

void setup() {
  size(800, 600, OPENGL);

  myRemoteLocation = new NetAddress("127.0.0.1", 54321);


  frameRate(30);

  OscProperties oscP = new OscProperties();
  //oscP.setDatagramSize(2600);
  oscP.setListeningPort(4000);
  /* start oscP5, listening for incoming messages at port 12000 */

  oscP5 = new OscP5(this, 4000);
//


  //saver.start();
  currentFrame = new Frame(0);

  frameNumber = 0;
  zoom = 1;
  setupP5();
  
  seq = new Sequence(txtSequenceFile.getText());
  seq.load();
  saver = new Saver(seq);
  player = new Player(seq, oscP5, myRemoteLocation);
}


synchronized void draw() {
  background(0);  
  pushMatrix();

  translate(width/2, height-100, 0);
  rotateX( radians(180));

  rotateY(rotY);
  rotateX(rotX);
  scale(zoom);
  drawAxis();


  stroke(0);
  if ( playing ) {
    currentFrame = player.lastFrame;
  }
  //Frame f = seq.get(frameNumber);
  if ( null != currentFrame ) {
    currentFrame.draw();
  }



  popMatrix();
  noLights();
  if ( saving ) {
    //println(sin(radians(frameCount))*255);
    fill((sin(radians(frameCount*3))+1)*127, 0, 0);
    ellipse(20, height-20, 20, 20);
    fill(255, 0, 0);
    text("Saving...", 40, height-20);
  } 

  if ( playing ) {
    fill(255);
    text("Replaying frame: " + currentFrame.frameNumber, 70, height-20);
    //sldTimeLine.setUpdate(false);
    sldTimeLine. changeValue(player.getFramePosition());
  }
}

void drawAxis() {
  stroke(255, 0, 0);
  line(0, 0, 0, 1000, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 1000, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 1000);
}

void mouseDragged() {
  if ( mouseButton == RIGHT) {
    zoom += map(mouseY-pmouseY, 0, height, 0, 2);
  } 
  else {
    if ( mouseY < height-80 ) {
      rotY += radians(map(mouseX-pmouseX, 0, width, 360, 0));
      rotX += radians(map(mouseY-pmouseY, 0, height, 360, 0));
    }
  }
}

void mousePressed() {
  color c = get(mouseX, mouseY);

  if ( null != currentFrame ) {
    String markerName = currentFrame.getMessageName((int)(255-red(c)));
    if ( markerName.length() > 0 ) {
      println(markerName);
      txtMarkerName.setValue(markerName);
    }
  }
}

synchronized void oscEvent(OscMessage theOscMessage) {
  if ( !saving ) return;
  PVector v = new PVector(theOscMessage.get(0).floatValue(), 
  theOscMessage.get(1).floatValue(), 
  theOscMessage.get(2).floatValue());
  int fra = theOscMessage.get(3).intValue();
  frameNumber = fra;
  //

  currentFrame.add(theOscMessage.addrPattern(), v);
  saver.save(frameNumber, theOscMessage.addrPattern(), v);
 println(" "+theOscMessage.addrPattern());
}

void exit() {
  player.stop();
  saver.stop();
  cp5.saveProperties("gui.properties");
  super.exit();
}

