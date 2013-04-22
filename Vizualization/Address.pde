
class Address implements Comparable<Address>{
    int currentBitcoins;
    int position;
    XYCoord loc;

    Address(int pos){
        position = pos;
        currentBitcoins = 0;
        loc = position2XY(position);
    }

    int compareTo(Address b){
        // bigger addresses are lower
        int diff = b.getBalance() - currentBitcoins;
        if (diff != 0){
            return diff;
        } else {
            return position - b.getPosition();
        }
    }

    XYCoord getXY(){
        return loc;
    }

    int addBitcoins(int amt){
        return currentBitcoins += amt;
    }

    int subtractBitcoins(int amt){
        currentBitcoins -= amt;
        if (currentBitcoins < 0){
            println("Warning: Addr:" + position + " has amt: " + currentBitcoins);
        }
        return currentBitcoins;

    }

    int getBalance(){
        return currentBitcoins;
    }

    int getPosition(){
        return position;
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
