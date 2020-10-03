//+------------------------------------------------------------------+
//|                                        base on   swb grid 4 .mq4 |
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
#property description "scalper on the morning"
#define buy -2
#define sell 2
//---- input parameters
extern string comment="SMScalper";
bool      use_daily_target=false;
double    daily_target=100;
extern bool      trade_in_fri=true;
extern int       magic=253301;
extern int       slipage=3;
extern double    start_lot=0.01;
double    range=12;
int       level=1;
bool      lot_multiplier=false;
extern int       lot_percent=15;
double    multiplier=1.1;
double    increament=0.01;
extern bool      use_sl_and_tp=true;
extern double    sl=20;
extern double    tp=5;
double    tp_in_money=5.0;
bool      stealth_mode=true;
extern bool      use_bb=true;
extern int       bb_period=20;
extern int       bb_deviation=2;
extern int       bb_shift=0;
extern bool      use_stoch=true;
extern int       k=5;
extern int       d=3;
extern int       slowing=3;
extern int       price_field=0;
extern int       stoch_shift=0;
extern int       lo_level=30;
extern int       up_level=70;
extern bool      use_rsi=true;
extern int       rsi_period=12;
extern int       rsi_shift=0;
extern int       lower=30;
extern int       upper=70;
extern bool      use_candle=false;
extern int       candle_timeframe=0;
extern bool      use_ma=false;
extern int       ma_period=6;
extern int       ma_timeframe=0;
extern bool time_filter=true;
extern int start_hour=0;
extern int end_hour=1;
bool trade_time;
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
int start()
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
   trade_time=Hour()<start_hour||Hour()>end_hour;
   if(time_filter&&trade_time&&total()==0)
     {
      Comment("\nNot Trading Time");
      return(0);
     }
   else
     {
      Comment("");
     }
   if(use_daily_target && dailyprofit()>=daily_target)
     {
      Comment("\ndaily target achieved.");
      return(0);
     }
   if(!trade_in_fri && DayOfWeek()==5 && total()==0)
     {
      Comment("\nstop trading in Friday.");
      return(0);
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
               ticket=OrderSend(Symbol(),0,start_lot,Ask,slipage,        0,        0,comment,magic,0,Blue);
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
               ticket=OrderSend(Symbol(),1,start_lot,Bid,slipage,        0,        0,comment,magic,0,Red);
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
                        ticket=OrderSend(Symbol(),slipage,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Bid+(range*i)*pt,slipage,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,comment,magic,0,Red);
                     else
                        ticket=OrderSend(Symbol(),slipage,NormalizeDouble(start_lot+increament*i,prec),Bid+(range*i)*pt,slipage,(Bid+(range*i)*pt)+sl*pt,(Bid+(range*i)*pt)-tp*pt,comment,magic,0,Red);
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
                        ticket=OrderSend(Symbol(),slipage,NormalizeDouble(start_lot*MathPow(multiplier,i),prec),Bid+(range*i)*pt,slipage,0,0,comment,magic,0,Red);
                     else
                        ticket=OrderSend(Symbol(),slipage,NormalizeDouble(start_lot+increament*i,prec),Bid+(range*i)*pt,slipage,0,0,comment,magic,0,Red);
                    }
                 }
              }
           }
        }
     }
   if(stealth_mode && total()>0 && total()<level)
     {
      int type;
      double op, lastlot;
      for(i=0; i<OrdersTotal(); i++)
        {
         int o=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic)
            continue;
         type=OrderType();
         op=OrderOpenPrice();
         lastlot=OrderLots();
        }
      if(type==0 && Ask<=op-range*pt)
        {
         if(use_sl_and_tp)
           {
            if(lot_multiplier)
               ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot*multiplier,prec),Ask,slipage,Ask-sl*pt,Ask+tp*pt,comment,magic,0,Blue);
            else
               ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot+increament,prec),Ask,slipage,Ask-sl*pt,Ask+tp*pt,comment,magic,0,Blue);
           }
         else
           {
            if(lot_multiplier)
               ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot*multiplier,prec),Ask,slipage,0,0,comment,magic,0,Blue);
            else
               ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot+increament,prec),Ask,slipage,0,0,comment,magic,0,Blue);
           }
        }
      if(type==1 && Bid>=op+range*pt)
        {
         if(use_sl_and_tp)
           {
            if(lot_multiplier)
               ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot*multiplier,prec),Bid,slipage,Bid+sl*pt,Bid-tp*pt,comment,magic,0,Red);
            else
               ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot+increament,prec),Bid,slipage,Bid+sl*pt,Bid-tp*pt,comment,magic,0,Red);
           }
         else
           {
            if(lot_multiplier)
               ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot*multiplier,prec),Bid,slipage,0,0,comment,magic,0,Red);
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
   return(0);
  }
