
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
