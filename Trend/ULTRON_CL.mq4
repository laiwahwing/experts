//ULTRON H1//


#property copyright "cheedo lai"
#property link      "lhuarong@hotmail.com"
#property description "Base on Ultron"
#property version     "1.00"

extern int magic=20200444;
extern string comment="Ultron";
extern double lots_percent=10;
extern double lots=0.01;
extern double take_profit=68;
extern double stop_loss=58;
extern int hour1 = 6;
extern int hour2 = 21;
int    res;
double ma1;
double ma2;
double ma3;
double ma4;
double ma5;
double ma6;
double ma1ma2;
double ma2ma1;
double ma3ma4;
double ma4ma3;
double TakeProfit;
double StopLoss;
double TakeProfit1;
double StopLoss1;
double training=20;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForSell()
  {

   if(Volume[0]>25)
      return;
   res=OrderSend(Symbol(),OP_SELL,lots,Bid,20,StopLoss,TakeProfit,comment,magic,0,Red);
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForBuy()
  {

   if(Volume[0]>25)
      return;
   res=OrderSend(Symbol(),OP_BUY,lots,Ask,20,StopLoss1,TakeProfit1,comment,magic,0,Blue);
   return;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(lots_percent!=0)
     {
      lots=AccountBalance() * lots_percent * 0.01 * 0.001;
      if(lots>MarketInfo(NULL,MODE_MAXLOT))
        {
         lots=MarketInfo(NULL,MODE_MAXLOT);
        }
     }
   ma1 = iMA(NULL,60,9,0,MODE_LWMA,PRICE_OPEN,0);
   ma2 = iMA(NULL,60,9,0,MODE_LWMA,PRICE_CLOSE,0);
   ma3 = iMA(NULL,60,50,0,MODE_SMA,PRICE_CLOSE,0);
   ma4 = iMA(NULL,60,1,0,MODE_SMA,PRICE_CLOSE,0);
   ma1ma2 = ma1-ma2;
   ma2ma1 = ma2-ma1;
   ma3ma4 = ma3-ma4;
   ma4ma3 = ma4-ma3;

   int CountSymbolPositions=0;

   for(int trade=OrdersTotal()-1; trade>=0; trade--)
     {
      if(!OrderSelect(trade,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()==Symbol())
        {
         if((OrderType()==OP_SELL||OrderType()==OP_BUY) && OrderMagicNumber()==magic)
            CountSymbolPositions++;
        }
     }

   TakeProfit = Bid - take_profit *10*Point;
   StopLoss = Ask + stop_loss*10*Point;
   TakeProfit1 = Ask + take_profit*10*Point;
   StopLoss1 = Bid - stop_loss*10*Point;

   if(ma3ma4<0.0048 && ma3>ma1 && ma3>ma2 && Close[1]<Close[2] && Close[2]<Open[2] && CountSymbolPositions<1 && Hour()>hour1 && Hour()<hour2 && ma1ma2<0.0013 && ma1ma2>0.0004)
     {

      CheckForSell();
     };

   if(ma4ma3<0.0048 && ma3<ma1 && ma3<ma2 && Close[1]>Close[2] && Close[2]>Open[2] && CountSymbolPositions<1 && Hour()>hour1 && Hour()<hour2  && ma2ma1<0.0013&& ma2ma1>0.0004)
     {
      CheckForBuy();
     };
  }
//+------------------------------------------------------------------+
