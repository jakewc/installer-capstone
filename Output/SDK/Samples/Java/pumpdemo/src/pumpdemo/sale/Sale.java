/**
 * Sale.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */
package pumpdemo.sale;

import itl.enabler.api.ApiResult;
import itl.enabler.api.DeliveryData;
import itl.enabler.api.EnablerException;
import itl.enabler.api.Forecourt;
// import itl.enabler.api.ForecourtItem;
import itl.enabler.api.Grade;
import itl.enabler.api.Pump;
import itl.enabler.api.PumpAuthoriseLimits;
import itl.enabler.api.Transaction;
// import itl.enabler.api.types.DeliveryTypes;
import itl.enabler.api.types.TransactionClearTypes;

import java.text.NumberFormat;

import pumpdemo.MainWindow;
import ca.odell.glazedlists.BasicEventList;
import ca.odell.glazedlists.EventList;
//import ca.odell.glazedlists.impl.Main;

/**
 * Represents a sale by the cashier on the forecourt
 */
public class Sale {

	public Sale( Forecourt forecourt) {
		this.forecourt = forecourt;
	}
	
	/**
	 * @return the collection of items for sale
	 */
	public EventList<SaleItem> getSaleItems() {
		return saleItems;
	}

	/**
	 * @return the sub total for this sale
	 */
	public double getSubTotal() {
		return subTotal;
	}

	/**
	 * @return the {@link SaleState state} of this sale
	 */
	public SaleState getSaleState() {
		return saleState;
	}

	/**
	 * @return the sub total for this sale formatted as a String with the
	 *         current currency
	 */
	public String getFormattedSubTotal() {

		return NumberFormat.getCurrencyInstance().format(subTotal);
	}

	/**
	 * Adds a normal sale item from the forecourt convenience store
	 * 
	 * @param description
	 * @param quantity
	 * @param unitPrice
	 * @throws EnablerException
	 */
	public void addNormalSaleItem(String description, double quantity,
			double unitPrice) throws EnablerException {
		addSaleItem(new SaleItem(SaleItemType.NO_ITEM, description, unitPrice,
				quantity, quantity * unitPrice));
	}

	public void addPrepaySaleItem(Pump pump,
			PumpAuthoriseLimits pumpAuthoriseLimits, String description, Transaction transaction)
			throws EnablerException {
		addSaleItem(new PrepayFuelItem(pump, pumpAuthoriseLimits, description,
				pumpAuthoriseLimits.getValue(), 1,
				pumpAuthoriseLimits.getValue(), transaction ));
	}

	/**
	 * Add an existing fuel transaction to this sale
	 * 
	 * @param transaction
	 *            the fuel {@link Transaction transaction} to add to this sale
	 * @throws EnablerException
	 */
	public void addFuelTransaction(Transaction transaction)
			throws EnablerException {

		// get a lock on this transaction
		// unless already locked (ReinstateAndLock)
		if ( transaction.isLocked() &&  transaction.getLockedByID() == forecourt.getTerminal().getId()) {
			// locked by this terminal, now check not already in sale
			if ( ContainsTransaction( transaction.getId() ) == true ) {
				throw new EnablerException( ApiResult.TRANSACTION_ALREADY_LOCKED_BY_YOU, "Already in Sale");
			}
		}
		else {
			transaction.getLock();
		}

		if (transaction.getClientActivity() == "Prepay") {
			return;
		} else {
			String gradeName = "(hose not selected)";
			DeliveryData deliveryData = transaction.getDeliveryData();
			int pumpNo = transaction.getPump().getNumber();
			Grade theGrade = deliveryData.getGrade();
			if (theGrade != null )
				gradeName = deliveryData.getGrade().getName();
			String description = String.format("Pump %d : %s", pumpNo,
					gradeName);

			addSaleItem(new PostPayFuelItem(transaction, description,
					deliveryData.getUnitPrice(), deliveryData.getQuantity(),
					deliveryData.getMoney()));
		}
	}

    public Boolean ContainsPrepayItems() {
    	
    	for (SaleItem saleItem : saleItems) {
            if ( saleItem.getSaleItemType() == SaleItemType.PREPAY_ITEM ) {
                return true;
            }
         }
    	
    	return false;
    }

    public Boolean ContainsTransaction(int transID) {
    	
    	for (SaleItem saleItem : saleItems) {
            if ( saleItem.getSaleItemType() == SaleItemType.PREPAY_ITEM ) {
                PrepayFuelItem pi = (PrepayFuelItem)saleItem;
                if ( pi.getTransaction().getId() == transID) {
                	return true;
                }
            }
            else if ( saleItem.getSaleItemType() == SaleItemType.DELIVERY_ITEM ) {
            	PostPayFuelItem pi =  (PostPayFuelItem)saleItem;
                if ( pi.getTransaction().getId() == transID) {
                	return true;
                }
            }
         }
    	
    	return false;
    }
    

