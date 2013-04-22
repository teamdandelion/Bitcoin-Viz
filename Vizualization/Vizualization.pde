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
