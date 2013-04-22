
class Block{
    Transaction[] txs;
    int numTransactions;
    Manager myManager;
    
    Block(Manager myManager, XML blockXML){
        this.myManager = myManager;

        XML[] transactionXMLs = blockXML.getChildren();
        numTransactions = blockXML.getInt("Transactions");

        txs = new Transaction[numTransactions];
        for (int i=0; i<numTransactions; i++){
            txs[i] = new Transaction(transactionXMLs[i]);
        }
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
        XML inputs, outputs;

        String genStr = transactionXML.getString("Generative");
        if (genStr == "True"){
            isGenerative = true;
        } else if (genStr == "False"){
            isGenerative = false;
        } else {
            assert 0
        }

        inputs  = transactionXML.getChild("Inputs");
        outputs = transactionXML.getChild("Outputs");

        numInputs  = inputs.getInt("Num");
        numOutputs = outputs.getInt("Num");
        totalOut   = outputs.getInt("Total");

        inFlows  = inputs.getChildren();
        outFlows = outputs.getChildren();


        for (int i=0; i<numInputs; i++){
            XML flow = inFlows[i];
            int pos = flow.getInt("Position");
            int amt = flow.getInt("Amount");
            inputPositions[i] = pos;
            inputAmounts[i]   = amt;
        }

        for (int i=0; i<numOutputs; i++){
            XML flow = outFlows[i];
            int pos = flow.getInt("Position");
            int amt = flow.getInt("Amount");
            outputPositions[i] = pos;
            outputAmounts[i]   = amt;
        }

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