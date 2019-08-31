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
    /// Dialog show the details of the selected transaction with the option of reinstating transaction.
    /// </summary>
    public partial class TransactionDetailsDialog : Window
    {
        Transaction _Trans;

        public TransactionDetailsDialog( Transaction trans )
        {
            InitializeComponent();

            _Trans = trans;

            UpdateDialog();
        }

        void UpdateDialog()
        {
            textBox_transID.Text = _Trans.Id.ToString();
            textBox_ClientRef.Text = _Trans.ClientReference;
            textBox_ClientAct.Text = _Trans.ClientActivity;
            if (_Trans.Attendant == null)
                textBox_AttendantID.Text = "";
            else
                textBox_AttendantID.Text = _Trans.Attendant.Name + "(" + _Trans.Attendant.Id.ToString() + ")";
			
			// use reflection to read Delivery ID in case an old API is being used
			var deliverIDProperty = _Trans.DeliveryData.GetType().GetProperty( "DeliveryID" );
			textBox_deliveryID.Text = ( deliverIDProperty != null ? 
										deliverIDProperty.GetValue( _Trans.DeliveryData, null ).ToString() :
										"" );


            if (_Trans.State == TransactionState.Completed || _Trans.State == TransactionState.Cleared)
            {
                if ( _Trans.DeliveryData.Grade!=null )
                    textBox_GradeName.Text = _Trans.DeliveryData.Grade.Name;

                textBox_Price.Text = _Trans.DeliveryData.UnitPrice.ToString("c02");
                textBox_Quantity.Text = _Trans.DeliveryData.Quantity.ToString("f03");
                textBox_Value.Text = _Trans.DeliveryData.Money.ToString("c02");
            }

            textBox_State.Text = _Trans.State.ToString();

            button_reinstate.IsEnabled = true;
            button_reinstateAndLock.IsEnabled = true;

        }

        private void button_reinstate_Click(object sender, RoutedEventArgs e)
        {
            int paymentTypeID = Convert.ToInt32(textBox_PaymentType.Text);

            try
            {
                if (paymentTypeID > 0)
                    _Trans.Reinstate(paymentTypeID);
                else
                    _Trans.Reinstate();
            }
            catch( EnablerException EE )
            {
                MessageBox.Show("Error Reinstating transaction:" + Forecourt.GetResultString(EE.ResultCode));
                return;
            }

            DialogResult = true; ;
        }

        private void button_reinstateAndLock_Click(object sender, RoutedEventArgs e)
        {
            int paymentTypeID = Convert.ToInt32(textBox_PaymentType.Text);
            try
            {
                if (paymentTypeID > 0)
                    _Trans.ReinstateAndLock(paymentTypeID);
                else
                    _Trans.ReinstateAndLock();
            }
            catch (EnablerException EE)
            {
                MessageBox.Show("Error Reinstating transaction:" + Forecourt.GetResultString(EE.ResultCode));
                return;
            }

            DialogResult = true; ;
        }


        private void button_exit_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
        }
    }
}
