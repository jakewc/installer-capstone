using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Windows;

using ITL.Enabler.API;

namespace ITL.Enabler.Samples
{
    public enum SaleState { SaleOpen, Cashfinalised, CreditFinalised };

    /// <summary>
    /// The class is used to encapsulate the current sale.
    /// Handles the Authorisation of Prepay items if it has been paid.
    /// </summary>
    public class Sale
    {
        private MainWindow _Main;
        private decimal _SubTotal;
        private ObservableCollection<SaleItem> _SaleItems = new ObservableCollection<SaleItem>();
        private SaleState _State = SaleState.SaleOpen;
        private bool SaleFinialised;

        public Sale(MainWindow main)
        {
            _Main = main;        
        }
        /// <summary>
        /// Collection of items in sale
        /// </summary>
        public ObservableCollection<SaleItem> SaleItems
        {
            get { return _SaleItems; }
        }

        public Decimal SubTotal
        {
            get { return _SubTotal; }
        }

        public String SubTotalFormatted
        {
            get { return String.Format("{0:c2}", _SubTotal );; }
        }

        public SaleState State
        {
            get { return _State; }
        }

        #region Public Methods

        public void AddNormalSaleItem(String description, decimal quantity, decimal unitPrice)
        {
            AddSaleItem(new SaleItem(SalesItemType.NoItem,
                                        description,
                                        unitPrice,
                                        quantity,
                                        quantity * unitPrice
                                        ));
        }

        /// <summary>
        /// Add a prepay item to sale. Paying this item will authorise the Transaction
        /// </summary>
        /// <param name="description"></param>
        /// <param name="value"></param>

        public void AddPrepayItem(String description, Transaction trans, PumpAuthoriseLimits authData)
        {
            AddSaleItem(new PrepayFuelItem(description,
                                           authData.Value,
                                           1,
                                           authData.Value,
                                           trans,
                                           authData
                                           ));
        }


        /// <summary>
        /// Add an existing fuel transaction to sale
        /// </summary>
        /// <param name="trans"></param>
        public bool AddFuelTransaction(Transaction trans)
        {
            try
            {
                if (!trans.IsLocked)
                {
                    trans.GetLock();
                }
                else
                {
                    // This could be a ReinsateAndLock transaction so it will be in the pump statck and already locked 
                    // Is it already locked by me
                    if (trans.IsLocked && trans.LockedById != _Main._Forecourt.TerminalId) 
                    {
                        // no ignore
                        return false;
                    }

                    // its lock by me, see if its already in the sales window
                    // Is it already in the Sales items ?
                    if ( ContainsTransaction( trans.Id ) )
                    { 
                        // yes
                        return true;
                    }
                }

                if (trans.ClientActivity.StartsWith(MainWindow.Activity_Prepay))
                {
                    _Main.SetPumpCaption(trans.Pump.Number, "");
                    ProcessPrepayComplete(trans);
                }
                else
                {
                    // Some non normal transaction types don't have a grade associatted
                    Grade grade = trans.DeliveryData.Grade;
                    string GradeName = grade == null ? "" : grade.Name;

                    // Normal fuel transaction
                    AddSaleItem(new PostPayFuelItem(
                        String.Format("{0}-{1}", trans.Pump.Number, GradeName),
                        trans.DeliveryData.UnitPrice,
                        trans.DeliveryData.Quantity,
                        trans.DeliveryData.Money,
                        trans
                        ));
                }
            }
            catch (EnablerException )
            {
                return false;
            }

            return true;
        }


        #endregion

        /// <summary>
        /// Process a completed prepay, if delivered money < authorised money then create a refund 
        /// </summary>
        /// <param name="trans"></param>
        void ProcessPrepayComplete(Transaction trans)
        {
            if (trans.DeliveryData.Money < trans.AuthoriseData.MoneyLimit)
            {
                // Create refund
                MessageBox.Show("Refund");
            }
            else
            {
                // No refund
                MessageBox.Show("No refund");
            }

            trans.Clear(TransactionClearTypes.Normal);
            _Main.SetPumpCaption(trans.Pump.Number, "");
        }


        void AddSaleItem(SaleItem si)
        {
            // Clear sales window if previosly been finialised
            if (SaleFinialised)
            {
                _SaleItems.Clear();
                SaleFinialised = false;
            }

            _SaleItems.Add(si);

            UpdateSubtotal();
        }

        void UpdateSubtotal()
        {
            _SubTotal = 0;
            foreach (SaleItem si in _SaleItems)
            {
                _SubTotal += si.Value;
            }
        }

        public void Payment()
        {
            Payment(false, 0, true);
        }

