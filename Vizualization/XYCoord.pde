
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

    XYCoord divide(float scalar){
        return new XYCoord(x / scalar, y / scalar);
    }

    XYCoord travelAlong(XYCoord destination, float proportion){
        XYCoord diffVector;
        diffVector = destination.subtract(this).multiply(proportion);
        return this.add(diffVector);
    }

    float getLength(){
        return sqrt(x*x + y*y);
    }

    XYCoord getUnitVector(){
        return this.divide(this.getLength());
    }

    XYCoord getRadialXY(){
        XYCoord uv = this.getUnitVector();
        return uv.multiply(RADIUS+100).add(CENTERPOINT);
    }

};
