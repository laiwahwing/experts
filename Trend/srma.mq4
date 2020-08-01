//+------------------------------------------------------------------+
//|                                        base on  swb grid 4 .mq4 |
//|                                                totom sukopratomo |
//|                                            forexengine@gmail.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+----- rsi and candle to entry  --------------------------------+
//+----- coder by cheedo lai ----------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+-----  -----------------+
//+-----  ------------+
//+-----  ------+
//+------------------------------------------------------------------+

#property copyright "cheedo lai"
#property link      "lhuarong@hotmail.com"
#property description "Base on Rsi and MA"
#property version "1.1"
#define buy -2
#define sell 2
//---- input parameters
extern string comment="SRMB";
extern bool      use_daily_target=false;
extern double    daily_target=100;
extern bool      trade_in_fri=true;
extern int       magic=2433112;
extern int       slipage=3;
extern double    start_lot=0.02;
extern double    range=12;
extern int       level=25;
extern bool      lot_multiplier=false;
extern int       lot_percent=0;
extern double    multiplier=1.8;
extern double    increament=0.01;
extern bool      use_sl_and_tp=true;
extern double    sl=50;
extern double    tp=60;
extern double    tp_in_money=15.0;
bool      stealth_mode=true;
extern string    __rsi_settings__="Rsi settings";
extern bool      use_rsi=true;
extern int       rsi_period=14;
extern int       rsi_shift=0;
extern int       lower=40;
extern int       upper=60;
extern bool      use_candle=false;
extern int       candle_timeframe=0;
extern bool      use_ma=true;
extern int       ma_period=5;
extern int       ma_timeframe=0;
extern bool      use_trend=true;
extern int       trend_period=50;
extern int       trend_timeframe=0;
extern double    trend_diff=0.006;
int       mid_period=50;
extern string    __diff__="Use ma diff to detect entry";
extern bool      use_diff=false;
extern bool      close_on_reverse=false;
double pt;
double minlot;
double stoplevel;
int prec=0;
int a=0;
int ticket=0;
int res;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   if(Digits==3 || Digits==5)
      pt=10*Point;
   else
      pt=Point;
   minlot   =   MarketInfo(Symbol(),MODE_MINLOT);
   stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(start_lot<minlot)
      Print("lotsize is to small.");
   if(sl<stoplevel)
      Print("stoploss is to tight.");
   if(tp<stoplevel)
      Print("takeprofit is to tight.");
   if(minlot==0.01)
      prec=2;
   if(minlot==0.1)
      prec=1;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(lot_percent!=0)
     {
      start_lot=AccountBalance() * lot_percent * 0.01 * 0.001;
      if(start_lot>MarketInfo(NULL,MODE_MAXLOT))
        {
         start_lot=MarketInfo(NULL,MODE_MAXLOT);
        }
      if(start_lot<MarketInfo(NULL,MODE_MINLOT))
        {
         start_lot=MarketInfo(NULL,MODE_MINLOT);
        }
     }
   if(use_daily_target && dailyprofit()>=daily_target)
     {
      Comment("\ndaily target achieved.");
      return;
     }
   if(!trade_in_fri && DayOfWeek()==5 && total()==0)
     {
      Comment("\nstop trading in Friday.");
      return;
     }
   if(close_on_reverse && total()>1)
     {
      if(signal()==buy)
        {
         for(int o=OrdersTotal()-1; o>=0; o--)
           {
            if(OrderSelect(o,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic)
                  continue;
               if(OrderType()==1)
                  // close the sell order if the signal is buy
                  res=OrderClose(OrderTicket(),OrderLots(),Ask,slipage,CLR_NONE);
              }
           }
        }
      if(signal()==sell)
        {
         for(o=OrdersTotal()-1; o>=0; o--)
           {
            if(OrderSelect(o,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic)
                  continue;
               if(OrderType()==0)
                  res=OrderClose(OrderTicket(),OrderLots(),Bid,slipage,CLR_NONE);
              }
           }
        }
     }
   if(total()==0 && a==0)
     {
      if(signal()==buy)
        {

         if(stealth_mode)
           {
            if(use_sl_and_tp)
               ticket=OrderSend(Symbol(),0,start_lot,Ask,slipage,Ask-sl*pt,Ask+tp*pt,comment,magic,0,Blue);
            else
               ticket=OrderSend(Symbol(),0,start_lot,Ask,slipage,0,0,comment,magic,0,Blue);
           }
         else
           {
            if(use_sl_and_tp)
              {
               if(OrderSend(Symbol(),0,start_lot,Ask,slipage,Ask-sl*pt,Ask+tp*pt,comment,magic,0,Blue)>0)
                 {
                  for(int i=1; i<level; i++)
                    {
                     if(lot_multiplier)
                        ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Ask-(range*i)*pt,slipage,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,comment,magic,0,Blue);
                     else
                        ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot+increament*i,prec),Ask-(range*i)*pt,slipage,(Ask-(range*i)*pt)-sl*pt,(Ask-(range*i)*pt)+tp*pt,comment,magic,0,Blue);
                    }
                 }
              }
            else
              {
               if(OrderSend(Symbol(),0,start_lot,Ask,slipage,0,0,comment,magic,0,Blue)>0)
                 {
                  for(i=1; i<level; i++)
                    {
                     if(lot_multiplier)
                        ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Ask-(range*i)*pt,slipage,0,0,comment,magic,0,Blue);
                     else
                        ticket=OrderSend(Symbol(),2,NormalizeDouble(start_lot+increament*i,prec),Ask-(range*i)*pt,slipage,0,0,comment,magic,0,Blue);
                    }
                 }
              }
           }
        }
      if(signal()==sell)
        {
         if(stealth_mode)
           {
            if(use_sl_and_tp)
               ticket=OrderSend(Symbol(),1,start_lot,Bid,slipage,Bid+sl*pt,Bid-tp*pt,comment,magic,0,Red);
            else
               ticket=OrderSend(Symbol(),1,start_lot,Bid,slipage,0,0,comment,magic,0,Red);
           }
         else
           {
            if(use_sl_and_tp)
              {
               if(OrderSend(Symbol(),1,start_lot,Bid,slipage,Bid+sl*pt,Bid-tp*pt,comment,magic,0,Red)>0)
                 {
                  for(i=1; i<level; i++)
                    {
                     if(lot_multiplier)
                        ticket=OrderSend(Symbol(),0,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Bid+(range*i)*pt,slipage,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,comment,magic,0,Red);
                     else
                        ticket=OrderSend(Symbol(),0,NormalizeDouble(start_lot+increament*i,prec),Bid+(range*i)*pt,slipage,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,comment,magic,0,Red);
                    }
                 }
              }
            else
              {
               if(OrderSend(Symbol(),1,start_lot,Bid,slipage,0,0,comment,magic,0,Red)>0)
                 {
                  for(i=1; i<level; i++)
                    {
                     if(lot_multiplier)
                       {
                        ticket=OrderSend(Symbol(),1,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Bid+(range*i)*pt,slipage,0,0,comment,magic,0,Red);
                        printf("Lots is %.2f",NormalizeDouble(start_lot*MathPow(multiplier,i),prec));
                       }
                     else
                        ticket=OrderSend(Symbol(),1,NormalizeDouble(start_lot+increament*i,prec),Bid+(range*i)*pt,slipage,0,0,comment,magic,0,Red);
                    }
                 }
              }
           }
        }
     }
   if(stealth_mode && total()>0 && total()<level)
     {
      int type;
      int inc;
      double op, lastlot;
      for(i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic)
               continue;
            inc+=1;
            type=OrderType();
            op=OrderOpenPrice();
            lastlot=OrderLots();
           }
        }
      if(type==0 && Ask<=op-range*pt)
        {
         if(use_sl_and_tp)
           {
            if(lot_multiplier)
               ticket=OrderSend(Symbol(),0,NormalizeDouble(start_lot*MathPow(multiplier,inc),prec),Ask,slipage,Ask-sl*pt,Ask+tp*pt,comment,magic,0,Blue);
            else
               ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot+increament,prec),Ask,slipage,Ask-sl*pt,Ask+tp*pt,comment,magic,0,Blue);
           }
         else
           {
            if(lot_multiplier)
               ticket=OrderSend(Symbol(),0,NormalizeDouble(start_lot*MathPow(multiplier,inc),prec),Ask,slipage,0,0,comment,magic,0,Blue);
            else
               ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot+increament,prec),Ask,slipage,0,0,comment,magic,0,Blue);
           }
        }
      if(type==1 && Bid>=op+range*pt)
        {
         if(use_sl_and_tp)
           {
            if(lot_multiplier)
               ticket=OrderSend(Symbol(),1,NormalizeDouble(start_lot*MathPow(multiplier,inc),prec),Bid,slipage,Bid+sl*pt,Bid-tp*pt,comment,magic,0,Red);
            else
               ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot+increament,prec),Bid,slipage,Bid+sl*pt,Bid-tp*pt,comment,magic,0,Red);
           }
         else
           {
            if(lot_multiplier)
              {
               ticket=OrderSend(Symbol(),1,NormalizeDouble(start_lot*MathPow(multiplier,inc),prec),Bid,slipage,0,0,comment,magic,0,Red);
              }
            else
               ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot+increament,prec),Bid,slipage,0,0,comment,magic,0,Red);
           }
        }
     }
   if(use_sl_and_tp && total()>1)
     {
      double s_l, t_p;
      for(i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || OrderType()>1)
               continue;
            type=OrderType();
            s_l=OrderStopLoss();
            t_p=OrderTakeProfit();
           }
        }
      for(i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || OrderType()>1)
               continue;
            if(OrderType()==type)
              {
               if(OrderStopLoss()!=s_l || OrderTakeProfit()!=t_p)
                 {
                  res=OrderModify(OrderTicket(),OrderOpenPrice(),s_l,t_p,0,CLR_NONE);
                 }
              }
           }
        }
     }
   double profit=0;
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic || OrderType()>1)
            continue;
         double p = OrderProfit() + OrderSwap() + OrderCommission();
         profit += p;
        }
     }
   if(!use_sl_and_tp)
     {
      // close when match the profit
      if(profit>=tp_in_money || a>0)
        {
         closeall();
         closeall();
         closeall();
         a++;
         if(total()==0)
            a=0;
        }
     }
   if(!stealth_mode && use_sl_and_tp && total()<level)
      closeall();