        public void Payment(bool attendantPay, int paymentID, bool updateFloat)
        {
            foreach (SaleItem si in _SaleItems)
            {
                switch (si.ItemType)
                {
                    case SalesItemType.NoItem:

                        break;

                    case SalesItemType.DeliveryItem:
                        PostPayFuelItem pfi = si as PostPayFuelItem;

                        try
                        {
                            if (attendantPay)
                                pfi.Trans.Clear(TransactionClearTypes.Attendant, paymentID, updateFloat);
                            else
                                pfi.Trans.Clear(TransactionClearTypes.Normal);
                        }
                        catch (EnablerException EE)
                        {
                            _Main.ShowEnablerError(EE);
                            pfi.Trans.ReleaseLock();
                        }

                        // Remove transation
                        pfi.ItemType = SalesItemType.NoItem;
                        pfi.Trans = null;
                        break;

                    case SalesItemType.prepayItem:
                        PrepayFuelItem ppfi = si as PrepayFuelItem;
                        Pump pump = ppfi.Trans.Pump;


                        if (pump.CurrentTransaction == null) break;

                        // Prepay items
                        try
                        {
                            //if the item is a prepay item it needs to be authorised
                            pump.Authorise(
                                String.Format("Prepay ${0}", ppfi.AuthData.Value),    // Use same Activity & Ref as Reserve
                                pump.CurrentTransaction.ClientReference,
                                -1,
                                ppfi.AuthData
                                );
                        }
                        catch (EnablerException EE)
                        {
                            _Main.ShowEnablerError(EE);
                            if (pump.CurrentTransaction.IsLocked)
                                pump.CurrentTransaction.ReleaseLock();
                        }

                        ppfi.ItemType = SalesItemType.NoItem;
                        pump = null;
                        break;
                }


            }

            SaleFinialised = true;
        }

        /// <summary>
        /// Clear all items from sale
        /// If items no paid then void them
        /// </summary>
        public void Clear()
        {
            foreach (SaleItem si in _SaleItems)
            {
                VoidSaleItem(si);
            }

            Reset();
        }

        // Just clear all
        public void Reset()
        {
            SaleItems.Clear();

            UpdateSubtotal();
        }
 

        public void VoidItem(SaleItem si)
        {
            if ( VoidSaleItem(si) )
            {
                _SaleItems.Remove(si);
            }

            UpdateSubtotal();
        }

        public void RemovePrepayTrans(int transID)
        {
            foreach (SaleItem si in _SaleItems)
            {
                if (si.ItemType == SalesItemType.prepayItem)
                {
                    PrepayFuelItem pi = si as PrepayFuelItem;
                    if (pi.Trans.Id == transID)
                    {
                        _SaleItems.Remove(si);
                        UpdateSubtotal();
                        return;
                    }

                }
            }
        }

        public bool ContainsPrepayItems()
        {
            foreach (SaleItem si in _SaleItems)
            {
               if ( si.ItemType == SalesItemType.prepayItem )
               {
                       return true;
               }
                   
            }
            return false;
        }

        public bool ContainsTransaction(int transid)
        {
            foreach (SaleItem si in _SaleItems)
            {
                if (si.ItemType == SalesItemType.prepayItem)
                {
                    PrepayFuelItem pfi = si as PrepayFuelItem;
                    if (pfi.Trans.Id == transid) return true;
                }
                else if (si.ItemType == SalesItemType.DeliveryItem )
                {
                    PostPayFuelItem ppi = si as PostPayFuelItem;
                    if (ppi.Trans.Id == transid) return true;
                }

            }
            return false;
        }

        public bool VoidPrePayItem(Transaction trans)
        {
            foreach (SaleItem si in _SaleItems)
            {
               if ( si.ItemType == SalesItemType.prepayItem )
               {
                   PrepayFuelItem pi = si as PrepayFuelItem;
                   if (pi.Trans == trans)
                   {
                       VoidSaleItem(si);
                       _SaleItems.Remove(si);
                       return true;
                   }
                   
               }
            }
            return false;
        }


        bool VoidSaleItem(SaleItem si)
        {
            bool VoidOk = false;

            try
            {
                switch (si.ItemType)
                {
                    case SalesItemType.NoItem:
                        VoidOk = true;
                        break;

                    // Release locks on any transactions left in sales window
                    case SalesItemType.DeliveryItem:
                        PostPayFuelItem pfi = si as PostPayFuelItem;
                        pfi.Trans.ReleaseLock();
                        VoidOk = true;
                        break;

                    // Any prepays unpaid then just remove reserve
                    case SalesItemType.prepayItem:
                        PrepayFuelItem ppfi = si as PrepayFuelItem;
                        ppfi.Trans.Pump.CancelReserve();
                        VoidOk = true;
                        break;

                }
            }
            catch (EnablerException EE)
            {
                _Main.ShowEnablerError(EE);
            }


            return VoidOk;
        }

    }
}
