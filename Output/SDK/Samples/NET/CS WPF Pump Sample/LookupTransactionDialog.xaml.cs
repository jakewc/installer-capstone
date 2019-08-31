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
    /// Dialog to select transaction to look up.
    /// </summary>
    public partial class LookupTransactionDialog : Window
    {
        Forecourt _Forecourt;

        public LookupTransactionDialog(Forecourt forecourt)
        {
            _Forecourt = forecourt;

            InitializeComponent();
        }

        public Transaction GetTransaction { get; private set; }

        private void button_lookup_Click(object sender, RoutedEventArgs e)
        {
            if (radioButton_transID.IsChecked == true)
            {
                int TransID;

                if (!int.TryParse(textBox_data.Text, out TransID))
                {
                    MessageBox.Show("Not a valid transaction ID");
                    return;
                }

                try
                {
                    GetTransaction = _Forecourt.GetTransactionById(TransID);
                }
                catch (EnablerException)
                {
                    MessageBox.Show("Transaction not found");
                    return;
                }
            }
            else
            {
                if (textBox_data.Text.Length < 1)
                {
                    MessageBox.Show("Client reference missing");
                    return;
                }

                try
                {
                    GetTransaction = _Forecourt.GetTransactionByReference(textBox_data.Text);
                }
                catch (EnablerException )
                {
                    MessageBox.Show("Transaction not found");
                    return;
                }
            }

            this.DialogResult = true;
        }
    }
}
