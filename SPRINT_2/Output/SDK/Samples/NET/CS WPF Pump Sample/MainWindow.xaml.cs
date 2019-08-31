using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Threading;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Media.Animation;

using System.Windows.Navigation;
using System.Windows.Shapes;
using Microsoft.Win32;
using System.Reflection;

using System.Diagnostics;

using ITL.Enabler.API;
using ITL.Enabler.WPFControls;


namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Main window implementaion.
    /// 
    /// </summary>
    public partial class MainWindow : Window
    {
        public const string MyRegistryKey = "Software\\ITL\\PumpDemoWPF";
        public const double DefaultWidth = 950;
        public const double DefaultHeight = 700;

        public const string Activity_Prepay        = "Prepay";
        public const string Activity_LegacyPrepay  = "PrepayV3";
        public const string Activity_LegacyPreAuth = "PreAuthV3";

        // Tank control Settings
        TankControlSettings _TankSettings = new TankControlSettings();

       
        public Forecourt _Forecourt;  // Enabler API forecourt object

        // Controls settings
        PumpControlSettings _PumpControlSettings = new PumpControlSettings();
        TransactionStackControlSettings _TransactionStackSettings = new TransactionStackControlSettings();

        Sale _CurrentSale;
        Pump _CurrentSelectedPump = null;
        int _MyTransRef = 1;

        bool   _ReserveClearIfZero = false;
        string _ReserveClientRef = "";

        // Save initial log on params
        LogonData _logonData = new LogonData();

        PreAuthDialog _preAuthDlg = null;
        PrePayDialog _prePayDlg = null;

        static Version _ApiVersion;

        public MainWindow()
        {
            InitializeComponent();

            // Get the version of the API which supports the Legacy Prepay
            try
            {
                // Use first as odd instances wherein you can have two assemblies with itl.enabler.api!
                AssemblyName LoadedAPI = Assembly.GetExecutingAssembly().GetReferencedAssemblies().First(api => api.Name.ToLower() == "itl.enabler.api");
                _ApiVersion = LoadedAPI.Version;

                if (ApiVersion >= new Version("1.0.13.0"))
                    RedecoratePumpButtons();
            }
            catch (Exception e) 
            { 
                Debug.WriteLine("MainWindow Error: {0}", e.Message); 
            }

            _CurrentSale = new Sale(this);

            LoadApplicationSettings();

            // Create a Forecourt object for Enabler
            _Forecourt = new Forecourt();

            // Set up an Event handler for Connection error events
            _Forecourt.OnServerEvent += new EventHandler(_Forecourt_OnServerEvent);

            _Forecourt.OnConfigChange += new EventHandler<ConfigChangeEventArgs>(_Forecourt_OnConfigChange);

            // Set up an Event handler for Async Connect results
            _Forecourt.OnConnectAsyncResult += new EventHandler<ConnectCompletedEventArgs>(_Forecourt_OnConnectAsyncResult);


            GridView_Journal.DataContext = _CurrentSale.SaleItems;
            Label_SubTotal.DataContext = _CurrentSale;

            SetWindowsStates();

            // The logon window is shown as a panel in main windows
            ShowLogonPanel();

        }

        public static Version ApiVersion { get { return _ApiVersion; } }

        /// <summary>
        /// Based on API version, redecorate main framework
        /// </summary>
        private void RedecoratePumpButtons()
        {
            // add a new column
            ColumnDefinition girdCol4 = new ColumnDefinition();
            this.PumpControlColumn.ColumnDefinitions.Add(girdCol4);

            // Make the Legacy buttons visible
            btnLegacyPrepayReserve.Visibility = Visibility.Visible;
            btnLegacyPreAuthReserve.Visibility = Visibility.Visible;
 
            // Relocate STOP button 
            Grid.SetRow(this.button_stop, 0);
            Grid.SetColumn(this.button_stop, 3);
            Grid.SetRowSpan(this.button_stop, 4);

            // Change Group width
            this.groupBox_PumpButtons.Width = 400;
        }

        /// <summary>
        /// Legacy Prepay function
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void btnLegacyPrepay_Click (object sender, RoutedEventArgs e)
        {
            // Check a pump is selected
            if (!TestSelectedPump()) return;

            if (_CurrentSelectedPump.State != PumpState.Locked)
            {
                MessageBox.Show("Please select a valid pump");
                return;
            }

            // Reserve pump 
            try
            {
                _CurrentSelectedPump.Reserve( Activity_LegacyPrepay, _MyTransRef.ToString(), false, ReservedType.Prepay);

                DoShowPrepayDialog(_CurrentSelectedPump, Activity_LegacyPrepay);
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }

        /// <summary>
        /// Legacy PreAuth function
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void btnLegacyPreAuth_Click(object sender, RoutedEventArgs e)
        {
            // Check a pump is selected
            if (!TestSelectedPump()) return;

            if (_CurrentSelectedPump.State != PumpState.Locked &&
                _CurrentSelectedPump.State != PumpState.Calling) // EP-2259, pump not authorised when calling
            {
                MessageBox.Show("Please select a valid pump");
                return;
            }

            // Reserve pump 
            try
            {
                _CurrentSelectedPump.Reserve(Activity_LegacyPreAuth, _MyTransRef.ToString(), false, ReservedType.PreAuth);

                DoShowPreAuthDialog(_CurrentSelectedPump);
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }

        /// <summary>
        /// Show the PrAuth Dialog
        /// </summary>
        /// <param name="pump"></param>
        private void DoShowPreAuthDialog(Pump pump)
        {
            try
            {
                PumpAuthoriseLimits AuthData = new PumpAuthoriseLimits();

                // Show prepay formmay
                _preAuthDlg = new PreAuthDialog(ref AuthData, pump, _MyTransRef);
                _preAuthDlg.Owner = this;

                _preAuthDlg.ShowDialog();
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
            finally
            {
                _preAuthDlg = null;
            }

        }



        /// <summary>
        /// Called when a connection to Enabler has been successful.
        /// Setup Main window and display controls.
        /// </summary>
        void Connected()
        {
            try
            {
                _Forecourt.Pumps.OnJournalEvent += new EventHandler<JournalEventArgs>(Pumps_OnJournalEvent);
                _Forecourt.Pumps.OnTransactionEvent += new EventHandler<PumpTransactionEventArgs>(Pumps_OnTransactionEvent);
                _CurrentSale.Reset();
                
                // Load the Pump & Tank controls based on current configuration
                SetUpPumpsAndTankControls();

                // Enable / Disable windows based on current state
                SetWindowsStates();


                // We have re-connected, check if there is a currently reserved prepay transaction created by this terminal
                // if there is create a sales item for it so we can continue to work with it
                // this will work when pump server restarts or pump demo is closed an restarted
                foreach (Pump pump in _Forecourt.Pumps)
                {
                    Transaction trans = pump.CurrentTransaction;
                    if (trans != null)
                    {
                        if (trans.State == TransactionState.Reserved &&
                             trans.HistoryData.ReservedBy.Id == _Forecourt.TerminalId)
                        {
                            string[] activity = trans.ClientActivity.Split(',');

                            // Ok its reseve by use, is it a prepay
                            if (activity[0].StartsWith(Activity_Prepay))
                            {
                                string descFormat = "Prepay on pump:{0}";
                                if (activity[0] == Activity_LegacyPrepay)
                                {
                                    descFormat = "Legacy Prepay on pump:{0}";
                                }

                                // Had we entered the Auth details
                                if (activity.Length > 1)
                                {
                                    PumpAuthoriseLimits auth = new PumpAuthoriseLimits();
                                    auth.Value = decimal.Parse(activity[1]);

                                    _CurrentSale.AddPrepayItem(string.Format(descFormat, pump.Number), trans, auth);
                                }
                                else
                                {
                                    if ( _prePayDlg == null )
                                    {
                                        // If no Auth data in Activity then call dialog
                                        DoShowPrepayDialog(trans.Pump, activity[0]);
                                    }
                                }
                                break;
                            }
                        }

                        // Was a legacy preauth reserved on this pump for this terminal
                        if ( trans.HistoryData.ReservedBy != null &&
                             trans.HistoryData.ReservedBy.Id == _Forecourt.TerminalId)
                        {
                            // Preauth was running
                            if (trans.ClientActivity.Equals(Activity_LegacyPreAuth))
                            {
                                // if preAuth dialog is showing then close it
                                if (_preAuthDlg != null)
                                {
                                    _preAuthDlg.DialogResult = false;
                                }

                                // Re show PreAuth dialog so it links up to current pump object and recovers 
                                DoShowPreAuthDialog(pump);
                            }

                        }
                    }
                }

                Message.Content = string.Format("Connected to Server:'{0}'  version:'{1}'", _Forecourt.ServerInformation.ServerName, _Forecourt.ServerInformation.ServerVersion); ;

            }
            catch (EnablerException EE) 
            {
                ShowEnablerError(EE);
            }
            catch (Exception Ex)
            {
                ShowException(Ex);
            }
        }

 
        void SetUpPumpsAndTankControls()
        {
            // Load the Pump & Tank controls based on current configuration
            InitialisePumpControls();

            InitialiseTankControls();

            // Enable / Disable windows based on current state
            SetWindowsStates();
        }
 

        /// <summary>
        /// Clear & Load the Pump controls into PumpControlWrapPanel
        /// </summary>
        void InitialisePumpControls()
        {
            // Add all pump controls to main window wrap panel


            // First we remove all existing PumpControls by disposing so they immediately remove all their resources
            // i.e links in to forecourt pumps
            // If we just delete them the resources won't be removed until the Garbage collector gets around to removing it.
            while (PumpControlWrapPanel.Children.Count > 0)
            {
                PumpControl pc = PumpControlWrapPanel.Children[0] as PumpControl;
                PumpControlWrapPanel.Children.RemoveAt(0);

                pc.Dispose();
            }

            _CurrentSelectedPump = null;

            // Note: Using foreach here when cloning 4+ pumps gives "InvalidOperationException: Collection was modified after the enumerator was instantiated."
            //       This is due to collection size changing during 'foreach' processing - not allowed.
            int i = 0;
            while ( i < _Forecourt.Pumps.Count )
            {
                var pump = _Forecourt.Pumps.GetByIndex(i); 
                PumpControl pumpControl = new PumpControl(pump, _PumpControlSettings);

                // Link in to the OnSelected event for Control
                pumpControl.OnSelected += new EventHandler(pumpControl_OnSelected);
                pump.OnTransactionEvent += new EventHandler<PumpTransactionEventArgs>(pump_OnTransactionEvent);

                PumpControlWrapPanel.Children.Add(pumpControl);

                i++;
            }
    }

        public void SetPumpCaption(int number, string text)
        {
            foreach (PumpControl pump in PumpControlWrapPanel.Children)
            {
                if (pump.Number == number)
                {
                    pump.CaptionText = text;
                }

            }
        }

        /// <summary>
        /// Clear and Load the tank controls
        /// </summary>
        void InitialiseTankControls()
        {

            // First we remove all existing TankControls by disposing so they immediately remove all their resources
            // i.e links in to forecourt pumps
            while (TankControlWrapPanel.Children.Count > 0)
            {
                TankControl tc = TankControlWrapPanel.Children[0] as TankControl;
                TankControlWrapPanel.Children.RemoveAt(0);

                tc.Dispose();
            }

            if (_TankSettings.LoadControl == TankControlSettings.Loaded.Not) return;

            double height = _TankSettings.Size, width = _TankSettings.Size;

            switch (_TankSettings.Style)
            {
                case TankControlStyle.ChartOnly: break;
                case TankControlStyle.DetailOnly: break;
                case TankControlStyle.DetailBottom: height = 1.5 * _TankSettings.Size; break;
                case TankControlStyle.DetailRight: width = 2 * _TankSettings.Size; break;
            }

            if (_TankSettings.AllInOne)
            {
                // All tanks in one control
                bool firstTank = true;
                TankControl tankControl = null;

                // extend width depending on number of tanks
                width += (_Forecourt.Tanks.Count - 1) * 40;

                foreach (Tank tank in _Forecourt.Tanks)
                {
                    if (_TankSettings.LoadControl == TankControlSettings.Loaded.Gauged)
                    {
                        if (!tank.IsGauged) continue;
                    }
                    
                    if (firstTank)
                    {
                        firstTank = false;
                        tankControl = new TankControl(tank);
                        tankControl.Height = height; tankControl.Width = width;
                        tankControl.Style = _TankSettings.Style;
                        tankControl.Title = "Display all tanks in 1 control";
                    }
                    else
                    {
                        tankControl.AddTank(tank);
                    }
                }

                if (tankControl != null) TankControlWrapPanel.Children.Add(tankControl);
            }
            else
            {
                foreach (Tank tank in _Forecourt.Tanks)
                {
                    if (_TankSettings.LoadControl == TankControlSettings.Loaded.Gauged)
                    {
                        if (!tank.IsGauged) continue;
                    }

                    TankControl tankControl = new TankControl(tank);
                    tankControl.Height = height; tankControl.Width = width;
                    tankControl.Style = _TankSettings.Style;
                    TankControlWrapPanel.Children.Add(tankControl);
                }
            }
        }

        #region Enabler Events
        void pump_OnTransactionEvent(object sender, PumpTransactionEventArgs e)
        {
            // Fetch transaction properties here. Because transaction object can be null once GUI thread is Invoked (EP-872)
            int PumpNumber = e.Transaction.Pump.Number;
            string ClientActivity = e.Transaction.ClientActivity;
            Transaction t = e.Transaction;
            
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                SetWindowsStates();
                switch (e.EventType)
                {
                    case TransactionEventType.Cleared:
                        if (ClientActivity.StartsWith(Activity_Prepay))
                            SetPumpCaption(PumpNumber, "");
                        break;

                    case TransactionEventType.Completed:

                        if (ClientActivity.StartsWith(Activity_Prepay))
                            SetPumpCaption(PumpNumber, ClientActivity);

                        if (t.DeliveryType.ToString().Contains("Refund"))
                        {
                            // Display MessageBox if we originally reserved pump
                            if (t.HistoryData.ReservedBy != null)
                            {
                                if (_Forecourt.TerminalId == t.HistoryData.ReservedBy.Id)
                                {
                                    string messageTital = "Prepay Refund";

                                    string refundDetails = string.Format("\n Pump {0} \n Refund Trans ID {1} \n Refund Value {2}",
                                        PumpNumber, t.Id, t.DeliveryData.Money);

                                    MessageBox.Show(this, refundDetails, messageTital, MessageBoxButton.OK);
                                }
                            }
                        }
                        break;

                    default:
                        if (ClientActivity.StartsWith(Activity_Prepay))
                            SetPumpCaption(PumpNumber, ClientActivity);
                        break;
                }
            }
            ));
        }

        void Pumps_OnJournalEvent(object sender, JournalEventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                Pump pmp = (Pump)(sender);
                Message.Content = string.Format("Pump {0} - {1}", pmp.Number, e.Message); ;
            }
            ));
        }

        void Pumps_OnTransactionEvent(object sender, PumpTransactionEventArgs e)
        {
            if (e.EventType == TransactionEventType.Cleared)
            {
                //  Update on GUI thread
                this.Dispatcher.BeginInvoke((Action)(() =>
                {
                    // Make sure any Prepay transaction are removed from sales window if they have been cleared(timeout)
                    _CurrentSale.RemovePrepayTrans(e.TransactionId);
                }
                ));
            }
        }

        /// <summary>
        /// Catch server offline event and try to logon if _AutoReconnect set.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void _Forecourt_OnServerEvent(object sender, EventArgs e)
        {
            if (!_ConnectRunning)
            {
                //  Update on GUI thread
                this.Dispatcher.BeginInvoke((Action)(() =>
                {
                    Message.Content = string.Format("Server has {0}", _Forecourt.IsConnected ? "Connected" : "Disconnected"); ;

                    // If we are doing a prepay or preauth then cancel the dialogs
                    if (_prePayDlg != null)
                    {
                        _prePayDlg.DialogResult = false;
                    }

                    if (_preAuthDlg != null)
                    {
                        _preAuthDlg.DialogResult = false;
                    }


                    SetWindowsStates();

                    if (!_Forecourt.IsConnected)
                    {
                        this.Title = "WPF Pump demo - disconnected";
                    }

                    ShowLogonPanel();
                }
                ));
            }

        }

 
        /// <summary>
        /// There has been a configuration change on pump server. Reload the Pump and Tank controls 
        /// to reflect the change.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void _Forecourt_OnConfigChange(object sender, ConfigChangeEventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                // Reload all controls if we have a Pump or Tank deleted/added.
                if (e.ActionType == ActionType.Add || e.ActionType == ActionType.Delete)
                {
                    if (e.DataType == DataType.Pump || e.DataType == DataType.Tank)
                    {
                        SetUpPumpsAndTankControls();
                    }
                }
            }
            ));
        }

        #endregion

        /// <summary>
        /// Called when a pump control is selected
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void pumpControl_OnSelected(object sender, EventArgs e)
        {
            _CurrentSelectedPump = ((PumpControl)sender).Pump;

            groupBox_PumpButtons.Header = String.Format("Pump controls for pump {0}", _CurrentSelectedPump.Number);

            // check for completed transactions and the pump state to decide what to do based on this click
            Transaction trans = _CurrentSelectedPump.CurrentTransaction;

            try
            {
                if (trans != null && _CurrentSelectedPump.TransactionStack.Count > 0)
                {
                    // we have a current transaction and a stacked one - display the transaction list
                    ShowTransactionList(_CurrentSelectedPump);
                }
                else
                {
                    if (trans != null)
                    {

                        switch( trans.HistoryData.CompletionReason )
                        {
                            case CompletionReason.Normal:
                            case CompletionReason.StoppedByClient:
                            case CompletionReason.StoppedByLimit:
                            case CompletionReason.StoppedByError:
                                // we have a completed transaction; add it to a sale
                                   _CurrentSale.AddFuelTransaction(trans);
                                   break;


                            default:
                            case CompletionReason.Zero:
                                   ShowTransactionList(_CurrentSelectedPump);
                                   break;
                        
                            // Ignore 
                            case CompletionReason.NotComplete:
                                   break;
                        }
                    }
                    else
                    {
                        // decide what to do based on the pump state
                        switch (_CurrentSelectedPump.State)
                        {
                            case PumpState.Locked:
                                if ( _CurrentSelectedPump.TransactionStack.Count > 0 ) ShowTransactionList(_CurrentSelectedPump);
                                break;

                            case PumpState.Calling:
                                _CurrentSelectedPump.AuthoriseNoLimits("","", -1);
                                break;
                        }
                    }
                }
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }

            SetWindowsStates();
        }

        internal void ShowException(Exception Ex)
        {
            MessageBox.Show(this,  "Exception : " + Ex.Message);
        }

        internal void ShowEnablerError(Window owner, ApiResult res)
        {
            // Show local langauge error string
            MessageBox.Show(owner, "Enabler error : " + Forecourt.GetResultString(res));
        }

        internal void ShowEnablerError(EnablerException EE)
        {
            // Show local langauge error string
            ShowEnablerError(this, EE.ResultCode);
        }

        void UpdateWindow()
        {
            Label_SubTotal.Content = string.Format("{0:c}", _CurrentSale.SubTotal);
        }

        /// <summary>
        /// Enable and Disable buttons and groups depending on current state
        /// </summary>
        void SetWindowsStates()
        {
            bool CurrentPump = false;
            bool CurrentTransaction = false;

            // Enabler group boxes depending on current state
            // Pump control box when a pump is selected & online
            // Delivery box if we also have a current completed transaction
            if (_Forecourt.IsConnected)
            {
                if (_CurrentSelectedPump != null) CurrentPump = true;

                if (CurrentPump && (_CurrentSelectedPump.CurrentTransaction != null))
                {
                    if (_CurrentSelectedPump.CurrentTransaction.State == TransactionState.Completed)
                        CurrentTransaction = true;
                }
            }

            groupBox_PumpButtons.IsEnabled = CurrentPump;
           
            // Visibility of buttons
            SetPumpButtons();

            groupBox_transaction.IsEnabled = CurrentTransaction;
            
            groupBox_forecourt.IsEnabled = _Forecourt.IsConnected;
            groupBox_payment.IsEnabled = _Forecourt.IsConnected;
            Border_journal.IsEnabled = _Forecourt.IsConnected;
        }

        /// <summary>
        /// Set Pump control buttons
        /// </summary>
        void SetPumpButtons()
        {
            Visibility vis = Visibility.Visible;

            if (_CurrentSelectedPump != null)
            {
                if (_CurrentSelectedPump.State == PumpState.ManualPump)
                {
                    vis = Visibility.Collapsed;
                    button_manual.Visibility = Visibility.Visible;
                }
                else
                {
                    button_manual.Visibility = Visibility.Collapsed;
                }
                button_block.Visibility = vis;
                button_reserve.Visibility = vis;
                button_cancelReserve.Visibility = vis;
                button_cancelAuthorise.Visibility = vis;
                button_pause.Visibility = vis;
                button_resume.Visibility = vis;
                button_stop.Visibility = vis;
                button_prepay.Visibility = vis;
                button_authorise.Visibility = vis;
                button_authorise_limits.Visibility = vis;
            }
        }

        
        bool TestSelectedPump()
        {
            // Check a pump is selected
            if (_CurrentSelectedPump == null)
            {
                MessageBox.Show("Please select a pump");
                return false;
            }
            return true;
        }

        #region Pump Control button click events

        private void button_reserve_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;

            ReserveDialog dlg = new ReserveDialog();
            dlg.Owner = this;
            
            dlg.clearIfZero = _ReserveClearIfZero;  // persisted

            dlg.ShowDialog();

            // if cancelled , cancel reserve & exit
            if (dlg.DialogResult == false)
            {
                return;
            }

            _ReserveClientRef = dlg.clientReference;  // save it for Authorise

            try
            {
                _CurrentSelectedPump.Reserve(dlg.clientActivity, dlg.clientReference, dlg.clearIfZero );
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }

        private void button_cancelReserve_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;

            try
            {
                // First make sure not a unpaid Prepay item in sales list
                // if it is then void item which will cancel reserve
                if (_CurrentSale.VoidPrePayItem(_CurrentSelectedPump.CurrentTransaction) == false)
                {
                    // Not unpaid prepay so just cancel reserve
                    _CurrentSelectedPump.CancelReserve();
                }
 
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }

        private void button_authorise_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;

            try
            {
                // Ignore Auth if prepays present
                if (_CurrentSale.ContainsPrepayItems() ) return;

                _CurrentSelectedPump.Authorise("Postpay", _ReserveClientRef, -1,  new PumpAuthoriseLimits());
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }

            _ReserveClientRef = "";
        }

        private void button_cancelAuthorise_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;

            try
            {
                _CurrentSelectedPump.CancelAuthorise();
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }

        private void button_pause_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;
            try
            {
                _CurrentSelectedPump.Pause();
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }


        private void button_stop_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;
            try
            {
                _CurrentSelectedPump.Stop();
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }


        private void button_resume_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;
            try
            {
                _CurrentSelectedPump.Resume();
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }


        private void button_block_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;

            try
            {
                // Toggle block
                _CurrentSelectedPump.SetBlock(!_CurrentSelectedPump.IsBlocked, "");
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }

        }

        /// <summary>
        /// Here we implement the prepay logic.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_prepay_Click(object sender, RoutedEventArgs e)
        {
            // Check a pump is selected
            if (!TestSelectedPump()) return;

            if (_CurrentSelectedPump.State != PumpState.Locked)
            {
                MessageBox.Show("Please select a valid pump");
                return;
            }

            // Reserve pump 
            try
            {
                _CurrentSelectedPump.Reserve(Activity_Prepay, _MyTransRef.ToString(), false);

                DoShowPrepayDialog(_CurrentSelectedPump, Activity_Prepay);
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }

        /// <summary>
        /// Show the Prepay dialog
        /// </summary>
        /// <param name="thePump">The pup object to reserve a prepay</param>
        /// <param name="activity">Client activity</param>
        private void DoShowPrepayDialog( Pump thePump, string activity )
        {
            try
            {
                PumpAuthoriseLimits AuthData = new PumpAuthoriseLimits();

                // Show prepay form
                _prePayDlg = new PrePayDialog(ref AuthData, thePump);
                _prePayDlg.Owner = this;

                _prePayDlg.ShowDialog();

                Transaction trans = thePump.CurrentTransaction;

                // If no longer a transaction then just end
                // Reserve timed out
                if (trans == null)
                {
                    return;
                }

                // if cancelled , cancel reserve & exit
                if (_prePayDlg.DialogResult == false)
                {
                    // we could get an error if the reserve timed out afer returning from dialog
                    try
                    {
                        thePump.CancelReserve();
                    }
                    catch(Exception){};

                    return;
                }

                // Set the Activity with the value so we can recover if connection or we are restarted
                trans.SetClientActivity(activity + "," + AuthData.Value.ToString());

                // Add Prepay item to Sale
                // when it is paid the transaction will be authorised
                string saleDescription = activity == Activity_Prepay ?
                    String.Format("Prepay pump:{0}", thePump.Number) :
                    String.Format("Legacy Prepay pump:{0}", thePump.Number);

                _CurrentSale.AddPrepayItem(
                    saleDescription,
                    trans,
                    AuthData
                    );
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
            finally
            {
                _prePayDlg = null;
            }
        }

        private void button_authorise_limits_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;

            // Ignore Auth if prepays present
            if (_CurrentSale.ContainsPrepayItems() ) return;

            // Show Authorise dialog
            PumpAuthoriseLimits AuthData = new PumpAuthoriseLimits();

            AuthoriseDialog dlg = new AuthoriseDialog(AuthData, _CurrentSelectedPump, "Preset", _ReserveClientRef );
            dlg.Owner = this;
 
            dlg.ShowDialog();

            // if cancelled , cancel reserve & exit
            if (dlg.DialogResult == false)
            {
                return;
            }

            try
            {
                _CurrentSelectedPump.Authorise(
                    dlg.clientActivity,
                    dlg.clientReference,
                    dlg.AttendantId,
                    AuthData
                    );
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }

            _ReserveClientRef = "";
        }


        private void button_showTransactions_Click(object sender, RoutedEventArgs e)
        {
            if (!TestSelectedPump()) return;

            ShowTransactionList(_CurrentSelectedPump);
        }

        void ShowTransactionList(Pump pump)
        {
            // Close any PumpTransactionDialog windows already open (should only be one)
            PumpTransacionDialog Dlg;

            do
            {
                Dlg = FindOwnedWindow("", typeof(PumpTransacionDialog)) as PumpTransacionDialog;
                if ( Dlg != null )
                    Dlg.Close();
            }
            while (Dlg != null);

            // create new one for the current pump
            Dlg = new PumpTransacionDialog(_TransactionStackSettings, pump, _CurrentSale);
            Dlg.Owner = this;
            Dlg.Show();
            Dlg.Focus();

        }

        /// <summary>
        /// Look for owned window of passed type with title ending in passed TitleEnd
        /// </summary>
        /// <param name="TitleEnd">End of title to find.</param>
        /// <param name="WinType">Window type to find.</param>
        /// <returns></returns>
        Window FindOwnedWindow(string TitleEnd, Type WinType)
        {
            foreach (Window ownedWindow in this.OwnedWindows)
            {
                if (ownedWindow.GetType() == WinType)
                {
                    // check the title matches - TitleEnd blank matches anything
                    if ( TitleEnd == "" )
                        return ownedWindow;
                    else if (ownedWindow.Title.EndsWith(TitleEnd))
                        return ownedWindow;
                }
            }

            return null;
        }

        #endregion

        #region Transaction buttons click events
        /// <summary>
        /// Stack the current transaction
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_stack_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                _CurrentSelectedPump.StackCurrentTransaction();
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }

        /// <summary>
        /// Move the current transaction to sale window
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_tosale_Click(object sender, RoutedEventArgs e)
        {
            _CurrentSale.AddFuelTransaction(_CurrentSelectedPump.CurrentTransaction);
        }

        /// <summary>
        /// Clear transaction as a Drive off 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_driveOff_Click(object sender, RoutedEventArgs e)
        {
            ClearCurrentTransaction(TransactionClearTypes.DriveOff);
        }

        /// <summary>
        /// Clear the transaction as Test Delivery
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_testDelivery_Click(object sender, RoutedEventArgs e)
        {
            ClearCurrentTransaction(TransactionClearTypes.Test);
        }

        private void button_manual_Click(object sender, RoutedEventArgs e)
        {

            ManualTransactionDialog Dlg = new ManualTransactionDialog(this, _CurrentSelectedPump);
            Dlg.Owner = this;

            Dlg.ShowDialog();
        }


        #endregion

        #region Forecourt buttons click events
        private void button_AuthoriseAll_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Authorise all pumps that are calling
                foreach (Pump pump in _Forecourt.Pumps)
                {
                    if (pump.State == PumpState.Calling)
                    {
                        pump.AuthoriseNoLimits("AllAuthorise", "", -1);
                    }
                }
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }

        private void button_emergencyStop_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                _Forecourt.Stop();
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }

        }

        private void button_pumpLights_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Toggle Forecourt pump lights
                _Forecourt.SetPumpLightsOn( !_Forecourt.PumpLightsOn );

            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }

        }

        private void button_broadcast_Click(object sender, RoutedEventArgs e)
        {
            SendMessage dlg = new SendMessage();
            dlg.NotificationID = 1;
            dlg.TerminalID = -1;
            dlg.Message = "Hello clients";
            dlg.Owner = this;

            dlg.ShowDialog();

            if (dlg.DialogResult == true)
            {
                try
                {
                    _Forecourt.BroadcastMessage(dlg.TerminalID, dlg.NotificationID, dlg.Message, 100);
                }
                catch (EnablerException)
                {
                    MessageBox.Show("Terminal did not acknowledge receipt of message");
                }
            }
        }

        #endregion
 
        #region Payment button click events

        private void button_payment_Click(object sender, RoutedEventArgs e)
        {
            // Process sale
            _CurrentSale.Payment();
            UpdateWindow();

        }

        private void button_payment_clear_Click(object sender, RoutedEventArgs e)
        {
            _CurrentSale.Clear();
            UpdateWindow();
        }

        private void button_void_item_Click(object sender, RoutedEventArgs e)
        {
            for (int Index = GridView_Journal.SelectedItems.Count - 1; Index >= 0; Index--)
            {
                SaleItem si = GridView_Journal.SelectedItems[Index] as SaleItem;
                _CurrentSale.VoidItem(si);
            }

            UpdateWindow();
        }



        private void GridView_Journal_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            ListView Lv = sender as ListView;

            button_void_item.IsEnabled = (Lv.Items.Count > 0);
        }


        #endregion



        /// <summary>
        /// Lock and Clear a transaction using specified type
        /// </summary>
        /// <param name="type"></param>
        private void ClearCurrentTransaction(TransactionClearTypes type)
        {
            try
            {
                // We need to get a lock before we can do anything
                _CurrentSelectedPump.CurrentTransaction.GetLock();

                _CurrentSelectedPump.CurrentTransaction.Clear(type);
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }



        #region Menu Item handlers

        private void MenuItem_Logoff_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                _logonData.AutoConnect = false;
                _Forecourt.Disconnect("Bye");

                ShowLogonPanel();
            }
            catch (EnablerException EE)
            {
                ShowEnablerError(EE);
            }
        }

        private void MenuItem_Pump_Control_style_Click(object sender, RoutedEventArgs e)
        {
            PumpControlSettingsDialog dlg = new PumpControlSettingsDialog(ref _PumpControlSettings);
            dlg.Owner = this;

            dlg.ShowDialog();

            if (dlg.DialogResult == true)
            {
                InitialisePumpControls();
            }
        }

        private void MenuItem_Tank_Control_style_Click(object sender, RoutedEventArgs e)
        {
            TankControlSettingsDialog dlg = new TankControlSettingsDialog(_TankSettings);
            dlg.Owner = this;

            dlg.ShowDialog();
            if (dlg.DialogResult == true)
            {
                InitialiseTankControls();
            }
        }

        private void MenuItem_Transaction_Control_style_Click(object sender, RoutedEventArgs e)
        {
            PumpTransactionSettingsDialog dlg = new PumpTransactionSettingsDialog(_TransactionStackSettings);
            
            dlg.Owner = this;

            dlg.ShowDialog();
        }

        private void MenuItem_Logging_Click(object sender, RoutedEventArgs e)
        {

            // Check if window showing already
            LogDialog Dlg = FindOwnedWindow("", typeof(LogDialog)) as LogDialog;
            if (Dlg == null)
            {
                // No create new one
                Dlg = new LogDialog(_Forecourt);
                Dlg.Owner = this;
            }

            Dlg.Show();
            //Dlg.Focus();

            Dlg.Activate();
        }


        private void MenuItem_About_Click(object sender, RoutedEventArgs e)
        {
            AboutDialog dlg = new AboutDialog();
            dlg.Owner = this;

            dlg.ShowDialog();
        }

        
        #endregion


        private void button_lookup_Click(object sender, RoutedEventArgs e)
        {
            LookupTransactionDialog dlg = new LookupTransactionDialog(_Forecourt);
            dlg.Owner = this;

            dlg.ShowDialog();
            if (dlg.DialogResult == true)
            {
                TransactionDetailsDialog transDlg = new TransactionDetailsDialog(dlg.GetTransaction);
                transDlg.Owner = this;
                transDlg.ShowDialog();
            }
        }

        private void button_grade_pricing_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                GradePricingDialog dlg = new GradePricingDialog(_Forecourt);
                dlg.Owner = this;

                dlg.ShowDialog();
            }
            catch (Exception) { }
                
        }

        private void button_Atttendants_Click(object sender, RoutedEventArgs e)
        {
            if (ApiVersion < new Version(1, 0, 15))
            {
                MessageBox.Show("Attendants dialog only supported on API version 1,0,15 or greater");
                return;
            }

            if (_Forecourt.Attendants.Count == 0)
            {
                MessageBox.Show("No Attendants configured");
                return;
            }

            AttendantsDialog dlg = new AttendantsDialog(_Forecourt);
            dlg.Owner = this;

            dlg.ShowDialog();
        }

        private void button_tanks_Click(object sender, RoutedEventArgs e)
        {
            TanksDialog dlg = new TanksDialog(_Forecourt);
            dlg.Owner = this;

            dlg.Show();
        }

        private void button_terminals_Click(object sender, RoutedEventArgs e)
        {
            TerminalsDialog dlg = new TerminalsDialog(_Forecourt);
            dlg.Owner = this;

            dlg.Show();
        }

        private void MenuItem_Exit_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Window_Closed(object sender, EventArgs e)
        {
            SaveApplicationSettings();
        }

        private void SaveApplicationSettings()
        {
            RegistryKey currentUser = RegistryKey.OpenRemoteBaseKey(RegistryHive.CurrentUser, "");
            RegistryKey pumpDemoWPFKeys = currentUser.CreateSubKey(MyRegistryKey, RegistryKeyPermissionCheck.ReadWriteSubTree);

            // Location on Screen and size
            double height = this.Height;
            double width = this.Width;
            double left = this.Left;
            double top = this.Top;

            // Save current window size and position    
            pumpDemoWPFKeys.SetValue("Top", top);
            pumpDemoWPFKeys.SetValue("Left", left);
            pumpDemoWPFKeys.SetValue("Height", height);
            pumpDemoWPFKeys.SetValue("Width", width);

            pumpDemoWPFKeys.SetValue("Clear If Zero", _ReserveClearIfZero );

            _PumpControlSettings.Save(pumpDemoWPFKeys);

            _TankSettings.Save(pumpDemoWPFKeys);

            _TransactionStackSettings.Save(pumpDemoWPFKeys);
        }

        private void LoadApplicationSettings()
        {
            try
            {
                RegistryKey currentUser = RegistryKey.OpenRemoteBaseKey(RegistryHive.CurrentUser, "");
                RegistryKey pumpDemoWPFKeys = currentUser.CreateSubKey(MyRegistryKey, RegistryKeyPermissionCheck.ReadSubTree);

                double height = Convert.ToDouble(pumpDemoWPFKeys.GetValue("Height"));
                double width = Convert.ToDouble(pumpDemoWPFKeys.GetValue("Width"));
                double left = Convert.ToDouble(pumpDemoWPFKeys.GetValue("Left"));
                double top = Convert.ToDouble(pumpDemoWPFKeys.GetValue("Top"));

                // Do a range check
                if (top < 0) top = 0;
                if (height < 400) height = DefaultHeight;
                if (width < 400) width = DefaultWidth;

                this.Top = top;
                this.Left = left;
                this.Width = width;
                this.Height = height;

                _ReserveClearIfZero = Convert.ToBoolean(pumpDemoWPFKeys.GetValue("Clear If Zero", true));

                _PumpControlSettings.Load(pumpDemoWPFKeys);

                _TankSettings.Load(pumpDemoWPFKeys);

                _TransactionStackSettings.Load(pumpDemoWPFKeys);

            }
            catch (Exception Ex) {
                Debug.WriteLine("Exception:" + Ex.Message);
            };

        }


        void StartAnimation(String StoryboardName)
        {
            Storyboard CurrentStoryBoard;

            try
            {
                CurrentStoryBoard = this.FindResource(StoryboardName) as Storyboard;
                CurrentStoryBoard.Begin(this, false);
            }
            catch (Exception Ex)
            {
                MessageBox.Show("Error:" + Ex.Message);
            }
        }

        private void button_payment_attendant(object sender, RoutedEventArgs e)
        {
            if (_Forecourt.Attendants.Count == 0)
            {
                MessageBox.Show("No Attendants configured");
                return;
            }

            AttendantPayDialog attPayDlg = new AttendantPayDialog(_Forecourt, _CurrentSale);
            attPayDlg.AttendantPayComplete += new EventHandler(attPayDlg_AttendantPayComplete);

            attPayDlg.Owner = this;

            attPayDlg.ShowDialog();
        }

        void attPayDlg_AttendantPayComplete(object sender, EventArgs e)
        {
            UpdateWindow();
        }
    }
}
