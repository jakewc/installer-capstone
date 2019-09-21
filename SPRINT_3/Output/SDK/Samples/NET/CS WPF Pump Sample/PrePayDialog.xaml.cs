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

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Dialog to allow the entering of prepay options. 
    /// </summary>
    public partial class PrePayDialog : Window
    {
        Pump _Pump;
        PumpAuthoriseLimits _AuthData;

        public PrePayDialog(ref PumpAuthoriseLimits authData, Pump pump)
        {
            _AuthData = authData;
            _Pump = pump;

            InitializeComponent();

            LinkEvents();
       
            // Display       
            textbox_limit.Text = "10.00";
            LoadProductList();
        }

        /// <summary>
        /// Link Enabler API events from the Pump we reserved
        /// </summary>
        private void LinkEvents()
        {
            _Pump.OnTransactionEvent += new EventHandler<PumpTransactionEventArgs>(_Pump_OnTransactionEvent);
        }

        /// <summary>
        /// Remove Enabler API Event links
        /// </summary>
        private void UnlinkEvents()
        {
            _Pump.OnTransactionEvent -= _Pump_OnTransactionEvent;
        }

        /// <summary>
        /// Event handler for Pump Status Events 
        /// </summary>

        /// <summary>
        /// Event handler for Fuel Transaction events
        /// </summary>
        void _Pump_OnTransactionEvent(object sender, PumpTransactionEventArgs e)
        {
            Pump pump = sender as Pump;
            string dialogMessage = "";
            string dialogTitle = "";
            bool ShowMessageAndClose = false;

            if (e.EventType == TransactionEventType.Completed)
            {
                // check for and handle end of pump reserve (cancel or timeout)
                // here we show a message and close this dialog
                switch (e.Transaction.HistoryData.CompletionReason)
                {
                    case CompletionReason.Cancelled:
                        ShowMessageAndClose = true;
                        dialogMessage = string.Format("Prepay cancelled\nPump {0} is no longer reserved for a prepay", pump.Number);
                        dialogTitle = "Prepay cancelled";
                        break;

                    case CompletionReason.Timeout:
                        ShowMessageAndClose = true;
                        dialogMessage = string.Format("Prepay reserve timeout\nPump {0} is no longer reserved for a prepay", pump.Number);
                        dialogTitle = "Prepay Timeout";
                        // clear the (zero) transaction
                        pump.CurrentTransaction.Clear(TransactionClearTypes.Normal);
                        break;
                }
            }

            if (ShowMessageAndClose)
            {
                this.Dispatcher.BeginInvoke((Action)(() =>
                {
                    MessageBox.Show(this, dialogMessage, dialogTitle, MessageBoxButton.OK);
                    CloseDialog(false);
                }));
            }
        }

        /// <summary>
        /// Load the product list from names of grades on hoses
        /// </summary>
        void LoadProductList()
        {
            foreach (Hose hose in _Pump.Hoses)
            {
                ListBoxItem li = new ListBoxItem();
                CheckBox cb = new CheckBox();
                cb.IsChecked = true;
                cb.Content = hose.Grade.Name;

                cb.Tag = hose.Grade.Id;

                li.Content = cb;

                Listbox_products.Items.Add(li);
            }
        }

        /// <summary>
        /// Build AuthData from select options.
        /// </summary>
        /// <param name="AuthData"></param>
        /// <param name="products"></param>
        /// <param name="amount"></param>
        /// <returns></returns>
        public static bool BuildAuthData(ref PumpAuthoriseLimits AuthData, ListBox products, TextBox amount)
        {
            decimal AmountLimit = 0;

            if (!Decimal.TryParse(amount.Text, out AmountLimit) || AmountLimit == 0)
            {
                MessageBox.Show("Invalid prepay amount");
                return false;
            }
            AuthData.Value = AmountLimit;

            bool AllProducts = true;

            foreach (ListBoxItem li in products.Items)
            {
                CheckBox cb = li.Content as CheckBox;
                if (cb.IsChecked == false)
                    AllProducts = false;
                else
                    AuthData.Products.Add((int)cb.Tag);
            }

            // If all products don't need to specify
            if (AllProducts)
            {
                AuthData.Products.Clear();
            }
            else
            {
                if (AuthData.Products.Count == 0)
                {
                    MessageBox.Show("Please select one or more products to authorise");
                    return false;
                }
                
            }

            return true;
        }

        
        private void Button_Ok_Click(object sender, RoutedEventArgs e)
        {
            if ( !BuildAuthData(ref _AuthData, Listbox_products, textbox_limit) ) return;
            CloseDialog(true);
        }

        private void Button_Cancel_Click(object sender, RoutedEventArgs e)
        {
            CloseDialog(false);
        }

        /// <summary>
        /// Close dialog and remove the links to pump
        /// </summary>
        /// <param name="result"></param>
        private void CloseDialog(bool result)
        {
            this.DialogResult = result;
            UnlinkEvents();
        }
    }
}
