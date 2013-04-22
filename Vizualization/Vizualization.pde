Manager myManager;
XML myXML;

void setup(){
    size(800, 800);
    noStroke();
    myXML = loadXML("bitcoins.xml");
    myManager = new Manager(myXML);

};

void draw(){
    translate(20,20);
    background(155);
    myManager.display();

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
