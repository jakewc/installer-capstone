using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
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
using ITL.Enabler.WPFControls;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Dialog to configure the Transaction control settings.
    /// </summary>
    public partial class PumpTransactionSettingsDialog : Window
    {
        TransactionStackControlSettings _Settings;
            
        public class ListData
        {
            public TransactionStackControl.ColumnItem.FieldType Ftype{get; set;}

            public string Type { get; set; }
            public string Header{get;set;}

            public ListData(string header, TransactionStackControl.ColumnItem.FieldType ftype)
            {
                Header = header;
                Ftype = ftype;
                Type = ftype.ToString(); ;
            }

        }

        public class ComboItem
        {
            public TransactionStackControl.ColumnItem.FieldType Item{get; set; }
             
            public string DisplayText { 
                get
                {
                    return Item.ToString();
                }
            }

            public ComboItem(TransactionStackControl.ColumnItem.FieldType item)
            {
                Item = item;
            }
        }

        /// <summary>
        /// Observable Collection for Transaction list columns definition.
        /// </summary>
        public ObservableCollection<ListData> ItemData = new ObservableCollection<ListData>();

        public ObservableCollection<ComboItem> ComboChoices = new ObservableCollection<ComboItem>();

        public bool ShowActiveTransaction{ get; set; }

        public bool ShowBitmapsOnButtons { get; set; }

        public bool MultiTransactionSelect { get; set; }

        public PumpTransactionSettingsDialog(TransactionStackControlSettings settings)
        {
            InitializeComponent();

            _Settings = settings;

            checkBox_ShowCurrentTrans.IsChecked = _Settings.ShowActiveTransaction;
            checkBox_ShowBitmapButtons.IsChecked = _Settings.ShowBitmapsOnButtons;
            checkBox_MultiTransactionSelect.IsChecked = _Settings.MultiTransactionSelect;

            ListView_items.ItemsSource = ItemData;
            combo_item_choice.ItemsSource = ComboChoices;
            
            RefreshListItems();

            RefreshItemChoices();
        }


        private void RefreshListItems()
        {
            ItemData.Clear();

            // Copy from settings to ObservableCollection
            foreach (TransactionStackControl.ColumnItem item in _Settings.Items)
            {
                ItemData.Add( new ListData(item.HeaderString, item.ColumnFieldType) );
            }
        }

        /// <summary>
        /// Add Items to choice combo that are not in current list
        /// </summary>
        private void RefreshItemChoices()
        {
            ComboChoices.Clear();

            // Only add item not in List control
            foreach (TransactionStackControl.ColumnItem.FieldType item1 in Enum.GetValues(typeof(TransactionStackControl.ColumnItem.FieldType)))
            {
                bool present = false;
                foreach (ListData item2  in ListView_items.Items)
                {
                    if (item1 == item2.Ftype )
                    {
                        present = true;
                        break;
                    }
                }

                if (present == false)
                {
                    ComboChoices.Add(new ComboItem(item1));
                }
            }

            if ( combo_item_choice.Items.Count > 0 )
                combo_item_choice.SelectedIndex = 0;
        
        }

        private void button_add_Click(object sender, RoutedEventArgs e)
        {
            ComboItem SelItem = combo_item_choice.SelectedItem as ComboItem;
            if (SelItem != null)
            {
                // Add type as header text if missing
                string HeaderText = textBox_header.Text;
                if (HeaderText.Length == 0)
                    HeaderText = SelItem.DisplayText;

                ItemData.Add(new ListData(HeaderText, SelItem.Item));

                RefreshItemChoices();
            }
        }

        private void button_delete_Click(object sender, RoutedEventArgs e)
        {

            while( ListView_items.SelectedItems.Count > 0 )
            {
                ListData item = ListView_items.SelectedItems[0] as ListData;

                // Remove from ListView
                ItemData.Remove(item);
               // _Settings.Items.Remove();
            }

            RefreshItemChoices();
        }

        private void button_ok_Click(object sender, RoutedEventArgs e)
        {
            _Settings.ShowActiveTransaction = (bool)checkBox_ShowCurrentTrans.IsChecked;
            _Settings.ShowBitmapsOnButtons = (bool)checkBox_ShowBitmapButtons.IsChecked;
            _Settings.MultiTransactionSelect = (bool)checkBox_MultiTransactionSelect.IsChecked;

            _Settings.Items.Clear();
            foreach (ListData item in ItemData)
            {
                _Settings.Items.Add(new TransactionStackControl.ColumnItem(item.Header, item.Ftype ));
            }

            this.DialogResult = true;
        }

        private void ListView_items_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (ListView_items.SelectedItems.Count > 0)
                button_delete.IsEnabled = true;
            else
                button_delete.IsEnabled = false;

            bool MoveButs = (ListView_items.SelectedItems.Count == 1);

            button_up.IsEnabled = MoveButs;
            button_down.IsEnabled = MoveButs;
            
            if ( MoveButs )
            {
                if (ListView_items.SelectedIndex == 0)
                    button_up.IsEnabled = false;

                if (ListView_items.SelectedIndex == (ListView_items.Items.Count-1) )
                    button_down.IsEnabled = false;
            }
        }

        private void button_up_Click(object sender, RoutedEventArgs e)
        {
            int itemIndex = ListView_items.SelectedIndex;

            if (itemIndex > 0)
            {
                ListData Data = ItemData[itemIndex];

                ItemData.RemoveAt(itemIndex);
                ItemData.Insert(itemIndex - 1, Data);

                ListView_items.SelectedIndex = itemIndex - 1;
            }
        }

        private void button_down_Click(object sender, RoutedEventArgs e)
        {
            int itemIndex = ListView_items.SelectedIndex;

            if (itemIndex < (ItemData.Count - 1) )
            {
                ListData Data = ItemData[itemIndex];

                ItemData.RemoveAt(itemIndex);
                ItemData.Insert(itemIndex + 1, Data);

                ListView_items.SelectedIndex = itemIndex + 1;
            }

        }
    }
}
