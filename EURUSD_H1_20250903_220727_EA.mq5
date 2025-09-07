mq5
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create trade object
   CTrade trade;
   
   // Calculate starting equity
   double equityStart = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // Initialize MA handles
   maHandleH1 = iMA(_Symbol, PERIOD_H1, 14, 0, MODE_SMA, PRICE_CLOSE);
   maHandleD1 = iMA(_Symbol, PERIOD_D1, 14, 0, MODE_SMA, PRICE_CLOSE);
   
   // Initialize RSI handle
   rsiHandleH1 = iRSI(_Symbol, PERIOD_H1, 14, PRICE_CLOSE);
   
   // Initialize Stochastic handle
   stochHandleH1 = iStochastic(_Symbol, PERIOD_H1, 14, 3, 3, MODE_MAIN, 0, 1, 1);
   
   // Check if handles are valid
   if(maHandleH1 == INVALID_HANDLE || maHandleD1 == INVALID_HANDLE || 
      rsiHandleH1 == INVALID_HANDLE || stochHandleH1 == INVALID_HANDLE)
   {
      Print("Error initializing indicators");
      return(INIT_FAILED);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Release indicator handles
   if(maHandleH1 != INVALID_HANDLE) IndicatorRelease(maHandleH1);
   if(maHandleD1 != INVALID_HANDLE) IndicatorRelease(maHandleD1);
   if(rsiHandleH1 != INVALID_HANDLE) IndicatorRelease(rsiHandleH1);
   if(stochHandleH1 != INVALID_HANDLE) IndicatorRelease(stochHandleH1);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Skip if no trade allowed (drawdown protection)
   if(!IsTradeAllowed())
   {
      // Check if drawdown recovered
      if(CalculateDrawdown() < MaxDD && drawdownStart != 0)
      {
         Print("Drawdown recovered. Resuming trading.");
         drawdownStart = 0;
      }
      return;
   }

   // Get current prices
   double maH1 = iMA(_Symbol, PERIOD_H1, 14, 0, MODE_SMA, PRICE_CLOSE, 0);
   double maD1 = iMA(_Symbol, PERIOD_D1, 14, 0, MODE_SMA, PRICE_CLOSE, 0);
   double rsi = iRSI(_Symbol, PERIOD_H1, 14, PRICE_CLOSE, 0);
   double stoch = iStochastic(_Symbol, PERIOD_H1, 14, 3, 3, MODE_MAIN, 0, 0, 0);

   // Trading logic here
   if(maH1 > maD1 && rsi > 50 && stoch > 50)
   {
      MqlTradeRequest request = {0};
      MqlTradeResult result = {0};
      request.action = TRADE_ACTION_DEAL;
      request.symbol = _Symbol;
      request.volume = 0.1;
      request.type = ORDER_TYPE_BUY;
      request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      request.deviation = 5;
      request.type_filling = ORDER_FILLING_FOK;
      
      if(CustomTrade(request, result) && result.retcode == TRADE_RETCODE_DONE)
      {
         Print("Buy order executed at ", request.price);
      }
   }
   else if(maH1 < maD1 && rsi < 50 && stoch < 50)
   {
      MqlTradeRequest request = {0};
      MqlTradeResult result = {0};
      request.action = TRADE_ACTION_DEAL;
      request.symbol = _Symbol;
      request.volume = 0.1;
      request.type = ORDER_TYPE_SELL;
      request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      request.deviation = 5;
      request.type_filling = ORDER_FILLING_FOK;
      
      if(CustomTrade(request, result) && result.retcode == TRADE_RETCODE_DONE)
      {
         Print("Sell order executed at ", request.price);
      }
   }
}
//+------------------------------------------------------------------+