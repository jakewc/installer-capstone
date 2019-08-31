package pumpdemo;

import java.awt.BorderLayout;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JPanel;
import java.awt.SystemColor;
import java.awt.Toolkit;
import javax.swing.JCheckBox;
import java.awt.Component;
import javax.swing.SwingConstants;
import java.awt.Dimension;
import javax.swing.JLabel;
import javax.swing.ImageIcon;
import java.awt.Font;
import javax.swing.JTextField;
import javax.swing.JPasswordField;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.util.prefs.Preferences;
import javax.swing.border.LineBorder;
import java.awt.Color;
import net.miginfocom.swing.MigLayout;

@SuppressWarnings("serial")
public class LogonDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();
	private JTextField textServer;
	private JTextField textTerminal;
	private JPasswordField pwdPassword;
	private JCheckBox chckbxActiveTerminal;
	private JButton okButton;

	// Preferences
	Preferences preference = Preferences.userRoot().node(
			this.getClass().getName());
	private static final String prefServerName = "Server";
	private static final String prefTermId = "TerminalId";
	private static final String prefPassword = "Password";

	// Model
	public String server;
	public int terminalID;
	public char[] password;
	public boolean active;
	public boolean result = false;
	private JButton btnExitApp;

	/**
	 * Create the dialog.
	 * 
	 * @param frmPumpDemo
	 */
	public LogonDialog(final JFrame frmPumpDemo) {

		super(frmPumpDemo);
		setModalityType(ModalityType.DOCUMENT_MODAL);
		setUndecorated(true);
		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		setResizable(false);
		setAlwaysOnTop(true);
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				LogonDialog.class.getResource("/pumpdemo/images/ITLLogo.png")));
		setBounds(100, 100, 450, 273);
		BorderLayout borderLayout = new BorderLayout();
		borderLayout.setHgap(5);
		getContentPane().setLayout(borderLayout);
		contentPanel.setBorder(new LineBorder(new Color(0, 0, 0), 2, true));
		contentPanel.setPreferredSize(new Dimension(100, 84));
		contentPanel.setMinimumSize(new Dimension(100, 84));
		contentPanel.setMaximumSize(new Dimension(100, 84));
		contentPanel.setAlignmentX(Component.LEFT_ALIGNMENT);
		contentPanel.setFont(new Font("Tahoma", Font.PLAIN, 11));
		contentPanel.setBackground(SystemColor.info);
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		contentPanel.setLayout(new MigLayout("",
				"[141px]10[112px]10[47px,grow]",
				"[]25[24px][47px][24px][25px][]"));
		{
			JLabel lblEnablerLogon = new JLabel("Enabler Logon");
			lblEnablerLogon.setFont(new Font("Dialog", Font.BOLD, 22));
			contentPanel.add(lblEnablerLogon, "cell 1 0");
		}
		{
			JLabel lblTheEnablerServer = new JLabel("The Enabler Server :");
			lblTheEnablerServer.setAlignmentX(Component.RIGHT_ALIGNMENT);
			lblTheEnablerServer.setFont(new Font("Dialog", Font.PLAIN, 14));
			contentPanel.add(lblTheEnablerServer,
					"cell 1 1,alignx right,aligny center");
		}
		{
			textServer = new JTextField();
			textServer.setFont(new Font("Dialog", Font.PLAIN, 12));
			textServer.setText(preference.get(prefServerName, "localhost"));
			contentPanel.add(textServer, "cell 2 1,growx,aligny top");
			textServer.setColumns(10);
		}
		{
			JLabel lblNewLogo = new JLabel("");
			lblNewLogo.setIcon(new ImageIcon(LogonDialog.class
					.getResource("/pumpdemo/images/ITLLogo.png")));
			contentPanel.add(lblNewLogo, "cell 0 2,alignx left,aligny top");
		}
		{
			JLabel lblTerminalId = new JLabel("Terminal ID :");
			lblTerminalId.setFont(new Font("Dialog", Font.PLAIN, 14));
			contentPanel.add(lblTerminalId,
					"cell 1 2,alignx right,aligny center");
		}
		{
			textTerminal = new JTextField();
			textTerminal.setFont(new Font("Dialog", Font.PLAIN, 12));
			textTerminal.setText(preference.get(prefTermId, "3"));
			contentPanel.add(textTerminal, "cell 2 2,growx,aligny center");
			textTerminal.setColumns(10);
		}
		{
			JLabel lblPassword = new JLabel("Password :");
			lblPassword.setFont(new Font("Dialog", Font.PLAIN, 14));
			contentPanel
					.add(lblPassword, "cell 1 3,alignx right,aligny center");
		}
		{
			pwdPassword = new JPasswordField();
			pwdPassword.setFont(new Font("Dialog", Font.PLAIN, 12));
			pwdPassword.setText(preference.get(prefPassword, "password"));
			pwdPassword.setText("password");
			contentPanel.add(pwdPassword, "cell 2 3,growx,aligny bottom");
		}
		{
			chckbxActiveTerminal = new JCheckBox("Active Terminal");
			chckbxActiveTerminal.setBackground(SystemColor.info);
			contentPanel.add(chckbxActiveTerminal,
					"cell 0 5,alignx right,aligny center");
			chckbxActiveTerminal.setFont(new Font("Dialog", Font.PLAIN, 14));
			chckbxActiveTerminal.setSelected(true);
			chckbxActiveTerminal.setBorder(null);
			chckbxActiveTerminal
					.setHorizontalTextPosition(SwingConstants.LEADING);
			chckbxActiveTerminal.setHorizontalAlignment(SwingConstants.LEFT);
		}
		{
			okButton = new JButton("Logon");
			contentPanel.add(okButton, "cell 1 5,alignx right,aligny top");
			okButton.setFont(new Font("Dialog", Font.PLAIN, 12));
			okButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					result = true;
					server = textServer.getText();
					terminalID = Integer.parseInt(textTerminal.getText());
					password = pwdPassword.getPassword();
					active = chckbxActiveTerminal.isSelected();

					// now save preferences for future use
					preference.put(prefServerName, server);
					preference.put(prefTermId, textTerminal.getText());
					preference.put(prefPassword,
							String.format("%s", pwdPassword.getPassword()));

					// close dialog
					setVisible(false);
				}
			});
			okButton.setActionCommand("");
			getRootPane().setDefaultButton(okButton);
		}
		{
			btnExitApp = new JButton("Exit App");
			btnExitApp.setFont(new Font("Dialog", Font.PLAIN, 12));
			btnExitApp.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent arg0) {
					frmPumpDemo.dispose();
					System.exit(0);		// release all objects!
				}
			});
			contentPanel.add(btnExitApp, "cell 2 5");
		}
	}

}
