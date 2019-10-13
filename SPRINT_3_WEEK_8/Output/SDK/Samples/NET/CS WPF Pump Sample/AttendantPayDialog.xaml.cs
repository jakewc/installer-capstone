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
    /// Interaction logic for AttendantPayDIalog.xaml
    /// </summary>
    public partial class AttendantPayDialog : Window
    {
        Forecourt _Forecourt;
        Sale _CurrentSales;
        public event EventHandler AttendantPayComplete;

        public AttendantPayDialog()
        {
            InitializeComponent();
        }

        public AttendantPayDialog(Forecourt Forecourt, Sale CurrentSales)
            : this()
        {
            _Forecourt = Forecourt;
            _CurrentSales = CurrentSales;
            WindowStartupLocation = WindowStartupLocation.CenterOwner;
        }

        private void Button_Pay_Clicked(object sender, RoutedEventArgs e)
        {
            int paymentTypeID = 0 ;
            bool updateFloat = true;
            try
            {

                paymentTypeID = Convert.ToInt32(txt_PaymentTypeID.Text);
                updateFloat = ckb_UpdateFLoat.IsChecked.Value;
            }
            catch{}

            if (_CurrentSales != null)
            {
                _CurrentSales.Payment(true, paymentTypeID, updateFloat);
            }

            if (AttendantPayComplete != null)
            {
                AttendantPayComplete(this, null);
            }

            this.Close();
        }


    }
}
