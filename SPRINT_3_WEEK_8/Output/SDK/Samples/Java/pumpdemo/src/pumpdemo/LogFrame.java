package pumpdemo;

import itl.enabler.api.Attendant;
import itl.enabler.api.AttendantCollection;
import itl.enabler.api.EnablerException;
import itl.enabler.api.Fallback;
import itl.enabler.api.Forecourt;
import itl.enabler.api.Grade;
import itl.enabler.api.GradeCollection.GradeCollectionEventListener;
import itl.enabler.api.Pump;
import itl.enabler.api.PumpCollection;
import itl.enabler.api.Tank;
import itl.enabler.api.TankCollection;
import itl.enabler.api.Terminal;
import itl.enabler.api.TerminalCollection.TerminalCollectionEventListener;
import itl.enabler.api.events.attendant.AttendantLogOnOffEventArgs;
import itl.enabler.api.events.attendant.AttendantStatusEventArgs;
import itl.enabler.api.events.forecourt.ConfigChangeEventArgs;
import itl.enabler.api.events.forecourt.ForecourtStatusEventArgs;
import itl.enabler.api.events.forecourt.MessageReceivedEventArgs;
import itl.enabler.api.events.forecourt.ServerJournalEventArgs;
import itl.enabler.api.events.forecourt.TagReadEventArgs;
import itl.enabler.api.events.grade.GradePriceChangeEventArgs;
import itl.enabler.api.events.grade.GradeStatusEventArgs;
import itl.enabler.api.events.pump.FuellingProgressEventArgs;
import itl.enabler.api.events.pump.JournalEventArgs;
import itl.enabler.api.events.pump.PumpHoseEventArgs;
import itl.enabler.api.events.pump.PumpStatusEventArgs;
import itl.enabler.api.events.pump.PumpTransactionEventArgs;
import itl.enabler.api.events.tank.TankAlarmEventArgs;
import itl.enabler.api.events.tank.TankStatusEventArgs;
import itl.enabler.api.events.types.HoseEventType;
import itl.enabler.api.events.types.PumpStatusEventType;
import itl.enabler.api.events.types.TankStatusEventType;
import itl.enabler.api.reasons.HoseBlockedReasons;
import itl.enabler.api.types.*;

import java.awt.BorderLayout;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import java.awt.Toolkit;
import java.awt.Color;
import javax.swing.JToolBar;
import javax.swing.JTextArea;
import javax.swing.JButton;
import javax.swing.SwingUtilities;

import java.awt.Font;
import javax.swing.JCheckBox;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.EventObject;
import java.util.Locale;
import javax.swing.JScrollPane;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.Component;
import javax.swing.Box;
import javax.swing.UIManager;

@SuppressWarnings("serial")
public class LogFrame extends JFrame {

	private JPanel contentPane;
	private Forecourt forecourt;
	private JTextArea textArea;
	private JCheckBox chckbxShowLatest;
	private JCheckBox chckbxShowRunningtotals = new JCheckBox(
			"Show RunningTotals");

