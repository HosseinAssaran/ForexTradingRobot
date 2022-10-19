
#include <Trade\Trade.mqh>

CTrade trade;

input int StopLossPoints = 30;
input int TakeProfitPoints = 50;

void OnTick()
  {
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      
      string signal = "";
  
      double myMovingAvrageArray20[], myMovingAvrageArray50[];
      
      int movingAvrageDefinition20 = iMA (_Symbol, _Period, 20, 0, MODE_SMA, PRICE_CLOSE);
      int movingAvrageDefinition50 = iMA (_Symbol, _Period, 50, 0, MODE_SMA, PRICE_CLOSE);

      ArraySetAsSeries(myMovingAvrageArray20, true);
      ArraySetAsSeries(myMovingAvrageArray50, true);
      
      CopyBuffer(movingAvrageDefinition20, 0, 0, 2, myMovingAvrageArray20);
      CopyBuffer(movingAvrageDefinition50, 0, 0, 2, myMovingAvrageArray50);
      
      if(myMovingAvrageArray20[1] > myMovingAvrageArray50[1])
         {
         Print("My moving average: ", myMovingAvrageArray20[1]);
         signal = "buy";
         }
        
      
      if(myMovingAvrageArray20[1] < myMovingAvrageArray50[1])
       {
         signal = "sell";
       }
        
       if(signal=="sell" && PositionsTotal()>0){
         CloseAllBuyPositionsOfCurrentPair();
       }
       
       if(signal=="buy" && PositionsTotal()==0){
         trade.Buy(0.10, NULL, Ask, (Ask - StopLossPoints * _Point), (Ask + TakeProfitPoints * _Point), NULL);
       }
      
      Comment("The signal is: ", signal);
      
  }

void CloseAllBuyPositionsOfCurrentPair(){

   for(int i=PositionsTotal()-1; i>=0; i--){
      
      ulong ticket = PositionGetTicket(i);
      
      string currencyPair = PositionGetSymbol(i);
      
      long postionDirection = PositionGetInteger(POSITION_TYPE);
      
      if(postionDirection == POSITION_TYPE_BUY)
      
      if(currencyPair == _Symbol)
      {
         trade.PositionClose(ticket);
      }
      
   }

}