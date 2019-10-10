package pumpdemo;

import itl.enabler.api.EnablerException;
import itl.enabler.api.Forecourt;
import itl.enabler.api.Tank;
import itl.enabler.api.events.tank.TankAlarmEventArgs;
import itl.enabler.api.types.GaugeAlarmType;

import java.awt.BorderLayout;
import java.awt.FlowLayout;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;
import java.awt.SystemColor;
import javax.swing.border.TitledBorder;
import javax.swing.JLabel;
import java.awt.Font;
import javax.swing.JComboBox;
import javax.swing.JTextField;

import ca.odell.glazedlists.BasicEventList;
import ca.odell.glazedlists.EventList;
import ca.odell.glazedlists.swing.EventComboBoxModel;

import java.awt.Toolkit;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.util.EventObject;
import net.miginfocom.swing.MigLayout;
import javax.swing.ImageIcon;
import javax.swing.UIManager;

@SuppressWarnings("serial")
public class TanksDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();

	private JTextField txtGaugelevel;
	private JTextField txtGaugeVolume;
	private JTextField txtTheoVolume;

	private MainWindow mainWindow;
	private Forecourt forecourt;
	private Tank selectedTank = null;

	private EventList<Tank> tankEventList = new BasicEventList<Tank>();
	private EventComboBoxModel<Tank> comboBoxModelTank = new EventComboBoxModel<Tank>(
			tankEventList);

	private JLabel icon_LEAK_ALARM = new JLabel();
	private JLabel icon_HIGH_WATER_ALARM = new JLabel();
	private JLabel icon_OVERFILL_ALARM = new JLabel();
	private JLabel icon_LOW_LIMIT_ALARM = new JLabel();
	private JLabel icon_THEFT_ALARM = new JLabel();
	private JLabel icon_HIGH_LIMIT_ALARM = new JLabel();
	private JLabel icon_INVALID_HEIGHT_ALARM = new JLabel();
	private JLabel icon_PROBE_OUT_ALARM = new JLabel();
	private JLabel icon_HIGH_WATER_WARNING = new JLabel();
	private JLabel icon_LOW_LIMIT_WARNING = new JLabel();
	private JLabel icon_MAX_LEVEL_ALARM = new JLabel();

	/**
	 * Create the dialog.
	 */
	@SuppressWarnings({"rawtypes", "unchecked"})
	public TanksDialog(MainWindow app, Forecourt fcourt) {
		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		setModalityType(ModalityType.DOCUMENT_MODAL);

		mainWindow = app;
		forecourt = fcourt;

		for (Tank tank : forecourt.getTanks()) {
			tankEventList.add(tank);
		}

		setLocationByPlatform(true);

		setResizable(false);
		setTitle("Tanks");
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				TanksDialog.class.getResource("/pumpdemo/images/ITLLogo.png")));
		setBounds(100, 100, 484, 463);
		getContentPane().setLayout(new BorderLayout());
		contentPanel.setBackground(UIManager.getColor("Button.background"));
		contentPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		contentPanel.setLayout(null);

		JPanel panelTankDetails = new JPanel();
		panelTankDetails.setBorder(new TitledBorder(null, "Tank Details",
				TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panelTankDetails.setBackground(UIManager.getColor("Button.background"));
		panelTankDetails.setBounds(12, 58, 298, 117);
		contentPanel.add(panelTankDetails);
		panelTankDetails.setLayout(null);

		JLabel lblGaugeLevel = new JLabel("Gauge Level");
		lblGaugeLevel.setBackground(SystemColor.info);
		lblGaugeLevel.setFont(new Font("Dialog", Font.PLAIN, 12));
		lblGaugeLevel.setBounds(12, 27, 78, 16);
		panelTankDetails.add(lblGaugeLevel);

		JLabel lblGaugeVolume = new JLabel("Gauge Volume");
		lblGaugeVolume.setBackground(SystemColor.info);
		lblGaugeVolume.setFont(new Font("Dialog", Font.PLAIN, 12));
		lblGaugeVolume.setBounds(12, 55, 88, 16);
		panelTankDetails.add(lblGaugeVolume);

		JLabel lblTheoreticalVolume = new JLabel("Theoretical Volume");
		lblTheoreticalVolume.setBackground(SystemColor.info);
		lblTheoreticalVolume.setFont(new Font("Dialog", Font.PLAIN, 12));
		lblTheoreticalVolume.setBounds(12, 83, 119, 16);
		panelTankDetails.add(lblTheoreticalVolume);

		txtGaugelevel = new JTextField();
		txtGaugelevel.setEditable(false);
		txtGaugelevel.setBounds(136, 25, 150, 20);
		panelTankDetails.add(txtGaugelevel);
		txtGaugelevel.setColumns(10);

		txtGaugeVolume = new JTextField();
		txtGaugeVolume.setEditable(false);
		txtGaugeVolume.setBounds(136, 53, 150, 20);
		panelTankDetails.add(txtGaugeVolume);
		txtGaugeVolume.setColumns(10);

		txtTheoVolume = new JTextField();
		txtTheoVolume.setEditable(false);
		txtTheoVolume.setBounds(136, 81, 150, 20);
		panelTankDetails.add(txtTheoVolume);
		txtTheoVolume.setColumns(10);

		JLabel lblSelectTank = new JLabel("Select Tank");
		lblSelectTank.setFont(new Font("Dialog", Font.PLAIN, 12));
		lblSelectTank.setBounds(19, 25, 67, 16);
		contentPanel.add(lblSelectTank);

		JComboBox comboBoxTank = new JComboBox();
		comboBoxTank.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				if (comboBoxModelTank.getSelectedItem() != null) {
					selectedTank = (Tank) comboBoxModelTank.getSelectedItem();
					selectedTank
							.addTankEventListener(new Tank.TankEventAdapter() {

								@Override
								public void onLevelChanged(EventObject ev) {
									SwingUtilities.invokeLater(new Runnable() {

										@Override
										public void run() {
											updateDetails();

										}
									});
								}

								@Override
								public void onGaugeLevelChanged(EventObject ev) {
									SwingUtilities.invokeLater(new Runnable() {

										@Override
										public void run() {
											updateDetails();

										}
									});
								}

								@Override
								public void onAlarm(TankAlarmEventArgs ev) {
									SwingUtilities.invokeLater(new Runnable() {

										@Override
										public void run() {
											updateAlarms();

										}
									});
								}

							});
					updateDetails();
					updateAlarms();
				}
			}
		});
		comboBoxTank.setModel(comboBoxModelTank);
		comboBoxTank.setSelectedIndex(0);
		comboBoxTank.setBounds(98, 21, 212, 20);
		contentPanel.add(comboBoxTank);

		JPanel panelAlarms = new JPanel();
		panelAlarms.setBorder(new TitledBorder(null, "Alarms",
				TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panelAlarms.setBackground(UIManager.getColor("Button.background"));
		panelAlarms.setBounds(12, 188, 454, 193);
		contentPanel.add(panelAlarms);
		panelAlarms.setLayout(new MigLayout("",
				"[][30.00][23.00px:n,fill][][152.00,fill][22.00]",
				"[][][][][][][][]"));

		JLabel lblLeakAlarm = new JLabel("LEAK ALARM");
		panelAlarms.add(lblLeakAlarm, "cell 0 0");

		icon_LEAK_ALARM.setEnabled(false);
		icon_LEAK_ALARM.setIconTextGap(0);
		icon_LEAK_ALARM.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		panelAlarms.add(icon_LEAK_ALARM, "cell 2 0,alignx center");

		JLabel lblHighWaterWarning = new JLabel("HIGH WATER WARNING");
		panelAlarms.add(lblHighWaterWarning, "cell 4 0");

		icon_HIGH_WATER_WARNING.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_HIGH_WATER_WARNING.setIconTextGap(0);
		icon_HIGH_WATER_WARNING.setEnabled(false);
		panelAlarms.add(icon_HIGH_WATER_WARNING, "cell 5 0");

		JLabel lblHighWaterAlarm = new JLabel("HIGH WATER ALARM");
		panelAlarms.add(lblHighWaterAlarm, "cell 0 1");

		icon_HIGH_WATER_ALARM.setEnabled(false);
		icon_HIGH_WATER_ALARM.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_HIGH_WATER_ALARM.setIconTextGap(0);
		panelAlarms.add(icon_HIGH_WATER_ALARM, "cell 2 1");

		JLabel lblLowLimitWarning = new JLabel("LOW LIMIT WARNING");
		panelAlarms.add(lblLowLimitWarning, "cell 4 1");

		icon_LOW_LIMIT_WARNING.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_LOW_LIMIT_WARNING.setIconTextGap(0);
		icon_LOW_LIMIT_WARNING.setEnabled(false);
		panelAlarms.add(icon_LOW_LIMIT_WARNING, "cell 5 1");

		JLabel lblOverfill = new JLabel("OVERFILL ALARM");
		panelAlarms.add(lblOverfill, "cell 0 2");

		icon_OVERFILL_ALARM.setEnabled(false);
		icon_OVERFILL_ALARM.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_OVERFILL_ALARM.setIconTextGap(0);
		panelAlarms.add(icon_OVERFILL_ALARM, "cell 2 2");

		JLabel lblMaximumLevelAlarm = new JLabel("MAXIMUM LEVEL ALARM");
		panelAlarms.add(lblMaximumLevelAlarm, "cell 4 2");

		icon_MAX_LEVEL_ALARM.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_MAX_LEVEL_ALARM.setIconTextGap(0);
		icon_MAX_LEVEL_ALARM.setEnabled(false);
		panelAlarms.add(icon_MAX_LEVEL_ALARM, "cell 5 2");

		JLabel lblLowLimit = new JLabel("LOW LIMIT ALARM");
		panelAlarms.add(lblLowLimit, "cell 0 3");

		icon_LOW_LIMIT_ALARM.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_LOW_LIMIT_ALARM.setEnabled(false);
		icon_LOW_LIMIT_ALARM.setIconTextGap(0);
		panelAlarms.add(icon_LOW_LIMIT_ALARM, "cell 2 3");

		JLabel lblTheft = new JLabel("THEFT ALARM");
		panelAlarms.add(lblTheft, "cell 0 4");

		icon_THEFT_ALARM.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_THEFT_ALARM.setEnabled(false);
		icon_THEFT_ALARM.setIconTextGap(0);
		panelAlarms.add(icon_THEFT_ALARM, "cell 2 4");

		JLabel lblHighLimit = new JLabel("HIGH LIMIT ALARM");
		panelAlarms.add(lblHighLimit, "cell 0 5");

		icon_HIGH_LIMIT_ALARM.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_HIGH_LIMIT_ALARM.setEnabled(false);
		icon_HIGH_LIMIT_ALARM.setIconTextGap(0);
		panelAlarms.add(icon_HIGH_LIMIT_ALARM, "cell 2 5");

		JLabel lblInvalidHeight = new JLabel("INVALID HEIGHT ALARM");
		panelAlarms.add(lblInvalidHeight, "cell 0 6");

		icon_INVALID_HEIGHT_ALARM.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_INVALID_HEIGHT_ALARM.setEnabled(false);
		icon_INVALID_HEIGHT_ALARM.setIconTextGap(0);
		panelAlarms.add(icon_INVALID_HEIGHT_ALARM, "cell 2 6");

		JLabel lblProbeOut = new JLabel("PROBE OUT ALARM");
		panelAlarms.add(lblProbeOut, "cell 0 7");

		icon_PROBE_OUT_ALARM.setIcon(new ImageIcon(TanksDialog.class
				.getResource("/pumpdemo/images/alarm.png")));
		icon_PROBE_OUT_ALARM.setEnabled(false);
		icon_PROBE_OUT_ALARM.setIconTextGap(0);
		panelAlarms.add(icon_PROBE_OUT_ALARM, "cell 2 7");
		{
			JPanel buttonPane = new JPanel();
			buttonPane.setBorder(new EmptyBorder(0, 0, 0, 0));
			buttonPane.setLayout(new FlowLayout(FlowLayout.RIGHT));
			getContentPane().add(buttonPane, BorderLayout.SOUTH);
			{
				JButton okButton = new JButton("Exit");
				okButton.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						disposeEventResources();
						dispose();
					}
				});
				okButton.setActionCommand("OK");
				buttonPane.add(okButton);
				getRootPane().setDefaultButton(okButton);
			}
		}
	}

	private void updateDetails() {

		if (selectedTank != null) {
			txtGaugelevel.setText(String.format("%.3f", selectedTank
					.getGaugeReading().getLevel()));
			txtGaugeVolume.setText(String.format("%.3f", selectedTank
					.getGaugeReading().getVolume()));
			txtTheoVolume.setText(String.format("%.3f",
					selectedTank.getTheoreticalVolume()));
		}
	}

	private void updateAlarms() {
		if (selectedTank != null) {

			try {
				if (selectedTank.getAlarm(GaugeAlarmType.LEAK_ALARM.getValue())) {
					icon_LEAK_ALARM.setEnabled(true);
				} else {
					icon_LEAK_ALARM.setEnabled(false);
				}
				if (selectedTank.getAlarm(GaugeAlarmType.HIGH_WATER_ALARM
						.getValue())) {
					icon_HIGH_WATER_ALARM.setEnabled(true);
				} else {
					icon_HIGH_WATER_ALARM.setEnabled(false);
				}
				if (selectedTank.getAlarm(GaugeAlarmType.OVERFILL_ALARM
						.getValue())) {
					icon_OVERFILL_ALARM.setEnabled(true);
				} else {
					icon_OVERFILL_ALARM.setEnabled(false);
				}
				if (selectedTank.getAlarm(GaugeAlarmType.LOW_LIMIT_ALARM
						.getValue())) {
					icon_LOW_LIMIT_ALARM.setEnabled(true);
				} else {
					icon_LOW_LIMIT_ALARM.setEnabled(false);
				}
				if (selectedTank
						.getAlarm(GaugeAlarmType.THEFT_ALARM.getValue())) {
					icon_THEFT_ALARM.setEnabled(true);
				} else {
					icon_THEFT_ALARM.setEnabled(false);
				}
				if (selectedTank.getAlarm(GaugeAlarmType.HIGH_LIMIT_ALARM
						.getValue())) {
					icon_HIGH_LIMIT_ALARM.setEnabled(true);
				} else {
					icon_HIGH_LIMIT_ALARM.setEnabled(false);
				}
				if (selectedTank.getAlarm(GaugeAlarmType.INVALID_HEIGHT_ALARM
						.getValue())) {
					icon_INVALID_HEIGHT_ALARM.setEnabled(true);
				} else {
					icon_INVALID_HEIGHT_ALARM.setEnabled(false);
				}
				if (selectedTank.getAlarm(GaugeAlarmType.PROBE_OUT_ALARM
						.getValue())) {
					icon_PROBE_OUT_ALARM.setEnabled(true);
				} else {
					icon_PROBE_OUT_ALARM.setEnabled(false);
				}
				if (selectedTank.getAlarm(GaugeAlarmType.HIGH_WATER_WARNING
						.getValue())) {
					icon_HIGH_WATER_WARNING.setEnabled(true);
				} else {
					icon_HIGH_WATER_WARNING.setEnabled(false);
				}
				if (selectedTank.getAlarm(GaugeAlarmType.LOW_LIMIT_WARNING
						.getValue())) {
					icon_LOW_LIMIT_WARNING.setEnabled(true);
				} else {
					icon_LOW_LIMIT_WARNING.setEnabled(false);
				}
				if (selectedTank.getAlarm(GaugeAlarmType.MAXIMUM_LEVEL_ALARM
						.getValue())) {
					icon_MAX_LEVEL_ALARM.setEnabled(true);
				} else {
					icon_MAX_LEVEL_ALARM.setEnabled(false);
				}
			} catch (EnablerException ex) {
				mainWindow.showEnablerError(ex);
			}

		}
	}

	private void disposeEventResources() {
		tankEventList.dispose();
		comboBoxModelTank.dispose();
	}
}
