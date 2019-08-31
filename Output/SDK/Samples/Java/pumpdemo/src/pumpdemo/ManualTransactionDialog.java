/**
 * ManualTransactionDialog.java
 * 
 * Copyright 1997-2012 Integration Technologies Limited
 * All rights reserved.
 * 
 */
package pumpdemo;

import javax.swing.JDialog;
import javax.swing.JPanel;
import java.awt.BorderLayout;
import java.awt.Dimension;
import net.miginfocom.swing.MigLayout;
import javax.swing.border.EmptyBorder;
import javax.swing.JLabel;
import java.awt.Font;

import javax.swing.JOptionPane;
import javax.swing.JTextField;
import javax.swing.JButton;
import javax.swing.ImageIcon;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.SwingConstants;

/**
 * Dialog class for entering a transaction for manual pumps
 */
@SuppressWarnings("serial")
public class ManualTransactionDialog extends JDialog {
	private JTextField textFieldVolume;
	private JTextField textFieldValue;
	private JTextField textFieldPrice;

	public ManualTransactionDialog(final ManualTransaction transaction) {
		setBounds(100, 100, 200, 250);
		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		setModalityType(ModalityType.APPLICATION_MODAL);
		setResizable(false);

		setTitle("Enter Manual Transaction");

		JPanel panelText = new JPanel();
		panelText.setBorder(new EmptyBorder(10, 10, 10, 10));
		getContentPane().add(panelText, BorderLayout.CENTER);
		panelText.setLayout(new MigLayout("", "[right]7[grow,right]",
				"[]10[]10[]"));

		JLabel lblVolume = new JLabel("Volume");
		lblVolume.setFont(new Font("Tahoma", Font.PLAIN, 14));
		panelText.add(lblVolume, "cell 0 0");

		textFieldVolume = new JTextField();
		textFieldVolume.setText("0");
		textFieldVolume.setHorizontalAlignment(SwingConstants.TRAILING);
		textFieldVolume.setFont(new Font("Tahoma", Font.BOLD, 14));
		panelText.add(textFieldVolume, "cell 1 0,growx");
		textFieldVolume.setColumns(10);

		JLabel lblValue = new JLabel("Value");
		lblValue.setFont(new Font("Tahoma", Font.PLAIN, 14));
		panelText.add(lblValue, "cell 0 1");

		textFieldValue = new JTextField();
		textFieldValue.setText("0");
		textFieldValue.setHorizontalAlignment(SwingConstants.TRAILING);
		textFieldValue.setFont(new Font("Tahoma", Font.BOLD, 14));
		panelText.add(textFieldValue, "cell 1 1,growx");
		textFieldValue.setColumns(10);

		JLabel lblPrice = new JLabel("Price");
		lblPrice.setFont(new Font("Tahoma", Font.PLAIN, 14));
		panelText.add(lblPrice, "cell 0 2");

		textFieldPrice = new JTextField();
		textFieldPrice.setText("0");
		textFieldPrice.setHorizontalAlignment(SwingConstants.TRAILING);
		textFieldPrice.setFont(new Font("Tahoma", Font.BOLD, 14));
		panelText.add(textFieldPrice, "cell 1 2,growx");
		textFieldPrice.setColumns(10);

		JPanel panelButtons = new JPanel();
		panelButtons.setBorder(new EmptyBorder(10, 10, 10, 10));
		panelButtons.setPreferredSize(new Dimension(10, 85));
		getContentPane().add(panelButtons, BorderLayout.SOUTH);
		panelButtons.setLayout(new MigLayout("", "[grow][]", "[]"));

		JButton buttonOk = new JButton("");
		buttonOk.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {

				double volume = 0.0;
				try {
					volume = Double.parseDouble(textFieldVolume.getText());
				} catch (NumberFormatException ex) {
					JOptionPane.showMessageDialog(getParent(),
							"Invalid Transaction Volume", getTitle(),
							JOptionPane.ERROR_MESSAGE);
				}

				double value = 0.0;
				try {
					value = Double.parseDouble(textFieldValue.getText());
				} catch (NumberFormatException ex) {
					JOptionPane.showMessageDialog(getParent(),
							"Invalid Transaction Value", getTitle(),
							JOptionPane.ERROR_MESSAGE);
				}

				double price = 0.0;
				try {
					price = Double.parseDouble(textFieldPrice.getText());
				} catch (NumberFormatException ex) {
					JOptionPane.showMessageDialog(getParent(),
							"Invalid Transaction Price", getTitle(),
							JOptionPane.ERROR_MESSAGE);
				}

				transaction.price = price;
				transaction.value = value;
				transaction.volume = volume;

				dispose();
			}
		});
		buttonOk.setIcon(new ImageIcon(ManualTransactionDialog.class
				.getResource("/pumpdemo/images/OK.png")));
		buttonOk.setPreferredSize(new Dimension(65, 60));
		panelButtons.add(buttonOk, "cell 0 0");

		JButton buttonCancel = new JButton("");
		buttonCancel.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				textFieldPrice.setText("");
				textFieldValue.setText("");
				textFieldVolume.setText("");
				dispose();
			}
		});
		buttonCancel.setIcon(new ImageIcon(ManualTransactionDialog.class
				.getResource("/pumpdemo/images/Cancel.png")));
		buttonCancel.setPreferredSize(new Dimension(65, 60));
		panelButtons.add(buttonCancel, "cell 1 0");
	}

}

class ManualTransaction {
	double volume;
	double value;
	double price;
}
