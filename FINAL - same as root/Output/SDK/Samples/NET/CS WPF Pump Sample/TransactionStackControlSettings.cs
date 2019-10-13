using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Media;
using Microsoft.Win32;

using ITL.Enabler.API;
using ITL.Enabler.WPFControls;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// This class encapsulates the settings used in the Transaction List control.
    /// </summary>
    /// <remarks>
    /// The class can be used to load and save settings to the registry and to create a 
    /// Transaction list control using the current settings.
    /// </remarks>
    public class TransactionStackControlSettings
    {
        const string TankControlRegistry = @"TransactionListControl";

        int  MaxRegIndex;

        #region Properties

        /// <summary>
        /// The get / set property determines if the current transaction progress is displayed in the Transaction list or
        /// only when the Transaction delivery has been completed.
        /// </summary>
        /// <remarks>
        /// When set to true the current transactions progress will be displayed.
        /// </remarks>
        public bool ShowActiveTransaction{ get; set; }

        /// <summary>
        /// Show bitmaps instead of text on buttons.
        /// </summary>
        public bool ShowBitmapsOnButtons { get; set; }

        /// <summary>
        /// Enable selection of multiple transactions in list.
        /// Normally a transaction is moved to sales window and transaction dialog closed. With this setting set
        /// it doesn't do that, it stays in transaction dialog and allows multilple transactions to be selected and
        /// moved to sale when the "To Sale" button is clicked.
        /// </summary>
        public bool MultiTransactionSelect { get; set; }

        /// <summary>
        /// Get or Set the String.Format of the displayed Value field.
        /// </summary>
        /// <remarks>
        /// Normally the default format will be ok which displays the value using the localised currency.
        /// </remarks>
        public string ValueFormat { get; set; }
        /// <summary>
        /// Get or Set the String.Format of the displayed Price field.
        /// </summary>
        /// <remarks>
        /// Normally the default format will be ok which displays the price using the localised currency.
        /// </remarks>
        public string PriceFormat { get; set; }
        /// <summary>
        /// Get or Set the String.Format of the displayed Quantity field.
        /// </summary>
        /// <remarks>
        /// Normally the default format will be ok which displays the quantity using the unit set up in the grade.
        /// Parameter 0 in the format is the quantity value and parameter 1 is the unit symbol.
        /// </remarks>
        public string QuantityFormat { get; set; }

        /// <summary>
        /// This list defines the columns to be displayed in the Transaction List.
        /// </summary>
        public List<TransactionStackControl.ColumnItem> Items = new List<TransactionStackControl.ColumnItem>();

        #endregion

        /// <summary>
        /// Constructor for TransactionStackControlSettings. 
        /// </summary>
        public TransactionStackControlSettings()
        {
            MaxRegIndex = 0;

            ShowBitmapsOnButtons = true;
            MultiTransactionSelect = false;

            // Get defaults from a TransactionStackControl
            TransactionStackControl tl = new TransactionStackControl();
            ValueFormat = tl.ValueFormat;
            PriceFormat = tl.PriceFormat;
            QuantityFormat = tl.QuantityFormat;

            Items.Add(new TransactionStackControl.ColumnItem("Grade Name", TransactionStackControl.ColumnItem.FieldType.GradeName));
            Items.Add(new TransactionStackControl.ColumnItem("Quantity", TransactionStackControl.ColumnItem.FieldType.Quantity));
            Items.Add(new TransactionStackControl.ColumnItem("Price", TransactionStackControl.ColumnItem.FieldType.UnitPrice));
            Items.Add(new TransactionStackControl.ColumnItem("Total", TransactionStackControl.ColumnItem.FieldType.Value));
            Items.Add(new TransactionStackControl.ColumnItem("Type", TransactionStackControl.ColumnItem.FieldType.Type));
        }

        /// <summary>
        /// This method will create a new Transaction List control using the current settings and the supplied pump object.
        /// </summary>
        /// <param name="pump">Enabler Pump object for which transaction will be listed.</param>
        /// <returns></returns>
        public TransactionStackControl CreateControl(Pump pump)
        {
            TransactionStackControl tl = new TransactionStackControl(pump);

            tl.ShowActiveTransaction = ShowActiveTransaction;

            // Add items to control if any
            // if none use default
            if (Items.Count > 0)
            {
                tl.ClearColumns();

                foreach (TransactionStackControl.ColumnItem item in Items)
                {
                    tl.AddColumn(item);
                }
            }

            return tl;
        }

        /// <summary>
        /// Load the Transaction List Control Settings from a location in the registry.
        /// </summary>
        /// <remarks>
        /// The setting will be loaded from the "TransactionListControl" subkey of the passed registry key.
        /// </remarks>
        /// <see cref="Save"/>
        /// <param name="RootSettingsKey">Root registry key for the settings.</param>
        public void Load(RegistryKey RootSettingsKey)
        {
            try
            {
                RegistryKey PumpTransactionListKey = RootSettingsKey.OpenSubKey(TankControlRegistry);

                ShowActiveTransaction = Convert.ToBoolean(PumpTransactionListKey.GetValue("ShowActiveTransaction"));
                ShowBitmapsOnButtons = Convert.ToBoolean(PumpTransactionListKey.GetValue("ShowBitmapsOnButtons"));
                MultiTransactionSelect = Convert.ToBoolean(PumpTransactionListKey.GetValue("MultiTransactionSelect"));

                TransactionStackControl tl = new TransactionStackControl();

                // If not present then use defaults
                ValueFormat = Convert.ToString(PumpTransactionListKey.GetValue("ValueFormat", tl.ValueFormat));
                PriceFormat = Convert.ToString(PumpTransactionListKey.GetValue("PriceFormat", tl.PriceFormat));
                QuantityFormat = Convert.ToString(PumpTransactionListKey.GetValue("QuantityFormat", tl.QuantityFormat));

                Items.Clear();

                MaxRegIndex = 0;
                do
                {
                    TransactionStackControl.ColumnItem.FieldType Type;
                    String Header;
                    Object ObjValue;

                    ObjValue = PumpTransactionListKey.GetValue("ItemType" + MaxRegIndex.ToString());
                    if (ObjValue == null) break;
                    Type = (TransactionStackControl.ColumnItem.FieldType)Convert.ToInt32(ObjValue);

                    ObjValue = PumpTransactionListKey.GetValue("ItemHeader" + MaxRegIndex.ToString());
                    if (ObjValue == null) break;
                    Header = Convert.ToString(ObjValue);

                    Items.Add(new TransactionStackControl.ColumnItem(Header, Type));

                    MaxRegIndex++;
                }
                while (MaxRegIndex < 30);

            }
            catch (Exception) { };
        }

        /// <summary>
        /// Save the Transaction List Control settings under the subkey "PumpControl".
        /// </summary>
        /// <see cref="Load"/>
        /// <param name="RootSettingsKey">Root registry key for the settings.</param>
        public void Save(RegistryKey RootSettingsKey)
        {
            try
            {
                RegistryKey PumpTransactionListKey = RootSettingsKey.CreateSubKey(TankControlRegistry, RegistryKeyPermissionCheck.ReadWriteSubTree);

                PumpTransactionListKey.SetValue("ShowActiveTransaction", ShowActiveTransaction);
                PumpTransactionListKey.SetValue("ShowBitmapsOnButtons", ShowBitmapsOnButtons);
                PumpTransactionListKey.SetValue("MultiTransactionSelect", MultiTransactionSelect);

                // Only write if different, i.e. use defaults
                TransactionStackControl tl = new TransactionStackControl();
                SetValueIfDifferent(PumpTransactionListKey, "ValueFormat", ValueFormat, tl.ValueFormat);
                SetValueIfDifferent(PumpTransactionListKey, "PriceFormat", PriceFormat, tl.PriceFormat);
                SetValueIfDifferent(PumpTransactionListKey, "QuantityFormat", QuantityFormat, tl.QuantityFormat);

                for (int index = 0; index < Items.Count; index++)
                {
                    PumpTransactionListKey.SetValue("ItemType" + index.ToString(), (int)Items[index].ColumnFieldType);
                    PumpTransactionListKey.SetValue("ItemHeader" + index.ToString(), Items[index].HeaderString);
                }

                // delete any old entries
                for (int index = Items.Count; index < MaxRegIndex; index++)
                {
                    DeleteName(PumpTransactionListKey, "ItemType" + index.ToString());
                    DeleteName(PumpTransactionListKey, "ItemHeader" + index.ToString());
                }
            }
            catch (Exception) { };

        }

        private void SetValueIfDifferent(RegistryKey key, string name, string newValue, string oldValue ) 
        {
            if (newValue != oldValue)
            {
                key.SetValue(name, newValue);
            }
            else
            {
                DeleteName(key, name);
            }
        }

        private void DeleteName(RegistryKey key, string name)
        {
            try
            {
                key.DeleteValue(name);
            }
            catch (Exception) { }
        }


    }
}
