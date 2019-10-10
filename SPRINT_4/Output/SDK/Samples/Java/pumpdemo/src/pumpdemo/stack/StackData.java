/**
 * StackData.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */
package pumpdemo.stack;

import java.awt.Color;

import itl.enabler.api.Transaction;

/**
 * Pump transaction stack element
 * 
 */
public class StackData {

	public Transaction getTransaction() {
		return transaction;
	}

	public int getTransactionID() {
		return transaction.getId();
	}

	public double getValue() {
		return value;
	}

	public double getQuantity() {
		return quantity;
	}

	public String getGradeName() {
		return gradeName;
	}

	public String getClientRef() {
		return clientRef;
	}

	public double getUnitPrice() {
		return unitPrice;
	}

	public Color getBackground() {
		return background;
	}

	public void setTransaction(Transaction transaction) {
		this.transaction = transaction;
	}

	public void setValue(double d) {
		this.value = d;
	}

	public void setQuantity(double d) {
		this.quantity = d;
	}

	public void setGradeName(String gradeName) {
		this.gradeName = gradeName;
	}

	public void setClientRef(String clientRef) {
		this.clientRef = clientRef;
	}

	public void setUnitPrice(double d) {
		this.unitPrice = d;
	}

	public void setBackground(Color background) {
		this.background = background;
	}

	private Transaction transaction;
	private String clientRef;

	private String gradeName;
	private double quantity;
	private double unitPrice;
	private double value;

	private Color background;
}
