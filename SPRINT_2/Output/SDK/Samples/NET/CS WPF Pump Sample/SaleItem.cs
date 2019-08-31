using System;
using System.Collections.Generic;
using System.Text;

using ITL.Enabler.API;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Type of item in sale
    /// </summary>
    public enum SalesItemType { NoItem = 0, DeliveryItem = 1, prepayItem = 2 };

 
    /// <summary>
    /// Class contains a single sales item which is saved in a sale.
    /// Encapsulates all details of sale item.
    /// </summary>
    public class SaleItem
    {
         /// <summary>
        /// Type of sales item
        /// </summary>
        public SalesItemType ItemType { get; set; }

        /// <summary>
        /// Item description
        /// </summary>
        public string Description { get; set; }
 
        /// <summary>
        /// Price of item
        /// </summary>
        public decimal Price { get; set; }

         /// <summary>
        /// Return formatted string of price with current currency
        /// </summary>
        public string FormattedPrice
        {
            get
            {
                return String.Format("{0:c2}", Price);
            }
        }

        /// <summary>
        /// Quantity or volume
        /// </summary>
        public decimal Quantity { get; set; }

        public string FormattedQuantity
        {
            get
            {
                if ( ItemType == SalesItemType.NoItem )
                    return String.Format("{0:f02}", Quantity );
                else
                    return String.Format("{0:f03}L", Quantity);
            }
        }

        /// <summary>
        /// Total value of item
        /// </summary>
        public decimal Value { get; set; }

        /// <summary>
        /// Return formatted string of value with current currency
        /// </summary>
        public string FormattedValue
        {
            get
            {
                return String.Format("{0:c2}", Value );
            }

        }
        
        /// <summary>
        /// Constructor for sale item
        /// </summary>
        /// <param name="itemType">Type of item</param>
        /// <param name="trans">Associatted fuel transaction or null</param>
        /// <param name="description">Item description</param>
        /// <param name="price">Price</param>
        /// <param name="quantity">Quantity or volume</param>
        /// <param name="value">Total value of item</param>
        public SaleItem(SalesItemType itemType, string description, decimal price, decimal quantity, decimal value)
        {
            ItemType = itemType;
            Description = description;
            Price = price;
            Quantity = quantity;
            Value = value;
        }
    }


    public class PrepayFuelItem : SaleItem
    {
        public PrepayFuelItem(string description, decimal price, decimal quantity, decimal value, Transaction trans, PumpAuthoriseLimits authData)
            : base(SalesItemType.prepayItem, description, price, quantity, value)
        {
            AuthData = authData;
            Trans = trans;
        }

        /// <summary>
        /// Authorise limits for pump
        /// </summary>
        public PumpAuthoriseLimits AuthData { get; set; }

        /// <summary>
        /// Related fuel transaction or null
        /// </summary>
        public Transaction Trans { get; set; } // Related fuel transaction

    }

    public class PostPayFuelItem : SaleItem
    {
        public PostPayFuelItem(string description, decimal price, decimal quantity, decimal value, Transaction trans)
            : base(SalesItemType.DeliveryItem, description, price, quantity, value)
        {
            Trans = trans;
        }
         /// <summary>
        /// Related fuel transaction or null
        /// </summary>
        public Transaction Trans { get; set; } // Related fuel transaction
    }
}
