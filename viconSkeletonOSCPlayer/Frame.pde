class Frame {
  int frameNumber;

  HashMap<String, PVector> messages;

  float minX, minY, minZ;
  float maxX, maxY, maxZ;

  public Frame(int fNumber) {
    this(fNumber, null, null);
  }

  public Frame(int fNumber, String name, PVector v) {
    this.frameNumber = fNumber;
    minX = minY = minZ = 1000000;
    maxX = maxY = maxZ = -10000000;
    messages  = new HashMap<String, PVector>();
    if ( null != name && null != v ) {
      this.add(name, v);
    }
  }


  public void merge(Frame f) {
    for ( String key : f.messages.keySet() ) {
      this.add(key, f.messages.get(key));
      //this.messages.put(key, f.messages.get(key));
    }
  }

  public void add(String name, PVector coords) {
    messages.put(name, coords);
    if ( coords.x < minX ) {
      minX = coords.x;
    }
    if ( coords.y < minY ) {
      minY = coords.y;
    }
    if ( coords.z < minZ ) {
      minZ = coords.z;
    }
    if ( coords.x > maxX ) {
      maxX = coords.x;
    }
    if ( coords.y > maxY ) {
      maxY = coords.y;
    }
    if ( coords.z > maxZ ) {
      maxZ = coords.z;
    }
  }



  public ArrayList<String> getFrameAsStrings() {
    ArrayList<String> fs= new ArrayList<String>();

    for ( String key : messages.keySet() ) {
      PVector c = messages.get(key);
      String s = this.frameNumber + " " + key + " " + c.x + " " + c.y + " " + c.z;
      fs.add(s);
    }
    return fs;
  }

  public String getMessageName(int index) {
    int i = 0;
    for ( String s : currentFrame.messages.keySet() ) {
      if (i == index ) {
        return s;
      }
      i++;
    }
    return "";
  }

   void draw() {
    int i = 0;
    for ( String s : messages.keySet() ) {
      PVector l = messages.get(s);
      pushMatrix();
      fill(255-i, 0, 0);
      translate(l.x, l.y, l.z);
      box(50);
      popMatrix();
      i++;
    }
    drawBB();
  }
  void drawBB() {
    stroke(255);
    strokeWeight(2);
    line(minX, minY, minZ, maxX, minY, minZ);
    line(maxX, minY, minZ, maxX, maxY, minZ);
    line(maxX, maxY, minZ, minX, maxY, minZ);
    line(minX, maxY, minZ, minX, minY, minZ);

    line(minX, minY, maxZ, maxX, minY, maxZ);
    line(maxX, minY, maxZ, maxX, maxY, maxZ);
    line(maxX, maxY, maxZ, minX, maxY, maxZ);
    line(minX, maxY, maxZ, minX, minY, maxZ);

    line(minX, minY, minZ, minX, minY, maxZ);
    line(maxX, minY, minZ, maxX, minY, maxZ);
    line(minX, maxY, minZ, minX, maxY, maxZ);
    line(maxX, maxY, minZ, maxX, maxY, maxZ);
  }
}

