import java.util.*;

class Sequence {
  private SortedMap<Integer, Frame> frames;
  private String fileName;
  
  public Sequence (String fileName) {
    frames = new TreeMap<Integer, Frame>();
    this.fileName = fileName;
  }

  Frame[] getFrames() {
    return this.frames.values().toArray(new Frame[] {
    }
    );
  }
  void add(Frame f) {
    Integer k = new Integer(f.frameNumber);
    if ( frames.containsKey(k) ) {
      Frame frame = frames.get(k);
      frame.merge(f);
    } 
    else {
      frames.put(k, f);
    }
  }

  void save() {
    println("Saving...");
    ArrayList<String> fs = new ArrayList<String>();
    for ( Frame f : frames.values() ) {
      fs.addAll(f.getFrameAsStrings());
    }

    saveStrings("sequence.txt", fs.toArray(new String[] {
    }
    ));
    println("Saved " + fs.size()  +  " frames.");
  }

  void load() {
    String [] raw = loadStrings(this.fileName);
    if ( null == raw ) return;
    for ( int i = 0; i < raw.length; i++ ) {
      String [] f = raw[i].trim().split(" ");
      if ( f.length < 5 ) continue;
      float x = 0, y = 0, z = 0;
      int fNumber = 0;

      try {
        fNumber = Integer.parseInt(f[0].trim());
        x = Float.parseFloat(f[2].trim());
        y = Float.parseFloat(f[3].trim());
        z = Float.parseFloat(f[4].trim());
      } 
      catch (Exception e ) {
        println("oops... " + e.getMessage());
      }

      PVector v = new PVector(x, y, z);
      Frame frame = new Frame(fNumber, f[1].trim(), v);
      this.add(frame);
    }

    println("Loaded " + frames.size() + " frames from " + this.fileName);
  }
}

