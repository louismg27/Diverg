//+------------------------------------------------------------------+
//|                                                EA_STO_DIVER1.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#property script_show_inputs


extern int TakeProfit=500;
extern int StopLoss=100;

//Parametro Stocastico a ser optimizado para Compra Venta
extern int KPeriod=8;
extern int DPeriod=3;
extern int Slowing=3;
//Parametros de optimizacion para ordenes de Venta
extern int PeriodBandsSell=10;


extern int    SL_PeriodATRSell_1=14;
extern double   SL_FactorATRSell_1=1.5;
extern int    TP_PeriodATRSell_1=14;
extern double    TP_FactorATRSell_1=1.5;

extern int    SL_PeriodATRSell_2=14;
extern double    SL_FactorATRSell_2=1.5;
extern int    TP_PeriodATRSell_2=14;
extern double    TP_FactorATRSell_2=1.5;
 

//Parametros de optimizacion para ordenes de Compra
extern int PeriodBandsBuy=10;
extern int Period_Fast_MH4=3;
extern int Period_Slow_MH4=10;
 
extern int    SL_PeriodATRBuy_1=14;
extern double   SL_FactorATRBuy_1=1.5;
extern int    TP_PeriodATRBuy_1=14;
extern double    TP_FactorATRBuy_1=1.5;

extern int    SL_PeriodATRBuy_2=14;
extern double   SL_FactorATRBuy_2=1.5;
extern int    TP_PeriodATRBuy_2=14;
extern double    TP_FactorATRBuy_2=1.5;

extern int OpcionBuySell=0;
extern int PeriodReversion=6;


 

input int magic = 17;
input double lots = 0.1;
int contador_ids_sell1=0; 
double ids_sells1[6000];
double idsell1=0;

int contador_ids_buyl1=0; 
double ids_buys1[6000];
double idbuy1=0;

bool flagbuy=false;
static string   indicatorName;
bool tradebuy=false;
int compra1=0;
int venta1=0;
int counbar=0;
int counbarsell=0;

bool DivergenciaBuy=False;
bool DivergenciaBuy2=False;

bool DivergenciaSell1=False;
bool DivergenciaSell2=False;

bool activar_espera2=false;
bool activar_espera=false;
bool activar_espera2_sell=false;
bool activar_espera_sell=false;
int OnInit()
  {
//---
ChartSetInteger(0,CHART_SHOW_GRID,false);
ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,Red);
ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,Lime);
ChartSetInteger(0,CHART_COLOR_CHART_DOWN,Red);
ChartSetInteger(0,CHART_COLOR_CHART_UP,Lime);
ChartSetInteger(0,CHART_MODE, CHART_CANDLES);
ChartSetInteger(0,CHART_COLOR_BACKGROUND, Black);
              
   

                   
                              
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
  
//Example 3

//--- day of week




void LecturaPrecio(double precio_sto,int cx, int cy, string name,string name2){

   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSet(name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSet(name,OBJPROP_XDISTANCE,cx);
   ObjectSet(name,OBJPROP_YDISTANCE,cy);
   ObjectSetText(name,name2 +DoubleToStr(precio_sto,5),10,"Arial",Yellow);

} 
double profitBUY()
{
   int total=OrdersTotal();
   double profit_BUY=0;
   for(int i=0; i<total; i++)
   {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
          if (OrderType() == OP_BUY){
               profit_BUY+=OrderProfit();}
   }
   return(profit_BUY);
}

double profitSELL()
{
   int total=OrdersTotal();
   double profit_SELL=0;
   for(int i=0; i<total; i++)
   {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
          if (OrderType() == OP_SELL){
               profit_SELL+=OrderProfit();}
   }
   return(profit_SELL);
}

void ModifyOrder(double trailingStop,double TP  ){
 
 
	   
	      for (int i = 0; i < OrdersTotal(); i++) {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            continue;
        }
  
        if (OrderSymbol() != Symbol()) {
            continue;
        }
  
        if(OrderType() == OP_BUY) {
       
                if (!OrderModify(OrderTicket(), OrderOpenPrice(),
                 Bid - trailingStop * Point, OrderTakeProfit(), 0, Green))
                 {
                    Print("OrderModify error ",GetLastError());
                }
           
        }
    }
    
    
}
	     
