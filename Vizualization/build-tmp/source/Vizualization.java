import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Vizualization extends PApplet {

Address[] addresses;
ArrayList flows;
int numAddresses;

public void setup(){
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

public void draw(){
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

  public float getX(){
    return x;
  }

  public float getY(){
    return y;
  }

  public XYCoord add(XYCoord otherCoord){
    return new XYCoord(x + otherCoord.getX(), y + otherCoord.getY());
  }

  public XYCoord subtract(XYCoord otherCoord){
    return new XYCoord(x - otherCoord.getX(), y - otherCoord.getY());
  }

  public XYCoord multiply(float scalar){
    return new XYCoord(x * scalar, y * scalar);
  }

  public XYCoord travelAlong(XYCoord destination, float proportion){
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
    sourceXY = new XYCoord(600.0f,600.0f);
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

  public void display(){
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

  public boolean isFinished(){
    return finished;
  }

  public void drawFlow(int currentTime){
    float p = (float) (currentTime - startTime) / travelTime;
    XYCoord myLocation = sourceXY.travelAlong(destinationXY, p);
    int c = size2color(amount);
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

  public XYCoord getXY(){
    return loc;
  }

  public int addBitcoins(int amt){
    return currentBitcoins += amt;
  }

  public int subtractBitcoins(int amt){
    return currentBitcoins -= amt;
  }

  public void display(){
    int c = size2color(currentBitcoins);
    float radius = size2radius(currentBitcoins);
    drawCircle(loc, radius, c);
  }

  public void forceDisplay(){
    int c = color(0,0,0);
    float radius = 20;
    drawCircle(loc, radius, c);

  }
};

public XYCoord position2XY(int position){
  int gridWidth = 6;
  int gridSize = 40;

  int x, y;
  x = position % gridWidth;
  y = position / gridWidth;
  return new XYCoord(x * gridSize, y*gridSize);
}

public int size2color(int bitcoins){
  return color(0,0,0);
}

public float size2radius(int bitcoins){
  return 1.0f + bitcoins / 20;
}

public void drawCircle(XYCoord xy, float radius, int c){
  fill(c);
  ellipse(xy.getX(), xy.getY(), radius*2, radius*2);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Vizualization" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
