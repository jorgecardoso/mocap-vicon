
int timeLinePosition;
Toggle tglBundleOSCMessages;
Button btnPlayPause;
Slider sldTimeLine;
Slider sldSendRate;
Textfield txtMarkerName;
Textfield txtSequenceFile;
Bang bngOpenFile;
Bang bngLoad;

PImage[] imgsPlay;
PImage[] imgsPause;

void setupP5() {
  cp5 = new ControlP5(this);


  imgsPlay = new PImage[3];
  imgsPlay[0] = loadImage("play_a.png");
  imgsPlay[1] = loadImage("play_b.png");
  imgsPlay[2] = loadImage("play_c.png");

  imgsPause = new PImage[3];
  imgsPause[0] = loadImage("pause_a.png");
  imgsPause[1] = loadImage("pause_b.png");
  imgsPause[2] = loadImage("pause_c.png");



  // OSC Sending stuff
  tglBundleOSCMessages = cp5.addToggle("bundleOSCMessages").setPosition(10, 10).setSize(25, 25).setValue(bundleOSCMessages);
  tglBundleOSCMessages.setLabel("Bundle OSC messages");
  tglBundleOSCMessages.getCaptionLabel().getStyle().marginTop = -20; //move upwards (relative to button size)
  tglBundleOSCMessages.getCaptionLabel().getStyle().marginLeft = 28; //move to the right


  sldSendRate = cp5.addSlider("playFrameRate").setPosition(10, 80).setRange(0.1, 60).setSize(100, 25).setValue(playFrameRate);
  sldSendRate.setLabel("OSC send framerate");

  txtSequenceFile = cp5.addTextfield("sequenceFile").setPosition(200, 10).setSize(200, 25);
  txtSequenceFile.setLabel("Sequence file");
  txtSequenceFile.getCaptionLabel().getStyle().marginTop = -20; //move upwards (relative to button size)
  txtSequenceFile.getCaptionLabel().getStyle().marginLeft = 208;

  bngOpenFile = cp5.addBang("openFile").setPosition(490, 10).setSize(25, 25);


  btnPlayPause = cp5.addButton("play").setPosition(10, height-70).setImages(imgsPlay)
    .updateSize()
      ;
  sldTimeLine = cp5.addSlider("timeLinePosition").setPosition(70, height-70).setSize(width-80, 30);

  txtMarkerName = cp5.addTextfield("markerName").setPosition(10, height-120)
    .setSize(200, 30);



  cp5.loadProperties("gui.properties");
}

public void controlEvent(ControlEvent theEvent) {
 // println(theEvent.getController().getName());
  //  n = 0;

  if ( theEvent.getController() == tglBundleOSCMessages ) {
    if ( null != player ) {
      player.setSendBundle(bundleOSCMessages);
    }
  } 
  else if ( theEvent.getController() == btnPlayPause) {
    buttonPlayPausePressed();
  } 
  else  if ( theEvent.getController() == sldTimeLine ) {
    if ( null != player ) {
      player.setFramePosition(timeLinePosition);
    }
  } 
  else if ( theEvent.getController() == sldSendRate ) {
    if ( null != player ) {
      player.setFrameRate( playFrameRate );
    }
  }
}

void openFile() {
  
selectInput("Select a file", "fileSelected");
  
}

void fileSelected(File selection) {
  //println("fileSelected");
  String f  = selection.getAbsolutePath();
  println("Selected file: " + f);
  txtSequenceFile.setValue(f);
  sequenceFile = f;
  seq = new Sequence(sequenceFile);
  seq.load();
  player = new Player(seq, oscP5, myRemoteLocation);
  playing = false;
}

void buttonPlayPausePressed() {
  //println("buttonPlayPausePressed");
  if ( playing ) {
    if ( player.paused ) {
      player.resume();
      btnPlayPause.setImages(imgsPause);
    } 
    else {
      player.pause();
      btnPlayPause.setImages(imgsPlay);
    }
  } 
  else {
    sldTimeLine.setRange(0, player.getLength());
    player.start();
    player.setFrameRate(playFrameRate);
    playing = true;
    btnPlayPause.setImages(imgsPause);
  }
}


void keyPressed() {
  if ( key == 'p' ) {
  } 
  else if ( key == 's' ) {
    if ( saving ) {
      saver.stop();
      seq.save();
    } 
    else {
      saver.start();
    }
    saving = !saving;
  }
}