//+------------------------------------------------------------------+
double dailyprofit()
  {
   int day=Day();
   double res_total;
   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic)
            continue;
         if(TimeDay(OrderOpenTime())==day)
            res_total+=OrderProfit();
        }
     }
   return(res_total);
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
   double upBB=iBands(Symbol(),0,bb_period,bb_deviation,0,PRICE_CLOSE,MODE_UPPER,bb_shift);
   double loBB=iBands(Symbol(),0,bb_period,bb_deviation,0,PRICE_CLOSE,MODE_LOWER,bb_shift);
   double stoch=iStochastic(Symbol(),0,k,d,slowing,MODE_SMA,price_field,MODE_SIGNAL,stoch_shift);
   double rsi=iRSI(Symbol(),0,rsi_period,PRICE_CLOSE,rsi_shift);
   double ma=iMA(NULL,ma_timeframe,ma_period,0,0,0,0);
   bool b15s=iClose(NULL,candle_timeframe,1)<iClose(NULL,candle_timeframe,2)<iClose(NULL,candle_timeframe,3);
   bool b15b=iClose(NULL,candle_timeframe,3)<iClose(NULL,candle_timeframe,2)<iClose(NULL,candle_timeframe,1);
   bool ma_up=true;
   bool ma_down=true;
   if(use_bb && use_stoch && use_rsi && !use_candle && use_ma)
     {
      ma_up=iClose(NULL,candle_timeframe,1)>ma;
      ma_down=iClose(NULL,candle_timeframe,1)<ma;
      if(rsi>upper && ma_down)
        {
         return(sell);
        }
      if(rsi<lower && ma_up)
        {
         return(buy);
        }
     }
   if(use_bb && use_stoch && use_rsi && use_candle)
     {
      bool candle_up=MarketInfo(Symbol(),MODE_BID)<iClose(NULL,candle_timeframe,1);
      bool candle_down=MarketInfo(Symbol(),MODE_BID)>iOpen(NULL,candle_timeframe,1);
      bool candle_prev2=MathAbs(iClose(NULL,candle_timeframe,2) - iOpen(NULL,candle_timeframe,2)) < 0.0015;
      bool candle_prev1=MathAbs(iClose(NULL,candle_timeframe,1) - iOpen(NULL,candle_timeframe,1)) < 0.0012;
      bool candle_go_down=iClose(NULL,candle_timeframe,1)<iClose(NULL,candle_timeframe,2);
      bool candle_go_up=iClose(NULL,candle_timeframe,1)>iClose(NULL,candle_timeframe,2);
      if(use_ma)
        {
         ma_up=iClose(NULL,candle_timeframe,1)>ma;
         ma_down=iClose(NULL,candle_timeframe,1)<ma;
        }
      if(rsi>upper && candle_prev1 && candle_prev2 && candle_up && candle_go_down && ma_down)
        {
         return(sell);
        }
      if(rsi<lower && candle_prev1 && candle_prev2 && candle_down && candle_go_up && ma_up)
        {
         return(buy);
        }
     }
   if(use_bb && use_stoch && use_rsi && !use_candle)
     {
      if(High[bb_shift]>upBB && stoch>up_level && rsi>upper)
         return(sell);
      if(Low[bb_shift]<loBB && stoch<lo_level && rsi<lower)
         return(buy);
     }
   if(use_bb && use_stoch && !use_rsi)
     {
      if(High[bb_shift]>upBB && stoch>up_level)
         return(sell);
      if(Low[bb_shift]<loBB && stoch<lo_level)
         return(buy);
     }
   if(use_bb && !use_stoch && !use_rsi)
     {
      if(High[bb_shift]>upBB)
         return(sell);
      if(Low[bb_shift]<loBB)
         return(buy);
     }
   if(!use_bb && use_stoch && use_rsi)
     {
      if(stoch>up_level && rsi>upper)
         return(sell);
      if(stoch<lo_level && rsi<lower)
         return(buy);
     }
   if(!use_bb && use_stoch && !use_rsi)
     {
      if(stoch>up_level)
         return(sell);
      if(stoch<lo_level)
         return(buy);
     }
   if(use_bb && !use_stoch && use_rsi)
     {
      if(High[bb_shift]>upBB && rsi>upper)
         return(sell);
      if(Low[bb_shift]<loBB && rsi<lower)
         return(buy);
     }
   if(!use_bb && !use_stoch && use_rsi)
     {
      if(rsi>upper)
         return(sell);
      if(rsi<lower)
         return(buy);
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
