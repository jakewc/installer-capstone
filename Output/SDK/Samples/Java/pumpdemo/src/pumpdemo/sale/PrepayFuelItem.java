/**
 * PrepayFuelItem.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */
package pumpdemo.sale;

import itl.enabler.api.Pump;
import itl.enabler.api.PumpAuthoriseLimits;
import itl.enabler.api.Transaction;

/**
 * A sale item generated from a prepay fuel transaction wherein a customer has
 * already payed for fuel before the delivery starts
 * 
 */
public class PrepayFuelItem extends SaleItem {

	private Pump pump;
	private PumpAuthoriseLimits authoriseLimits;
	private Transaction transacton;
	
	/**
	 * @param saleItemType
	 * @param description
	 * @param price
	 * @param quantity
	 * @param value
	 */
	public PrepayFuelItem(Pump pmp, PumpAuthoriseLimits pumpAuthoriseLimits,
			String description, double price, double quantity, double value, Transaction trans) {
		super(SaleItemType.PREPAY_ITEM, description, price, quantity, value);

		setPump(pmp);
		setAuthoriseLimits(pumpAuthoriseLimits);
		setTransaction(trans);
	}

	public Pump getPump() {
		return pump;
	}

	public void setPump(Pump pump) {
		this.pump = pump;
	}

	public PumpAuthoriseLimits getAuthoriseLimits() {
		return authoriseLimits;
	}

	public void setAuthoriseLimits(PumpAuthoriseLimits authoriseLimits) {
		this.authoriseLimits = authoriseLimits;
	}

	public Transaction getTransaction() {
		return transacton;
	}

	public void setTransaction(Transaction transacton) {
		this.transacton = transacton;
	}
}
