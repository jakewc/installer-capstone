package pumpdemo;

import java.awt.BorderLayout;
import java.awt.FlowLayout;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.JLabel;
import java.awt.Font;
import javax.swing.JComboBox;
import java.awt.Rectangle;
import java.awt.Dimension;
import java.awt.SystemColor;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JCheckBox;
import java.awt.Toolkit;

@SuppressWarnings("serial")
public class TankControlDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		try {
			TankControlDialog dialog = new TankControlDialog();
			dialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
			dialog.setVisible(true);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Create the dialog.
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public TankControlDialog() {
		setResizable(false);
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				TankControlDialog.class.getResource("/pumpdemo/ITLLogo.png")));
		setTitle("Tank Control Settings");
		setBounds(100, 100, 262, 239);
		getContentPane().setLayout(new BorderLayout());
		contentPanel.setBackground(SystemColor.info);
		contentPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		contentPanel.setLayout(null);
		{
			JLabel lblStyle = new JLabel("Style :");
			lblStyle.setBounds(20, -1, 37, 162);
			lblStyle.setFont(new Font("Dialog", Font.PLAIN, 12));
			contentPanel.add(lblStyle);
		}
		{
			JComboBox comboBoxStyleType = new JComboBox();
			comboBoxStyleType.setModel(new DefaultComboBoxModel(new String[] {
					"Chart Only", "Detail Only", "Chart + Detail on right",
					"Chart + Detail on bottom" }));
			comboBoxStyleType.setMaximumSize(new Dimension(110, 20));
			comboBoxStyleType.setBounds(new Rectangle(66, 70, 140, 20));
			comboBoxStyleType.setFont(new Font("Dialog", Font.PLAIN, 12));
			contentPanel.add(comboBoxStyleType);
		}

		JCheckBox chckbxShowAllTanks = new JCheckBox(
				"Show all tanks in one control");
		chckbxShowAllTanks.setBackground(SystemColor.info);
		chckbxShowAllTanks.setFont(new Font("Monospaced", Font.PLAIN, 12));
		chckbxShowAllTanks.setBounds(20, 119, 230, 20);
		contentPanel.add(chckbxShowAllTanks);
		{
			JPanel buttonPane = new JPanel();
			buttonPane.setLayout(new FlowLayout(FlowLayout.RIGHT));
			getContentPane().add(buttonPane, BorderLayout.SOUTH);
			{
				JButton okButton = new JButton("OK");
				okButton.setPreferredSize(new Dimension(73, 26));
				okButton.setMaximumSize(new Dimension(73, 26));
				okButton.setMinimumSize(new Dimension(73, 26));
				okButton.setActionCommand("OK");
				buttonPane.add(okButton);
				getRootPane().setDefaultButton(okButton);
			}
			{
				JButton cancelButton = new JButton("Cancel");
				cancelButton.setMinimumSize(new Dimension(51, 26));
				cancelButton.setMaximumSize(new Dimension(51, 26));
				cancelButton.setActionCommand("Cancel");
				buttonPane.add(cancelButton);
			}
		}
	}
}