void CloseBuyPositions(){
   
   for(int i=OrdersTotal()-1;i>=0;i--) { 
      int selectBuys=OrderSelect(i,SELECT_BY_POS,MODE_TRADES); 
      if(_Symbol == OrderSymbol()) 
      if(OrderType()==OP_BUY){
         int ClosePositionBuy=OrderClose(OrderTicket(),OrderLots(),Bid,3,NULL);
      } 
   } 
}  

void CloseSellPositions(){
   
   for(int i=OrdersTotal()-1;i>=0;i--) { 
      int selectSells=OrderSelect(i,SELECT_BY_POS,MODE_TRADES); 
      if(_Symbol == OrderSymbol()) 
      if(OrderType()==OP_SELL){
         int ClosePositionSell=OrderClose(OrderTicket(),OrderLots(), Ask,3,NULL);
      } 
   } 
}  
  
bool contains(double &a[], double obj) {
    bool detect=false;
    for (int i = 0; i < 6000; i++) {
        if (a[i] == obj) { 
            detect= true;
            break;
        }
    }
    if (detect==true){return true;} else {return false;}
}




double sto(int i){
   double sto;
   sto = iStochastic(NULL, PERIOD_H1, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, i); 
   return sto;
}

double signal(int i){
   double signal;
   signal = iStochastic(NULL,PERIOD_H1, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, i);
   return signal;
}

//EL INDICADOR SE ENCUENTRA EN UN PICO ALCISTA?
bool ExistePicoDownEnIndicador(int shift)
{
  if((sto(shift) <= sto(shift+1)) && (sto(shift) < sto(shift+2)) && 
      (sto(shift) < sto(shift-1)))
       return true;
   else 
       return false;
}

// CAPTURAR EL INDICE DEL VALOR PICO DETECTADO
int CapturarUltimoPicoDown(int shift)
{
 for(int i = shift + 5; i < Bars; i++)
   {
     if(signal(i) <= signal(i+1) && signal(i) <= signal(i+2) &&
        signal(i) <= signal(i-1) && signal(i) <= signal(i-2))
       {
         for (int j = i; j < Bars; j++)
           {
             if(sto(j) <= sto(j+1) && sto(j) < sto(j+2) &&
                sto(j) <= sto(j-1) && sto(j) < sto(j-2))
                 return(j);
           }
       }
   }
 return(-1);
}  

