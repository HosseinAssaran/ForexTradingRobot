#include <Trade/Trade.mqh>

CTrade trade;
input double startLot = 0.01;
input double step = 0.02;
input int hedgeDistanceInPip = 20;
double lowerline, upperline;
int lastDirection = 0;
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

   
  }


void OnTick()
  {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      int totalProfitPoints = 0;
       
       //if there is no position start with a buy position
      if(!PositionsTotal()){
         trade.Buy(startLot);
         upperline = bid;
         lowerline = bid - hedgeDistanceInPip * _Point;
         lastDirection = 1;
      }
         
      double posLotBuy = 0;
      double posLotSell = 0;
      for(int i=PositionsTotal()-1; i>=0; i--){
      
      ulong ticket = PositionGetTicket(i);
      
      if(PositionSelectByTicket(ticket))
      {
      
           double posLot = PositionGetDouble(POSITION_VOLUME);
           
           if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
               posLotBuy += posLot;
               totalProfitPoints += (int)((bid - PositionGetDouble(POSITION_PRICE_OPEN)) / _Point );
               
           }
           else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
               posLotSell += posLot;
               totalProfitPoints += (int)((PositionGetDouble(POSITION_PRICE_OPEN) -ask) / _Point );
           }
           
      }      
      
      if(lastDirection > 0 && ask < lowerline){
         trade.Sell(step);
         lastDirection = -1;
         Print("last direction: ", lastDirection);
        
      }
      else if(lastDirection < 0 && bid > upperline){
          trade.Buy(step);
          lastDirection = 1;
          Print("last direction: ", lastDirection);
      }

      
   }
   if(totalProfitPoints > 1000) Print("Save the profit");
            Comment("Current Time: ",TimeCurrent(),
        "\nUpperline: ", DoubleToString(upperline),
        "\nLowerLine: ", DoubleToString(lowerline),
        "\nTotal Profit: ", totalProfitPoints);       


  }

