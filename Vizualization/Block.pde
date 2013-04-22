
class Block{
    Transaction[] txs;
    int numTransactions;
    Manager myManager;
    
    Block(Manager myManager, XML blockXML){
        this.myManager = myManager;
        //TODO: Implement this...
    }

    void addFlows(){
        for (int i=0; i<numTransactions; i++){
            txs[i].addFlows(myManager);
        }
    }

};

class Transaction{
    int   numInputs     , numOutputs     ;
    int[] inputPositions, outputPositions;
    int[] inputAmounts  , outputAmounts  ;
    int totalOut;
    boolean isGenerative;

    Transaction(XML transactionXML){
        //T
    }


    void addFlows(Manager myManager){
        if (isGenerative){
            int outPos, outAmt;
            // I think generative trx have only one output
            // But let's iterate over the list to be safe
            for (int i=0; i<numOutputs; i++){
                outPos = outputPositions[i]
                outAmt = outputAmounts[i]
                myManager.addBitcoins(outPos, outAmt);
            }
        } else {
            sendNormalFlows(myManager);
        }
    }

    void addNormalFlows(Manager myManager){
        // Issue: Due to rounding issues, this algorithm
        // May lose track of a few ubitcoins when transactions have 
        // Multiple outputs
        int amt, outAmt;
        int srcPos, dstPos;
        float p;

        for (int i=0; i<numInputs, i++){
            amt = inputAmounts[i];
            srcPos = inputPositions[i]
            for (int j=0; j<numOutputs; j++){
                p = (float) outputAmounts[j] / totalOut;
                outAmt = (int) (amt * p);
                dstPos = outputPositions[j]

                myManager.addFlow(srcPos, dstPos, outAmt)
            }
        }
    }


};