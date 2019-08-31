using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Reflection;

using ITL.Enabler.API;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Dialog to manage the Attendants.
    /// Logon,Logoff and block Attenants.
    /// Status updated via events.
    /// </summary>
    public partial class AttendantsDialog : Window
    {
        Forecourt _Forecourt;
        Boolean NewAPIVersion = MainWindow.ApiVersion >= new Version("1.0.16.0");

        public AttendantsDialog(Forecourt forecourt)
        {
            _Forecourt = forecourt;

            InitializeComponent();

            GroupBoxPeriod.IsEnabled = NewAPIVersion;
            GroupBoxLogonSite.IsEnabled = GroupBoxPeriod.IsEnabled;

            comboBox_pumps.DataContext = _Forecourt.Pumps;
            comboBox_pumps.SelectedIndex = 0;

            comboBox_attendants.DataContext = _Forecourt.Attendants;
            comboBox_attendants.SelectedIndex = 0;

            if (NewAPIVersion)
            {
                Dictionary<AttendantBlockReasons, String> AttendantBlockReasonList = new Dictionary<AttendantBlockReasons, String>()
                {
                    {AttendantBlockReasons.OnBreak, "On Break"},
                    {AttendantBlockReasons.BlockManual, "Manually Block"},
                };

                com_blockType.ItemsSource = AttendantBlockReasonList;
                com_blockType.DisplayMemberPath = "Value";
                com_blockType.SelectedValuePath = "Key";
                com_blockType.SelectedIndex = 0;
            }
            else
                com_blockType.Visibility = Visibility.Hidden;

            _Forecourt.Attendants.OnLogOn += new EventHandler<AttendantLogOnOffEventArgs>(Attendants_OnLogOn);
            _Forecourt.Attendants.OnLogOff += new EventHandler<AttendantLogOnOffEventArgs>(Attendants_OnLogOff);
            _Forecourt.Attendants.OnStatusChanged += new EventHandler<AttendantStatusEventArgs>(Attendants_OnStatusChanged);
            
            // Previous API version didn't have the attendant period logic, so only enable if available
            try
            {
                _Forecourt.Attendants.OnPeriodStateChange += new EventHandler(Attendants_OnPeriodStateChange);
            }
            catch( Exception )
            {
                GroupBoxPeriod.IsEnabled = false;
            }
        }

         private void Window_Unloaded(object sender, RoutedEventArgs e)
        {
            _Forecourt.Attendants.OnLogOn -= Attendants_OnLogOn;
            _Forecourt.Attendants.OnLogOff -= Attendants_OnLogOff;
            _Forecourt.Attendants.OnStatusChanged -= Attendants_OnStatusChanged;

            if (GroupBoxPeriod.IsEnabled == true)
            {
                _Forecourt.Attendants.OnPeriodStateChange -= Attendants_OnPeriodStateChange;
            }
        }
        
        private void button_logoff_Click(object sender, RoutedEventArgs e)
        {
            Pump pump = GetPump();
            Attendant att = GetAttendant();
            if (att != null && pump != null)
            {
                try
                {
                    att.LogOffPump(pump.Number);
                }
                catch (EnablerException ee)
                {
                    MessageBox.Show("Logoff error :" + Forecourt.GetResultString(ee.ResultCode));
                }
            }
        }

        private void button_logon_Click(object sender, RoutedEventArgs e)
        {
            Pump pump = GetPump();
            Attendant att = GetAttendant();
            if (att != null && pump != null)
            {
                try
                {
                    att.LogOnPump(pump.Number);
                }
                catch (EnablerException ee)
                {
                    MessageBox.Show("Logon error :" + Forecourt.GetResultString(ee.ResultCode));
                }
            }
        }

        private void button_block_Click(object sender, RoutedEventArgs e)
        {
            Pump pump = GetPump();
            Attendant att = GetAttendant();
            //get block reason
            
            if (att != null && pump != null)
            {
                try
                {
                    if (NewAPIVersion)
                    {
                        AttendantBlockReasons reasonCode = (AttendantBlockReasons)com_blockType.SelectedValue;
                        att.SetBlock(true, reasonCode);
                    }
                    else
                    {
                        att.Block(1);
                    }
               
                }
                catch (EnablerException ee)
                {
                    MessageBox.Show("Block error :" + Forecourt.GetResultString(ee.ResultCode));
                }
            }

        }

        private void button_unblock_Click(object sender, RoutedEventArgs e)
        {
            Pump pump = GetPump();
            Attendant att = GetAttendant();

            if (att != null && pump != null)
            {
                try
                {
                    if (NewAPIVersion)
                    {
                        AttendantBlockReasons reasonCode = (AttendantBlockReasons)com_blockType.SelectedValue;
                        att.SetBlock(false, reasonCode);
                    }
                    else
                    {
                        att.Block(0);
                    }
                }
                catch (EnablerException ee)
                {
                    MessageBox.Show("UnBlock error :" + Forecourt.GetResultString(ee.ResultCode));
                }
            }
        }

         private Attendant GetAttendant()
        {
            if (comboBox_attendants.SelectedItem != null)
            {
                return comboBox_attendants.SelectedItem as Attendant;
            }

            return null;
        }

        private Pump GetPump()
        {
            if (comboBox_pumps.SelectedItem != null)
            {
                return comboBox_pumps.SelectedItem as Pump;
            }

            return null;
        }


        private void comboBox_attendants_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            SetBlockStatus();

            SetPeriodState();
        }

        private void SetPeriodState()
        {
            Attendant att = GetAttendant();
            if (att != null)
            {
                textBox_periodstate.Text = att.PeriodState.ToString();
            }
            else
            {
                textBox_periodstate.Text = "";
            }
        }

 
        private void comboBox_pumps_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            SetAttendantStatus();
        }

        private void SetBlockStatus()
        {
            Attendant at = GetAttendant();
            if (at.IsBlocked)
                attendant_status.Content = "Blocked(" + at.BlockReason.ToString() + ")";
            else
                attendant_status.Content = "Not blocked";
        }

        private void SetAttendantStatus()
        {
            Pump pmp = GetPump();
            if (pmp != null)
            {
                Attendant pumpCurrentAttendant = pmp.Attendant;
                if (pumpCurrentAttendant == null)
                {
                    logon_status.Content = "Logged off";
                }
                else
                {
                    logon_status.Content = pumpCurrentAttendant.ToString();
                }
            }
        }

        #region Event_handlers
        void Attendants_OnStatusChanged(object sender, AttendantStatusEventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                switch (e.EventType)
                {
                    case AttendantStatusEventType.Blocked:
                        SetBlockStatus();
                        break;
                }
            }
            ));
        }


        void Attendants_OnPeriodStateChange(object sender, EventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                SetPeriodState();
            }
            ));
        }

        void Attendants_OnLogOff(object sender, AttendantLogOnOffEventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                SetAttendantStatus();
            }
            ));
        }

        void Attendants_OnLogOn(object sender, AttendantLogOnOffEventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                SetAttendantStatus();
            }
            ));
        }

        #endregion

        private void button_logon_forecourt_Click(object sender, RoutedEventArgs e)
        {
            Attendant att = GetAttendant();
            if (att != null)
            {
                int tagid = 0;

                if (!int.TryParse(textBox_tag.Text, out tagid))
                {
                    MessageBox.Show("Invalid tag id");
                    return;
                }

                try
                {
                    att.LogOnForecourt(tagid);
                }
                catch (EnablerException ee)
                {
                    MessageBox.Show("Logon forecourt with tag error :" + Forecourt.GetResultString(ee.ResultCode));
                }
            }
        }

        private void button_logoff_forecourt_Click(object sender, RoutedEventArgs e)
        {
            Attendant att = GetAttendant();
            try
            {
                att.LogOffForecourt();
            }
            catch (EnablerException ee)
            {
                MessageBox.Show("Logoff forecourt error :" + Forecourt.GetResultString(ee.ResultCode));
            }

        }

        private void button_closePeriod_Click(object sender, RoutedEventArgs e)
        {
            Attendant att = GetAttendant();
            if (att != null)
            {
                try
                {
                    att.CloseCurrentPeriod();
                }
                catch (EnablerException ee)
                {
                    MessageBox.Show("Close Period error :" + Forecourt.GetResultString(ee.ResultCode));
                }
            }
        }

        private void button_reconcile_Click(object sender, RoutedEventArgs e)
        {
            Attendant att = GetAttendant();
            if (att != null)
            {
                try
                {
                    att.Reconcile();
                }
                catch (EnablerException ee)
                {
                    MessageBox.Show("Reconcile error :" + Forecourt.GetResultString(ee.ResultCode));
                }
            }
        }
    }
}
