using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;
using System.Windows.Controls;


using ITL.Enabler.API;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Dialog to Authorise a transaction with limits.
    /// </summary>
    public partial class AuthoriseDialog : Window
    {
        Pump _Pump;
        PumpAuthoriseLimits _AuthData;

        public AuthoriseDialog(PumpAuthoriseLimits authData, Pump pump, string Acivity, string Reference)
        {
            InitializeComponent();

            _AuthData = authData;
            _Pump = pump;

            LoadProductList();

            textBox_ca.Text = clientActivity = Acivity;
            textBox_cr.Text = clientReference = Reference;

            // Initialise Price levels list
            comboBox_pricelevel.Items.Clear();
            foreach (PriceLevel plevel in _Pump.Forecourt.Settings.PriceLevels)
            {
                string level = string.Format( "{0} - {1}", plevel.Number, plevel.Name );
                comboBox_pricelevel.Items.Add(level);
            }

            if (comboBox_pricelevel.Items.Count>0 )
                comboBox_pricelevel.SelectedIndex = 0;


            // Initialise Attendants list
            comboBox_attendants.Items.Add("None");

            foreach (Attendant at in pump.Forecourt.Attendants)
            {
                comboBox_attendants.Items.Add(at.ToString());
            }

            if (comboBox_attendants.Items.Count > 0)
                comboBox_attendants.SelectedIndex = 0;

        }

        public PumpAuthoriseLimits authoriseData { get; set; }
        public String clientActivity { get; set; }
        public String clientReference { get; set; }
        public int AttendantId { get; private set; }


        /// <summary>
        /// Load the product list from names of grades on hoses of pump.
        /// </summary>
        void LoadProductList()
        {
            foreach (Hose hose in _Pump.Hoses)
            {
                ListBoxItem li = new ListBoxItem();
                CheckBox cb = new CheckBox();
                cb.IsChecked = true;
                cb.Content = hose.Grade.Name;

                cb.Tag = hose.Grade.Id;

                li.Content = cb;

                Listbox_products.Items.Add(li);
            }
        }

        /// <summary>
        /// Ok clicked.
        /// Validate authorise parameters and fill in AuthData.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_ok_Click(object sender, RoutedEventArgs e)
        {
            decimal limitValue = 0;

            clientActivity = textBox_ca.Text;
            clientReference = textBox_cr.Text;

            if (textbox_limit_money.Text.Length != 0 &&
                 decimal.TryParse(textbox_limit_money.Text, out limitValue) == false)
            {
                MessageBox.Show("Invalid money value");
                this.DialogResult = false;
                return;
            };
            _AuthData.Value = limitValue;

            limitValue = 0;
            if (textbox_limit_quantity.Text.Length != 0 &&
                 decimal.TryParse(textbox_limit_quantity.Text, out limitValue) == false)
            {
                MessageBox.Show("Invalid quantity value");
                this.DialogResult = false;
                return;
            };
            _AuthData.Quantity = limitValue;

            int timeoutValue = 0;
            if (textbox_auth_timeout.Text.Length != 0 &&
                 int.TryParse(textbox_auth_timeout.Text, out timeoutValue) == false)
            {
                MessageBox.Show("Invalid authorise timeout ( 0 -> ? secs )");
                this.DialogResult = false;
                return;
            };
            _AuthData.AuthoriseTimeout = timeoutValue;


            limitValue = 0;
            if (textbox_fuelling_timeout.Text.Length != 0 &&
                 int.TryParse(textbox_fuelling_timeout.Text, out timeoutValue) == false)
            {
                MessageBox.Show("Invalid fuelling timeout ( 0 -> ? secs )");
                this.DialogResult = false;
                return;
            };
            _AuthData.FuellingTimeout = timeoutValue;

            
            int levelValue = comboBox_pricelevel.SelectedIndex;
            if ( levelValue != -1 )
            {
                _AuthData.Level = levelValue + 1;
            }

            BuildAuthProducts(ref _AuthData, Listbox_products);

            AttendantId = -1;
            if ( comboBox_attendants.SelectedIndex > 0 )
            {
                Attendant at = _Pump.Forecourt.Attendants.GetByIndex(comboBox_attendants.SelectedIndex-1);
                AttendantId = at.Id;
            }

            this.DialogResult = true;
        }

        /// <summary>
        /// Utility method to build a list of products in AuthData from the products listBox.
        /// </summary>
        /// <param name="AuthData"></param>
        /// <param name="products"></param>
        public static void BuildAuthProducts(ref PumpAuthoriseLimits AuthData, ListBox products)
        {

            bool AllProducts = true;
            foreach (ListBoxItem li in products.Items)
            {
                CheckBox cb = li.Content as CheckBox;
                if (cb.IsChecked == false)
                    AllProducts = false;
                else
                    AuthData.Products.Add((int)cb.Tag);
            }

            // If all products don't need to specify
            if (AllProducts)
            {
                AuthData.Products.Clear();
            }

        }
    }
}