	/**
	 * Make a payment for a sale
	 * 
	 * @param mainWindow
	 */
	public void makePayment(MainWindow mainWindow) throws EnablerException {

		for (SaleItem saleItem : saleItems) {
			switch (saleItem.getSaleItemType()) {

			case NO_ITEM:
				break;

			case DELIVERY_ITEM:
				PostPayFuelItem postPay = (PostPayFuelItem) saleItem;
				try {
					postPay.getTransaction()
							.clear(TransactionClearTypes.NORMAL);
				} catch (EnablerException ex) {
					postPay.getTransaction().releaseLock();
					throw ex;
				}

				// remove transaction
				postPay.setSaleItemType(SaleItemType.NO_ITEM);
				postPay.setTransaction(null);
				break;

			case PREPAY_ITEM:
				PrepayFuelItem prepayFuelItem = (PrepayFuelItem) saleItem;

				// Use same Activity & Reference as Reserve
				String clientActivity = prepayFuelItem.getPump()
						.getCurrentTransaction().getClientActivity().trim();
				String clientReference = prepayFuelItem.getPump()
						.getCurrentTransaction().getClientReference().trim();

				try {
					// authorise the pump for prepay
					prepayFuelItem.getPump().authoriseWithLimits(
							clientActivity, clientReference, -1,
							prepayFuelItem.getAuthoriseLimits());
				} catch (EnablerException ex) {
					mainWindow.showEnablerError(ex);
					continue;
					// prepayFuelItem.getPump().getCurrentTransaction().releaseLock();
					// throw ex;
				}
				prepayFuelItem.setSaleItemType(SaleItemType.NO_ITEM);
				prepayFuelItem.setPump(null);
				break;

			default:
				break;
			}
		}

		// mark this sale as done.
		setSaleState(SaleState.CASH_FINALISED);
	}

	/**
	 * Process a completed prepay. If delivered money < authorised money create
	 * a refund
	 * 
	 * @throws EnablerException
	 * 
	 */
	public double processPrepayComplete(Transaction transaction)
			throws EnablerException {

		// get a lock on this transaction
		transaction.getLock();

		double deliveredMoney = transaction.getDeliveryData().getMoney();
		double authorisedMoney = transaction.getAuthoriseData().getMoneyLimit();
		double refund = 0;

		if (deliveredMoney < authorisedMoney) {
			refund = authorisedMoney - deliveredMoney;
		}
		
		try {
			transaction.clear(TransactionClearTypes.NORMAL);
		} catch (EnablerException ex) {
			throw ex;
		}

		return refund;
	}

	/**
	 * Process a completed legacy preauth. 
	 * 
	 * @throws EnablerException
	 * 
	 */
	public double processPreauthComplete(Transaction transaction)
			throws EnablerException {

		// No need to lock as already locked

		double deliveredMoney = transaction.getDeliveryData().getMoney();

		try {
			transaction.clear(TransactionClearTypes.NORMAL);
		} catch (EnablerException ex) {
			throw ex;
		}

		return deliveredMoney;
	}
	/**
	 * Clear all items from sale.<br>
	 * If items are not paid for then void them
	 * 
	 * @throws EnablerException
	 */
	public void clearSales() throws EnablerException {

		for (SaleItem saleItem : saleItems) {
			try {
				voidSaleItem(saleItem);
			} catch (EnablerException ex) {
				throw ex;
			}
		}

		saleItems.getReadWriteLock().writeLock().lock();
		try {
			saleItems.clear();
		} finally {
			saleItems.getReadWriteLock().writeLock().unlock();
		}
		updateSubTotal();
	}

	/**
	 * @param saleItem
	 *            the {@link SaleItem} to void.
	 * @throws EnablerException
	 */
	public void voidItem(SaleItem saleItem) throws EnablerException {
		if (voidSaleItem(saleItem)) {
			saleItems.remove(saleItem);
		}
		updateSubTotal();
	}
	
	public void RemovePrepayTrans(int transID)
    {
		for (SaleItem saleItem : saleItems) {
            if ( saleItem.getSaleItemType() == SaleItemType.PREPAY_ITEM ) {
                PrepayFuelItem pi = (PrepayFuelItem)saleItem;
                if ( pi.getTransaction().getId() == transID)
                {
                	saleItems.remove(saleItem);
                }
            }
         }
    }
	
	 public boolean VoidPrePayItem(Transaction trans) throws EnablerException {
		for (SaleItem saleItem : saleItems) {
            if ( saleItem.getSaleItemType() == SaleItemType.PREPAY_ITEM ) {
                PrepayFuelItem pi = (PrepayFuelItem)saleItem;
                if ( pi.getTransaction() == trans)
                {
                	voidSaleItem(saleItem);
                	saleItems.remove(saleItem);
                    return true;
                }
                
            }
         }
         return false;
     }

	private boolean voidSaleItem(SaleItem saleItem) throws EnablerException {

		boolean result = false;
		try {
			switch (saleItem.getSaleItemType()) {

			case NO_ITEM:
				result = true;
				break;

			// Release locks on any transactions left in sales window
			case DELIVERY_ITEM:
				PostPayFuelItem postPayFuelItem = (PostPayFuelItem) saleItem;
				postPayFuelItem.getTransaction().releaseLock();
				result = true;
				break;

			// Remove reserves for any unpaid prepays
			case PREPAY_ITEM:
				PrepayFuelItem prepayFuelItem = (PrepayFuelItem) saleItem;
				prepayFuelItem.getPump().cancelReserve();
				result = true;

			default:
				break;
			}
		} catch (EnablerException ex) {
			throw ex;
		}

		return result;
	}

	private void addSaleItem(SaleItem saleItem) throws EnablerException {

		/**
		 * If Sale is not open (i.e some items have already been paid for) clear
		 * the sale window.
		 */
		if (getSaleState() != SaleState.SALE_OPEN) {
			clearSales();
			setSaleState(SaleState.SALE_OPEN);
		}
		saleItems.add(saleItem);
		updateSubTotal();
	}

	private void updateSubTotal() {
		subTotal = 0;
		for (SaleItem saleItem : saleItems) {
			subTotal += saleItem.getValue();
		}
	}

	private void setSaleState(SaleState state) {
		saleState = state;
	}

	private double subTotal;
	private EventList<SaleItem> saleItems = new BasicEventList<SaleItem>();
	private SaleState saleState = SaleState.SALE_OPEN;
	private Forecourt forecourt;
}
