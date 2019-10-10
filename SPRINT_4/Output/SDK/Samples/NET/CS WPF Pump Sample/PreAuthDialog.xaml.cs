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
    /// Interaction logic for PreAuthDialog.xaml
    /// </summary>
    public partial class PreAuthDialog : Window
    {
        Pump _Pump;
        PumpAuthoriseLimits _AuthData;
        // Must be the same Client Reference as Reserved
        int _ClientReference;

        public PreAuthDialog(ref PumpAuthoriseLimits authData, Pump pump, int TransRef)
        {
            _AuthData = authData;
            _Pump = pump;
            _ClientReference = TransRef;

            InitializeComponent();
            LinkEvents();
            txtPreAuth_limit.Text = "10.00";
            LoadProductList();

            // Handle preauth dialog restart
            Transaction trans = pump.CurrentTransaction;
            if (trans != null)
            {
                SetWindowStates(trans.State);

                if ( trans.State == TransactionState.Completed )
                {
                        HandleTransactionEvent(pump, TransactionEventType.Completed, trans);
                }
            }
        }

        /// <summary>
        /// Link events to pump
        /// </summary>
        private void LinkEvents()
        {
            _Pump.OnFuellingProgress += new EventHandler<FuellingProgressEventArgs>(_Pump_OnFuellingProgress);
            _Pump.OnTransactionEvent += new EventHandler<PumpTransactionEventArgs>(_Pump_OnTransactionEvent);
        }

        /// <summary>
        /// Remove Event links
        /// </summary>
        private void UnlinkEvents()
        {
            _Pump.OnTransactionEvent -= _Pump_OnTransactionEvent;
            _Pump.OnFuellingProgress -= _Pump_OnFuellingProgress;
        }

        #region Event Functions

        void _Pump_OnTransactionEvent(object sender, PumpTransactionEventArgs e)
        {
            Pump pump = sender as Pump;
            HandleTransactionEvent( pump, e.EventType, e.Transaction  );
        }

        void HandleTransactionEvent( Pump pump, TransactionEventType et, Transaction fuelTransaction  )
        {
            if (et == TransactionEventType.Completed && pump.CurrentTransaction != null)
            {
                if (fuelTransaction.DeliveryData.Grade != null)
                {
                    this.Dispatcher.BeginInvoke((Action)(() =>
                    {
                        txt_delivery.Visibility = Visibility.Visible;
                        btn_Close.Visibility = Visibility.Visible;
                        lbl_status.Content = "Delivery Completed";
                        txt_delivery.Text = String.Format("Delivery: Price:{0:F3} Liter: {1:F3} Money: {2:F3}",
                            fuelTransaction.DeliveryData.UnitPrice,
                            fuelTransaction.DeliveryData.Quantity,
                            fuelTransaction.DeliveryData.Money);
                    }));
                }
                else
                {
                    string dialogMessage = "";
                    string dialogTitle = "";

                    // Timeout delivery will be cleared by PSRVR
                    switch (fuelTransaction.HistoryData.CompletionReason)
                    {
                        case CompletionReason.Zero:
                            dialogMessage = string.Format("Pump {0} is no longer reserved or authorised for a preauth", pump.Number);
                            dialogTitle = "Preauth Cancelled";
                            CancelPreAuth();
                            break;

                        case CompletionReason.Timeout:
                            dialogMessage = string.Format("Pump {0} is no longer reserved or authorised for a preauth", pump.Number);
                            dialogTitle = "Preauth Timeout";
                            fuelTransaction.Clear(TransactionClearTypes.Normal);
                            break;

                        default:
                            // Same pump cannot be linked twice.
                            UnlinkEvents();
                            break;
                    }

                    this.Dispatcher.BeginInvoke((Action)(() =>
                        {
                            // Get message box, before close the dialog, otherwise exception will be threw out
                            System.Windows.MessageBoxResult result = MessageBox.Show(this, dialogMessage, dialogTitle, MessageBoxButton.OK);
                            CloseDialog(false);
                        }));
                }
            }
        }

        /// <summary>
        /// Display running total
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void _Pump_OnFuellingProgress(object sender, FuellingProgressEventArgs e)
        {
            Pump pump = sender as Pump;

            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                SetWindowStates(TransactionState.Fuelling);

                lbl_status.Content = String.Format("Pump: {0} Quantity:{1:F3} Value:{2:F3}", pump.Number, e.Volume, e.Value);
            }));
        }

 
        private void SetWindowStates(TransactionState state)
        {
            if (state != TransactionState.Reserved)
            {
                lst_products.IsEnabled = false;
                ckb_allHose.IsEnabled = false;
                groupBox_limit.IsEnabled = false;
                groupBox_PriceLevel.IsEnabled = false;
                btn_ok.IsEnabled = false;
            }

            switch(state)
            {
                case TransactionState.Authorised:
                    lbl_status.Content = "Waiting for Delivery";
                    btn_cancel.IsEnabled = true;
                    break;

                case TransactionState.Fuelling:
                    btn_cancel.IsEnabled = false;
                    lbl_status.Visibility = Visibility.Visible;
                    break;

                case TransactionState.Completed:
                    lbl_status.Visibility = Visibility.Visible;
                    btn_cancel.IsEnabled = false;
                    break;
            }
        }

        #endregion

        /// <summary>
        /// Load the product list from names of grades on hoses
        /// </summary>
        private void LoadProductList()
        {
            foreach (Hose hose in _Pump.Hoses)
            {
                ListBoxItem lbItem = new ListBoxItem();
                CheckBox cb = new CheckBox();
                cb.IsChecked = true;
                cb.Content = hose.Grade.Name;

                cb.Tag = hose.Grade.Id;

                lbItem.Content = cb;

                lst_products.Items.Add(lbItem);
            }
        }

        /// <summary>
        /// Cancel PreAuth based on the current transaction status
        /// </summary>
        private void CancelPreAuth()
        {
            UnlinkEvents();
            
            Transaction trans = _Pump.CurrentTransaction;
            
            try
            {
                if (trans != null)
                {
                    switch( trans.State )
                    {
                        case TransactionState.Reserved:
                            _Pump.CancelReserve();
                            break;

                        case TransactionState.Authorised:
                            _Pump.CancelAuthorise();
                            break;

                        case TransactionState.Completed:
                            _Pump.CurrentTransaction.Clear(TransactionClearTypes.Normal);
                            break;
                    }
                }
            }
            catch (EnablerException ex)
            {
                MessageBox.Show(ex.Message, ex.ResultCode.ToString());
            }
        }

        #region Button Functions
        /// <summary>
        /// Authorize the preauth delivery
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btn_ok_Click(object sender, RoutedEventArgs e)
        {
            decimal limitValue = 0;

            if( txtPreAuth_limit.Text.Length != 0
                && decimal.TryParse(txtPreAuth_limit.Text, out limitValue) == false)
            {
                string errorMsg = "Invalid Preauth limit, please re-enter.";
                if (ckbMoney.IsChecked != true)
                    errorMsg = "Invalid Preauth volume, please re-enter.";
                MessageBox.Show(errorMsg, null, MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            if (ckbMoney.IsChecked == true)
                _AuthData.Value = limitValue;
            else
                MessageBox.Show("Only Accept Value Preauth");
                //_AuthData.Quantity = limitValue;

            int priceLevel = 1;

            if( PriceLevel1.IsChecked != true)
                priceLevel = 2;

            _AuthData.Level = priceLevel;

            if (!BuildAuthProducts(ref _AuthData, lst_products))
                return;

            try
            {
                _Pump.Authorise(MainWindow.Activity_LegacyPreAuth, _ClientReference.ToString(), -1, _AuthData);
            }
            catch (EnablerException ex)
            {
                MessageBox.Show(ex.Message, ex.ResultCode.ToString());
                CancelPreAuth();
                return;
            }

            SetWindowStates(TransactionState.Authorised );
        }


        /// <summary>
        /// Clear the completed delivery
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btn_Close_Click(object sender, RoutedEventArgs e)
        {
            UnlinkEvents();
            // Clear the transaction
            try
            {
                _Pump.CurrentTransaction.Clear(TransactionClearTypes.Normal);
            }
            catch (EnablerException ex)
            {
                MessageBox.Show(ex.Message, ex.ResultCode.ToString());
            }
            this.DialogResult = false;
        }

        /// <summary>
        /// Cancel preauth delivery
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btn_cancel_Click(object sender, RoutedEventArgs e)
        {
            CancelPreAuth();
            this.DialogResult = false;
        }
        #endregion

        /// <summary>
        /// Add authorized products into a list 
        /// </summary>
        /// <param name="_AuthData"></param>
        /// <param name="lst_products"></param>
        private bool BuildAuthProducts(ref PumpAuthoriseLimits _AuthData, ListBox lst_products)
        {
            if (ckb_allHose.IsChecked == false)
            {
                foreach (ListBoxItem i in lst_products.Items)
                {
                    CheckBox cb = i.Content as CheckBox;
                    if (cb.IsChecked == true)
                        _AuthData.Products.Add((int)cb.Tag);
                }
                if (_AuthData.Products.Count == 0) // no product 
                {
                    MessageBox.Show("Please select one or more products to authorise");
                    return false;
                }
                return true;
            } 
            else
            {
                _AuthData.Products.Clear();
                return true;
            }
        }

        private void ckb_allHose_Click(object sender, RoutedEventArgs e)
        {
            if (this.ckb_allHose.IsChecked == true)
            {
                lst_products.IsEnabled = false;
            }
            else
            {
                lst_products.IsEnabled = true;
            }
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
