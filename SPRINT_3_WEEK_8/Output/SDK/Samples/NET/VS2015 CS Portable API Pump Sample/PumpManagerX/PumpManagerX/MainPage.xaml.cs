/*****************************************************************
 *
 * Implementation of PumpManagerX::MainPage Class
 *
 * Copyright (C) 2017 Integration Technologies Limited
 * All rights reserved.
 *
 * Created 01/06/2011
 * 
 ******************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;
using ITL.Enabler.API;
using System.Diagnostics;

namespace PumpManagerX
{

#if __ANDROID__ || __IOS__
    public class PumpManagerXTracer : TraceListener
    {
        public PumpManagerXTracer() { }

        public override void Write(string message)
        {
            Console.WriteLine("AppTracer:" + message);
        }

        public override void WriteLine(string message)
        {
            Console.WriteLine("AppTracer:" + message);
        }
    }
#endif

    public partial class MainPage : ContentPage
    {
        public Forecourt theForecourtConnection;
        private int count = 0;

        public MainPage()
        {
            InitializeComponent();

#if __ANDROID__ || __IOS__
            Trace.Listeners.Add(new PumpManagerXTracer());
#endif        
            theForecourtConnection = new ITL.Enabler.API.Forecourt();
            theForecourtConnection.OnServerEvent += new EventHandler(_Forecourt_OnServerEvent);
            theForecourtConnection.OnStatusChange += new EventHandler<ForecourtStatusEventArgs>(_Forecourt_OnStatusChange);
            theForecourtConnection.OnConnectAsyncResult += new EventHandler<ConnectCompletedEventArgs>(_Forecourt_OnConnectAsyncResult);

            string thePlatform =
#if __ANDROID__
            "(Android)";
#else
#if __IOS__
             "(iOS)";
#else
             "(Windows)";
#endif
#endif
            this.TitleLabel.Text = this.TitleLabel.Text + thePlatform;
        }

        #region Event Handlers
        void _Forecourt_OnServerEvent(object sender, EventArgs e)
        {
            Xamarin.Forms.Device.BeginInvokeOnMainThread(() =>
            {
                count++;
                SetEventsText(e.ToString());
                SetConnectButtonText();
            });

        }

        void _Forecourt_OnStatusChange(object sender, ForecourtStatusEventArgs e)
        {
            Xamarin.Forms.Device.BeginInvokeOnMainThread(() =>
            {
                count++;
                SetEventsText(e.ToString());
            });

        }

        void _Forecourt_OnConnectAsyncResult(object sender, ConnectCompletedEventArgs e)
        {
            Xamarin.Forms.Device.BeginInvokeOnMainThread(() =>
            {
                SetConnectButtonText();
                if (theForecourtConnection.IsConnected)
                {
                    foreach (Pump p in theForecourtConnection.Pumps)
                    {
                        p.OnStatusChange += new EventHandler<PumpStatusEventArgs>(_Pump_OnStatusChange);
                        p.OnTransactionEvent += new EventHandler<PumpTransactionEventArgs>(_Pump_OnTransactionEvent);
                    }
                }

            });

        }

        void _Pump_OnTransactionEvent(object sender, PumpTransactionEventArgs e)
        {
            Pump thePump = (Pump)sender;
            Xamarin.Forms.Device.BeginInvokeOnMainThread(() =>
            {
                thePump = GetPumpObject();
                SetButtonsText(thePump);
                SetPumpImage(thePump);
                if ( thePump != null )
                    SetEventsText("Pump:" + thePump.Number + " eventType:" + e.EventType.ToString() + "State: " + thePump.State.ToString());
            });
        }

        void _Pump_OnStatusChange(object sender, PumpStatusEventArgs e)
        {
            Pump thePump = (Pump)sender;
            Xamarin.Forms.Device.BeginInvokeOnMainThread(() =>
            {
                thePump = GetPumpObject();
                SetButtonsText(thePump);
                SetPumpImage(thePump);
                if ( thePump!= null )
                    SetEventsText("Pump:" + thePump.Number + " eventType:" + e.EventType.ToString() + "State: " + thePump.State.ToString());
            });
        }
        #endregion

        #region UI Update
        public void InvokeUIThreadForResultsText(string message)
        {
            Xamarin.Forms.Device.BeginInvokeOnMainThread(() =>
            {
                SetResultsText(message);
            });
        }

        public void SetEventsText(string message)
        {
            this.EventsLabel.Text = string.Format("Event({0}):{1}", count, message);
        }

        public void SetResultsText(string message)
        {
            this.ResultsLabel.Text = string.Format("LastResult:{0}",message);
        }

        public void SetConnectButtonText()
        {
            if (theForecourtConnection.IsConnected)
            {
                this.ConnectButton.Text = "Disconnect";
                // Force to first pump on Connect
                this.PumpSlider.Value = 1;
                SetPumpImage(theForecourtConnection.Pumps[1]);
            }
            else
            {
                this.ConnectButton.Text = "Connect";
                SetPumpImage(null);
                SetButtonsText(null);
            }
        }

        public void SetPumpImage(Pump thePump)
        {
            if (theForecourtConnection.IsConnected == false || thePump == null)
            {
                this.PumpImage.Source = "logo.png";
                return;
            }

            switch (thePump.State)
            {
                case PumpState.Authorising:

                case PumpState.DeliveryPaused:
                case PumpState.DeliveryStopped:
                case PumpState.Delivering: this.PumpImage.Source = "deliverying.png"; break;

                case PumpState.Calling: this.PumpImage.Source = "calling1.png"; break;

                case PumpState.NotInstalled:
                case PumpState.NotAllowed:
                case PumpState.PumpError:
                case PumpState.NotResponding: this.PumpImage.Source = "error.png"; break;
                
                case PumpState.DeliveryFinished:
                case PumpState.Busy: this.PumpImage.Source = "pumpbusy.png"; break;
                default:
                    {
                        Transaction theTransaction = thePump.CurrentTransaction;
                        if (thePump.IsBlocked)
                            this.PumpImage.Source = "nozzledisabled.png";
                        else
                        // Pump idle with an authorised transaction?
                        if (thePump.State == PumpState.Locked && 
                            theTransaction != null &&
                            theTransaction.State == TransactionState.Authorised )
                            this.PumpImage.Source = "authed.png";
                        else
                        // All other states default to an idle pump
                            this.PumpImage.Source = "nozzle.png";
                    }
                    break;
            }
        }

        public void SetButtonsText(Pump thePump)
        {
            if (thePump == null)
            {
                this.AuthoriseButton.Text = "Authorise";
                this.ReserveButton.Text = "Reserve";
                this.PauseButton.Text = "Pause";
                this.BlockButton.Text = "Block";
                return;
            }

            if (thePump.IsBlocked)
                this.BlockButton.Text = "UnBlock";
            else
                this.BlockButton.Text = "Block";

            if (thePump.State == PumpState.DeliveryPaused)
                this.PauseButton.Text = "Resume";
            else
                this.PauseButton.Text = "Pause";

            Transaction theTransaction = thePump.CurrentTransaction;
            if (theTransaction != null && theTransaction.State == TransactionState.Reserved)
                this.ReserveButton.Text = "Cancel Reserve";
            else
                this.ReserveButton.Text = "Reserve";

            if (theTransaction != null && theTransaction.State == TransactionState.Authorised)
                this.AuthoriseButton.Text = "Cancel Authorise";
            else
                this.AuthoriseButton.Text = "Authorise";

        }
        #endregion

        #region UI Handlers
        public Task Connect()
        {
            return Task.Run(() =>
            {
                try
                {
                    theForecourtConnection.ConnectAsync(this.ServerText.Text.Trim(), Convert.ToInt32(this.Terminal.Text.Trim()), "", this.PasswordText.Text.Trim(), true);
                }
                catch (EnablerException e)
                {
                    InvokeUIThreadForResultsText(theForecourtConnection.ResultString(e.ResultCode));
                }
            });
        }

        public Task Disconnect()
        {
            return Task.Run(() =>
            {
                try
                {
                    theForecourtConnection.Disconnect("ta!");
                }
                catch (EnablerException e)
                {
                    InvokeUIThreadForResultsText(theForecourtConnection.ResultString(e.ResultCode));
                }
            });
        }

        Pump GetPumpObject()
        {
            int rounded = (int)Math.Round(PumpSlider.Value);
            int number = int.Parse(rounded.ToString());
            Pump p = theForecourtConnection.Pumps[number];
            return p;
        }

        async void OnSliderChanged(object sender, EventArgs args)
        {
            await Task.Run(() =>
            {
                Xamarin.Forms.Device.BeginInvokeOnMainThread(() =>
                {
                    Pump  thePump= GetPumpObject();
                    SetPumpImage(thePump);
                    SetButtonsText(thePump);
                });
            });
        }

        async void OnAuthoriseClicked(object sender, EventArgs args)
        {
            await Task.Run(() =>
            {
                try
                {
                    Pump thePump = GetPumpObject();
                    if (thePump == null)
                        return;
                    Transaction t = thePump.CurrentTransaction;
                    if (t != null && t.State == TransactionState.Authorised)
                        thePump.CancelAuthorise();
                    else
                        thePump.Authorise(null, null, -1, new PumpAuthoriseLimits());
                }
                catch (EnablerException e)
                {
                    InvokeUIThreadForResultsText(theForecourtConnection.ResultString(e.ResultCode));
                }
            });

        }

        async void OnStopClicked(object sender, EventArgs args)
        {
            await Task.Run(() =>
            {
                try
                {
                    Pump thePump = GetPumpObject();
                    if (thePump == null)
                        return;
                    thePump.Stop();
                }
                catch (EnablerException e)
                {
                    InvokeUIThreadForResultsText(theForecourtConnection.ResultString(e.ResultCode));
                }
            });
        }

        async void OnReserveClicked(object sender, EventArgs args)
        {
            await Task.Run(() =>
            {
                try
                {
                    Pump thePump = GetPumpObject();
                    if (thePump == null)
                        return;

                    Transaction t = thePump.CurrentTransaction;
                    if (t != null && t.State == TransactionState.Reserved)
                        thePump.CancelReserve();
                    else
                        thePump.Reserve("", "", true);
                }
                catch (EnablerException e)
                {
                    InvokeUIThreadForResultsText(theForecourtConnection.ResultString(e.ResultCode));
                }
            });
        }

        async void OnPauseClicked(object sender, EventArgs args)
        {
            await Task.Run(() =>
            {
                try
                {
                    Pump thePump = GetPumpObject();
                    if (thePump == null)
                        return;

                    if (thePump.State == PumpState.DeliveryPaused)
                        thePump.Resume();
                    else
                        thePump.Pause();
                }
                catch (EnablerException e)
                {
                    InvokeUIThreadForResultsText(theForecourtConnection.ResultString(e.ResultCode));
                }
            });
        }

        async void OnBlockCliked(object sender, EventArgs args)
        {
            await Task.Run(() =>
            {
                try
                {
                    Pump thePump = GetPumpObject();
                    if (thePump == null)
                        return;
                    if (thePump.IsBlocked)
                        thePump.SetBlock(false, "Unblock");
                    else
                        thePump.SetBlock(true, "Stop!");
                }
                catch (EnablerException e)
                {
                    InvokeUIThreadForResultsText(theForecourtConnection.ResultString(e.ResultCode));
                }
            });
        }

        async void OnConnectClicked(object sender, EventArgs args)
        {
            Button button = (Button)sender;
            await DisplayAlert("Connect!", string.Format("Connecting to Enabler Server:{0} Terminal:{1}...",
                this.ServerText.Text.Trim(),
                this.Terminal.Text.Trim()), "OK");

            if (theForecourtConnection.IsConnected == false)
                Connect();
            else
                Disconnect();
        }

        async void OnDisconnectClicked(object sender, EventArgs args)
        {
            Button button = (Button)sender;
            await DisplayAlert("Disconnect!", string.Format("Disconnecting from Enabler Server:{0}...", this.ServerText.Text.Trim()),"OK");
        }
        #endregion
    }
}
