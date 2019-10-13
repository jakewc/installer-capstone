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

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Interaction logic for ReserveDialog.xaml
    /// </summary>
    public partial class ReserveDialog : Window
    {
        public String clientActivity { get; set; }
        public String clientReference { get; set; }
        public bool clearIfZero { get; set; }

        public ReserveDialog()
        {
            InitializeComponent();

            textBox_ca.Text = clientActivity;
            textBox_cr.Text = clientReference;

            checkBox_ClearIfZero.IsChecked = clearIfZero;
        }

        // Reserve
        private void button_ok_Click(object sender, RoutedEventArgs e)
        {
            clientActivity = textBox_ca.Text;
            clientReference = textBox_cr.Text;

            clearIfZero = (bool)checkBox_ClearIfZero.IsChecked;

            this.DialogResult = true;
        }
    }
}
