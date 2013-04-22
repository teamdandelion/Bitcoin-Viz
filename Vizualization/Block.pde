
class Block{
    Transaction[] txs;
    int numTransactions;
    
    Block(XML blockXML){
        //TODO: Implement this...
    }

    void addFlows(ArrayList flows){
        for (int i=0; i<numTransactions; i++){
            txs[i].addFlows(flows);
        }
    }

};

class Transaction{
    int numInputs, numOutputs;

    Transaction(XML transactionXML){
        //T
    }


};