// CAPTURAR LA DIVERGENCIA ALCISTA
void CapturarDivergenciaAlcista(int shift)
  {
  
  double StopLossLevel=NormalizeDouble(Bid-StopLoss*10*Point,Digits);
double TakeProfitLevel=NormalizeDouble(Bid+TakeProfit*10*Point,Digits); 
  
   if(ExistePicoDownEnIndicador(shift) == false)
       return;  
   int currentTrough = shift;
   int lastTrough = CapturarUltimoPicoDown(shift);
   
   double BANDS_P1 = iBands(NULL,0,PeriodBandsBuy,0,0.5,PRICE_LOW,MODE_LOWER,currentTrough); 
   double BANDS_P2 = iBands(NULL,0,PeriodBandsBuy,0,0.5,PRICE_LOW,MODE_LOWER,lastTrough); 
//----   
 //if (SintoniaWithH4_Buy(currentTrough)==True){
     if(  (Close[currentTrough]< BANDS_P1) && (Close[lastTrough]< BANDS_P2)  )   {
   //EVALUAMOS CONDICION DIVERGENCIA ALCISTA #1   *********************************************************
      if(     ( sto(currentTrough) >= sto(lastTrough) && 
               Low[currentTrough] <= Low[lastTrough])      )
        {
          
            DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                                 Low[currentTrough], 
                                Low[lastTrough], Green, STYLE_SOLID); 
            
            DivergenciaBuy=True;  
       
        } else {DivergenciaBuy=False;}
        
    // }

   //EVALUAMOS CONDICION DIVERGENCIA ALCISTA #2 * ********************************************************
   if(sto(currentTrough) <= sto(lastTrough) && 
      Low[currentTrough] >= Low[lastTrough])
     {   
          DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                              Low[lastTrough], Green, STYLE_DOT);  
                               
           DivergenciaBuy2=True;      
         
     }  else {DivergenciaBuy2=False;}  
     
   if ((DivergenciaBuy==True)|| (DivergenciaBuy2==True)) {
          
            idbuy1= Low[currentTrough]+Low[lastTrough];  
                                
         if (  contains(ids_buys1, idbuy1)==false    ){ 
          
            ids_buys1[contador_ids_buyl1]=idbuy1; 
            contador_ids_buyl1=contador_ids_buyl1+1;  
           
            compra1= OrderSend (NULL,OP_BUY,0.1,Ask,10,
                        StopLossLevel,
                        TakeProfitLevel,
                         "Divergencia RSI", 3 , 0 , clrGreen );  
          }     
          
   
       } 
     
       }
 // }
  }
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "Stochastic_DivergenceLine_v1.0# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }  

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////BAJISTA  **//////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
//ESTAMOS EN UN INDICADOR PICO?
bool ExistePicoEnIndicador(int shift)
  {
   if(sto(shift) >= sto(shift+1) && sto(shift) > sto(shift+2) && 
      sto(shift) > sto(shift-1))
       return(true);
   else 
       return(false);
  }
//CAPTURAR EL INDICE DEL VALOR PICO
int CapturarUltimoPico(int shift)
  {
   for(int i = shift + 5; i < Bars; i++)
     {
       if(signal(i) >= signal(i+1) && signal(i) >= signal(i+2) &&
          signal(i) >= signal(i-1) && signal(i) >= signal(i-2))
         {
           for(int j = i; j < Bars; j++)
             {
               if(sto(j) >= sto(j+1) && sto(j) > sto(j+2) &&
                  sto(j) >= sto(j-1) && sto(j) > sto(j-2))
                   return(j);
             }
         }
     }
   return(-1);
  }
//CAPTURAR DIVERGENCIAS BAJISTAS  
void CapturarDivergenciaBajista(int shift)
  {
  
    double StopLossLevel=NormalizeDouble(Ask+StopLoss*10*Point,Digits);
    double TakeProfitLevel=NormalizeDouble(Ask-TakeProfit*10*Point,Digits); 

   if(ExistePicoEnIndicador(shift) == false)
       return;
   int currentPeak = shift;
   int lastPeak = CapturarUltimoPico(shift);
   
   
   double BANDS_P1 = iBands(NULL,0,PeriodBandsSell,0,0.5,PRICE_HIGH,MODE_HIGH,currentPeak); 
   double BANDS_P2 = iBands(NULL,0,PeriodBandsSell,0,0.5,PRICE_HIGH,MODE_HIGH,lastPeak); 
//----   
  
     if(  (Close[currentPeak]> BANDS_P1) && (Close[lastPeak]> BANDS_P2)  )   {
  
          
      //----   
         //EVALUAMOS CONDICION DE DIVERGENCIA BAJISTA  #1 ************************************************
         if ((sto(currentPeak) <= sto(lastPeak)) &&  (High[currentPeak] >= High[lastPeak]))        { 
         
                DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                                    High[currentPeak], 
                                    High[lastPeak], Pink, STYLE_SOLID);
                 DivergenciaSell1=True;                     
                       
         
           }else {DivergenciaSell1=False;}
         //EVALUAMOS CONDICION DE DIVERGENCIA BAJISTA  #2 ***********************************************
         if ((sto(currentPeak) >= sto(lastPeak)) &&   (High[currentPeak] <= High[lastPeak]))  { 
                DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                                    High[currentPeak], 
                                    High[lastPeak], Pink, STYLE_DOT); 
                                    
                DivergenciaSell2=True;                    
       
                   
                              
           }   else {DivergenciaSell2=False;  }
           
           
              if ((DivergenciaSell1==True)|| (DivergenciaSell2==True)) {
           
                      idsell1= High[currentPeak]+High[lastPeak];                   
                  if (  contains(ids_sells1, idsell1)==false    ){ 
                  
                     ids_sells1[contador_ids_sell1]=idsell1; 
                     contador_ids_sell1=contador_ids_sell1+1; 
                       venta1 = OrderSend (NULL,OP_SELL,0.1,Bid,10,
                              StopLossLevel ,
                              TakeProfitLevel,
                              "Divergencia RSI", 3 , 0 , clrRed );                                            
                     
              
                  }        
           
           } 
     
      }
     
  }  

