package pumpdemo;

import java.awt.BorderLayout;
import java.awt.FlowLayout;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.JLabel;
import java.awt.Font;
import java.awt.Toolkit;
import java.awt.SystemColor;

@SuppressWarnings("serial")
public class ConnectionDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();

	/**
	 * Create the dialog.
	 */
	public ConnectionDialog() {
		setResizable(false);
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				ConnectionDialog.class.getResource("/pumpdemo/ITLLogo.png")));
		setType(Type.POPUP);
		setBounds(100, 100, 299, 124);
		getContentPane().setLayout(new BorderLayout());
		contentPanel.setBackground(SystemColor.info);
		contentPanel.setLayout(new FlowLayout());
		contentPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		{
			JLabel lblEnablerOffline = new JLabel(
					"Enabler offline .. Reconnecting");
			lblEnablerOffline.setFont(new Font("Dialog", Font.BOLD, 18));
			contentPanel.add(lblEnablerOffline);
		}
		{
			JPanel buttonPane = new JPanel();
			buttonPane.setLayout(new FlowLayout(FlowLayout.CENTER));
			getContentPane().add(buttonPane, BorderLayout.SOUTH);
			{
				JButton cancelButton = new JButton("Cancel");
				cancelButton.setActionCommand("Cancel");
				buttonPane.add(cancelButton);
			}
		}
	}

}
