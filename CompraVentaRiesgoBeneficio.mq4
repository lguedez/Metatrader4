//+------------------------------------------------------------------+
//                        LEO
//+------------------------------------------------------------------+


extern int PeriodRSI = 34;
extern int PeriodStoch = 21;
extern int PeriodSK = 13;
extern int PeriodSD = 13;
extern int MAMode = 0;

extern int sttimeframe=60;               // st timeframe
extern double DINERO=400.001,APALANC=500.001;
extern int prevbars=100;                 // st prevbars
extern int shift=1;                      // bar in the past to take in consideration for the signal
extern int MagicNumber=13332;

extern int StopLoss=20;
extern int TakeProfit=200;
extern int TrailingStop=100;
extern int Slippage=3;    
double AMARILLO,AZUL,ROJO;
int result,Count=0;
int SW1=0,SW2=0,CoV,cnt,SL_R,SL_F,C=0,i;
double DIF,PIP,NUM1,NUM2,CR,PRECIO_SL=0.0,PRECIO_SL_G=0.0,PRECIO_SL_G20=0.0,PORC_RIESGO,PA,ST_blue=0.01,ST_red=0.01;
double EMA20AZUL,EMA20ROJO,EMA20_AZULpto,EMA20_ROJOPTO,RSI,SMA10ROJO=0.0001,leo=0.00001,SMA10_2=0.001,SL_EMA,antes,despues;
double SMA10[100000]; 
double Lots =0.01,acum=0.0;
    
//+-----------------------------------------------------------------------------------+
int TotalOrdersCount()
{
  int result=0;
  for(int i=0;i<OrdersTotal();i++)
  {
     OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber()==MagicNumber) result++;

   }
  return (result);
}
//----------------------------------------------------------------------------------------
  
int start()
{
   
   double PRECIO = Bid;                          // Local variable
   Count++;                                     // Ticks counter
   //Alert("New tick ",Count,"   PRECIO = ",PRECIO);// Alert
   double MyPoint=Point;
  if(Digits==3 || Digits==5) MyPoint=Point*10;
  //MessageBox("TotalOrdersCount="+TotalOrdersCount());
  AMARILLO=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, 1);
  AZUL=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, 1);
  ROJO=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, 1);
 
  //double ST_blue=iCustom(NULL,sttimeframe,"ST",periodmin,step,slowing,smoothing,prevbars,0,shift);
  //double ST_red=iCustom(NULL,sttimeframe,"ST",periodmin,step,slowing,smoothing,prevbars,1,shift);
  ST_blue=iCustom(NULL, sttimeframe,"ST", PeriodRSI, PeriodStoch, PeriodSK, PeriodSD, MAMode, 5, shift);
  ST_red=iCustom(NULL, sttimeframe,"ST", PeriodRSI, PeriodStoch, PeriodSK, PeriodSD, MAMode, 6, shift);
    
 
  CALCULO_PIP(NUM1, NUM2);
  EMA20AZUL=iMA(NULL,0,20,0,MODE_EMA,PRICE_HIGH,shift);
  EMA20ROJO=iMA(NULL,0,20,0,MODE_EMA,PRICE_LOW,shift);
  EMA20_AZULpto=iMA(NULL,0,10,0,MODE_EMA,PRICE_LOW,shift);
  EMA20_ROJOPTO=iMA(NULL,0,10,0,MODE_EMA,PRICE_HIGH,shift);
  RSI=iRSI(NULL,0,10,PRICE_CLOSE,shift);
  //SMA10ROJO=iMA(NULL,0,10,0,MODE_SMMA,RSI,shift);
  
 //----fkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
 //---- input parameters
   
   int counted_bars=Bars-990;

      SMA10[counted_bars] = RSI;
      SMA10_2 = iMAOnArray(SMA10,0,10,0,MODE_SMMA,shift);
       
       leo=SMA10[counted_bars]+SMA10[counted_bars-1]+SMA10[counted_bars-2]+SMA10[counted_bars-3]+SMA10[counted_bars-4]+SMA10[counted_bars-5]+SMA10[counted_bars-6]+SMA10[counted_bars-7]+SMA10[counted_bars-8]+SMA10[counted_bars-9];
       SMA10ROJO=leo/10;
       
      
      
      Alert("SMA10ROJO ",SMA10ROJO," RSI = ",RSI,"   counted_bars ",counted_bars,"  leo = ",leo,"  SMA10_2  ",SMA10_2);
      
      
      if(counted_bars<=10) return(0);
