using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

using ITL.Enabler.API;
using ITL.Enabler.WPFControls;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// This dialog encapsulates the WPF pump transaction control.
    /// Initialises the settings inputted in settings dialog passed on init.
    /// Formattes colums and button required.
    /// </summary>
    public partial class PumpTransacionDialog : Window
    {
        Pump _Pump;
        Sale _Sale;
        TransactionStackControlSettings _Settings;
        TransactionStackControl _TransStack;


        public PumpTransacionDialog(TransactionStackControlSettings settings, Pump pump, Sale sale)
        {
            _Pump = pump;
            _Sale = sale;
            _Settings = settings;

            InitializeComponent();

            _TransStack = settings.CreateControl(_Pump);

            _TransStack.OnTransactionSelected += new EventHandler<TransactionStackControl.TransactionListSelectedArgs>(_TransStack_OnTransactionSelected);

            // By Default the transaction list contains Grade, Quantity, Price, Total
            // Add a new column to the transaction list, we could also clear them all and add all the columns

            // Add new colum example
            //  _TransStack.AddColumn(new TransactionStackControl.ColumnItem("T", TransactionStackControl.ColumnItem.FieldType.Type));
            
            // Create the buttons on bottom of Transaction list control
            // You can add what ever content you like to PumpControlButton (Text, image etc)
            double fontsize = 16;
            if (settings.ShowBitmapsOnButtons)
            {
                _TransStack.Buttons.AddButton(new PumpControlButton(GetImage("Authed"), PumpControlButton.PumpActionType.Authorise, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(GetImage("Stack"), PumpControlButton.PumpActionType.StackCurrent, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(GetImage("Select"), PumpControlButton.PumpActionType.User1, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(GetImage("Exit" ), PumpControlButton.PumpActionType.User2, 1));

                _TransStack.Buttons.AddButton(new PumpControlButton(GetImage("Pause"), PumpControlButton.PumpActionType.Pause, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(GetImage("Blocked"), PumpControlButton.PumpActionType.Block, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("", fontsize), PumpControlButton.PumpActionType.User3, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("", fontsize), PumpControlButton.PumpActionType.User4, 1));
            }
            else
            {
                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("Authorise", fontsize), PumpControlButton.PumpActionType.Authorise, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("Stack", fontsize), PumpControlButton.PumpActionType.StackCurrent, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("To Sale", fontsize), PumpControlButton.PumpActionType.User1, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("Exit", fontsize), PumpControlButton.PumpActionType.User2, 1));

                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("Pause\nResume", fontsize), PumpControlButton.PumpActionType.Pause, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("Block", fontsize), PumpControlButton.PumpActionType.Block, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("", fontsize), PumpControlButton.PumpActionType.User3, 1));
                _TransStack.Buttons.AddButton(new PumpControlButton(CreateText("", fontsize), PumpControlButton.PumpActionType.User4, 1));
            }

            // Add Transaction control to stack panel
            TransactionControlPanel.Children.Add(_TransStack);

            // Link our user defined buttons to code.
            _TransStack.Buttons.OnUserButton1 += new EventHandler(Buttons_OnUser1_ToSale);
            _TransStack.Buttons.OnUserButton2 += new EventHandler(Buttons_OnUser2_Exit);

            this.Title = string.Format("Transaction stack for pump {0}", _Pump.Number);
        }

        /// <summary>
        /// Get image for button
        /// </summary>
        /// <param name="ImageName"></param>
        /// <returns></returns>
        Image GetImage(string ImageName)
        {
            Image im = new Image();
            im.Source = (BitmapImage)FindResource(ImageName);
            im.Height = 50;
            im.Width = 50;
            return im;
        }

        /// <summary>
        /// Create a text block to insert into button
        /// <param name="Text"></param>
        /// <param name="FontSize"></param>
        /// <returns></returns>
        TextBlock CreateText(string Text, double FontSize)
        {
            TextBlock tb = new TextBlock();
            tb.Text = Text;
            tb.VerticalAlignment = VerticalAlignment.Center;
            tb.HorizontalAlignment = HorizontalAlignment.Center;
            tb.FontSize = FontSize;
            tb.TextWrapping = TextWrapping.Wrap;
            return tb;
        }


        void _TransStack_OnTransactionSelected(object sender, TransactionStackControl.TransactionListSelectedArgs e)
        {
            TransactionStackControl tsc = sender as TransactionStackControl;

            switch (e.SelectType)
            {
                // If Single select enabled or only one transaction in list then move to sales
                case TransactionStackControl.SelectionType.Click:
                    if (tsc.Transactions.Count() == 1 ||
                        _Settings.MultiTransactionSelect == false )
                    {
                        MoveSelectedItemToSale();

                        this.Close();
                    }
                    break;

                /// If an item in trans list is double clicked or enter key etc then add it to sale window
                default:
                    MoveSelectedItemToSale();
                    break;
            }
        }


        /// <summary>
        /// Move any selected transacton to the sale window
        /// </summary>
        void MoveSelectedItemToSale()
        {
            List<Transaction> trans = _TransStack.SelectedTransactions;
            if (trans.Count() == 1)
            {
                if ( trans[0].State == TransactionState.Completed)
                    _Sale.AddFuelTransaction(trans[0]);
            }
        }
        
        /// <summary>
        /// Move all selected transactions to sale
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void Buttons_OnUser1_ToSale(object sender, EventArgs e)
        {
             List<Transaction> trans = _TransStack.SelectedTransactions;

            foreach (Transaction tran in trans)
            {
                if ( tran.State == TransactionState.Completed )
                    _Sale.AddFuelTransaction(tran);
            }
        }

        /// <summary>
        /// Exit dialog
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void Buttons_OnUser2_Exit(object sender, EventArgs e)
        {
            this.Close();
        }

        private void Window_GotFocus(object sender, RoutedEventArgs e)
        {
            _TransStack.Focus();
        }
    }
}
