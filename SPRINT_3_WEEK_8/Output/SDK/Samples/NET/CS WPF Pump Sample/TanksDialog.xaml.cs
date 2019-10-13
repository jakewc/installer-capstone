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
    /// Dialog to show individual tank details.
    /// Shows alarm states.
    /// </summary>
    public partial class TanksDialog : Window
    {
        Forecourt _Forecourt;

        Tank _SelectedTank = null;

        public TanksDialog(Forecourt forecourt)
        {
            _Forecourt = forecourt;

            InitializeComponent();

            this.DataContext = _Forecourt.Tanks;
            comboBox_tanks.SelectedIndex = 0;
        }

        private void comboBox_tanks_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (comboBox_tanks.SelectedItem != null)
            {
                Tank tank = comboBox_tanks.SelectedItem as Tank;

                //Unlink previously selected tank if any
                UnLinkTank();
 
                _SelectedTank = tank;
                _SelectedTank.OnLevelChanged+=new EventHandler(_SelectedTank_OnLevelChanged);
                _SelectedTank.OnGaugeLevelChanged+=new EventHandler(_SelectedTank_OnGaugeLevelChanged);
                _SelectedTank.OnAlarm += new EventHandler<TankAlarmEventArgs>(_SelectedTank_OnAlarm);

                UpdateDetails();
                UpdateAlarms();
            }
        }

        // Remove all events from previously selected tank
        void UnLinkTank()
        {
            if (_SelectedTank != null)
            {
                _SelectedTank.OnGaugeLevelChanged -= _SelectedTank_OnGaugeLevelChanged;
                _SelectedTank.OnLevelChanged -= _SelectedTank_OnLevelChanged;
                _SelectedTank = null;
            }
        }

        void UpdateDetails()
        {
            if (_SelectedTank != null)
            {
                textBox_gaugelevel.Text = _SelectedTank.GaugeReading.Level.ToString("f03");
                textBox_gaugevolume.Text = _SelectedTank.GaugeReading.Volume.ToString("f03");
                textBox_theorectical.Text = _SelectedTank.TheoreticalVolume.ToString("f03");
            }
        }

        void UpdateAlarms()
        {
            if (_SelectedTank != null)
            {   
                int AlarmType = 1;
                foreach( CheckBox check in AlarmGrid.Children )
                {
                    check.Content = ((GaugeAlarmType)AlarmType).ToString();

                    bool NewState = _SelectedTank.GetAlarm(AlarmType);

                    if (check.IsChecked == NewState)
                    {
                        check.Background = Brushes.White;
                    }
                    else
                    {
                        // Highlight new alarms
                        check.IsChecked = NewState;
                        check.Background = Brushes.Red;
                    }

                    AlarmType++;
                }
            }
        }

        void _SelectedTank_OnGaugeLevelChanged(object sender, EventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                UpdateDetails(); 
            }
            ));
        }

        void _SelectedTank_OnLevelChanged(object sender, EventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                UpdateDetails();
            }
            ));
        }

        void _SelectedTank_OnAlarm(object sender, TankAlarmEventArgs e)
        {
            //  Update on GUI thread
            this.Dispatcher.BeginInvoke((Action)(() =>
            {
                UpdateAlarms();
            }
            ));
        }

         private void button_cancel_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void Window_Unloaded(object sender, RoutedEventArgs e)
        {
            UnLinkTank();
        }

        private void button_settheo_Click(object sender, RoutedEventArgs e)
        {
            if (_SelectedTank == null) return;

            try
            {
                decimal volume = decimal.Parse( textBox_theorectical.Text );
                _SelectedTank.SetTheorecticalVolume(volume);
            }
            catch( Exception )
            {
                MessageBox.Show( "Invalid theorectical volume" );
                UpdateDetails(); // fix it
            }

        }

    }
}
