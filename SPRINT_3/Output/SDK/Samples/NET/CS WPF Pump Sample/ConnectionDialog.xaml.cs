using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Threading;

using ITL.Enabler.API;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Dialog to 
    /// </summary>
    public partial class ConnectionDialog : Window
    {
        Forecourt _Forecourt;
        string  _Server;
        int  _TerminalID;
        string _Password;
        bool _Active;

        bool _Reconnect;
        bool _Cancel;
        Timer _MyTimer;

        public ConnectionDialog(Forecourt ForeCourt, string Server, int  TerminalID, string Password, bool Active )
        {
            _Forecourt = ForeCourt;
            _Server = Server;
            _TerminalID = TerminalID;
            _Password = Password;
            _Active = Active;

            _MyTimer = new Timer(TimerCallback, true, 1000, 1000);
            
            InitializeComponent();

            }

        ~ConnectionDialog()
        {

        }

        /// <summary>
        /// Called every 1 sec
        /// </summary>
        /// <param name="state"></param>
        void TimerCallback(object state)
        {
            if (_Reconnect)
            {
                // Run on GUI thread
                this.Dispatcher.BeginInvoke((Action)(() =>
                {
                    _Reconnect = false;
                    Connect();
                }
                ));
            }
        }

        void _Forecourt_OnConnectAsyncResult(object sender, ConnectCompletedEventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                // Are connected ok ?
                if (e.ConnectResult == ApiResult.Ok)
                {
                    UnLink();
                    DialogResult = true;
                    Close();
                }
                else
                {
                    if (_Cancel)
                    {
                        UnLink();
                        DialogResult = false;
                        Close();
                    }
                    else
                    {
                        // Set flag for timer to pick up
                        _Reconnect = true;
                    }
                }
            }
            ));
        }

        private void button_cancel_Click(object sender, RoutedEventArgs e)
        {
            _Cancel = true;
            Label_status.Content = string.Format("Cancelling connect.." );

        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            // Start an Asyncronous Connect
            _Forecourt.OnConnectAsyncResult += new EventHandler<ConnectCompletedEventArgs>(_Forecourt_OnConnectAsyncResult);
            Connect();
        }

        private void Connect()
        {
            _Forecourt.ConnectAsync(_Server, _TerminalID, "Pump Demo", _Password, _Active);
        }

        private void UnLink()
        {
            _Forecourt.OnConnectAsyncResult -= _Forecourt_OnConnectAsyncResult;

        }


    }
}
