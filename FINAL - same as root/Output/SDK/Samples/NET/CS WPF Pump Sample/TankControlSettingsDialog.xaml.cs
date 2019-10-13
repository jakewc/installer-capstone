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

using ITL.Enabler.WPFControls;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Dialog to enter Tank control settings.
    /// </summary>
    public partial class TankControlSettingsDialog : Window
    {
        TankControlSettings Settings;

        public TankControlSettingsDialog(TankControlSettings settings)
        {
            Settings = settings;

            InitializeComponent();

            Checkbox_show_all_tanks.IsChecked = settings.AllInOne;
            Combox_Loaded.SelectedIndex = (int)Settings.LoadControl;
            Combox_Style.SelectedIndex = (int)settings.Style;
        }

        private void button_ok_Click(object sender, RoutedEventArgs e)
        {
            Settings.LoadControl = (TankControlSettings.Loaded)Combox_Loaded.SelectedIndex;
            Settings.AllInOne = (Checkbox_show_all_tanks.IsChecked == true);
            Settings.Style  = (TankControlStyle)Combox_Style.SelectedIndex;

            this.DialogResult = true;
        }
    }
}
