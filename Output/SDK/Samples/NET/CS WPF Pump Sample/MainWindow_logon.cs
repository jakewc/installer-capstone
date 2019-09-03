using System;
using System.Collections.Generic;
using System.IO;
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

using System.Diagnostics;

using ITL.Enabler.API;
using ITL.Enabler.WPFControls;

namespace ITL.Enabler.Samples
{
    public partial class MainWindow : Window
    {
        bool _ConnectRunning = false;
        Timer _MyAutoConnectTimer;

        void ShowLogonPanel()
        {
            if (_ConnectRunning) return;

            if (_Forecourt.IsConnected == false)
            {
                // Initialise panel fields
                button_logon.IsEnabled = true;

                textbox_server.Text = _logonData.Server;
                textbox_terminalid.Text = _logonData.TerminalID.ToString();

                if (_logonData.AutoConnect)
                    textbox_password.Password = _logonData.Password;
                else
                {
                    Focus_password();
                }

                checkBox_secure.IsChecked = _logonData.UseSSL;
                checkBox_active.IsChecked = _logonData.Active;
                checkBox_autoConnect.IsChecked = _logonData.AutoConnect;
                MenuItem_Logoff.IsEnabled = false;

                update_status("Logon");
                button_cancel.Visibility = Visibility.Hidden;
                LogonPanel.Visibility = Visibility.Visible;

                // Start animation to show logon panel
                // When animation completed will call "logon_Storyboard_Completed", used when auto connect is set
                StartAnimation("open_logon");
            }
        }

        void logon_Storyboard_Completed(object sender, EventArgs e)
        {
            // If Auto Connect set then automatcially try to reconnect
            if (_logonData.AutoConnect
                    && !Keyboard.IsKeyDown(Key.LeftShift)
                    && !Keyboard.IsKeyDown(Key.RightShift)
                )
            {
                pump_server_connect();
            }
        }

        /// <summary>
        /// Called every 1 sec for auto connecting
        /// </summary>
        /// <param name="state"></param>
        void AutoConnectTimerCallback(object state)
        {
            if (_Forecourt.IsConnected == false && _logonData.AutoConnect == true)
            {
                // Run on GUI thread
                this.Dispatcher.BeginInvoke((Action)(() =>
                {
                    pump_server_connect();
                }
                ));
            }
        }

        private void Focus_password()
        {
            textbox_password.Password = "";
            textbox_password.Focus();
        }

        private void update_status(string statusText)
        {
            logon_status.Content = "Status: "+ statusText;
        }


        private void button_logon_Click(object sender, RoutedEventArgs e)
        {
            if (textbox_password.Password.Length > 0)
                pump_server_connect();
            else
            {
                update_status("Missing password");
                Focus_password();
            }
        }

        private void button_logon_Cancel(object sender, RoutedEventArgs e)
        {
            button_cancel.Visibility = Visibility.Hidden;

            _logonData.AutoConnect = false;
            checkBox_autoConnect.IsChecked = _logonData.AutoConnect;
            button_logon.IsEnabled = true;
            update_status("Auto Connect cancelled");
            Focus_password();
        }

        private void pump_server_connect()
        {
            button_logon.IsEnabled = false;

            if (_logonData.AutoConnect == true)
            {
                button_cancel.Visibility = Visibility.Visible;
            }

            // Get logon data from text boxes
            _logonData.Server = textbox_server.Text;
            _logonData.Password = textbox_password.Password;
            _logonData.AutoConnect = (bool)checkBox_autoConnect.IsChecked;

            int Termid = -1;
            Int32.TryParse(textbox_terminalid.Text, out Termid);
            _logonData.TerminalID = Termid;

            _logonData.Active = (bool)checkBox_active.IsChecked;
            _logonData.UseSSL = (bool)checkBox_secure.IsChecked;

            
            // Start Asynchronous connect
            if (AsyncConnect(_logonData.Server, _logonData.TerminalID, _logonData.Password, _logonData.Active, _logonData.AutoConnect) == true)
            {
                this.Title = string.Format("WPF Pump demo {0} - {1}", _logonData.TerminalID, _Forecourt.ServerInformation.ServerVersion);

                MenuItem_Logoff.IsEnabled = true;

                update_status(_logonData.AutoConnect ? "Auto Connecting...." : "Connecting....");
            }
            else
            {
                // Failed allow a new logon
                update_status("Connect failed");
            }

            _logonData.SaveConnectSettings();
        }

        void pump_server_connect_ok()
        {
            this.Title = string.Format("WPF Pump demo {0} - {1}", _logonData.TerminalID, _Forecourt.ServerInformation.ServerVersion);
            update_status("Connected");

            // Remove timer if used (AutoConnect)
            if (_MyAutoConnectTimer != null)
            {
                _MyAutoConnectTimer.Dispose();
                _MyAutoConnectTimer = null;
            }

            LogonPanel.Visibility = Visibility.Collapsed;

            Connected();

            _ConnectRunning = false;
        }

        void pump_server_connect_failed(ApiResult result)
        {
            // If auto connect then start retry timer if not already running
            if (_logonData.AutoConnect)
            {
                // If not started, start timer 
                _MyAutoConnectTimer = new Timer(AutoConnectTimerCallback, true, 2000, Timeout.Infinite);
            }
            else
            {
                button_logon.IsEnabled = true;
                update_status("Logon failed");
                ShowEnablerError(this, result);
                _ConnectRunning = false;
                Focus_password();
            }
        }

        // Pick up result of Async connect and call ok or failed methods on GUI thread
        void _Forecourt_OnConnectAsyncResult(object sender, ConnectCompletedEventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                // Are connected ok ?
                if (e.ConnectResult == ApiResult.Ok)
                {
                    pump_server_connect_ok();
                }
                else
                {
                    pump_server_connect_failed(e.ConnectResult);
                }
            }
            ));
        }

     
        /// <summary>
        /// Async Connect to server
        /// </summary>
        /// <param name="server">IP or Name of server</param>
        /// <param name="terminalID">Terminal ID</param>
        /// <param name="password">Password for terminal ID</param>
        /// <param name="active">Active connection true, false</param>
        /// <param name="auto">Auto connect, don't show error message</param>
        /// <returns>Return true if async connect started</returns>
        bool AsyncConnect(string server, int terminalID, string password, bool active, bool auto)
        {
            bool result = false;

            _ConnectRunning = true;

            try
            {
                _Forecourt.ConnectionMode = _logonData.UseSSL ? SecurityMode.OnlySecure : _Forecourt.ConnectionMode;
                _Forecourt.ConnectAsync(server, terminalID, "Pump Demo", password, active);
                result = true;
            }
            catch (EnablerException EE)
            {
                if (!auto) ShowEnablerError(EE);
            }
            return result;
        }

    }
}
