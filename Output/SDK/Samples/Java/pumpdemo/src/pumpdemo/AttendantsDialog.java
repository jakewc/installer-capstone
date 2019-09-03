package pumpdemo;

import itl.enabler.api.Attendant;
import itl.enabler.api.AttendantCollection;
import itl.enabler.api.EnablerException;
import itl.enabler.api.Forecourt;
import itl.enabler.api.Pump;
import itl.enabler.api.events.attendant.AttendantLogOnOffEventArgs;
import itl.enabler.api.events.attendant.AttendantStatusEventArgs;

import java.awt.BorderLayout;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;
import java.awt.Dimension;
import java.awt.Font;
import javax.swing.JLabel;

import javax.swing.border.TitledBorder;
import javax.swing.JComboBox;
import ca.odell.glazedlists.BasicEventList;
import ca.odell.glazedlists.EventList;
import ca.odell.glazedlists.swing.EventComboBoxModel;

import java.awt.Toolkit;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import net.miginfocom.swing.MigLayout;
import javax.swing.border.LineBorder;
import java.awt.Color;
import java.awt.Insets;
import javax.swing.UIManager;

@SuppressWarnings("serial")
public class AttendantsDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();

	private MainWindow mainWindow;
	private Forecourt forecourt;

	private EventList<Attendant> attendantEventList = new BasicEventList<Attendant>();
	private EventComboBoxModel<Attendant> comboBoxModelAttendant = new EventComboBoxModel<Attendant>(
			attendantEventList);

	private EventList<Pump> pumpEventList = new BasicEventList<Pump>();
	private EventComboBoxModel<Pump> comboBoxModelPump = new EventComboBoxModel<Pump>(
			pumpEventList);
	@SuppressWarnings("rawtypes")
	private JComboBox comboBoxPump;
	@SuppressWarnings("rawtypes")
	private JComboBox comboBoxAttendant;
	private JButton btnLogoff = new JButton("Logoff");
	private JButton btnLogon = new JButton("Logon");

	private JLabel labelAttBlkStatusText = new JLabel("");

	private JLabel labelAttLogOnStatusTxt = new JLabel("");

	/**
	 * Create the dialog.
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public AttendantsDialog(MainWindow app, Forecourt fcourt) {
		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		setModalityType(ModalityType.DOCUMENT_MODAL);

		mainWindow = app;
		forecourt = fcourt;

		for (Attendant attendant : forecourt.getAttendants()) {
			attendantEventList.add(attendant);
		}
		for (Pump pump : forecourt.getPumps()) {
			pumpEventList.add(pump);
		}

		forecourt.getAttendants().addAttendantCollectionEventListener(
				new AttendantCollection.AttendantCollectionEventAdapter() {

					@Override
					public void onStatusChanged(AttendantStatusEventArgs ev) {
						SwingUtilities.invokeLater(new Runnable() {

							@Override
							public void run() {
								setBlockStatus();

							}
						});

					}

					@Override
					public void onLogOn(AttendantLogOnOffEventArgs ev) {
						SwingUtilities.invokeLater(new Runnable() {

							@Override
							public void run() {
								setAttendantStatus();

							}
						});
					}

					@Override
					public void onLogOff(AttendantLogOnOffEventArgs ev) {
						SwingUtilities.invokeLater(new Runnable() {

							@Override
							public void run() {
								setAttendantStatus();

							}
						});
					}

				});

		setLocationByPlatform(true);
		setAlwaysOnTop(true);

		setResizable(false);
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				AttendantsDialog.class
						.getResource("/pumpdemo/images/ITLLogo.png")));
		setTitle("Attendants");
		setBounds(100, 100, 237, 436);
		getContentPane().setLayout(new BorderLayout());
		contentPanel.setBackground(UIManager.getColor("Button.background"));
		contentPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		contentPanel.setLayout(null);

		JPanel panelLogonPump = new JPanel();
		panelLogonPump.setBackground(UIManager.getColor("Button.background"));
		panelLogonPump.setBorder(new TitledBorder(null,
				"Attendant Pump Logon / Logoff", TitledBorder.LEADING,
				TitledBorder.TOP, null, null));
		panelLogonPump.setBounds(12, 70, 206, 150);
		contentPanel.add(panelLogonPump);
		panelLogonPump.setLayout(null);

		comboBoxPump = new JComboBox();
		comboBoxPump.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				setAttendantStatus();
			}
		});
		comboBoxPump.setBounds(61, 40, 134, 20);
		comboBoxPump.setModel(comboBoxModelPump);
		comboBoxPump.setSelectedIndex(0);
		panelLogonPump.add(comboBoxPump);

		JLabel lblPump = new JLabel("Pump");
		lblPump.setFont(new Font("Dialog", Font.PLAIN, 12));
		lblPump.setBounds(12, 42, 55, 16);
		panelLogonPump.add(lblPump);
		btnLogon.setPreferredSize(new Dimension(66, 26));
		btnLogon.setMinimumSize(new Dimension(66, 26));
		btnLogon.setMargin(new Insets(2, 2, 2, 2));

		btnLogon.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				Pump pump = (Pump) comboBoxPump.getSelectedItem();
				Attendant attendant = (Attendant) comboBoxAttendant
						.getSelectedItem();
				if (attendant != null && pump != null) {
					try {
						attendant.logOnPump(pump.getNumber());
					} catch (EnablerException ex) {
						mainWindow.showEnablerError(ex);
					}
				}
			}
		});
		btnLogon.setBounds(23, 112, 69, 26);
		panelLogonPump.add(btnLogon);
		btnLogoff.setMargin(new Insets(2, 2, 2, 2));

		btnLogoff.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				Pump pump = (Pump) comboBoxPump.getSelectedItem();
				Attendant attendant = (Attendant) comboBoxAttendant
						.getSelectedItem();
				if (attendant != null && pump != null) {
					try {
						attendant.logOffPump(pump.getNumber());
					} catch (EnablerException ex) {
						mainWindow.showEnablerError(ex);
					}
				}
			}
		});
		btnLogoff.setBounds(118, 112, 63, 26);
		panelLogonPump.add(btnLogoff);

		JLabel lblLogonStatus = new JLabel("Logon Status :");
		lblLogonStatus.setBounds(12, 72, 88, 16);
		panelLogonPump.add(lblLogonStatus);

		labelAttLogOnStatusTxt.setBounds(108, 72, 87, 16);
		panelLogonPump.add(labelAttLogOnStatusTxt);

		JPanel panelLogonTag = new JPanel();
		panelLogonTag.setEnabled(false);
		panelLogonTag.setBorder(new TitledBorder(new LineBorder(new Color(184,
				207, 229)), "Attendant Blocking", TitledBorder.LEADING,
				TitledBorder.TOP, null, new Color(0, 0, 0)));
		panelLogonTag.setBackground(UIManager.getColor("Button.background"));
		panelLogonTag.setBounds(14, 232, 204, 124);
		contentPanel.add(panelLogonTag);
		panelLogonTag.setLayout(new MigLayout("", "[grow,center][grow,center]",
				"[51.00,center][43.00]"));

		JButton btnUnblock = new JButton("Unblock");
		btnUnblock.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				Attendant attendant = (Attendant) comboBoxAttendant.getSelectedItem();
				if (attendant != null) {
					try {
						attendant.unblock();
					} catch (EnablerException ex) {
						mainWindow.showEnablerError(ex);
					}
				}
			}
		});

		JLabel lblBlockStatus = new JLabel("Block Status :");
		panelLogonTag.add(lblBlockStatus, "cell 0 0");

		panelLogonTag.add(labelAttBlkStatusText, "cell 1 0");
		btnUnblock.setMargin(new Insets(2, 2, 2, 2));
		btnUnblock.setMinimumSize(new Dimension(66, 26));
		btnUnblock.setPreferredSize(new Dimension(66, 26));
		panelLogonTag.add(btnUnblock, "flowx,cell 1 1");

		JButton btnBlock = new JButton("Block");
		btnBlock.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				Attendant attendant = (Attendant) comboBoxAttendant.getSelectedItem();
				if (attendant != null) {
					try {
						attendant.block(4);
					} catch (EnablerException ex) {
						mainWindow.showEnablerError(ex);
					}
				}
			}
		});
		panelLogonTag.add(btnBlock, "cell 0 1");

		JLabel lblAttendant = new JLabel("Attendant");
		lblAttendant.setFont(new Font("Dialog", Font.PLAIN, 12));
		lblAttendant.setBounds(12, 27, 60, 16);
		contentPanel.add(lblAttendant);

		comboBoxAttendant = new JComboBox();
		comboBoxAttendant.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				setBlockStatus();
			}
		});
		comboBoxAttendant.setMaximumSize(new Dimension(32767, 20));
		comboBoxAttendant.setBounds(75, 25, 144, 20);
		comboBoxAttendant.setModel(comboBoxModelAttendant);
		comboBoxAttendant.setSelectedIndex(0);
		contentPanel.add(comboBoxAttendant);
		{
			JPanel buttonPane = new JPanel();
			getContentPane().add(buttonPane, BorderLayout.SOUTH);
			buttonPane.setLayout(new MigLayout("hidemode 0",
					"[][49.00:49.00][][][][115.00,grow,fill][]", "[26px]"));

			JButton btnExit = new JButton("Close");
			btnExit.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					disposeEventResources();
					dispose();
				}
			});
			buttonPane.add(btnExit, "cell 6 0");
		}
	}

	private void disposeEventResources() {

		attendantEventList.dispose();
		comboBoxModelAttendant.dispose();

		pumpEventList.dispose();
		comboBoxModelPump.dispose();
	}

	private void setBlockStatus() {

		Attendant attendant = (Attendant) comboBoxAttendant.getSelectedItem();
		if (attendant != null) {
			if (attendant.isBlocked()) {
				labelAttBlkStatusText.setText("Blocked" + "("
						+ Integer.toString(attendant.getBlockReason()) + ")");
			} else {
				labelAttBlkStatusText.setText("Not blocked");
			}
		}

	}

	private void setAttendantStatus() {

		Pump pump = (Pump) comboBoxPump.getSelectedItem();
		if (pump != null) {
			Attendant currPumpAttendant = pump.getAttendant();
			if (currPumpAttendant != null) {
				labelAttLogOnStatusTxt.setText(currPumpAttendant.toString());
			} else {
				labelAttLogOnStatusTxt.setText("Logged Off");
			}
		}
	}
}