//FUNCION PARA DIBUJAR TRENDLINE
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, 
                            double y2, color lineColor, double style)
  {
   int indicatorWindow = WindowFind(indicatorName);
   if(indicatorWindow < 0)
       return;
   string label = "Stochastic_DivergenceLine_v1.0$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 
                0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }  
  
  
//FUNCIONES DE MEDIAS MOVILES SMA H4/H1
double SMA_MEDIAN_H4_V(int vela, int period){
  double SMA_MEDIAN_H4_V=iMA( NULL, PERIOD_H4, period, 0, MODE_SMA, PRICE_MEDIAN, vela);
  return SMA_MEDIAN_H4_V;
}

double SMA_HIGH_H4_V(int vela, int period){
  double SMA_HIGH_H4_V=iMA( NULL, PERIOD_H4, period, 0, MODE_SMA, PRICE_HIGH, vela);
  return SMA_HIGH_H4_V;
}
double SMA_LOW_H4_V(int vela, int period){
  double SMA_LOW_H4_V=iMA( NULL, PERIOD_H4, period, 0, MODE_SMA, PRICE_LOW, vela);
  return SMA_LOW_H4_V;
}
 //para la reversion
double SMA_LHIGH_H1_V(int vela, int period){
  double SMA_LHIGH_H1_V=iMA( NULL, PERIOD_H1, period, 0, MODE_LWMA, PRICE_HIGH, vela);
  return SMA_LHIGH_H1_V;
}
double SMA_LLOW_H1_V(int vela, int period){
  double SMA_LLOW_H1_V=iMA( NULL, PERIOD_H1, period, 0, MODE_LWMA, PRICE_LOW, vela);
  return SMA_LLOW_H1_V;
}
 
  
//FUNCION PARA SINCRONIZAR ENTRE TIMEFRAMES H1 Y H4
bool SintoniaWithH4_Buy(int vela){
 
   if( (SMA_MEDIAN_H4_V(vela,3)>SMA_MEDIAN_H4_V(vela,10)) 
       && (SMA_MEDIAN_H4_V(vela,3)>SMA_MEDIAN_H4_V(vela+1,3))     )        {  //  
     
   return true; }  else {return false;}
   }

int CntOPenOrdersBUY()
   {
   int OOB = 0;  
  
     if(OrdersTotal()>0)
        {
        for(int a=OrdersTotal()-1;a>=0;a--)
           {
           if(OrderSelect(a,SELECT_BY_POS,MODE_TRADES)==true)
              {
              if (OrderType() == OP_BUY)// && OrderType() == OP_BUY)
                 {
                 OOB=OOB+1;
                 }
             
              }
           }
        }
   return OOB;     
   }
   
