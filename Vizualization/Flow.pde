
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