	/**
	 * Create the frame.
	 */
	public LogFrame(Forecourt fcourt) {

		this.forecourt = fcourt;
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				LogFrame.class.getResource("/pumpdemo/images/ITLLogo.png")));
		setTitle("Event Logging");
		setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		setBounds(100, 100, 450, 300);
		contentPane = new JPanel();
		contentPane.setBackground(Color.LIGHT_GRAY);
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		contentPane.setLayout(new BorderLayout(0, 0));
		setContentPane(contentPane);

		JToolBar toolBar = new JToolBar();
		contentPane.add(toolBar, BorderLayout.NORTH);

		JButton btnCopySelected = new JButton("Copy Selected");
		btnCopySelected.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				textArea.copy();
			}
		});
		btnCopySelected.setFont(new Font("Tahoma", Font.PLAIN, 13));
		toolBar.add(btnCopySelected);

		JButton btnClear = new JButton("Clear");
		btnClear.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				textArea.setText("");
			}
		});

		Component horizontalStrut_1 = Box.createHorizontalStrut(10);
		horizontalStrut_1.setForeground(UIManager
				.getColor("ToolBar.dockingBackground"));
		horizontalStrut_1.setBackground(UIManager
				.getColor("ToolBar.background"));
		toolBar.add(horizontalStrut_1);
		btnClear.setFont(new Font("Tahoma", Font.PLAIN, 13));
		toolBar.add(btnClear);

		chckbxShowLatest = new JCheckBox("Show Latest");
		chckbxShowLatest.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (chckbxShowLatest.isSelected()) {
					textArea.setCaretPosition(textArea.getDocument()
							.getLength());
				}
			}
		});

		Component horizontalStrut = Box.createHorizontalStrut(10);
		toolBar.add(horizontalStrut);
		chckbxShowLatest.setSelected(true);
		chckbxShowLatest.setFont(new Font("Tahoma", Font.PLAIN, 13));
		toolBar.add(chckbxShowLatest);

		Component horizontalStrut_2 = Box.createHorizontalStrut(10);
		toolBar.add(horizontalStrut_2);

		chckbxShowRunningtotals.setFont(new Font("Tahoma", Font.PLAIN, 13));
		toolBar.add(chckbxShowRunningtotals);

		JPanel panel = new JPanel();
		contentPane.add(panel, BorderLayout.CENTER);
		panel.setLayout(new BorderLayout(0, 0));

		textArea = new JTextArea();
		textArea.setEditable(false);
		textArea.setLineWrap(true);
		textArea.setWrapStyleWord(true);
		textArea.setFont(new Font("Tahoma", Font.PLAIN, 13));

		/*
		 * Put TextArea within a JScrollPane to allow the user to properly
		 * scroll through the logs
		 */
		JScrollPane scrollPane = new JScrollPane(textArea);
		panel.add(scrollPane, BorderLayout.CENTER);

		// link all events to log
		linkEvents();
	}

	private void linkEvents() {

		// forecourt events
		forecourt
				.addForecourtEventListener(new Forecourt.ForecourtEventAdapter() {

					@Override
					public void onConfigChangeEvent(ConfigChangeEventArgs evArgs) {
						
						logEntry(String
								.format("Forecourt Config Change event - Action:%s Type:%s Id:%d",
										evArgs.getActionType().toString(),
										evArgs.getDataType().toString(),
										evArgs.getId()));
						
						/*
						 * Log max. stack size for current site profile by capturing the correct 
						 * DataType from event information.
						 * Apparently, the pump server treats SITEMODE data as SITE data.
						 */
						if (evArgs.getDataType().toString() == DataType.SITE
								.toString()) {
							logEntry(String
									.format("Forecourt Config Change event - Maximum Stack size for current site profile is : %d",
											forecourt.getCurrentMode()
													.getMaxStackSize()));
						}
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see itl.enabler.api.Forecourt.ForecourtEventAdapter#
					 * onServerJournalEvent
					 * (itl.enabler.api.events.forecourt.ServerJournalEventArgs)
					 */
					@Override
					public void onServerJournalEvent(
							ServerJournalEventArgs evArgs) {
						logEntry(String
								.format("Forecourt Journal event - Devid:%d DevNum:%d DevType:%s Level:%s Message:%s",
										evArgs.getDeviceId(), evArgs
												.getDeviceNumber(), evArgs
												.getDeviceType().toString(),
										evArgs.getEventLevel().toString(),
										evArgs.getMessage()));
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see
					 * itl.enabler.api.Forecourt.ForecourtEventAdapter#onServerEvent
					 * (java.util.EventObject)
					 */
					@Override
					public void onServerEvent(EventObject eventObject) {
						logEntry(String.format(
								"Forecourt Server event  - Connection %s",
								forecourt.isConnected() ? "Online" : "Offline"));
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see itl.enabler.api.Forecourt.ForecourtEventAdapter#
					 * onMessageReceivedEvent
					 * (itl.enabler.api.events.forecourt.MessageReceivedEventArgs
					 * )
					 */
					@Override
					public void onMessageReceivedEvent(
							MessageReceivedEventArgs evArgs) {
						logEntry(String
								.format("Forecourt Message - Source:%d Id:%d Message:%s",
										evArgs.getSourceTerminalId(),
										evArgs.getNotificationID(),
										evArgs.getNotificationString()));
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see itl.enabler.api.Forecourt.ForecourtEventAdapter#
					 * onStatusChangeEvent
					 * (itl.enabler.api.events.forecourt.ForecourtStatusEventArgs
					 * )
					 */
					@Override
					public void onStatusChangeEvent(
							ForecourtStatusEventArgs evArgs) {
						switch (evArgs.getEventType()) {
							case CURRENT_MODE_ID :
								logEntry(String.format(
										"Forecourt Site Mode changed to : %s",
										forecourt.getCurrentMode().getName()));
								break;
							case PUMP_LIGHTS :
								String pumpLightStatus = (forecourt
										.getPumpLightState() ? "ON" : "OFF");
								logEntry(String.format(
										"Forecourt lights switched :%s",
										pumpLightStatus));
								break;
							default :
								logEntry(String.format(
										"Forecourt Status change - Type:%s",
										evArgs.getEventType().toString()));
						}
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see itl.enabler.api.Forecourt.ForecourtEventAdapter#
					 * onServerPowerEvent(java.util.EventObject)
					 */
					@Override
					public void onServerPowerEvent(EventObject eventObject) {
						logEntry(String
								.format("Forecourt Server Power event - Power : %s, Battery State : %s",
										forecourt.getUPS().getPowerState()
												.toString(), forecourt.getUPS()
												.getBatteryState().toString()));
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see itl.enabler.api.Forecourt.ForecourtEventAdapter#
					 * onTagReadEvent
					 * (itl.enabler.api.events.forecourt.TagReadEventArgs)
					 */
					@Override
					public void onTagReadEvent(TagReadEventArgs evArgs) {
						logEntry(String
								.format("Forecourt Tag read - Attendent:%d Pump:%d Reader:%d Tag ID:%d Tag data:%s",
										evArgs.getAttendantId(),
										evArgs.getPumpNumber(),
										evArgs.getTagReaderID(),
										evArgs.getTagId(), evArgs.getTagData()));
					}

				});

		// pump events
		forecourt.getPumps().addPumpCollectionEventListener(
				new PumpCollection.PumpCollectionEventAdapter() {

					/*
					 * (non-Javadoc)
					 * 
					 * @see
					 * itl.enabler.api.PumpCollection.PumpCollectionEventAdapter
					 * #onFuellingProgress(itl.enabler.api.events.pump.
					 * FuellingProgressEventArgs)
					 */
					@Override
					public void onFuellingProgress(FuellingProgressEventArgs ev) {
						if (chckbxShowRunningtotals.isSelected()) {
							Pump pump = (Pump) ev.getSource();
							logEntry(String
									.format("Pump %d Running Total event - Value:%.3f Volume:%.3f",
											pump.getNumber(), ev.getValue(),
											ev.getVolume()));
						}
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see
					 * itl.enabler.api.PumpCollection.PumpCollectionEventAdapter
					 * #
					 * onHoseEvent(itl.enabler.api.events.pump.PumpHoseEventArgs
					 * )
					 */
					@Override
					public void onHoseEvent(PumpHoseEventArgs ev) {

						Pump pump = (Pump) ev.getSource();
						if (ev.getEventType() == HoseEventType.BLOCK) {

							String blockedReasons = new String();

							// append "," between reasons
							for (HoseBlockedReasons reason : pump.getHoses()
									.getByNumber(ev.getHoseNumber())
									.getBlockedReasons()) {
								blockedReasons = blockedReasons
										+ reason.toString() + (",");
							}

							// remove trailing comma (,) while printing
							logEntry(String.format(
									"Pump %d Hose %d Event - %s, Reasons - %s",
									pump.getNumber(), ev.getHoseNumber(), ev
											.getEventType().toString(),
									blockedReasons.subSequence(0,
											blockedReasons.length() - 1)));

						} else {
							logEntry(String.format(
									"Pump %d Hose %d Event - %s", pump
											.getNumber(), ev.getHoseNumber(),
									ev.getEventType().toString()));

						}

					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see
					 * itl.enabler.api.PumpCollection.PumpCollectionEventAdapter
					 * #onStatusChange(itl.enabler.api.events.pump.
					 * PumpStatusEventArgs)
					 */
					@Override
					public void onStatusChange(PumpStatusEventArgs ev) {
						Pump pump = (Pump) ev.getSource();
						String status = "";

						switch (ev.getEventType()) {
							case STATE :
								status = "State change to "
										+ pump.getState().toString();
								break;
							case BLOCKED :
								status = "Block changed to "
										+ (pump.isBlocked() ? "true" : "false");
								break;
							case PUMP_LIGHTS :
								status = "Pump lights to "
										+ (pump.isPumpLightsOn() ? "On" : "Off");
								break;
							case CURRENT_MODE :
								status = "Pump mode ";
								break;
							case FUEL_FLOW :
								status = "Fuel flow "
										+ (pump.isFuelFlow() ? "On" : "Off");
								break;
							case PRICE_LEVEL1:
								status = "Price level 1 selected";
								break;
							case PRICE_LEVEL2:
								status = "Price level 2 selected";
								break;
						}

						String logStr = String.format(
								"Pump %d Status change event - %s.",
								pump.getNumber(), status);
						/*
						 * Log max. stack size for pump profile by capturing the correct 
						 * event type.
						 */
						if (ev.getEventType() == PumpStatusEventType.CURRENT_MODE) {
							logEntry(String
									.format("%s Maximum Stack size for pump profile is : %d",
											logStr,
											forecourt
													.getPumps()
													.getByNumber(
															pump.getNumber())
													.getCurrentProfile()
													.getMaxStackSize()));
						} else {
							logEntry(logStr);
						}
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see
					 * itl.enabler.api.PumpCollection.PumpCollectionEventAdapter
					 * #onPriceChange(java.util.EventObject)
					 */
					@Override
					public void onPriceChange(EventObject ev) {
						Pump pump = (Pump) ev.getSource();
						logEntry(String.format(
								"Pump %d Price change event - %s", pump
										.getNumber(), pump
										.getPriceChangeStatus().toString()));
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see
					 * itl.enabler.api.PumpCollection.PumpCollectionEventAdapter
					 * #onJournalEvent(java.util.EventObject)
					 */
					@Override
					public void onJournalEvent(JournalEventArgs ev) {
						Pump pump = (Pump) ev.getSource();
						logEntry(String
								.format("Pump %d Journal event - id:%d type:%d level:%s message:%s",
										pump.getNumber(), ev.getId(), ev
												.getJournalType(), ev
												.getLevel().toString(), ev
												.getMessage()));
					}

					/*
					 * (non-Javadoc)
					 * 
					 * @see
					 * itl.enabler.api.PumpCollection.PumpCollectionEventAdapter
					 * #onTransactionEvent(itl.enabler.api.events.pump.
					 * PumpTransactionEventArgs)
					 */
					@Override
					public void onTransactionEvent(PumpTransactionEventArgs ev) {
						Pump pump = (Pump) ev.getSource();
						switch (ev.getEventType()) {
							case COMPLETED :
								logEntry(String
										.format("Pump %d Transaction - ID:%d event:%s reason:%s - Quantity:%.3f Value:%.3f Price:%.3f",
												pump.getNumber(), ev
														.getTransactionId(), ev
														.getEventType()
														.toString(), ev
														.getTransaction()
														.getHistoryData()
														.getCompletionReason()
														.toString(), ev
														.getTransaction()
														.getDeliveryData()
														.getQuantity(), ev
														.getTransaction()
														.getDeliveryData()
														.getMoney(), ev
														.getTransaction()
														.getDeliveryData()
														.getUnitPrice()));
								break;
							case AUTHORISED :
								logEntry(String
										.format("Pump %d Transaction - ID:%d Authorised:%s",
												pump.getNumber(),
												ev.getTransactionId(), ev
														.getTransaction()
														.getAuthoriseData()
														.getAuthoriseReason()
														.toString()));
								break;
							case CLIENT_ACTIVITY_CHANGED :
								logEntry(String
										.format("Pump %d Transaction - ID:%d ClientActivityChanged activity:%s",
												pump.getNumber(), ev
														.getTransactionId(), ev
														.getTransaction()
														.getClientActivity()));
								break;
							case CLEARED :
								logEntry(String
										.format("Pump %d Transaction - ID:%d Cleared reason:%s",
												pump.getNumber(),
												ev.getTransactionId(), ev
														.getTransaction()
														.getDeliveryType()
														.name()));
								break;
							case LOCKED :
								Terminal terminal = ev.getTransaction()
										.getLockedBy();
								if (terminal != null) {
									logEntry(String
											.format("Pump %d Transaction - ID:%d Locked by Terminal:%s",
													pump.getNumber(),
													ev.getTransactionId(),
													terminal.getName()));
								} else {
									logEntry(String
											.format("Pump %d Transaction - ID:%d Locked by a Terminal that does not exist anymore",
													pump.getNumber(),
													ev.getTransactionId()));
								}
								break;
							case UNLOCKED :
								logEntry(String.format(
										"Pump %d Transaction - ID:%d Unlocked",
										pump.getNumber(), ev.getTransactionId()));

								break;
							case STACKED :
								logEntry(String
										.format("Pump %d Transaction - ID:%d stacked Stack count:%d",
												pump.getNumber(),
												ev.getTransactionId(), ev
														.getTransaction()
														.getPump()
														.getTransactionStack()
														.getCount()));
								break;

							default :
								logEntry(String.format(
										"Pump %d Transaction - ID:%d event:%s",
										pump.getNumber(),
										ev.getTransactionId(), ev
												.getEventType().toString()));
								break;

						}
					}

				});

		// grade events
		forecourt.getGrades().addGradeCollectionEventListener(
				new GradeCollectionEventListener() {

					@Override
					public void OnPriceChange(GradePriceChangeEventArgs evArgs) {
						Grade grade = (Grade) evArgs.getSource();
						logEntry(String
								.format("Grade %d Price change event - priceLevel:%d Price:%.3f",
										grade.getNumber(),
										evArgs.getPriceLevel(),
										evArgs.getUnitPrice()));
					}

					@Override
					public void OnGradeStatus(GradeStatusEventArgs evArgs) {
						Grade grade = (Grade) evArgs.getSource();
						String status = "";

						switch (evArgs.getEventType()) {
							case BLOCKED :
								status = "Block changed to "
										+ (grade.isBlocked() ? "true" : "false");
								break;
							default :
								status = String.format("Type:%s", evArgs
										.getEventType().toString());
						}

						logEntry(String.format(
								"Grade %d Status change event - %s",
								grade.getNumber(), status));

					}
				});

		// terminal events
		forecourt.getTerminals().addTerminalCollectionEventListener(
				new TerminalCollectionEventListener() {

					@Override
					public void OnTerminalStatus(EventObject ev) {
						Terminal terminal = (Terminal) ev.getSource();
						logEntry(String.format("Terminal %d Status:%s",
								terminal.getId(), terminal.isOnline()
										? "Online"
										: "Offline"));

					}
				});

		// tank events
		forecourt.getTanks().addTankCollectionEventListener(
				new TankCollection.TankCollectionEventAdapter() {

					@Override
					public void onLevelChanged(EventObject ev) {
						Tank tank = (Tank) ev.getSource();
						logEntry(String
								.format("Tank %d Level change event - Theo. Volume:%.3f",
										tank.getNumber(),
										tank.getTheoreticalVolume()));
					}

					@Override
					public void onGaugeLevelChanged(EventObject ev) {
						Tank tank = (Tank) ev.getSource();
						logEntry(String
								.format("Tank %d Gauge level event - Volume:%.3f, Non TC Volume:%.3f Temp:%.3f, ProbeStatus:%s",
										tank.getNumber(),
										tank.getGaugeReading().getVolume(),
										tank.getGaugeReading()
												.getNonCompensatedVolume(),
										tank.getGaugeReading().getTemperature(),
										tank.getGaugeReading().getProbeStatus()
												.toString()));
					}

					@Override
					public void onAlarm(TankAlarmEventArgs evArgs) {
						Tank tank = (Tank) evArgs.getSource();
						try {
							logEntry(String.format(
									"Tank %d Alarm Number:%d State:%s",
									tank.getNumber(), evArgs.getAlarmType(),
									tank.getAlarm(evArgs.getAlarmType())));
						} catch (EnablerException ex) {
							// ignore for now
						}
					}

					@Override
					public void onStatusChanged(TankStatusEventArgs evArgs) {
						Tank tank = (Tank) evArgs.getSource();
						if (evArgs.getEventType() == TankStatusEventType.BLOCKED) {
							logEntry(String.format(
									"Tank %d Blocked status : %s", tank
											.getNumber(),
									tank.isBlocked() == true ? "true" : "false"));
						} else if (evArgs.getEventType() == TankStatusEventType.AUTO_BLOCKING) {
							logEntry(String.format(
									"Tank %d AutoBlocking status : %s", tank
											.getNumber(),
									tank.isAutoBlocking() == true
											? "true"
											: "false"));
						}
					}
				});

		// attendant events
		forecourt.getAttendants().addAttendantCollectionEventListener(
				new AttendantCollection.AttendantCollectionEventAdapter() {

					/*
					 * Currently not used
					 * 
					 * @Override public void onPaymentChange(
					 * AttendantPaymentTypeChangeEventArgs evArgs) { Attendant
					 * attendant = (Attendant) evArgs.getSource();
					 * logEntry(String
					 * .format("Attendant %s Payment change type - %d Amount:%.3f"
					 * , attendant.toString(), evArgs.getPaymentType(),
					 * evArgs.getAmount())); }
					 */

					@Override
					public void onLogOn(AttendantLogOnOffEventArgs evArgs) {
						Attendant attendant = (Attendant) evArgs.getSource();
						logEntry(String.format(
								"Attendant %s LogOn Event - Pump:%d Tag:%d",
								attendant.toString(), evArgs.getPumpNumber(),
								evArgs.getTagID()));
					}

					@Override
					public void onLogOff(AttendantLogOnOffEventArgs evArgs) {
						Attendant attendant = (Attendant) evArgs.getSource();
						logEntry(String.format(
								"Attendant %s LogOff Event - Pump:%d",
								attendant.toString(), evArgs.getPumpNumber()));
					}

					@Override
					public void onStatusChanged(AttendantStatusEventArgs evArgs) {
						Attendant attendant = (Attendant) evArgs.getSource();
						logEntry(String.format(
								"Attendant %s Status Change Event:%s",
								attendant.toString(), evArgs.getEventType()
										.toString()));

					}

					/*
					 * Currently not used
					 * 
					 * @Override public void
					 * onLevelAlert(AttendantLevelEventArgs evArgs) { Attendant
					 * attendant = (Attendant) evArgs.getSource();
					 * logEntry(String
					 * .format("Attendant %s Level alert - Status:%s Reason:%d",
					 * attendant.toString(), evArgs .getStatus().toString(),
					 * evArgs .getBlockReason())); }
					 * 
					 * @Override public void onInitialFloatRequired(EventObject
					 * ev) { Attendant attendant = (Attendant) ev.getSource();
					 * logEntry(String.format(
					 * "Attendant %s Initial Float Required",
					 * attendant.toString()));
					 * 
					 * }
					 */

				});

		forecourt.getFallback().addFallbackEventListener(
				new Fallback.FallBackModeEventListener() {

					@Override
					public void onModeChange(EventObject ev) {
						logEntry(String
								.format("Fallback mode changed to %s,  Manual state : %s",
										forecourt.getFallback().getMode()
												.toString(),
										forecourt.getFallback()
												.isManualFallbackState() == true
												? "true"
												: "false"));
					}

					@Override
					public void onActiveClientChange(EventObject ev) {
						logEntry(String.format(
								"Fallback client count changed to : %d",
								forecourt.getFallback().getActiveClientCount()));
					}
				});
	}

	public void logEntry(final String message) {

		SwingUtilities.invokeLater(new Runnable() {

			@Override
			public void run() {
				SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss", Locale
						.getDefault());
				textArea.append(sdf.format(new Date()) + "-" + message + "\n");

				if (chckbxShowLatest.isSelected()) {
					textArea.setCaretPosition(textArea.getDocument()
							.getLength());
				}
			}
		});
	}
}
