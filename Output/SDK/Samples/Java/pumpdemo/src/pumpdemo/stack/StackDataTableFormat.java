/**
 * StackDataTableFormat.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */
package pumpdemo.stack;

import java.text.NumberFormat;

import ca.odell.glazedlists.gui.TableFormat;

/**
 * Specifies columns for the transaction stack table model
 * 
 */
public class StackDataTableFormat implements TableFormat<StackData> {

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
			return COL_GRADE;
		else if (column == 1)
			return COL_VOL;
		else if (column == 2)
			return COL_PRICE;
		else if (column == 3)
			return COL_VALUE;

		throw new IllegalStateException();
	}

	@Override
	public Object getColumnValue(StackData stackData, int column) {

		// for stack items without a delivery - don't show any values to distinguish
		// this scenario from a zero fuel transaction
		if (stackData.getTransaction() == null && column > 0)
			return new String("");
		
		if (column == 0)
			return stackData.getGradeName();
		else if (column == 1)
			return String.format("%.2fL", stackData.getQuantity());
		else if (column == 2)
			return NumberFormat.getCurrencyInstance().format(
					stackData.getUnitPrice());
		else if (column == 3)
			return NumberFormat.getCurrencyInstance().format(
					stackData.getValue());

		throw new IllegalStateException();
	}

	private static final String COL_GRADE = "Grade";
	private static final String COL_VOL = "Volume";
	private static final String COL_PRICE = "Price";
	private static final String COL_VALUE = "Total";
}
