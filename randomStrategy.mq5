#include <Trade/Trade.mqh>
CTrade trade;

input int TpPoints = 500;
input int SlPoints = 400;

void OnTick()
  {
   
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(PositionsTotal() == 0 ){
      int direction = rand() % 2;
      Print("direction: ", direction);
         if(direction)
            trade.Buy(0.1, _Symbol, NULL, bid - SlPoints * _Point, bid + TpPoints *_Point);
         else
            trade.Sell(0.1, _Symbol, NULL, ask + SlPoints * _Point, ask - TpPoints *_Point);
      }

   
  }

