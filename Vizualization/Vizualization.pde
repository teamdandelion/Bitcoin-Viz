Address[] addresses;
ArrayList flows;
int numAddresses;

void setup(){
  size(800, 800);
  noStroke();
  a1 = new Address(0);
  a2 = new Address(1);
  a3 = new Address(2);
  f = new Flow(a1, a2, 30, 5000);

};

void draw(){
  translate(20,20);
  background(155);
  a1.display();
  a2.display();
  a3.display();
  f.display();
};

// ============== ============== ============== ============== \\

class XYCoord{
  float x, y;
  
  XYCoord(float x, float y){
    this.x = x;
    this.y = y;
  }

  float getX(){
    return x;
  }

  float getY(){
    return y;
  }

  XYCoord add(XYCoord otherCoord){
    return new XYCoord(x + otherCoord.getX(), y + otherCoord.getY());
  }

  XYCoord subtract(XYCoord otherCoord){
    return new XYCoord(x - otherCoord.getX(), y - otherCoord.getY());
  }

  XYCoord multiply(float scalar){
    return new XYCoord(x * scalar, y * scalar);
  }

  XYCoord travelAlong(XYCoord destination, float proportion){
    XYCoord diffVector;
    diffVector = destination.subtract(this).multiply(proportion);
    return this.add(diffVector);
  }

};

// ============== ============== ============== ============== \\

class Flow {
  Address source, destination;
  XYCoord sourceXY, destinationXY;
  float currentX, currentY;
  int amount;
  int travelTime;  // in miliseconds
  int startTime; // in miliseconds


  Flow(Address source, Address destination, int amount, int travelTime){
    this.source = source;
    this.destination = destination;
    this.amount = amount;
    this.travelTime = travelTime;
    startTime = millis();
    sourceXY = source.getXY();
    destinationXY = destination.getXY();

    source.subtractBitcoins(amount);
  }

  Boolean display(){
    int curtime = millis();
    if (curtime > travelTime + startTime){
      // Flow is finished
      destination.addBitcoins(amount);
      return true;
    } else {
      drawFlow(curtime);
      return false;
    }
  }

  void drawFlow(int currentTime){
    float p = (float) (currentTime - startTime) / travelTime;
    XYCoord myLocation = sourceXY.travelAlong(destinationXY, p);
    color c = size2color(amount);
    float radius = size2radius(amount);
    drawCircle(myLocation, radius, c);
  }

};


// ============== ============== ============== ============== \\

class Address {
  int currentBitcoins;
  int position;
  XYCoord loc;

  Address(int pos){
    position = pos;
    currentBitcoins = 0;
    loc = position2XY(position);
  }

  XYCoord getXY(){
    return loc;
  }

  int addBitcoins(int amt){
    return currentBitcoins += amt;
  }

  int subtractBitcoins(int amt){
    return currentBitcoins -= amt;
  }

  void display(){
    color c = size2color(currentBitcoins);
    float radius = size2radius(currentBitcoins);
    drawCircle(loc, radius, c);
  }

  void forceDisplay(){
    color c = color(0,0,0);
    float radius = 20;
    drawCircle(loc, radius, c);

  }
};

XYCoord position2XY(int position){
  int gridWidth = 6;
  int gridSize = 40;

  int x, y;
  x = position % gridWidth;
  y = position / gridWidth;
  return new XYCoord(x * gridSize, y*gridSize);
}

color size2color(int bitcoins){
  return color(0,0,0);
}

float size2radius(int bitcoins){
  return 10.0 + bitcoins / 20;
}

void drawCircle(XYCoord xy, float radius, color c){
  fill(c);
  ellipse(xy.getX(), xy.getY(), radius*2, radius*2);
}