//----ffffffffffffffffffffffffffffffffffffffffffff
  
  
  //ESTO ES PARA ABRIR ORDENES DE COMPRA Y VENTA
   Alert("EMA20AZUL ",EMA20AZUL," EMA20ROJO = ",EMA20ROJO,"   EMA20_AZULpto ",EMA20_AZULpto,"  EMA20_ROJOPTO = ",EMA20_ROJOPTO,"   RSI = ",RSI,"   SMA10ROJO = ",SMA10ROJO);// ALERTA
  if( TotalOrdersCount()==0 ) 
  {
         
     if(  Close[1]>EMA20AZUL &&Ask>EMA20AZUL &&  RSI>55&& RSI>SMA10ROJO ) // Aqui es para comprar
     //if(Close[1]>AMARILLO && AMARILLO>AZUL &&AZUL>ROJO) // Aqui es para comprar
     {
         
        RIESGO_BENEFICIO(0);
        Lots=CR;
               
        //Alert("---Lots ",Lots,"   PRECIO_SL = ",PRECIO_SL, "   DIF  ",DIF, "   StopLoss   ",StopLoss,"  ask ",Ask,"  ROJO  ",ROJO, "  SL_R ",SL_R);
        result=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,PRECIO_SL,0,"comentario Leo 1",MagicNumber,0,Green);
        PRECIO_SL_G20=OrderOpenPrice(); 
        return(0);
     }
     if(  Close[1]<EMA20ROJO&&Bid<EMA20ROJO &&  RSI<45&& RSI<SMA10ROJO ) // Aqui es para vender
     //if(Close[1]<AMARILLO && AMARILLO<AZUL&& AZUL<ROJO ) // regla para vender
     {
        
        RIESGO_BENEFICIO(1);
        Lots=CR;
        result=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,PRECIO_SL,0,"Comentario Leo 2",MagicNumber,0,Red);
        PRECIO_SL_G20=OrderOpenPrice(); 
        return(0); 
             
     }
  }
  // ESTO ES PARA CERRRAR ORDENES DE COMPRA Y VENTA
  
  for(int cnt=0;cnt<OrdersTotal();cnt++)
     {
      SW1=0;
      SW2=0;
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)  
        {
         //Alert("OrderClosePrice ",OrderClosePrice(),"   Close[1] = ",Close[1],"   BID = ",Bid,"   ASK  ",Ask);
         
         if(OrderType()==OP_BUY)  
           {
              
              TOMA_GANANCIA(0);
              if(Ask<EMA20_AZULpto ) //here is your close buy rule
              {
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Green);
                  
              }
         
           }
         else 
           {
               TOMA_GANANCIA(1);
               if(Bid>EMA20_ROJOPTO) // here is your close sell rule
                {
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
                  
                }
           }
        }
     }
   return(0);
}


// RUTINA QUE CALCULA PIP Y DIFERENCIA DE DOS PUNTOS

double CALCULO_PIP(double NUM1, double NUM2)
{ 
   if(Digits>3)  
    {
      DIF=NUM1-NUM2;
      PIP=0.0001;
    }
   else
    {
      if (Digits<4)
         {
         DIF=NUM1-NUM2;
         PIP=0.01;
         }
      else
         {
         DIF=NUM1-NUM2;
         PIP=0.1;
         }
    }
   
return(0);   
}


//.................... RUTINA QUE CALCULA LA TOMA DE GANANCIA DE COMPRA(0) Y VENTA(1) 