//----

//----
   return;
  }
//+------------------------------------------------------------------+
double dailyprofit()
  {
   int day=Day();
   double ret=0;
   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic)
            continue;
         if(TimeDay(OrderOpenTime())==day)
            ret+=OrderProfit();
        }
     }
   return(ret);
  }
//+------------------------------------------------------------------+
int total()
  {
   int total=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic)
            continue;
         total++;
        }
     }
   return(total);
  }
//+------------------------------------------------------------------+
int signal()
  {
   double rsi=iRSI(Symbol(),0,rsi_period,PRICE_OPEN,rsi_shift);
   double rsi1=iRSI(Symbol(),0,rsi_period,PRICE_OPEN,rsi_shift+1);
   double rsi2=iRSI(Symbol(),0,rsi_period,PRICE_OPEN,rsi_shift+2);
   double rsi3=iRSI(Symbol(),0,rsi_period,PRICE_OPEN,rsi_shift+3);
   int rsi_trend=0;
   int trend=0;
   double ma=iMA(NULL,ma_timeframe,1,0,0,PRICE_CLOSE,0);
   if(rsi>rsi1&&rsi1>rsi2&&rsi2<lower)
      rsi_trend=1;
   if(rsi<rsi1&&rsi1<rsi2&&rsi2>upper)
      rsi_trend=-1;
   if(use_trend)
     {
      double fast_ma=iMA(NULL,trend_timeframe,ma_period,0,0,PRICE_OPEN,0);
      double fast_ma1=iMA(NULL,trend_timeframe,ma_period,0,0,PRICE_OPEN,1);
      double fast_ma2=iMA(NULL,trend_timeframe,ma_period,0,0,PRICE_OPEN,2);
      double fast_ma3=iMA(NULL,trend_timeframe,ma_period,0,0,PRICE_OPEN,3);
      double fast_ma4=iMA(NULL,trend_timeframe,ma_period,0,0,PRICE_OPEN,4);
      double mid_ma=iMA(NULL,trend_timeframe,mid_period,0,0,PRICE_CLOSE,0);
      double slow_ma=iMA(NULL,trend_timeframe,trend_period,0,0,PRICE_CLOSE,0);
      double slow_ma1=iMA(NULL,trend_timeframe,trend_period,0,0,PRICE_CLOSE,2);
      double slow_ma2=iMA(NULL,trend_timeframe,trend_period,0,0,PRICE_CLOSE,4);
      double slow_ma3=iMA(NULL,trend_timeframe,trend_period,0,0,PRICE_CLOSE,8);
      double ma_fast_diff=MathAbs(MarketInfo(Symbol(),MODE_BID)-fast_ma);
      double ma_slow_diff=MathAbs(MarketInfo(Symbol(),MODE_BID)-slow_ma);
      double ma_up_diff=fast_ma-slow_ma;
      double ma_down_diff=slow_ma-fast_ma;
      bool fast_up=fast_ma>fast_ma1 && fast_ma1>fast_ma2&&fast_ma2<fast_ma3&&fast_ma3<fast_ma4;
      bool fast_down=fast_ma<fast_ma1 && fast_ma1<fast_ma2&&fast_ma2>fast_ma3&&fast_ma3>fast_ma4;
      bool slow_up=slow_ma>slow_ma1 && slow_ma1>slow_ma2&&slow_ma2>slow_ma3;
      bool slow_down=slow_ma<slow_ma1 && slow_ma1<slow_ma2&&slow_ma2<slow_ma3;
      if(use_diff)
        {
         if(fast_up && slow_up && ma_up_diff<trend_diff)
           {
            trend=2;
           }
         if(fast_down && slow_down && ma_down_diff<trend_diff)
           {
            trend=-2;
           }
        }
      else
        {
         if(fast_up && slow_up)
           {
            trend=2;
           }
         if(fast_down && slow_down)
           {
            trend=-2;
           }
        }

     }
   if(!use_candle && use_ma && use_trend)
     {
      if(use_rsi)
        {
         if(rsi_trend==-1 && trend==-2)
            return(sell);
         if(rsi_trend==1 && trend==2)
            return(buy);
        }
      else
        {
         if(trend==-2)
            return(sell);
         if(trend==2)
            return(buy);
        }
     }
   if(!use_candle && use_ma && !use_trend)
     {
      bool ma_up=iClose(NULL,candle_timeframe,1)>ma;
      bool ma_down=iClose(NULL,candle_timeframe,1)<ma;
      if(rsi>upper && ma_down)
        {
         return(sell);
        }
      if(rsi<lower && ma_up)
        {
         return(buy);
        }
     }
   if(use_candle && !use_ma && !use_trend)
     {
      bool candle_up=MarketInfo(Symbol(),MODE_BID)<iClose(NULL,candle_timeframe,1);
      bool candle_down=MarketInfo(Symbol(),MODE_BID)>iOpen(NULL,candle_timeframe,1);
      bool candle_prev2=MathAbs(iClose(NULL,candle_timeframe,2) - iOpen(NULL,candle_timeframe,2)) < 0.0015;
      bool candle_prev1=MathAbs(iClose(NULL,candle_timeframe,1) - iOpen(NULL,candle_timeframe,1)) < 0.0012;
      bool candle_go_down=iClose(NULL,candle_timeframe,1)<iClose(NULL,candle_timeframe,2);
      bool candle_go_up=iClose(NULL,candle_timeframe,1)>iClose(NULL,candle_timeframe,2);
      if(rsi>upper && candle_prev1 && candle_prev2 && candle_up && candle_go_down && ma_down)
        {
         return(sell);
        }
      if(rsi<lower && candle_prev1 && candle_prev2 && candle_down && candle_go_up && ma_up)
        {
         return(buy);
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
void closeall()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic)
            continue;
         if(OrderType()>1)
            res=OrderDelete(OrderTicket());
         else
           {
            if(OrderType()==0)
               res=OrderClose(OrderTicket(),OrderLots(),Bid,slipage,CLR_NONE);
            else
               res=OrderClose(OrderTicket(),OrderLots(),Ask,slipage,CLR_NONE);
           }
        }
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
