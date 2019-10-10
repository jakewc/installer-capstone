package pumpdemo;

import java.awt.BorderLayout;
import java.awt.FlowLayout;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import java.awt.Component;
import java.awt.Dimension;
import javax.swing.border.TitledBorder;
import java.awt.SystemColor;
import javax.swing.JLabel;
import java.awt.Font;
import javax.swing.JComboBox;
import javax.swing.DefaultComboBoxModel;
import javax.swing.border.LineBorder;
import java.awt.Color;
import javax.swing.JCheckBox;
import javax.swing.JTextField;
import java.awt.Toolkit;

@SuppressWarnings("serial")
public class PumpControlDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();
	private JTextField textValueMask;
	private JTextField textValueSymbol;
	private JTextField textQuantityMask;
	private JTextField txtQuantitySymbol;

	enum Sounds {
		Asterix, Beep, Exclamation, Hand, Question
	}

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		try {
			PumpControlDialog dialog = new PumpControlDialog();
			dialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
			dialog.setVisible(true);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Create the dialog.
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public PumpControlDialog() {
		setResizable(false);
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				PumpControlDialog.class.getResource("/pumpdemo/ITLLogo.png")));
		setTitle("Pump Control Settings");
		setBounds(100, 100, 464, 338);
		getContentPane().setLayout(new BorderLayout());
		contentPanel.setBackground(SystemColor.info);
		contentPanel.setBorder(new EmptyBorder(3, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		contentPanel.setLayout(new BorderLayout(5, 0));
		{
			JPanel panelCurrDelivery = new JPanel();
			panelCurrDelivery.setPreferredSize(new Dimension(165, 10));
			panelCurrDelivery.setBackground(SystemColor.info);
			panelCurrDelivery.setBorder(new TitledBorder(null,
					"Current Delivery", TitledBorder.LEADING, TitledBorder.TOP,
					null, null));
			contentPanel.add(panelCurrDelivery, BorderLayout.CENTER);
			panelCurrDelivery.setAlignmentX(Component.LEFT_ALIGNMENT);
			panelCurrDelivery.setLayout(null);

			JCheckBox chckbxShowGradeName = new JCheckBox("Show Grade Name");
			chckbxShowGradeName.setFont(new Font("Dialog", Font.PLAIN, 12));
			chckbxShowGradeName.setBackground(SystemColor.info);
			chckbxShowGradeName.setBounds(22, 28, 135, 24);
			panelCurrDelivery.add(chckbxShowGradeName);

			JCheckBox chckbxShowValue = new JCheckBox("Show Value");
			chckbxShowValue.setFont(new Font("Dialog", Font.PLAIN, 12));
			chckbxShowValue.setBackground(SystemColor.info);
			chckbxShowValue.setBounds(22, 46, 112, 24);
			panelCurrDelivery.add(chckbxShowValue);

			JCheckBox chckbxShowQuantity = new JCheckBox("Show Quantity");
			chckbxShowQuantity.setFont(new Font("Dialog", Font.PLAIN, 12));
			chckbxShowQuantity.setBackground(SystemColor.info);
			chckbxShowQuantity.setBounds(22, 64, 112, 24);
			panelCurrDelivery.add(chckbxShowQuantity);

			textValueMask = new JTextField();
			textValueMask.setText("{0:C02}");
			textValueMask.setBounds(110, 112, 70, 20);
			panelCurrDelivery.add(textValueMask);
			textValueMask.setColumns(10);

			JLabel lblValueMask = new JLabel("Value mask :");
			lblValueMask.setFont(new Font("Dialog", Font.PLAIN, 12));
			lblValueMask.setBounds(7, 114, 73, 16);
			panelCurrDelivery.add(lblValueMask);

			textValueSymbol = new JTextField();
			textValueSymbol.setText("$");
			textValueSymbol.setBounds(110, 144, 70, 20);
			panelCurrDelivery.add(textValueSymbol);
			textValueSymbol.setColumns(10);

			JLabel lblValuesymbol = new JLabel("ValueSymbol :");
			lblValuesymbol.setFont(new Font("Dialog", Font.PLAIN, 12));
			lblValuesymbol.setBounds(7, 146, 89, 16);
			panelCurrDelivery.add(lblValuesymbol);

			textQuantityMask = new JTextField();
			textQuantityMask.setText("{1}{0:F02}");
			textQuantityMask.setBounds(110, 176, 70, 20);
			panelCurrDelivery.add(textQuantityMask);
			textQuantityMask.setColumns(10);

			JLabel lblQuantityMask = new JLabel("Quantity Mask :");
			lblQuantityMask.setFont(new Font("Dialog", Font.PLAIN, 12));
			lblQuantityMask.setBounds(7, 178, 89, 16);
			panelCurrDelivery.add(lblQuantityMask);

			txtQuantitySymbol = new JTextField();
			txtQuantitySymbol.setText("L");
			txtQuantitySymbol.setBounds(110, 208, 70, 20);
			panelCurrDelivery.add(txtQuantitySymbol);
			txtQuantitySymbol.setColumns(10);

			JLabel lblQuantitySymbiol = new JLabel("Quantity Symbol :");
			lblQuantitySymbiol.setFont(new Font("Dialog", Font.PLAIN, 12));
			lblQuantitySymbiol.setBounds(7, 210, 97, 16);
			panelCurrDelivery.add(lblQuantitySymbiol);
		}
		{
			JPanel panelExtras = new JPanel();
			panelExtras.setPreferredSize(new Dimension(250, 10));
			panelExtras.setAlignmentX(Component.LEFT_ALIGNMENT);
			panelExtras.setBackground(SystemColor.info);
			contentPanel.add(panelExtras, BorderLayout.EAST);
			panelExtras.setLayout(null);

			JPanel panelStyle = new JPanel();
			panelStyle.setBackground(SystemColor.info);
			panelStyle.setBorder(new TitledBorder(null,
					"Select style (Overrides Show)", TitledBorder.LEADING,
					TitledBorder.TOP, null, null));
			panelStyle.setBounds(5, 0, 245, 60);
			panelExtras.add(panelStyle);
			panelStyle.setLayout(null);

			JLabel lblStyle = new JLabel("Style");
			lblStyle.setFont(new Font("Dialog", Font.PLAIN, 12));
			lblStyle.setBounds(12, 26, 35, 16);
			panelStyle.add(lblStyle);

			JComboBox comboBoxStyles = new JComboBox();
			comboBoxStyles.setFont(new Font("Dialog", Font.PLAIN, 12));
			comboBoxStyles.setModel(new DefaultComboBoxModel(new String[] {
					"None", "Small 80 x 80", "Medium 100 x 100",
					"Large 150 x 150" }));
			comboBoxStyles.setBounds(123, 24, 110, 20);
			panelStyle.add(comboBoxStyles);

			JPanel panelSounds = new JPanel();
			panelSounds.setBackground(SystemColor.info);
			panelSounds.setBorder(new TitledBorder(new LineBorder(new Color(
					184, 207, 229)), "Sounds", TitledBorder.LEADING,
					TitledBorder.TOP, null, null));
			panelSounds.setBounds(5, 65, 245, 195);
			panelExtras.add(panelSounds);
			panelSounds.setLayout(null);

			JCheckBox chckbxNewCheckBox = new JCheckBox("Enables sounds");
			chckbxNewCheckBox.setFont(new Font("Dialog", Font.PLAIN, 12));
			chckbxNewCheckBox.setBackground(SystemColor.info);
			chckbxNewCheckBox.setBounds(8, 17, 129, 24);
			panelSounds.add(chckbxNewCheckBox);

			JLabel lblnote = new JLabel(
					"<html>Select which system sounds to play for following events.Also, can have any other sound file.<html>");
			lblnote.setFont(new Font("Tahoma", Font.PLAIN, 10));
			lblnote.setBounds(12, 30, 225, 42);
			panelSounds.add(lblnote);

			JLabel lblCalling = new JLabel("Calling");
			lblCalling.setFont(new Font("Dialog", Font.PLAIN, 12));
			lblCalling.setBounds(8, 81, 55, 16);
			panelSounds.add(lblCalling);

			JLabel lblAuthorised = new JLabel("Authorised");
			lblAuthorised.setFont(new Font("Dialog", Font.PLAIN, 12));
			lblAuthorised.setBounds(8, 105, 69, 16);
			panelSounds.add(lblAuthorised);

			JLabel lblDeliveryCompleted = new JLabel("Delivery completed");
			lblDeliveryCompleted.setFont(new Font("Dialog", Font.PLAIN, 12));
			lblDeliveryCompleted.setBounds(8, 130, 105, 16);
			panelSounds.add(lblDeliveryCompleted);

			JLabel lblNozzleLeftOut = new JLabel("Nozzle left out");
			lblNozzleLeftOut.setFont(new Font("Dialog", Font.PLAIN, 12));
			lblNozzleLeftOut.setBounds(8, 155, 101, 16);
			panelSounds.add(lblNozzleLeftOut);

			JComboBox comboBoxCalling = new JComboBox();
			comboBoxCalling.setFont(new Font("Dialog", Font.PLAIN, 12));
			comboBoxCalling.setModel(new DefaultComboBoxModel(Sounds.values()));
			comboBoxCalling.setBounds(123, 77, 110, 20);
			panelSounds.add(comboBoxCalling);

			JComboBox comboBoxAuth = new JComboBox();
			comboBoxAuth.setFont(new Font("Dialog", Font.PLAIN, 12));
			comboBoxAuth.setModel(new DefaultComboBoxModel(Sounds.values()));
			comboBoxAuth.setBounds(123, 101, 110, 20);
			panelSounds.add(comboBoxAuth);

			JComboBox comboBoxDelivery = new JComboBox();
			comboBoxDelivery.setFont(new Font("Dialog", Font.PLAIN, 12));
			comboBoxDelivery
					.setModel(new DefaultComboBoxModel(Sounds.values()));
			comboBoxDelivery.setBounds(123, 126, 110, 20);
			panelSounds.add(comboBoxDelivery);

			JComboBox comboBoxNozzleLeftOut = new JComboBox();
			comboBoxNozzleLeftOut.setFont(new Font("Dialog", Font.PLAIN, 12));
			comboBoxNozzleLeftOut.setModel(new DefaultComboBoxModel(Sounds
					.values()));
			comboBoxNozzleLeftOut.setBounds(123, 155, 110, 20);
			panelSounds.add(comboBoxNozzleLeftOut);
		}
		{
			JPanel buttonPane = new JPanel();
			buttonPane.setLayout(new FlowLayout(FlowLayout.RIGHT));
			getContentPane().add(buttonPane, BorderLayout.SOUTH);
			{
				JButton okButton = new JButton("OK");
				okButton.setPreferredSize(new Dimension(73, 26));
				okButton.setActionCommand("OK");
				buttonPane.add(okButton);
				getRootPane().setDefaultButton(okButton);
			}
			{
				JButton cancelButton = new JButton("Cancel");
				cancelButton.setActionCommand("Cancel");
				buttonPane.add(cancelButton);
			}
		}
	}
}
