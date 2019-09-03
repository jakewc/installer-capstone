package pumpdemo;

import itl.enabler.api.Forecourt;

import java.awt.BorderLayout;
import java.awt.FlowLayout;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import java.awt.Dimension;
import java.awt.Toolkit;
import javax.swing.JLabel;
import javax.swing.SwingConstants;
import java.awt.Font;
import javax.swing.ImageIcon;
import java.awt.SystemColor;
import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import net.miginfocom.swing.MigLayout;
import javax.swing.UIManager;
import javax.swing.JEditorPane;
import javax.swing.border.LineBorder;
import java.awt.Color;

@SuppressWarnings("serial")
public class AboutDialog extends JDialog {

	private final String applicationVersionString = "1.1.1.0";
	
	private final JPanel contentPanel = new JPanel();
	private JLabel labelApiVer = new JLabel("");
	private JLabel labelPumpSrvVer = new JLabel("");

	MainWindow mainWindow;
	Forecourt forecourt;
	private JLabel labelPumpDemoVer = new JLabel("");
	private JLabel labelJavaBuildVersion = new JLabel("");

	/**
	 * Create the dialog.
	 */
	public AboutDialog(MainWindow app, Forecourt fcourt) {

		mainWindow = app;
		forecourt = fcourt;

		setModal(true);
		setResizable(false);
		setModalityType(ModalityType.APPLICATION_MODAL);
		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		setSize(new Dimension(358, 401));
		getContentPane().setSize(new Dimension(350, 350));
		getContentPane().setMinimumSize(new Dimension(350, 340));
		getContentPane().setPreferredSize(new Dimension(350, 340));
		setFont(new Font("Serif", Font.PLAIN, 12));
		setBackground(SystemColor.info);
		getContentPane().setBackground(SystemColor.info);
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				AboutDialog.class.getResource("/pumpdemo/images/ITLLogo.png")));
		setTitle("About Pump Demo");
		setMinimumSize(new Dimension(358, 420));
		setPreferredSize(new Dimension(358, 390));
		setBounds(100, 100, 353, 294);
		getContentPane().setLayout(new BorderLayout());
		{
			JPanel panel = new JPanel();
			panel.setSize(new Dimension(350, 340));
			panel.setMinimumSize(new Dimension(350, 340));
			panel.setPreferredSize(new Dimension(350, 340));
			panel.setBackground(UIManager.getColor("Button.highlight"));
			getContentPane().add(panel, BorderLayout.CENTER);
			panel.setLayout(new BorderLayout(0, 0));
			contentPanel.setSize(new Dimension(350, 295));
			contentPanel.setPreferredSize(new Dimension(350, 295));
			contentPanel.setMinimumSize(new Dimension(350, 295));
			panel.add(contentPanel);
			contentPanel.setBackground(UIManager.getColor("Button.background"));
			contentPanel.setBorder(new EmptyBorder(10, 10, 10, 10));
			GridBagLayout gbl_contentPanel = new GridBagLayout();
			gbl_contentPanel.columnWidths = new int[] { 334, 0 };
			gbl_contentPanel.rowHeights = new int[] { 27, 78, 93, 0, 0 };
			gbl_contentPanel.columnWeights = new double[] { 1.0,
					Double.MIN_VALUE };
			gbl_contentPanel.rowWeights = new double[] { 0.0, 0.0, 1.0, 1.0,
					Double.MIN_VALUE };
			contentPanel.setLayout(gbl_contentPanel);
			{
				JLabel lblPumpDemoSample = new JLabel(
						"Pump Demo Sample Application");
				lblPumpDemoSample.setMaximumSize(new Dimension(0, 0));
				lblPumpDemoSample.setFont(new Font("Monospaced",
						lblPumpDemoSample.getFont().getStyle() | Font.BOLD,
						lblPumpDemoSample.getFont().getSize() + 4));
				lblPumpDemoSample.setHorizontalAlignment(SwingConstants.CENTER);
				GridBagConstraints gbc_lblPumpDemoSample = new GridBagConstraints();
				gbc_lblPumpDemoSample.gridx = 0;
				gbc_lblPumpDemoSample.gridy = 0;
				contentPanel.add(lblPumpDemoSample, gbc_lblPumpDemoSample);
			}
			{
				JLabel lblLogo = new JLabel("");
				lblLogo.setIcon(new ImageIcon(AboutDialog.class
						.getResource("/pumpdemo/images/ITLLogo.png")));
				GridBagConstraints gbc_lblLogo = new GridBagConstraints();
				gbc_lblLogo.fill = GridBagConstraints.VERTICAL;
				gbc_lblLogo.gridx = 0;
				gbc_lblLogo.gridy = 1;
				contentPanel.add(lblLogo, gbc_lblLogo);
			}
			{
				JEditorPane dtrpnThisApplicationDemonstrates = new JEditorPane();
				dtrpnThisApplicationDemonstrates.setBackground(UIManager
						.getColor("Button.background"));
				dtrpnThisApplicationDemonstrates
						.setText("This application demonstrates the use of the Enabler Java API in a Swing application. \r\n\r\nThis product includes software developed by Joda.org (http://www.joda.org/).");
				GridBagConstraints gbc_dtrpnThisApplicationDemonstrates = new GridBagConstraints();
				gbc_dtrpnThisApplicationDemonstrates.fill = GridBagConstraints.BOTH;
				gbc_dtrpnThisApplicationDemonstrates.gridx = 0;
				gbc_dtrpnThisApplicationDemonstrates.gridy = 2;
				contentPanel.add(dtrpnThisApplicationDemonstrates,
						gbc_dtrpnThisApplicationDemonstrates);
			}
			{
				JPanel panelVer = new JPanel();
				panelVer.setBorder(new LineBorder(new Color(0, 0, 0)));
				panelVer.setBackground(UIManager.getColor("Button.background"));
				GridBagConstraints gbc_panelVer = new GridBagConstraints();
				gbc_panelVer.fill = GridBagConstraints.BOTH;
				gbc_panelVer.gridx = 0;
				gbc_panelVer.gridy = 3;
				contentPanel.add(panelVer, gbc_panelVer);
				panelVer.setLayout(new MigLayout("", "[][26.00,center][]",
						"[30.00][][][][]"));
				{
					JLabel lblVersionInfo = new JLabel("Version Info");
					panelVer.add(lblVersionInfo, "cell 0 0");
				}
				{
					JLabel lblApi = new JLabel("API Specification");
					panelVer.add(lblApi, "cell 0 1");
				}
				{
					JLabel label = new JLabel(":");
					panelVer.add(label, "cell 1 1");
				}
				{
					panelVer.add(labelApiVer, "cell 2 1");
				}
				{
					JLabel lblPumpSrv = new JLabel("Pump Server");
					panelVer.add(lblPumpSrv, "cell 0 2");
				}
				{
					JLabel label = new JLabel(":");
					panelVer.add(label, "cell 1 2");
				}
				{
					panelVer.add(labelPumpSrvVer, "cell 2 2");
				}
				{
					JLabel lblPumpDemo = new JLabel("Pump Demo");
					panelVer.add(lblPumpDemo, "cell 0 4");
				}
				{
					JLabel label = new JLabel(":");
					panelVer.add(label, "cell 1 3");
				}
				{
					panelVer.add(labelPumpDemoVer, "cell 2 4");
				}
				{
					JLabel lblJavaBuild = new JLabel("Java Build");
					panelVer.add(lblJavaBuild, "cell 0 3");
				}
				{
					JLabel label = new JLabel(":");
					panelVer.add(label, "cell 1 4");
				}
				{
					panelVer.add(labelJavaBuildVersion, "cell 2 3");
				}
			}
			{
				JPanel buttonPane = new JPanel();
				panel.add(buttonPane, BorderLayout.SOUTH);
				buttonPane.setLayout(new FlowLayout(FlowLayout.RIGHT));
				{
					JButton okButton = new JButton("OK");
					okButton.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent e) {
							dispose();
						}
					});
					okButton.setActionCommand("OK");
					buttonPane.add(okButton);
					getRootPane().setDefaultButton(okButton);
				}
			}
		}

		setVersionInfo();
	}

	private void setVersionInfo() {

		if (forecourt.isConnected()) {
			labelPumpSrvVer.setText(forecourt.getServerInformation()
					.getServerVersion().trim());
		} else {
			labelPumpSrvVer.setText("Not Connected to Server");
		}

		labelApiVer.setText(forecourt.getClass().getPackage()
				.getSpecificationVersion());
		labelJavaBuildVersion.setText(forecourt.getClass().getPackage()
				.getImplementationVersion());

		labelPumpDemoVer.setText(applicationVersionString);
	}
}
