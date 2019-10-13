/**
 * SaleItem.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */
package pumpdemo.sale;

import java.text.NumberFormat;

/**
 * Contains a single sales item
 */
public class SaleItem {

	/**
	 * @return the {@link SaleItemType}
	 */
	public SaleItemType getSaleItemType() {
		return itemType;
	}

	/**
	 * @return the item description
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * @return the price of the item
	 */
	public double getPrice() {
		return price;
	}

	/**
	 * @return the quantity or volume of the item
	 */
	public double getQuantity() {
		return quantity;
	}

	/**
	 * @return the total value of the item
	 */
	public double getValue() {
		return value;
	}

	/**
	 * @param itemType
	 *            the {@link SaleItemType} to set
	 */
	public void setSaleItemType(SaleItemType saleItemType) {
		this.itemType = saleItemType;
	}

	/**
	 * @param description
	 *            the item description to set
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	/**
	 * @param price
	 *            the item price to set
	 */
	public void setPrice(double price) {
		this.price = price;
	}

	/**
	 * @param quantity
	 *            the quantity or volume of the item to set
	 */
	public void setQuantity(double quantity) {
		this.quantity = quantity;
	}

	/**
	 * @param value
	 *            the value of the item to set
	 */
	public void setValue(double value) {
		this.value = value;
	}

	/**
	 * @return the price formatted as a String with the current currency
	 */
	public String getFormattedPrice() {

		return NumberFormat.getCurrencyInstance().format(price);
	}

	/**
	 * @return the value formatted as a String with the current currency
	 */
	public String getFormattedValue() {

		return NumberFormat.getCurrencyInstance().format(value);
	}

	/**
	 * @return the quantity formatted as a String
	 */
	public String getFormattedQuantity() {

		// Can be made locale sensitive
		if (itemType == SaleItemType.NO_ITEM) {
			return String.format("%.2f", quantity);
		} else {
			return String.format("%.2fL", quantity);
		}
	}

	/**
	 * @param itemType
	 *            {@link SaleItemType}
	 * @param description
	 *            Item description
	 * @param price
	 *            Price of sale item
	 * @param quantity
	 *            Quantity of volume of sale item
	 * @param value
	 *            Total value of sale item
	 */
	public SaleItem(SaleItemType saleItemType, String description,
			double price, double quantity, double value) {
		this.itemType = saleItemType;
		this.description = description;
		this.price = price;
		this.quantity = quantity;
		this.value = value;
	}

	private SaleItemType itemType;
	private String description;

	private double price;
	private double quantity;
	private double value;

}
