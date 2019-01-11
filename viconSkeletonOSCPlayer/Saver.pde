class Saver implements Runnable {

  Sequence sequence;

  boolean running;

  Object lock;

  ArrayList<Frame> toSave;

  public Saver(Sequence seq) {
    this.sequence = seq;
    running = false;
    lock = new Object();
  }

  public void save(int fNumber, String name, PVector coords) {
    Frame f = new Frame(fNumber, name, coords);
    synchronized(lock) {
      toSave.add(f);
      lock.notify();
    }
  }
  public void start() {
    println("Starting saver process...");
    running = true;
    toSave = new ArrayList<Frame>();
    new Thread(this).start();
  }

  public void stop() {
    println("Stopping saver process...");
    running = false;
    synchronized(lock) {
      lock.notify();
    }
  }


  void run() {
    println("Running... " + this);
    while ( running ) {
      synchronized(lock) {
        if ( toSave.size() <= 0 ) {
          try {
            lock.wait();
          } catch (InterruptedException ie) {
            println("Oops... " + ie.getMessage());
          }
        }
        if ( !running ) {
          break;
        }
        Frame f = toSave.remove(0);
        sequence.add(f);
        
      }
    }
    println("Stopped saver process.");
  }
}

