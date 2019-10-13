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
    /// Dialog to allow the entering on manual transactions.
    /// Manual transactions can only be logged against mechanical pumps.
    /// </summary>
    public partial class ManualTransactionDialog : Window
    {
        private MainWindow _Main;
        private Pump _Pump;

        public ManualTransactionDialog(MainWindow main, Pump pump)
        {
            InitializeComponent();

            _Main = main;        
            _Pump = pump;

            textBox_volume.Focus();
        }

        
        private void button_enter_Click(object sender, RoutedEventArgs e)
        {
            Decimal Volume;
            Decimal Value;
            Decimal Price;

            if ( !ValidateField( textBox_volume, out Volume) ) return;
            if ( !ValidateField( textBox_value, out Value) ) return;
            if ( !ValidateField( textBox_price, out Price) ) return;

            try
            {
                _Pump.LogManualTransaction(
                    1, // hose
                    Value,
                    Volume,
                    0,
                    Price,
                    1,
                    0,
                    0,
                    0
                    );

                this.DialogResult = true;
            }
            catch( EnablerException EE ) 
            {
                _Main.ShowEnablerError(this, EE.ResultCode);
            }
        }

        bool ValidateField(TextBox box, out Decimal value)
        {
            bool ok = false;
            value = 0;

            try
            {
                value = Decimal.Parse(box.Text);
                
                // ok redisplay
                box.Text = string.Format("{0:F02}", value);
                ok = true;
            }
            catch(Exception){}
            
            return ok;
        }

    }
}
