/**
 * PostPayFuelItem.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */
package pumpdemo.sale;

import itl.enabler.api.Transaction;

/**
 * A sale item generated from a normal post pay fuel transaction
 * 
 */
public class PostPayFuelItem extends SaleItem {

	/**
	 * @return the fuel {@link Transaction transaction} for this sale
	 */
	public Transaction getTransaction() {
		return transaction;
	}

	/**
	 * @param transaction
	 *            the fuel {@link Transaction transaction} to set for this sale
	 */
	public void setTransaction(Transaction transaction) {
		this.transaction = transaction;
	}

	/**
	 * Constructs a post pay fuel transaction.
	 * 
	 * @param transaction
	 *            The fuel {@link Transaction transaction} to add to this sale
	 * @see SaleItem#SaleItem(SaleItemType saleItemType, String description,
	 *      double price, double quantity, double value)
	 */
	public PostPayFuelItem(Transaction transaction, String description,
			double price, double quantity, double value) {
		super(SaleItemType.DELIVERY_ITEM, description, price, quantity, value);

		this.setTransaction(transaction);
	}

	private Transaction transaction;
}