double TOMA_GANANCIA(int CoV)
{ 
   Alert("PRECIO_SL ",PRECIO_SL,"  acum = ",acum," EMA20_AZULpto = ",EMA20_AZULpto,"   PRECIO_SL_G = ",PRECIO_SL_G,"   ASK  ",Ask,"   PRECIO_SL_G20 ",PRECIO_SL_G20, "  DINERO  ",DINERO);  
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
   if(CoV==0)  
    {//COMPRA
      if (PRECIO_SL<EMA20_AZULpto&& OrderOpenPrice()<EMA20_AZULpto )
         {
         OrderModify(OrderTicket(),OrderOpenPrice() ,EMA20_AZULpto,0,0,Green);
         
         }

       PRECIO_SL_G=Ask-20*PIP;
         
       
       if (Ask>PRECIO_SL_G20 && PRECIO_SL_G>EMA20_AZULpto)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),PRECIO_SL_G,0,0,Green);
            PRECIO_SL=PRECIO_SL_G;
            PRECIO_SL_G20=PRECIO_SL_G20+10*PIP;
         }  
    }
   else
    {//VENTA
      if (PRECIO_SL>EMA20_ROJOPTO&& OrderOpenPrice()>EMA20_ROJOPTO)
         {
          OrderModify(OrderTicket(),OrderOpenPrice(),EMA20_ROJOPTO,0,0,Red);
         }
       
       PRECIO_SL_G=Bid+20*PIP;
         
       if (Bid<PRECIO_SL_G20&& PRECIO_SL_G<EMA20_ROJOPTO)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),PRECIO_SL_G,0,0,Red);
            PRECIO_SL=PRECIO_SL_G;
            PRECIO_SL_G20=PRECIO_SL_G20-10*PIP;
         }
    }
   
return(0);   
}

//.................... RUTINA QUE CALCULA LA RELACION RIESGO BENEFICIO............................
double RIESGO_BENEFICIO(int CoV)
{ 
   
   DINERO=AccountBalance();
   PORC_RIESGO=2*DINERO/100;
      
   if(CoV==0)  
    {//COMPRA
        CALCULO_PIP(Ask, ROJO);
        SL_R=DIF/PIP;
        CALCULO_PIP(Ask, EMA20_AZULpto);
        SL_EMA=DIF/PIP;
        if (SL_EMA<SL_R)
        {
        PRECIO_SL=NormalizeDouble(Ask-SL_R*PIP,Digits);
        SL_F=SL_R;
        }
        else
        {
        PRECIO_SL=NormalizeDouble(Ask-SL_EMA*PIP,Digits);
        SL_F=SL_EMA;
        }   
    }
   else
    {//VENTA
        CALCULO_PIP(ROJO, Bid);
        SL_R=DIF/PIP;
        CALCULO_PIP(EMA20_ROJOPTO, Bid);
        SL_EMA=DIF/PIP;
        if (SL_EMA<SL_R)
        {
        PRECIO_SL=NormalizeDouble(Bid+SL_R*PIP,Digits);
        SL_F=SL_R;
        }
        else
        {
        PRECIO_SL=NormalizeDouble(Bid+SL_EMA*PIP,Digits);
         SL_F=SL_EMA;
        } 
        
    }
   //Alert("---SL_F ",SL_F,"   PORC_RIESGO = ",PORC_RIESGO, "   SL_F  ",SL_F, "   APALANC   ",APALANC,"  CR ",CR,"  PRECIO_SL  ",PRECIO_SL);
   CR=(PORC_RIESGO/SL_F)*100.0/APALANC;
   
   
return(0);   
}

//OTROS-------------------------------------------------------------------------

//int DayOfWeek( ) 
//Devuelve el día actual de base cero de la semana (0-Domingo, 1,2,3,4,5,6) de la última hora del servidor conocido.
//Nota: En las pruebas, la última hora del servidor conocido es el modelo. 
//
 // if(DayOfWeek()==0 || DayOfWeek()==6) return(0);
// Devuelve la hora (0,1,2, .. 23) de la última hora del servidor conocido por el momento del inicio del programa (este valor no va a cambiar en el momento de la ejecución del programa).
//Nota: En las pruebas, la última hora del servidor conocido es el modelo.
//int Hour( ) 
// bool is_siesta=false;
//  if(Hour()>=12 || Hour()<17)
//     is_siesta=true;

 

// FIN+++++++++++++++++++++++++++++++++++++++++++++++ 