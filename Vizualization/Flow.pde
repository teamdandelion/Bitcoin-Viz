
class Flow {
    Address destination;
    XYCoord sourceXY, destinationXY;
    int amount;
    int travelTime;  // in miliseconds
    int startTime; // in miliseconds
    boolean finished;

    Flow(Address source, Address destination, int amount, int travelTime){
        this.destination = destination;
        this.amount = amount;
        this.travelTime = travelTime;
        startTime = millis();
        
        assert (source != null || destination != null);

        if (source == null){
            destinationXY = destination.getXY();
            sourceXY = destinationXY.getRadialXY();
        } else if (destination == null){
            sourceXY = source.getXY();
            destinationXY = sourceXY.getRadialXY();
        } else {
            sourceXY = source.getXY();
            destinationXY = destination.getXY();
        }

        if (source != null){
            source.subtractBitcoins(amount);
        }
        finished = false;
    }

    void display(){
        int curtime = millis();
        if (!finished){
            if (curtime > travelTime + startTime){
                // Flow is finished
                if (destination != null){
                    destination.addBitcoins(amount);
                }
                
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

