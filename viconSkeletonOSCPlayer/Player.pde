class Player implements Runnable {

  private Sequence sequence;
  private int milliInterval = 100;
  private boolean running;
  private boolean paused;
  private int currentFrame;
  private Frame lastFrame;
  private OscP5 oscP5;
  private boolean bundle;
  private Frame[] frames;
  NetAddress myRemoteLocation; 

  public Player(Sequence seq, OscP5 oscP5, NetAddress loc ) {
    this.sequence = seq;
    this.running = false;
    this.paused = false;
    this.oscP5 = oscP5;
    this.myRemoteLocation = loc;
    this.bundle = true;
    this.currentFrame = 0;
    frames = this.sequence.getFrames();
    println("Frames length:" + frames.length);
  }

  public void setFrameRate(float frameRate) {
    milliInterval = (int)(1000/frameRate);
  }

  public void start() {
    println("Starting player...");
    running = true;

    new Thread(this).start();
  }

  public void setFramePosition(int frameNumber) {
    this.currentFrame = frameNumber;
    if ( playing ) {
      triggerOSC(frames[currentFrame]);
    }
  }
  public int getFramePosition() {
    return this.currentFrame;
  }
  public int getLength() {
    return frames.length;
  }

  public void stop() {
    println("Stopping player process...");
    running = false;
  }

  public void pause() {
    this.paused = true;
  }

  public boolean isPaused() {
    return this.paused;
  }

  public void resume() {
    this.paused = false;
  }

  public void setSendBundle(boolean bundle) {
    this.bundle = bundle;
    if ( this.bundle ) {
      println("Player: sending OSC bundles.");
    } 
    else {
      println("Player: sending individual OSC messages.");
    }
  }

  public boolean getSendBundle() {
    return this.bundle;
  }

  void run() {
    println("Running... " + this);

    while ( running ) {

      if ( !paused ) {

        triggerOSC(frames[this.currentFrame]);
      }
      try {
        Thread.sleep(milliInterval);
      } 
      catch ( InterruptedException ie ) {
        println("Oops... " + ie.getMessage());
      } 
      
      if ( !running ) {
        break;
      }
      
      if ( !paused ) {
        this.currentFrame++;
      }
      if ( this.currentFrame >= frames.length ) {
        this.currentFrame = 0;
      }
    }
    println("Stopped player process.");
  }

  void triggerOSC(Frame f) {
    //println("Triggered frame: " + f.frameNumber);
    lastFrame = f;
    OscBundle myBundle = new OscBundle();
    OscMessage myMessage = new OscMessage("");
    long now = System.currentTimeMillis();
    for ( String name : f.messages.keySet() ) {

      PVector v = f.messages.get(name);

      myMessage.clear();
      myMessage.setAddrPattern(name);

      myMessage.add(v.x); 
      myMessage.add(v.y); 
      myMessage.add(v.z); 
      myMessage.add((int)f.frameNumber); 

      /* send the message */
      if ( this.bundle ) {

        int bSize = myBundle.getBytes().length;

        int mSize = myMessage.getBytes().length;
        if ( myBundle.size() <= 0 || ( bSize + mSize ) < 1024*1) {
          myBundle.add(myMessage);
        } 
        else {
          //println("Size of bundle int: " + myBundle.getBytes().length);
          myBundle.setTimetag(now);
          oscP5.send(myBundle, myRemoteLocation);
          myBundle = new OscBundle();
        }
      } 
      else {
        oscP5.send(myMessage, myRemoteLocation);
        //println("sent message");
      }
    }

    if ( this.bundle ) {
      //println("Size of final bundle: " + myBundle.getBytes().length);
      myBundle.setTimetag(now);
      oscP5.send(myBundle, myRemoteLocation);
      //println("sent bundle");
    }
  }
}
