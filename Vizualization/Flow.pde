
class Flow {
    Address destination;
    XYCoord sourceXY, destinationXY;
    int amount;
    int travelTime;  // in miliseconds
    int startTime; // in miliseconds
    boolean finished;
    color myColor;

    Flow(Address source, Address destination, int amount, int travelTime){
        this.destination = destination;
        this.amount = amount;
        this.travelTime = travelTime;
        startTime = millis();
        
        assert (source != null || destination != null);

        if (source == null){
            destinationXY = destination.getXY();
            sourceXY = destinationXY.getRadialXY();
            myColor = color(255,0,0); // OON->IN = Red
        } else if (destination == null){
            sourceXY = source.getXY();
            destinationXY = sourceXY.getRadialXY();
            myColor = color(0,255,0); // IN->OUT = Green
        } else {
            sourceXY = source.getXY();
            destinationXY = destination.getXY();
            myColor = color(255,255,255); // IN->IN = Black
        }

        if (source != null){
            source.subtractBitcoins(amount);
        }
        finished = false;
    }

    void display(int currentTime){
        if (!finished){
            if (currentTime > travelTime + startTime){
                // Flow is finished
                if (destination != null){
                    destination.addBitcoins(amount);
                }

                finished = true;
            } else {
                drawFlow(currentTime);
            }
        }
    }

    boolean isFinished(){
        return finished;
    }

    void drawFlow(int currentTime){
        float p = (float) (currentTime - startTime) / travelTime;
        XYCoord myLocation = sourceXY.travelAlong(destinationXY, p);
        color c = myColor;
        float radius = size2radius(amount);
        drawCircle(myLocation, radius, c);
    }

};

