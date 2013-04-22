Manager myManager;
XML myXML;

int XBOUND = 800;
int YBOUND = 800;
int RADIUS = 360;
int N_CIRCLES = 80;
// The spiral code taken from a Processing.js example by 
// Jim Bumgardner
// http://krazydad.com/tutorials/circles_js/showexample.php?ex=phyllo_equal

float PHI = (sqrt(5) + 1)/2 -1;
float GOLDEN_ANGLE = PHI * TWO_PI;
float LG_AREA = sq(RADIUS) * PI;
float SM_AREA = LG_AREA / N_CIRCLES;
float SM_RAD  = sqrt(SM_AREA / PI) * 2 * 0.87;
float CX = XBOUND / 2.0;
float CY = YBOUND / 2.0;



XYCoord CENTERPOINT = new XYCoord(CX, CY);


void setup(){
    println("Starting setup");
    size(XBOUND, YBOUND);
    noStroke();
    println("Loading XML");
    myXML = loadXML("transactions.xml");
    //println(myXML);
    println("Got XML; starting manager init");
    myManager = new Manager(myXML);

};

void draw(){
    translate(20,20);
    background(155);
    myManager.display();

};


XYCoord position2XY(int position){
    int pos = position + 1;
    float angle = pos * GOLDEN_ANGLE;
    float cum_area = pos * SM_AREA;
    float spiral_rad = sqrt(cum_area / PI);
    float x = CX + cos(angle) * spiral_rad;
    float y = CY + sin(angle) * spiral_rad;

    return new XYCoord(x, y);
}

color size2color(int bitcoins){
    return color(0,0,0);
}

float size2radius(int bitcoins){
    return 1.0 + sqrt(bitcoins) / 10;
}

void drawCircle(XYCoord xy, float radius, color c){
    fill(c);
    ellipse(xy.getX(), xy.getY(), radius*2, radius*2);


}
