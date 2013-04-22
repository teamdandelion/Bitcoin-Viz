Address[] addresses;
ArrayList flows;
int numAddresses;

void setup(){
  size(800, 800);
  noStroke();
  numAddresses = 30;

  frameRate(100);
  addresses = new Address[numAddresses];
  flows = new ArrayList();
  for (int i=0; i<numAddresses; i++){
    addresses[i] = new Address(i);
  }

  Flow firstFlow = new Flow(addresses[17], 30, 5000);
  Flow secondFlow = new Flow(addresses[13], 80, 5000);
  flows.add(firstFlow);
  flows.add(secondFlow);

};

void draw(){
  translate(20,20);
  background(155);
  for (int i=0; i<numAddresses; i++){
    addresses[i].display();
  }

  for (int i=flows.size()-1; i>=0; i--){
    Flow flow = (Flow) flows.get(i);
    flow.display();
    if (flow.isFinished()){
      flows.remove(i);
    }
  }
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
  Address destination;
  XYCoord sourceXY, destinationXY;
  int amount;
  int travelTime;  // in miliseconds
  int startTime; // in miliseconds
  boolean finished;

  Flow (Address destination, int amount, int travelTime){
    this.destination = destination;
    this.amount = amount;
    this.travelTime = travelTime;
    startTime = millis();
    sourceXY = new XYCoord(600.0,600.0);
    destinationXY = destination.getXY();
    finished = false;
  }

  Flow(Address source, Address destination, int amount, int travelTime){
    this.destination = destination;
    this.amount = amount;
    this.travelTime = travelTime;
    startTime = millis();
    sourceXY = source.getXY();
    destinationXY = destination.getXY();

    source.subtractBitcoins(amount);
    finished = false;
  }

  void display(){
    int curtime = millis();
    if (!finished){
      if (curtime > travelTime + startTime){
        // Flow is finished
        destination.addBitcoins(amount);
        finished = true;
      } else {
        drawFlow(curtime);
      }
    }
  }

  boolean isFinished(){
    return finished;
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
  return 1.0 + bitcoins / 20;
}

void drawCircle(XYCoord xy, float radius, color c){
  fill(c);
  ellipse(xy.getX(), xy.getY(), radius*2, radius*2);
}
