package pumpdemo.sale;

import ca.odell.glazedlists.gui.TableFormat;

/**
 * SaleItemTableFormat.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */

/**
 * Specifies columns for the sale table model
 * 
 */
public class SaleItemTableFormat implements TableFormat<SaleItem> {

	/*
	 * (non-Javadoc)
	 * 
	 * @see ca.odell.glazedlists.gui.TableFormat#getColumnCount()
	 */
	@Override
	public int getColumnCount() {
		return 4;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see ca.odell.glazedlists.gui.TableFormat#getColumnName(int)
	 */
	@Override
	public String getColumnName(int column) {

		if (column == 0)
			return COL_DESC;
		else if (column == 1)
			return COL_QUANTITY;
		else if (column == 2)
			return COL_PRICE;
		else if (column == 3)
			return COL_VALUE;

		throw new IllegalStateException();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * ca.odell.glazedlists.gui.TableFormat#getColumnValue(java.lang.Object,
	 * int)
	 */
	@Override
	public Object getColumnValue(SaleItem saleItem, int column) {

		if (column == 0)
			return saleItem.getDescription();
		else if (column == 1)
			return saleItem.getFormattedQuantity();
		else if (column == 2)
			return saleItem.getFormattedPrice();
		else if (column == 3)
			return saleItem.getFormattedValue();

		throw new IllegalStateException();
	}

	private static final String COL_DESC = "Description";
	private static final String COL_QUANTITY = "Quantity";
	private static final String COL_PRICE = "Price";
	private static final String COL_VALUE = "Value";
}