int CntOPenOrdersSELL()
   {
   int OOS = 0;  
  
     if(OrdersTotal()>0)
        {
        for(int a=OrdersTotal()-1;a>=0;a--)
           {
           if(OrderSelect(a,SELECT_BY_POS,MODE_TRADES)==true)
              {
              if (OrderType() == OP_SELL)// && OrderType() == OP_BUY)
                 {
                 OOS=OOS+1;
                 }
             
              }
           }
        }
   return OOS;     
   }   
             
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
 
 { 

 
          
 LecturaPrecio(counbar,50,70,"p2D",  StringConcatenate("counbar: ",999,": "));   
  LecturaPrecio(contador_ids_buyl1,50,90,"p2",  StringConcatenate("contador_ids_buyl1: ",999,": ")); 
  
 
        for(int i = 0; i <= 20; i++)
           {    CapturarDivergenciaAlcista(i + 2); } 
 
   //**********************************************************************************************
   //*****COMPRA******LOGICA DE CIERRE AUTOMATICO CUANDO EMPIEZA A RETROCEDER EL PRECIO H1*********
   //********************************************************************************************
 
   if (CntOPenOrdersBUY()>=1){
   counbar=counbar+1; 
   }else {counbar=0;}
	 if (counbar > 6)  {
      	 //Cuando el Beneficio es positivo y empieza darse la vuelta en H1 entonces cerramos posiciones
      	 if ((SMA_LHIGH_H1_V(0,PeriodReversion)<=SMA_LHIGH_H1_V(3,PeriodReversion)) && profitBUY()>10 ) {//
      	      CloseBuyPositions();
      	       activar_espera2=false;
      	       activar_espera=false;
      	      Print("Cierre por Reversion de la Media Movil High Price - 6 SMA");
      	     }   
      	 if (profitBUY()<10 ) {//
               activar_espera=true;
           }       
      	 if (activar_espera==true){
      	         if(SMA_LHIGH_H1_V(0,PeriodReversion)>SMA_LHIGH_H1_V(1,PeriodReversion)) {
      	      
      	         }
      	 }    
       	 if ((activar_espera2==true)&& (profitBUY()<0 ) && 
       	      (SMA_LHIGH_H1_V(0,PeriodReversion)<=SMA_LHIGH_H1_V(3,PeriodReversion))     ){
               	 CloseBuyPositions();
               	 activar_espera2=false;
               	 activar_espera=false;
      	 }   
	           
	  }
	     
	      
	      
	     
	// }     
	      
       
     
 
        for(int ii = 0; ii <= 20; ii++)  {    
            CapturarDivergenciaBajista(ii + 2);
            
             
          }    
  
   
     //**********************************************************************************************
   //*****VENTA*******LOGICA DE CIERRE AUTOMATICO CUANDO EMPIEZA A RETROCEDER EL PRECIO H1*********
   //********************************************************************************************
 
   if (CntOPenOrdersSELL()>=1){
   counbarsell=counbarsell+1; 
   }else {counbarsell=0;}
   
	if (counbarsell > 6)  {
      	 //Cuando el Beneficio es positivo y empieza darse la vuelta en H1 entonces cerramos posiciones
      	 if ((SMA_LLOW_H1_V(0,PeriodReversion)>=SMA_LLOW_H1_V(3,PeriodReversion)) && profitSELL()>10 ) {//
      	      CloseSellPositions();
      	       activar_espera2_sell=false;
      	       activar_espera_sell=false;
      	      Print("Cierre por Reversion Venta de la Media Movil High Price - 6 SMA");
      	     }   
      	 //Cuando el beneficio es negativo activamos espera de cierre #2 de seguridad.
      	 if (profitSELL()<10 ) {//
               activar_espera_sell=true;
           }       
      	 if (activar_espera_sell==true){
      	         if(SMA_LLOW_H1_V(0,PeriodReversion)<SMA_LLOW_H1_V(1,PeriodReversion)) {
      	         activar_espera2_sell=true;
      	         }
      	 }    
       	 if ((activar_espera2_sell==true)&& (profitSELL()>0 ) && 
       	      (SMA_LLOW_H1_V(0,PeriodReversion)>=SMA_LLOW_H1_V(3,PeriodReversion))     ){
               	 CloseSellPositions();
               	 activar_espera2_sell=false;
               	 activar_espera_sell=false;
      	 }   
	           
	  }
	      
  }
//+------------------------------------------------------------------+
