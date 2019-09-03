package pumpdemo;

import itl.enabler.api.EnablerException;
import itl.enabler.api.Transaction;

import java.awt.BorderLayout;
import java.awt.FlowLayout;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.JRadioButton;
import java.awt.Font;
import javax.swing.JLabel;
import javax.swing.JTextField;
import javax.swing.ButtonGroup;
import java.awt.Toolkit;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.UIManager;

@SuppressWarnings("serial")
public class LookupTransactionDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();
	private JTextField textFieldLookupData;
	private final ButtonGroup buttonGroup = new ButtonGroup();

	private MainWindow mainWindow;
	private Transaction transaction = null;

	public Transaction getTransaction() {
		return transaction;
	}

	/**
	 * Create the dialog.
	 * 
	 * @param transaction
	 * @param mainWindow
	 */
	public LookupTransactionDialog(MainWindow app) {
		setBackground(UIManager.getColor("Button.background"));
		getContentPane().setBackground(UIManager.getColor("Button.background"));
		setModalityType(ModalityType.APPLICATION_MODAL);

		mainWindow = app;

		setResizable(false);
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				LookupTransactionDialog.class
						.getResource("/pumpdemo/images/ITLLogo.png")));
		setTitle("Lookup Transaction");
		setBounds(100, 100, 299, 207);
		getContentPane().setLayout(new BorderLayout());
		contentPanel.setBackground(UIManager.getColor("Button.background"));
		contentPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		contentPanel.setLayout(null);

		final JRadioButton rdbtnLookupByID = new JRadioButton(
				"By Transaction ID");
		rdbtnLookupByID.setBackground(UIManager.getColor("Button.background"));
		buttonGroup.add(rdbtnLookupByID);
		rdbtnLookupByID.setFont(new Font("Dialog", Font.PLAIN, 12));
		rdbtnLookupByID.setBounds(8, 21, 157, 24);
		rdbtnLookupByID.setSelected(true);
		contentPanel.add(rdbtnLookupByID);

		JRadioButton rdbtnLookupByRef = new JRadioButton("By Client Reference");
		rdbtnLookupByRef.setBackground(UIManager.getColor("Button.background"));
		buttonGroup.add(rdbtnLookupByRef);
		rdbtnLookupByRef.setFont(new Font("Dialog", Font.PLAIN, 12));
		rdbtnLookupByRef.setBounds(8, 49, 139, 24);
		contentPanel.add(rdbtnLookupByRef);

		JLabel lblLookupDats = new JLabel("Lookup Data");
		lblLookupDats.setFont(new Font("Dialog", Font.PLAIN, 12));
		lblLookupDats.setBounds(8, 93, 99, 16);
		contentPanel.add(lblLookupDats);

		textFieldLookupData = new JTextField();
		textFieldLookupData.setBounds(92, 91, 188, 20);
		contentPanel.add(textFieldLookupData);
		textFieldLookupData.setColumns(10);
		{
			JPanel buttonPane = new JPanel();
			buttonPane.setLayout(new FlowLayout(FlowLayout.RIGHT));
			getContentPane().add(buttonPane, BorderLayout.SOUTH);
			{
				JButton btLookup = new JButton("Lookup");
				btLookup.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {

						String lookupData = textFieldLookupData.getText()
								.trim();
						// by ID
						if (rdbtnLookupByID.isSelected() == true) {
							try {

								int transactionID = Integer
										.parseInt(lookupData);
								transaction = mainWindow.forecourt
										.getTransactionById(transactionID);
							} catch (NumberFormatException ex) {
								JOptionPane.showMessageDialog(getParent(),
										"Invalid Transaction ID",
										mainWindow.frmPumpDemo.getTitle()
												+ "Lookup Transaction",
										JOptionPane.ERROR_MESSAGE);
							} catch (EnablerException ex) {
								mainWindow.showEnablerError(ex);
							}
						} // by ref
						else {
							if (lookupData.isEmpty()) {
								JOptionPane.showMessageDialog(getParent(),
										"Client reference missing",
										mainWindow.frmPumpDemo.getTitle()
												+ "Lookup Transaction",
										JOptionPane.ERROR_MESSAGE);
							}
							try {
								transaction = mainWindow.forecourt
										.getTransactionByReference(lookupData);
							} catch (EnablerException ex) {
								mainWindow.showEnablerError(ex);
							}
						}

						setVisible(false);
					}
				});

				btLookup.setActionCommand("OK");
				buttonPane.add(btLookup);
				getRootPane().setDefaultButton(btLookup);
			}
			{
				JButton cancelButton = new JButton("Cancel");
				cancelButton.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent arg0) {
						transaction = null;
						setVisible(false);
					}
				});
				cancelButton.setActionCommand("Cancel");
				buttonPane.add(cancelButton);
			}
		}
	}
}
