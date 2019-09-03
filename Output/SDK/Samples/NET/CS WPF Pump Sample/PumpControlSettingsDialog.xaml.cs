using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;
using System.Windows.Controls;

using ITL.Enabler.API;
using ITL.Enabler.WPFControls;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Dialog to enter and update the WPF Pump control settings class.
    /// </summary>
    public partial class PumpControlSettingsDialog : Window
    {
        PumpControlSettings _ControlSettings;

        public PumpControlSettingsDialog( ref PumpControlSettings settings)
        {
            _ControlSettings = settings;

            InitializeComponent();

            InitControls();
        }


        void InitControls()
        {
            comboBox_style.Items.Add("None");
            comboBox_style.Items.Add("Small 80x80");
            comboBox_style.Items.Add("Medium 100x100");
            comboBox_style.Items.Add("Large  150x150");
            comboBox_style.SelectedIndex = (int)_ControlSettings.Style;
 
            checkBox_show_grade.IsChecked = _ControlSettings.ShowGradeName;
            checkBox_show_quantity.IsChecked = _ControlSettings.ShowQuantity;
            checkBox_show_value.IsChecked = _ControlSettings.ShowValue;
            checkBox_show_captiontext.IsChecked = _ControlSettings.ShowCaption;

            textBox_value_mask.Text = _ControlSettings.ValueMask;
            textBox_quantity_mask.Text = _ControlSettings.QuantityMask;

            // Sounds
            checkBox_enable_sounds.IsChecked = _ControlSettings.IsSoundEnabled;

            string[] PosSounds = new string[] {
                "", 
                "Asterisk", "Beep", "Exclamation", "Hand", "Question"
            };

            int index = 0;
            PumpDeliverySounds sounds = _ControlSettings.Sounds;

            comboBox_calling_sound.SelectedIndex = 1;
            comboBox_authorised_sound.SelectedIndex = 1;
            comboBox_delivery_complete.SelectedIndex = 1;
            comboBox_nozzleleftout_sound.SelectedIndex = 1;

            foreach (string sound in PosSounds)
            {
                comboBox_calling_sound.Items.Add(sound);
                if (sounds.Calling == sound) comboBox_calling_sound.SelectedIndex = index;

                comboBox_authorised_sound.Items.Add(sound);
                if (sounds.Authorised == sound) comboBox_authorised_sound.SelectedIndex = index;

                comboBox_delivery_complete.Items.Add(sound);
                if (sounds.DeliveryComplete == sound) comboBox_delivery_complete.SelectedIndex = index;
                
                comboBox_nozzleleftout_sound.Items.Add(sound);
                if (sounds.NozzleLeftOut == sound) comboBox_nozzleleftout_sound.SelectedIndex = index;

                index++;
            }


        }


        void LoadSettings()
        {
            if (comboBox_style.SelectedIndex != -1)
            {
                switch( comboBox_style.SelectedIndex )
                {
                    case 0: 
                        _ControlSettings.Style = PumpControlStyle.none;  
                        break;

                    case 1: 
                        _ControlSettings.Style = PumpControlStyle.Small; 
                        break;

                    case 2: 
                        _ControlSettings.Style = PumpControlStyle.Medium; 
                        break;

                    case 3: 
                        _ControlSettings.Style = PumpControlStyle.Large; 
                        break;
                }
            }

            _ControlSettings.ShowGradeName = checkBox_show_grade.IsChecked == true;
            _ControlSettings.ShowQuantity = checkBox_show_quantity.IsChecked == true;
            _ControlSettings.ShowValue = checkBox_show_value.IsChecked == true;
            _ControlSettings.ShowValue = checkBox_show_value.IsChecked == true;
            _ControlSettings.ShowCaption = checkBox_show_captiontext.IsChecked == true;

            _ControlSettings.ValueMask = textBox_value_mask.Text;
            _ControlSettings.QuantityMask = textBox_quantity_mask.Text;

            // Sounds
            _ControlSettings.IsSoundEnabled = checkBox_enable_sounds.IsChecked == true;

            PumpDeliverySounds sounds = _ControlSettings.Sounds;
            sounds.Calling = comboBox_calling_sound.SelectedItem.ToString();
            sounds.Authorised = comboBox_authorised_sound.SelectedItem.ToString();
            sounds.DeliveryComplete = comboBox_delivery_complete.SelectedItem.ToString();
            sounds.NozzleLeftOut = comboBox_nozzleleftout_sound.SelectedItem.ToString();

            _ControlSettings.Sounds = sounds;

        }

        private void button_ok_Click(object sender, RoutedEventArgs e)
        {
            LoadSettings();

            this.DialogResult = true;
        }

        private void button_cancel_Click(object sender, RoutedEventArgs e)
        {
        }


        /// <summary>
        /// Test the entered value mask is valid.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void textBox_value_mask_TextChanged(object sender, TextChangedEventArgs e)
        {
            // Mask has changed so test it works before allowing it
            decimal value = 123.23M;

            try
            {
                String Text = string.Format(textBox_value_mask.Text, value, "$");
            }
            catch (Exception)
            {
                MessageBox.Show("Invalid value mask");
                textBox_value_mask.Text = " {0:C02} ";   
            }

        }

        /// <summary>
        /// Test the entered quantity mask is valid.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void textBox_quantity_mask_TextChanged(object sender, TextChangedEventArgs e)
        {
            decimal value = 123.23M;

            try
            {
                String Text = string.Format(textBox_quantity_mask.Text, value, "Ltrs" );
            }
            catch (Exception)
            {
                MessageBox.Show("Invalid quantity mask");
                textBox_quantity_mask.Text = "{1}{0:F02}";
            }
        }


    }
}
