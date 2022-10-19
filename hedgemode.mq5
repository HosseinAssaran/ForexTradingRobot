#include <Trade/Trade.mqh>

input double Lots = 0.01;
input int DistancePoints = 100;
input int StepDistancePoints = 50;

input int TpPointsOddPosition = 800;
input int TpPointsEvenPosition = 400;
input int TimeStartHour = 8;
input int TimeStartMin = 0;
input int LotsMultiplier = 2;
input int MovingAverageCount = 4;
input int AtrAverageCount = 14;
input double AtrUp = 0.00090;
input double AtrDown = 0.00050;
int TpPoints;
double upperline, lowerline;
datetime resetTime;
double lastLots = Lots;
bool EmergencyCondition = false;


CTrade trade;

int OnInit()
  {

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

   
  }

void OnTick()
  {
       double MovingAvrageArray[];
       double atrVals[];
       int movingAvrageDefinition = iMA (_Symbol, _Period, MovingAverageCount, 0, MODE_EMA, PRICE_CLOSE);
       int atrDefinition = iATR(_Symbol, _Period, AtrAverageCount);
       ArraySetAsSeries(atrVals, true);
       ArraySetAsSeries(MovingAvrageArray, true);
         
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double highestlotsize = 0;
      int lastDirection = 0;
      int totalProfitPoints = 0;
      for(int i=PositionsTotal()-1 ; i >=0 ; i--){
         ulong ticket = PositionGetTicket(i);
         if(MathMod(PositionsTotal(),2) == 0)
            TpPoints = TpPointsEvenPosition;
         else
            TpPoints = TpPointsOddPosition;
         if(PositionSelectByTicket(ticket))
         {
             double posLot = PositionGetDouble(POSITION_VOLUME);
             if(posLot > highestlotsize){
                highestlotsize = posLot;
                if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
                  lastDirection = 1;
                }
                else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                  lastDirection = -1;
                }
             }  
             if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
                  totalProfitPoints += (int)((bid - PositionGetDouble(POSITION_PRICE_OPEN)) / _Point * posLot / Lots);
              }
              else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                  totalProfitPoints +=  (int)((PositionGetDouble(POSITION_PRICE_OPEN) -ask) / _Point * posLot / Lots);
              }
         }
      }
      

      
      MqlDateTime structTime;
      TimeCurrent(structTime);
      
      structTime.hour = TimeStartHour;
      structTime.min = TimeStartMin;
      structTime.sec = 0;
      
      datetime timeStart = StructToTime(structTime);
      
      if(TimeCurrent() < timeStart && highestlotsize ==0){
         upperline=0;
         lowerline=0;
         resetTime = timeStart;
      }
      
      if(totalProfitPoints > TpPoints)
      {
         Print("Hit the profit: ", totalProfitPoints);
         for(int i=PositionsTotal()-1 ; i >=0 ; i--){
            ulong ticket = PositionGetTicket(i);
            if(PositionSelectByTicket(ticket))
            {
                  trade.PositionClose(ticket);
            }
         }
         highestlotsize = 0;
         //lastDirection = 0;
         upperline=0;
         lowerline=0;
         lastLots = Lots;
         EmergencyCondition = false;
         resetTime = TimeCurrent() /*+ 3600*/;
         Print("Reset Time: ", resetTime);
      }
      
       CopyBuffer(atrDefinition, 0, 0, 2, atrVals);
       atrVals[1] = NormalizeDouble(atrVals[1],_Digits);
      if(TimeCurrent() > resetTime && upperline == 0 && lowerline == 0 && atrVals[1] < AtrDown){
        
         CopyBuffer(movingAvrageDefinition, 0, 0, 2, MovingAvrageArray);
         MovingAvrageArray[0] = NormalizeDouble(MovingAvrageArray[0],_Digits);

         //upperline = MovingAvrageArray[0] + DistancePoints * _Point;
         //lowerline = MovingAvrageArray[0] - DistancePoints * _Point;
         if(lastDirection > 0){
            lowerline = ask;
            upperline = lowerline + DistancePoints * 2 * _Point;
         }
         else if(lastDirection < 0) {
            upperline = bid;
            lowerline = upperline - DistancePoints * 2 * _Point;
         }
         else {
            upperline = MovingAvrageArray[0] + DistancePoints * _Point;
            lowerline = MovingAvrageArray[0] - DistancePoints * _Point;
         }

         upperline = NormalizeDouble(upperline,_Digits);
         lowerline = NormalizeDouble(lowerline,_Digits);
         Print("Moving Average: ", MovingAvrageArray[0]);
         Print("upperline: ", upperline);
         Print("lowerline: ", lowerline);
      }  
      

      if(upperline > 0 && lowerline > 0){

         
         if(atrVals[1] > AtrUp && !EmergencyCondition){
            upperline = upperline + DistancePoints * _Point;
            lowerline = lowerline - DistancePoints * _Point;
            Print("Atr Value(E): ", atrVals[1]);
            EmergencyCondition = true;
         } 
         else if (atrVals[1] < AtrDown && EmergencyCondition){
            upperline = upperline - DistancePoints * _Point;
            lowerline = lowerline + DistancePoints * _Point;
            Print("Atr Value: ", atrVals[1]);
            EmergencyCondition = false;
         }          
         if(highestlotsize > 0){
            bool haveBuyPosition = false;
            bool haveSellPosition = false;
            for(int i=PositionsTotal()-1 ; i >=0 ; i--){
            ulong ticket = PositionGetTicket(i);
               if(PositionSelectByTicket(ticket))
               {
                      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
                        haveBuyPosition = true;
                      }
                      else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                        haveSellPosition = true;
                      }
               }  
            }
            if(lastLots <= highestlotsize)
               if((bid > upperline /*&& !haveBuyPosition*/) || (bid < lowerline /*&& !haveSellPosition*/))
               {
                  lastLots = highestlotsize * LotsMultiplier;
                  lastLots = NormalizeDouble(lastLots,2);
                if( MathMod(lastLots,0.04) == 0)
                { 
                  if(lastDirection < 0)
                     upperline = upperline + StepDistancePoints * _Point;
                   else if(lastDirection > 0)
                     lowerline = lowerline - StepDistancePoints * _Point;
                   upperline = NormalizeDouble(upperline,_Digits);
                   lowerline = NormalizeDouble(lowerline,_Digits);
                }
               }
            //else{
            //   lastLots = highestlotsize * LotsMultiplier;
            //}
            

         }

         if(bid > upperline){
 
            if(highestlotsize == 0 || lastDirection < 0)
               trade.Buy(lastLots);
               //trade.Buy(lastLots,_Symbol,NULL,NULL,(bid + 200 * _Point));
         }
         else if(ask < lowerline){
            if(highestlotsize == 0 || lastDirection > 0)
             trade.Sell(lastLots);
             
             //trade.Sell(lastLots,_Symbol,NULL,NULL,(bid - 200 * _Point));
         }
      }
         Comment("Current Time: ",TimeCurrent(),
        "\n Time Start: ", timeStart,
        "\nUpperline: ", DoubleToString(upperline),
        "\nLowerLine: ", DoubleToString(lowerline),
        "\nTotal Profit: ", totalProfitPoints,
        "\nEmergency Condition: ", EmergencyCondition);     
      
  }

