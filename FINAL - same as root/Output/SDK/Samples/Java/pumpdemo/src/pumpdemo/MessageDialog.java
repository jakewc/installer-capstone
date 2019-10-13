package pumpdemo;

import itl.enabler.api.EnablerException;
import itl.enabler.api.Forecourt;
import java.awt.BorderLayout;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import java.awt.Font;
import net.miginfocom.swing.MigLayout;
import java.awt.Dimension;
import javax.swing.ImageIcon;
import javax.swing.UIManager;
import javax.swing.SwingConstants;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.JLabel;
import java.text.NumberFormat;

import javax.swing.JFormattedTextField;

/**
 * Dialog used to send messages to other terminals
 */
@SuppressWarnings("serial")
public class MessageDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();
	private JFormattedTextField textTermID;
	private JFormattedTextField textNotID;
	private JFormattedTextField textMsg;;

	/**
	 * Create the dialog.
	 * 
	 * @param parent
	 */
	public MessageDialog(final MainWindow parent, final Forecourt forecourt) {

		setLocationByPlatform(true);
		setModalityType(ModalityType.APPLICATION_MODAL);

		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);

		setResizable(false);
		setTitle("Broadcast Message");
		setBounds(100, 100, 524, 333);
		getContentPane().setLayout(new BorderLayout());
		contentPanel.setBackground(UIManager.getColor("Button.background"));
		contentPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		contentPanel.setLayout(new BorderLayout(0, 0));
		{
			JPanel panelValues = new JPanel();
			panelValues.setPreferredSize(new Dimension(200, 10));
			contentPanel.add(panelValues, BorderLayout.CENTER);
			panelValues.setLayout(new BorderLayout(0, 0));
			{
				JPanel panelHeader = new JPanel();
				panelHeader.setBorder(null);
				panelValues.add(panelHeader, BorderLayout.NORTH);
				panelHeader.setLayout(new MigLayout("", "[180.00:492.00]",
						"[68.00]"));
				{
					JLabel lblSendAMessage = new JLabel(
							"Send a message to a specific terminal or broadcast to all");
					lblSendAMessage
							.setHorizontalAlignment(SwingConstants.CENTER);
					lblSendAMessage.setFont(new Font("Tahoma", Font.BOLD, 17));
					panelHeader.add(lblSendAMessage,
							"cell 0 0,growx,alignx center");
				}
			}
			{
				JPanel panelBody = new JPanel();
				panelBody.setFont(new Font("Dialog", Font.PLAIN, 12));
				panelBody.setBorder(null);
				panelBody.setPreferredSize(new Dimension(10, 125));
				panelBody.setMinimumSize(new Dimension(10, 30));
				panelValues.add(panelBody, BorderLayout.SOUTH);
				panelBody.setLayout(new MigLayout("gapx 10", "[194.00][grow]",
						"[35.00][38.00][36.00]"));
				{
					JLabel lblTerminalIdOr = new JLabel(
							"Terminal ID or -1 for ALL");
					lblTerminalIdOr.setFont(new Font("Tahoma", Font.BOLD, 13));
					panelBody.add(lblTerminalIdOr,
							"cell 0 0,alignx trailing,aligny center");
				}
				{
					textTermID = new JFormattedTextField(
							NumberFormat.getInstance());
					textTermID.setFont(new Font("Tahoma", Font.PLAIN, 12));
					textTermID.setText("-1");
					panelBody.add(textTermID, "cell 1 0,growx");
				}
				{
					JLabel lblClientSpecificMessage = new JLabel(
							"Client specific message ID");
					lblClientSpecificMessage.setFont(new Font("Tahoma",
							Font.BOLD, 13));
					panelBody.add(lblClientSpecificMessage,
							"cell 0 1,alignx trailing");
				}
				{
					textNotID = new JFormattedTextField(
							NumberFormat.getInstance());
					textNotID.setFont(new Font("Tahoma", Font.PLAIN, 12));
					textNotID.setText("1");
					panelBody.add(textNotID, "cell 1 1,growx");
				}
				{
					JLabel lblMessageToSend = new JLabel(
							"Message to send to client(s)");
					lblMessageToSend.setFont(new Font("Tahoma", Font.BOLD, 13));
					panelBody.add(lblMessageToSend, "cell 0 2,alignx trailing");
				}
				{
					textMsg = new JFormattedTextField();
					textMsg.setFont(new Font("Tahoma", Font.PLAIN, 12));
					textMsg.setText("Hello Clients !!");
					panelBody.add(textMsg, "cell 1 2,growx,aligny center");
				}
			}
		}

		{
			JPanel buttonPane = new JPanel();
			buttonPane.setPreferredSize(new Dimension(10, 80));
			buttonPane.setBorder(new EmptyBorder(0, 0, 0, 9));
			getContentPane().add(buttonPane, BorderLayout.SOUTH);
			buttonPane.setLayout(new MigLayout("alignx right", "[grow][]10[]",
					"[73.00]"));
			{
				JButton btnOKButton = new JButton("");
				btnOKButton.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						int terminalID = Integer.parseInt(textTermID.getText());
						int notificationID = Integer.parseInt(textNotID
								.getText());
						String message = textMsg.getText();
						int waitForAck = 1000; // msec

						try {
							forecourt.broadcastMessage(terminalID,
									notificationID, message, waitForAck);
						} catch (EnablerException ex) {
							parent.showEnablerError(ex);
							return;
						}
						dispose();
					}
				});
				btnOKButton.setIcon(new ImageIcon(MessageDialog.class
						.getResource("/pumpdemo/images/OK.png")));
				btnOKButton.setMaximumSize(new Dimension(65, 60));
				btnOKButton.setMinimumSize(new Dimension(65, 60));
				btnOKButton.setPreferredSize(new Dimension(65, 60));
				buttonPane.add(btnOKButton, "cell 1 0");
			}
			{
				JButton btnCancelButton = new JButton("");
				btnCancelButton.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						dispose();
					}
				});
				btnCancelButton.setBackground(UIManager
						.getColor("Button.background"));
				btnCancelButton.setIcon(new ImageIcon(MessageDialog.class
						.getResource("/pumpdemo/images/Cancel.png")));
				btnCancelButton.setMinimumSize(new Dimension(65, 60));
				btnCancelButton.setPreferredSize(new Dimension(65, 60));
				buttonPane.add(btnCancelButton, "cell 2 0");
			}
		}

	}
}
