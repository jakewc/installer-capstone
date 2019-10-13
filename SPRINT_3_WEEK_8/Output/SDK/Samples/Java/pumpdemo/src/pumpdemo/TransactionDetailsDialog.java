package pumpdemo;

import itl.enabler.api.DeliveryData;
import itl.enabler.api.EnablerException;
import itl.enabler.api.Transaction;
import itl.enabler.api.states.TransactionState;

import java.awt.BorderLayout;
import java.awt.FlowLayout;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import java.awt.Toolkit;
import javax.swing.JLabel;
import javax.swing.JTextField;
import javax.swing.SwingConstants;

import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;
import java.awt.Insets;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.UIManager;

@SuppressWarnings("serial")
public class TransactionDetailsDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();
	private JTextField textTransactionID;
	private JTextField textDeliveryID;
	private JTextField textClientReference;
	private JTextField textClientActivity;
	private JTextField txtAttendantId;
	private JTextField txtGrade;
	private JTextField txtPrice;
	private JTextField txtQuantity;
	private JTextField txtValue;
	private JTextField txtState;

	private Transaction transaction;
	private JButton reinstateButton;
	private JButton reinstateAndLockButton;

	private MainWindow mainWindow;

	/**
	 * Create the dialog.
	 */
	public TransactionDetailsDialog(MainWindow app, Transaction trans) {

		mainWindow = app;
		transaction = trans;
		
		int dialogWidth = 338;
		int dialogHeight = 309;

		setResizable(false);
		setSize(new Dimension(dialogWidth, dialogHeight));
		getContentPane().setMinimumSize(new Dimension(dialogWidth, dialogHeight));
		getContentPane().setPreferredSize(new Dimension(dialogWidth, dialogHeight));
		setPreferredSize(new Dimension(dialogWidth, dialogHeight));

		setMaximumSize(new Dimension(0, 0));
		setMinimumSize(new Dimension(dialogWidth, dialogHeight));
		setAlwaysOnTop(true);
		setFont(new Font("Dialog", Font.PLAIN, 12));
		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		setModalityType(ModalityType.APPLICATION_MODAL);
		setType(Type.UTILITY);
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				TransactionDetailsDialog.class
						.getResource("/pumpdemo/images/ITLLogo.png")));
		setTitle("Transaction Detail");
		setBounds(100, 100, 338, 290);
		getContentPane().setLayout(new BorderLayout(0, 0));
		{
			JPanel panel = new JPanel();
			panel.setMinimumSize(new Dimension(dialogWidth, dialogHeight));
			panel.setPreferredSize(new Dimension(dialogWidth, dialogHeight));
			getContentPane().add(panel, BorderLayout.CENTER);
			panel.setLayout(new BorderLayout(0, 0));
			panel.add(contentPanel, BorderLayout.CENTER);
			contentPanel.setBackground(UIManager.getColor("Button.background"));
			contentPanel.setBorder(new EmptyBorder(20, 20, 20, 20));
			GridBagLayout gbl_contentPanel = new GridBagLayout();
			gbl_contentPanel.columnWidths = new int[] { 123, 148, 0 };
			gbl_contentPanel.rowHeights = new int[] { 20, 20, 20, 0, 0, 0, 0,
					0, 0, 0 };
			gbl_contentPanel.columnWeights = new double[] { 0.0, 1.0,
					Double.MIN_VALUE };
			gbl_contentPanel.rowWeights = new double[] { 0.0, 0.0, 0.0, 0.0,
					0.0, 0.0, 0.0, 0.0, 0.0, Double.MIN_VALUE };
			contentPanel.setLayout(gbl_contentPanel);
			{
				JLabel lblTransctionID = new JLabel("Transaction ID");
				lblTransctionID.setFont(new Font("Dialog", Font.PLAIN, 12));
				lblTransctionID.setHorizontalAlignment(SwingConstants.LEFT);
				GridBagConstraints gbc_lblTransctionID = new GridBagConstraints();
				gbc_lblTransctionID.insets = new Insets(0, 0, 0, 20);
				gbc_lblTransctionID.anchor = GridBagConstraints.EAST;
				gbc_lblTransctionID.gridx = 0;
				gbc_lblTransctionID.gridy = 0;
				contentPanel.add(lblTransctionID, gbc_lblTransctionID);
			}
			{
				textTransactionID = new JTextField();
				textTransactionID.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_textTransactionID = new GridBagConstraints();
				gbc_textTransactionID.weightx = 1.0;
				gbc_textTransactionID.fill = GridBagConstraints.HORIZONTAL;
				gbc_textTransactionID.gridx = 1;
				gbc_textTransactionID.gridy = 0;
				contentPanel.add(textTransactionID, gbc_textTransactionID);
				textTransactionID.setColumns(20);
			}
			{
				JLabel lblDeliveryID = new JLabel("Delivery ID");
				lblDeliveryID.setFont(new Font("Dialog", Font.PLAIN, 12));
				lblDeliveryID.setHorizontalAlignment(SwingConstants.LEFT);
				GridBagConstraints gbc_lblDeliveryID = new GridBagConstraints();
				gbc_lblDeliveryID.insets = new Insets(0, 0, 0, 20);
				gbc_lblDeliveryID.anchor = GridBagConstraints.EAST;
				gbc_lblDeliveryID.gridx = 0;
				gbc_lblDeliveryID.gridy = 1;
				contentPanel.add(lblDeliveryID, gbc_lblDeliveryID);
			}
			{
				textDeliveryID = new JTextField();
				textDeliveryID.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_textDeliveryID = new GridBagConstraints();
				gbc_textDeliveryID.weightx = 1.0;
				gbc_textDeliveryID.fill = GridBagConstraints.HORIZONTAL;
				gbc_textDeliveryID.gridx = 1;
				gbc_textDeliveryID.gridy = 1;
				contentPanel.add(textDeliveryID, gbc_textDeliveryID);
				textDeliveryID.setColumns(20);
			}
			{
				JLabel lblClientReference = new JLabel("Client Reference");
				lblClientReference.setFont(new Font("Dialog", Font.PLAIN, 12));
				lblClientReference.setHorizontalAlignment(SwingConstants.LEFT);
				GridBagConstraints gbc_lblClientReference = new GridBagConstraints();
				gbc_lblClientReference.anchor = GridBagConstraints.EAST;
				gbc_lblClientReference.insets = new Insets(0, 0, 0, 20);
				gbc_lblClientReference.gridx = 0;
				gbc_lblClientReference.gridy = 2;
				contentPanel.add(lblClientReference, gbc_lblClientReference);
			}
			{
				textClientReference = new JTextField();
				textClientReference.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_textClientReference = new GridBagConstraints();
				gbc_textClientReference.weightx = 1.0;
				gbc_textClientReference.fill = GridBagConstraints.BOTH;
				gbc_textClientReference.gridx = 1;
				gbc_textClientReference.gridy = 2;
				contentPanel.add(textClientReference, gbc_textClientReference);
				textClientReference.setColumns(10);
			}
			{
				JLabel lblClientActivity = new JLabel("Client Activity");
				lblClientActivity.setFont(new Font("Dialog", Font.PLAIN, 12));
				GridBagConstraints gbc_lblClientActivity = new GridBagConstraints();
				gbc_lblClientActivity.anchor = GridBagConstraints.EAST;
				gbc_lblClientActivity.insets = new Insets(0, 0, 0, 20);
				gbc_lblClientActivity.gridx = 0;
				gbc_lblClientActivity.gridy = 3;
				contentPanel.add(lblClientActivity, gbc_lblClientActivity);
			}
			{
				textClientActivity = new JTextField();
				textClientActivity.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_textClientActivity = new GridBagConstraints();
				gbc_textClientActivity.fill = GridBagConstraints.BOTH;
				gbc_textClientActivity.gridx = 1;
				gbc_textClientActivity.gridy = 3;
				contentPanel.add(textClientActivity, gbc_textClientActivity);
				textClientActivity.setColumns(10);
			}
			{
				JLabel lblAttendantId = new JLabel("Attendant ID");
				lblAttendantId.setFont(new Font("Dialog", Font.PLAIN, 12));
				GridBagConstraints gbc_lblAttendantId = new GridBagConstraints();
				gbc_lblAttendantId.insets = new Insets(0, 0, 0, 20);
				gbc_lblAttendantId.anchor = GridBagConstraints.EAST;
				gbc_lblAttendantId.gridx = 0;
				gbc_lblAttendantId.gridy = 4;
				contentPanel.add(lblAttendantId, gbc_lblAttendantId);
			}
			{
				txtAttendantId = new JTextField();
				txtAttendantId.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_txtAttendantId = new GridBagConstraints();
				gbc_txtAttendantId.fill = GridBagConstraints.HORIZONTAL;
				gbc_txtAttendantId.gridx = 1;
				gbc_txtAttendantId.gridy = 4;
				contentPanel.add(txtAttendantId, gbc_txtAttendantId);
				txtAttendantId.setColumns(10);
			}
			{
				JLabel lblGrade = new JLabel("Grade");
				lblGrade.setFont(new Font("Dialog", Font.PLAIN, 12));
				GridBagConstraints gbc_lblGrade = new GridBagConstraints();
				gbc_lblGrade.insets = new Insets(0, 0, 0, 20);
				gbc_lblGrade.anchor = GridBagConstraints.EAST;
				gbc_lblGrade.gridx = 0;
				gbc_lblGrade.gridy = 5;
				contentPanel.add(lblGrade, gbc_lblGrade);
			}
			{
				txtGrade = new JTextField();
				txtGrade.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_txtGrade = new GridBagConstraints();
				gbc_txtGrade.fill = GridBagConstraints.HORIZONTAL;
				gbc_txtGrade.gridx = 1;
				gbc_txtGrade.gridy = 5;
				contentPanel.add(txtGrade, gbc_txtGrade);
				txtGrade.setColumns(10);
			}
			{
				JLabel lblPrice = new JLabel("Price");
				lblPrice.setFont(new Font("Dialog", Font.PLAIN, 12));
				GridBagConstraints gbc_lblPrice = new GridBagConstraints();
				gbc_lblPrice.anchor = GridBagConstraints.EAST;
				gbc_lblPrice.insets = new Insets(0, 0, 0, 20);
				gbc_lblPrice.gridx = 0;
				gbc_lblPrice.gridy = 6;
				contentPanel.add(lblPrice, gbc_lblPrice);
			}
			{
				txtPrice = new JTextField();
				txtPrice.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_txtPrice = new GridBagConstraints();
				gbc_txtPrice.fill = GridBagConstraints.HORIZONTAL;
				gbc_txtPrice.gridx = 1;
				gbc_txtPrice.gridy = 6;
				contentPanel.add(txtPrice, gbc_txtPrice);
				txtPrice.setColumns(10);
			}
			{
				JLabel lblQuantity = new JLabel("Quantity");
				lblQuantity.setFont(new Font("Dialog", Font.PLAIN, 12));
				GridBagConstraints gbc_lblQuantity = new GridBagConstraints();
				gbc_lblQuantity.anchor = GridBagConstraints.EAST;
				gbc_lblQuantity.insets = new Insets(0, 0, 0, 20);
				gbc_lblQuantity.gridx = 0;
				gbc_lblQuantity.gridy = 7;
				contentPanel.add(lblQuantity, gbc_lblQuantity);
			}
			{
				txtQuantity = new JTextField();
				txtQuantity.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_txtQuantity = new GridBagConstraints();
				gbc_txtQuantity.fill = GridBagConstraints.HORIZONTAL;
				gbc_txtQuantity.gridx = 1;
				gbc_txtQuantity.gridy = 7;
				contentPanel.add(txtQuantity, gbc_txtQuantity);
				txtQuantity.setColumns(10);
			}
			{
				JLabel lblValue = new JLabel("Value");
				lblValue.setFont(new Font("Dialog", Font.PLAIN, 12));
				GridBagConstraints gbc_lblValue = new GridBagConstraints();
				gbc_lblValue.anchor = GridBagConstraints.EAST;
				gbc_lblValue.insets = new Insets(0, 0, 0, 20);
				gbc_lblValue.gridx = 0;
				gbc_lblValue.gridy = 8;
				contentPanel.add(lblValue, gbc_lblValue);
			}
			{
				txtValue = new JTextField();
				txtValue.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_txtValue = new GridBagConstraints();
				gbc_txtValue.fill = GridBagConstraints.HORIZONTAL;
				gbc_txtValue.gridx = 1;
				gbc_txtValue.gridy = 8;
				contentPanel.add(txtValue, gbc_txtValue);
				txtValue.setColumns(10);
			}
			{
				JLabel lblState = new JLabel("State");
				lblState.setFont(new Font("Dialog", Font.PLAIN, 12));
				GridBagConstraints gbc_lblState = new GridBagConstraints();
				gbc_lblState.anchor = GridBagConstraints.EAST;
				gbc_lblState.insets = new Insets(0, 0, 0, 20);
				gbc_lblState.gridx = 0;
				gbc_lblState.gridy = 9;
				contentPanel.add(lblState, gbc_lblState);
			}
			{
				txtState = new JTextField();
				txtState.setMaximumSize(new Dimension(6, 20));
				GridBagConstraints gbc_txtState = new GridBagConstraints();
				gbc_txtState.fill = GridBagConstraints.HORIZONTAL;
				gbc_txtState.gridx = 1;
				gbc_txtState.gridy = 9;
				contentPanel.add(txtState, gbc_txtState);
				txtState.setColumns(10);
			}
			{
				JPanel buttonPane = new JPanel();
				panel.add(buttonPane, BorderLayout.SOUTH);
				buttonPane.setBorder(new EmptyBorder(0, 0, 2, 0));
				buttonPane.setLayout(new FlowLayout(FlowLayout.CENTER));
				{
					reinstateButton = new JButton("Reinstate");
					reinstateButton.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent e) {
							try {
								transaction.reinstate();
							} catch (EnablerException ex) {
								mainWindow.showEnablerError(ex);
							}
							// close the dialog now
							dispose(); 
						}
					});
					reinstateButton.setFont(new Font("Dialog",Font.PLAIN, 12));
					reinstateButton.setEnabled(false);
					reinstateButton.setActionCommand("OK");
					buttonPane.add(reinstateButton);
					getRootPane().setDefaultButton(reinstateButton);
				}
				{
					reinstateAndLockButton = new JButton("Reinstate And Lock");
					reinstateAndLockButton.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent e) {
							try {
								transaction.reinstateAndLock();
							} catch (EnablerException ex) {
								mainWindow.showEnablerError(ex);
							}
							
							// close the dialog now
							dispose(); 
						}
					});
					reinstateAndLockButton.setFont(new Font("Dialog", Font.PLAIN, 12));
					reinstateAndLockButton.setEnabled(false);
					reinstateAndLockButton.setActionCommand("OK");
					buttonPane.add(reinstateAndLockButton);
					getRootPane().setDefaultButton(reinstateAndLockButton);
				}
				{
					JButton exitButton = new JButton("Exit");
					exitButton.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent arg0) {
							dispose();
						}
					});
					exitButton.setFont(new Font("Dialog", Font.PLAIN, 12));
					exitButton.setActionCommand("Cancel");
					buttonPane.add(exitButton);
				}
			}
		}

		// populate all fields with Transaction data
		loadTransaction();
	}

	private void loadTransaction() {

		textTransactionID.setText(Integer.toString(transaction.getId()));
		
		textDeliveryID.setText(Integer.toString(transaction.getDeliveryData().getDeliveryID()));

		textClientReference.setText(transaction.getClientReference().trim());

		textClientActivity.setText(transaction.getClientActivity().trim());

		if (transaction.getAttendant() == null)
			txtAttendantId.setText("");
		else {
			String text = String.format("%s(%s)", transaction.getAttendant()
					.getName(), transaction.getAttendant().getLogOnID());
			txtAttendantId.setText(text);
		}

		if (transaction.getState() == TransactionState.COMPLETED
				|| transaction.getState() == TransactionState.CLEARED) {
			DeliveryData deliveryData = transaction.getDeliveryData();

			if (deliveryData.getGrade() == null) {
				txtGrade.setText("(no grade selected)");
			}
			else{
				txtGrade.setText(deliveryData.getGrade().getName().trim());
			}

			txtPrice.setText(Double.toString(deliveryData.getUnitPrice()));
			txtQuantity.setText(Double.toString(deliveryData.getQuantity()));
			txtValue.setText(Double.toString(deliveryData.getMoney()));
		}

		txtState.setText(transaction.getState().toString());

		if (transaction.getState() == TransactionState.CLEARED) {
			reinstateButton.setEnabled(true);
			reinstateAndLockButton.setEnabled(true);
		}

	}

}
