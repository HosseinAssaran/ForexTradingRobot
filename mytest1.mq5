
void OnTick()
  {
      string text="This is balance:    ";
      datetime localtime= TimeLocal();
      double balance = ACCOUNT_BALANCE;
      double newbalance = balance + 0.12;
      long accountinfo = AccountInfoInteger(ACCOUNT_LOGIN);
      bool trueorfalse = true;
      
      Comment(text, localtime);
      Print("this is ",localtime);
  }

