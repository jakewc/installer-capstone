package pumpdemo;

import itl.enabler.api.ApiResult;
//import itl.enabler.api.DeliveryData;
import itl.enabler.api.EnablerException;
import itl.enabler.api.EnablerInterface;
import itl.enabler.api.EnablerInterface.EnablerInterfaceType;
import itl.enabler.api.Forecourt;
import itl.enabler.api.Forecourt.ForecourtEventAdapter;
import itl.enabler.api.HardwareInf;
import itl.enabler.api.Pump;
import itl.enabler.api.PumpAuthoriseLimits;
import itl.enabler.api.Transaction;
//import itl.enabler.api.TransactionAuthoriseData;
//import itl.enabler.api.TransactionHistory;
import itl.enabler.api.events.forecourt.ConfigChangeEventArgs;
import itl.enabler.api.events.forecourt.ConnectCompletedEventArgs;
import itl.enabler.api.events.forecourt.MessageReceivedEventArgs;
import itl.enabler.api.events.forecourt.ServerJournalEventArgs;
import itl.enabler.api.events.pump.JournalEventArgs;
import itl.enabler.api.events.pump.PumpTransactionEventArgs;
import itl.enabler.api.events.types.TransactionEventType;
import itl.enabler.api.reasons.CompletionReason;
import itl.enabler.api.states.PumpState;
import itl.enabler.api.states.TransactionState;
import itl.enabler.api.types.ActionType;
import itl.enabler.api.types.DataType;
import itl.enabler.api.types.DeliveryTypes;
import itl.enabler.api.types.ReservedType;
import itl.enabler.api.types.TransactionClearTypes;
import itl.enabler.controls.pump.PumpControl;
import itl.enabler.controls.pump.PumpControlSettings;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.ComponentOrientation;
import java.awt.Dialog.ModalExclusionType;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.Insets;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.SystemColor;
import java.awt.Toolkit;
import java.awt.Window;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.text.NumberFormat;
import java.util.Arrays;
import java.util.EventObject;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JCheckBoxMenuItem;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.SwingConstants;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import javax.swing.border.TitledBorder;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.JTableHeader;

import net.miginfocom.swing.MigLayout;
import pumpdemo.sale.Sale;
import pumpdemo.sale.SaleItem;
import pumpdemo.sale.SaleItemTableFormat;
import ca.odell.glazedlists.EventList;
import ca.odell.glazedlists.event.ListEvent;
import ca.odell.glazedlists.event.ListEventListener;
import ca.odell.glazedlists.swing.EventSelectionModel;
import ca.odell.glazedlists.swing.EventTableModel;

//import javax.swing.AbstractAction;
//import javax.swing.Action;

public class MainWindow {

	/**
	 * Launch application.
	 */
	public static void main(String[] args) {
		try {

			UIManager.setLookAndFeel(UIManager
					.getCrossPlatformLookAndFeelClassName());

		} catch (Throwable e) {
			e.printStackTrace();
		}
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					MainWindow window = new MainWindow();
					window.frmPumpDemo.setVisible(true);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}

	/**
	 * Create application.
	 */
	public MainWindow() {

		forecourt.addForecourtEventListener(new ForecourtEventAdapter() {
			/**
			 * Handle server disconnects
			 * 
			 * @see itl.enabler.api.Forecourt.ForecourtEventAdapter#onServerEvent(java.util.EventObject)
			 */
			@Override
			public void onServerEvent(EventObject eventObject) {

				final String msgString = Forecourt
						.getResultString(ApiResult.DISCONNECT_FROM_SERVER);

				SwingUtilities.invokeLater(new Runnable() {

					@Override
					public void run() {

						/**
						 * Always check if parent frame is still in existence
						 * before showing pop up because this code might even be
						 * called when user clicks on "Exit" menu item and we
						 * don't want the pop up to be dangling on the screen.
						 * See <code>actionPerformed</code> handler on Exit menu
						 * button.
						 * 
						 */
						if (frmPumpDemo.isDisplayable()) {
							/*JOptionPane optionPane = new JOptionPane(msgString,
									JOptionPane.INFORMATION_MESSAGE);
							JDialog dialog = optionPane
									.createDialog(frmPumpDemo.getTitle());
							dialog.setAlwaysOnTop(true);
							dialog.setLocationRelativeTo(frmPumpDemo);
							dialog.setModal(true);
							dialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
							dialog.setVisible(true);*/

							setWindowsStates();
							getStatusText().setText(msgString);
							if (currSelPmpControl != null) {
								currSelPmpControl.setSelected(false);
								currSelPmpControl = null;
							}
							
							if (connectRunning)	// was previously connected?
							{
								connectRunning = false;
								showLogonDialog();
							}
						}
					}
				});
			}

			/**
			 * Show entries made into the system journal on the status bar POS
			 * developers can integrate these events into their own logging
			 * mechanisms.
			 * 
			 * @see itl.enabler.api.Forecourt.ForecourtEventAdapter#onServerJournalEvent(itl.enabler.api.events.forecourt.ServerJournalEventArgs)
			 */
			@Override
			public void onServerJournalEvent(ServerJournalEventArgs evArgs) {

				final String msgString = String.format("%s : %s", evArgs
						.getEventLevel().toString(), evArgs.getMessage());

				SwingUtilities.invokeLater(new Runnable() {

					@Override
					public void run() {
						statusText.setText("");
						statusText.setText(msgString);
					}
				});
			}

			/**
			 * Display messages from other terminals
			 */
			@Override
			public void onMessageReceivedEvent(MessageReceivedEventArgs evArgs) {

				final String msgString = String.format(
						"Message from Terminal %d : (%d)%s",
						evArgs.getSourceTerminalId(),
						evArgs.getNotificationID(),
						evArgs.getNotificationString());

				SwingUtilities.invokeLater(new Runnable() {

					@Override
					public void run() {
						JOptionPane.showMessageDialog(frmPumpDemo, msgString,
								frmPumpDemo.getTitle(),
								JOptionPane.INFORMATION_MESSAGE);
					}
				});
			}

			/*
			 * Reload pump controls and set window states accordingly
			 */
			@Override
			public void onConfigChangeEvent(ConfigChangeEventArgs evArgs) {

				// Only refresh pump controls if there is a change in pump
				// config
				if (evArgs.getDataType() == DataType.PUMP
						&& (evArgs.getActionType() == ActionType.ADD || evArgs
								.getActionType() == ActionType.DELETE)) {

					SwingUtilities.invokeLater(new Runnable() {
						@Override
						public void run() {
							initPumpControls();
							setWindowsStates();
						}
					});
				}
			}

			/**
			 * Handle response for a connection request made to the Enabler from
			 * this terminal.
			 */
			@Override
			public void onConnectAsyncResultEvent(
					ConnectCompletedEventArgs evArgs) {

				// check for result of connect request
				final ApiResult resultCode = evArgs.getConnectResult();
				if (resultCode == ApiResult.OK) {
					
					SwingUtilities.invokeLater(new Runnable() {

						@Override
						public void run() {
							// Load the Pump controls based on current
							// configuration
							initPumpControls();

							// Enable / Disable windows based on current state
							setWindowsStates();

							// show connection details on status bar
							getStatusText().setText("");
							getStatusText().setText(
									statusText.getText()
											+ "Terminal "
											+ terminalID
											+ " connected to  Server : "
											+ forecourt.getServerInformation()
													.getServerName()
											+ " Version : "
											+ forecourt.getServerInformation()
													.getServerVersion());
							connectRunning = true;
						}
					});

				} else { // show error dialog
					SwingUtilities.invokeLater(new Runnable() {

						@Override
						public void run() {
							showPumpDemoError(Forecourt.getResultString(resultCode));
							showLogonDialog();
						}
					});
					
				}
			}
		});

		forecourt.setDebugMode(false);
		initialize();
		enablePanels(false);
		setWindowsStates();
	}

	public JPanel getPanelLayout() {
		return panelLayout;
	}

	public JPanel getPanelControls() {
		return panelControls;
	}

	public JPanel getPanelStatusBar() {
		return panelStatusBar;
	}

	public JPanel getPanelJournal() {
		return panelSales;
	}

	public JPanel getPanelPumpControl() {
		return panelPumpControl;
	}

	public JPanel getPanelTransactionControl() {
		return panelTransactionControl;
	}

	public JPanel getPanelForecourt() {
		return panelForecourt;
	}

	public JPanel getPanelProducts() {
		return panelProducts;
	}

	public JPanel getPanelPayment() {
		return panelPayment;
	}

	public JLabel getStatusText() {
		return statusText;
	}

	/**
	 * Extract API result code from passed exception and display an error
	 * message to the user
	 */
	public void showEnablerError(EnablerException ex) {
		ApiResult apiResult = ex.getResultCode();
		String msg = String.format("Enabler Error (%d): %s",
				apiResult.getValue(), Forecourt.getResultString(apiResult));

		JOptionPane optionPane = new JOptionPane(msg, JOptionPane.ERROR_MESSAGE);
		JDialog dialog = optionPane.createDialog(frmPumpDemo.getTitle());
		dialog.setAlwaysOnTop(true);
		dialog.setLocationRelativeTo(frmPumpDemo);
		dialog.setModal(true);
		dialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		dialog.setVisible(true);
	}

	/**
	 * Error dialog for the pump demo application
	 */
	void showPumpDemoError(String msgStr) {
		JOptionPane optionPane = new JOptionPane(msgStr,
				JOptionPane.ERROR_MESSAGE);
		JDialog dialog = optionPane.createDialog(frmPumpDemo.getTitle());
		dialog.setAlwaysOnTop(true);
		dialog.setLocationRelativeTo(frmPumpDemo);
		dialog.setModal(true);
		dialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		dialog.setVisible(true);
	}

	/**
	 * Initialise the contents of the frame.
	 */
	private void initialize() {

		frmPumpDemo = new JFrame();
		frmPumpDemo
				.setModalExclusionType(ModalExclusionType.APPLICATION_EXCLUDE);
		frmPumpDemo.addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {

				/**
				 * Before exiting Logout if connected to the Enabler and then
				 * close the window
				 */
				if (forecourt.isConnected()) {
					forecourt.disconnect("Exiting");
				}

				if (frmPumpDemo.isDisplayable()) {
					frmPumpDemo.dispose();
				}
			}

			@Override
			public void windowOpened(WindowEvent arg0) {
				showLogonDialog();
			}
		});
		frmPumpDemo.setResizable(false);
		frmPumpDemo.setFont(defaultFont);
		frmPumpDemo.getContentPane().setPreferredSize(new Dimension(950, 400));
		frmPumpDemo.getContentPane().setBackground(UIManager.getColor("inactiveCaption"));
		frmPumpDemo.setIconImage(Toolkit.getDefaultToolkit().getImage(
				MainWindow.class.getResource("/pumpdemo/images/ITLLogo.png")));
		frmPumpDemo.setBackground(SystemColor.windowText);
		frmPumpDemo.setTitle("Pump Demo");
		frmPumpDemo.setBounds(0, 0, 1063, 700);

		frmPumpDemo.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		JMenuBar menuBar = new JMenuBar();
		frmPumpDemo.setJMenuBar(menuBar);

		JMenu mnSession = new JMenu("Session");
		menuBar.add(mnSession);

		mntmLogoff.setEnabled(false);
		mntmLogoff.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				// Only logout if connected to the Enabler
				if (forecourt.isConnected()) {
					forecourt.disconnect("Shift Over");
				} else {
					JOptionPane.showMessageDialog(
							frmPumpDemo,
							Forecourt.getResultString(ApiResult.NOT_CONNECT_TO_PUMP_SERVER),
							frmPumpDemo.getTitle(), JOptionPane.ERROR_MESSAGE);
				}
			}
		});
		mnSession.add(mntmLogoff);

		JMenuItem mntmExit = new JMenuItem("Exit");
		mntmExit.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				/**
				 * Before exiting Logout if connected to the Enabler and then
				 * close the window
				 */
				if (forecourt.isConnected()) {
					forecourt.disconnect("Exiting");
				}

				if (frmPumpDemo.isDisplayable()) {
					frmPumpDemo.dispose();
				}
				
				System.exit(0);	// release all objects!
			}
		});
		mnSession.add(mntmExit);

		JMenu mnOptions = new JMenu("Options");
		menuBar.add(mnOptions);

		final JCheckBoxMenuItem chckbxmntmResrvClearIfZero = new JCheckBoxMenuItem(
				"Reserve Clear if Zero");
		chckbxmntmResrvClearIfZero.setSelected(true);
		mnOptions.add(chckbxmntmResrvClearIfZero);

		JMenuItem mntmShowLog = new JMenuItem("Show Log");
		mntmShowLog.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (logDialog == null) {
					logDialog = new LogFrame(forecourt);

					logDialog.addWindowListener(new WindowAdapter() {
						@Override
						public void windowClosed(WindowEvent e) {
							logDialog = null;

						}
					});

					/**
					 * Always place dialog adjacent to the main window. If main
					 * window is too near to the screen boundary display the
					 * dialog on the other side
					 */
					Point locParent = frmPumpDemo.getLocationOnScreen();
					Dimension dimParent = frmPumpDemo.getSize();
					Dimension dimDialog = logDialog.getSize();
					int location = locParent.x + dimParent.width
							+ dimDialog.width;
					if (location >= Toolkit.getDefaultToolkit().getScreenSize().width) {
						location = locParent.x - dimDialog.width;
					} else {
						location = location - dimDialog.width;
					}
					logDialog.setLocation(new Point(location, locParent.y));
					logDialog.setAlwaysOnTop(true);
					logDialog.setVisible(true);
				}
			}
		});

		mnOptions.add(mntmShowLog);

		JMenu mnAbout = new JMenu("Help");
		menuBar.add(mnAbout);

		JMenuItem mntmAbout = new JMenuItem("About ...");
		mntmAbout.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				showAboutDialog();
			}
		});
		mnAbout.add(mntmAbout);

		JMenuItem mntmHrdInf = new JMenuItem("Hardware Info ...");
		mntmHrdInf.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				// copied from 'Show Log' event
				if (logDialog == null) {
					logDialog = new LogFrame(forecourt);
					logDialog.addWindowListener(new WindowAdapter() {
						@Override
						public void windowClosed(WindowEvent e) {logDialog = null;}
					});
					Point locParent = frmPumpDemo.getLocationOnScreen();
					Dimension dimParent = frmPumpDemo.getSize();
					Dimension dimDialog = logDialog.getSize();
					int location = locParent.x + dimParent.width + dimDialog.width;
					if (location >= Toolkit.getDefaultToolkit().getScreenSize().width) {
						location = locParent.x - dimDialog.width;
					} else {
						location = location - dimDialog.width;
					}
					logDialog.setLocation(new Point(location, locParent.y));
					logDialog.setAlwaysOnTop(true);
					logDialog.setVisible(true);
				}
				
				getHardwareInfo();
			}
		});
		mnAbout.add(mntmHrdInf);
		
		frmPumpDemo.getContentPane().setLayout(
				new BoxLayout(frmPumpDemo.getContentPane(), BoxLayout.Y_AXIS));

		panelLayout = new JPanel();
		panelLayout.setBorder(new CompoundBorder(new EmptyBorder(5, 5, 0, 5),
				new LineBorder(new Color(0, 0, 0))));
		panelLayout.setPreferredSize(new Dimension(10, 390));
		panelLayout.setBackground(SystemColor.text);
		panelLayout.setAlignmentY(Component.TOP_ALIGNMENT);
		panelLayout.setAlignmentX(Component.LEFT_ALIGNMENT);
		frmPumpDemo.getContentPane().add(panelLayout);
		panelLayout.setLayout(new BoxLayout(panelLayout, BoxLayout.X_AXIS));

		panelPumps = new JPanel();
		panelPumps.setBorder(new LineBorder(UIManager.getColor("Button.select"), 3));
		panelPumps.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		panelPumps.setMinimumSize(new Dimension(640, 415));
		panelLayout.add(panelPumps);
		panelPumps.setLayout(new FlowLayout(FlowLayout.LEFT));

		panelSales = new JPanel();
		panelSales.setMinimumSize(new Dimension(450, 100));
		panelSales.setBackground(SystemColor.activeCaptionText);
		panelSales.setBorder(new LineBorder(SystemColor.inactiveCaption, 3));
		panelSales.setMinimumSize(new Dimension(400, 415));
		panelLayout.add(panelSales);
		panelSales.setMaximumSize(new Dimension(450, 415));

		EventList<SaleItem> saleItemEventList = currSale.getSaleItems();
		saleItemEventList
				.addListEventListener(new ListEventListener<SaleItem>() {

					@Override
					public void listChanged(ListEvent<SaleItem> listChanges) {
						SwingUtilities.invokeLater(new Runnable() {
							@Override
							public void run() {
								lblSubTotal.setText(currSale
										.getFormattedSubTotal());

								/**
								 * For some reason the table does not update
								 * itself properly so forced a repaint
								 */
								saleItemTable.repaint();

								// Enable voidItem button if sale is not empty
								if (currSale.getSaleItems().size() > 0) {
									buttonVoidItem.setEnabled(true);
								} else {
									buttonVoidItem.setEnabled(false);
								}

							}
						});
					}
				});

		EventTableModel<SaleItem> saleItemTableModel = new EventTableModel<SaleItem>(
				saleItemEventList, new SaleItemTableFormat());
		final EventSelectionModel<SaleItem> saleItemSelectionModel = new EventSelectionModel<SaleItem>(
				saleItemEventList);

		saleItemTable = new JTable(saleItemTableModel);
		saleItemTable
				.setPreferredScrollableViewportSize(new Dimension(450, 370));
		saleItemTable.setFillsViewportHeight(true);
		saleItemTable.setSelectionModel(saleItemSelectionModel);

		// make all header texts center aligned and set background color
		DefaultTableCellRenderer defaultTableCellRenderer = (DefaultTableCellRenderer) saleItemTable
				.getTableHeader().getDefaultRenderer();
		defaultTableCellRenderer.setHorizontalAlignment(SwingConstants.CENTER);
		JTableHeader header = saleItemTable.getTableHeader();
		header.setBackground(Color.LIGHT_GRAY);

		// make numeric cells right aligned
		DefaultTableCellRenderer rightRenderer = new DefaultTableCellRenderer();
		rightRenderer.setHorizontalAlignment(JLabel.RIGHT);
		saleItemTable.getColumnModel().getColumn(1)
				.setCellRenderer(rightRenderer);
		saleItemTable.getColumnModel().getColumn(2)
				.setCellRenderer(rightRenderer);
		saleItemTable.getColumnModel().getColumn(3)
				.setCellRenderer(rightRenderer);

		// Make the description column a bit wider
		int prefDescColWidth = saleItemTable.getColumnModel().getColumn(0)
				.getPreferredWidth() + 15;
		saleItemTable.getColumnModel().getColumn(0)
				.setPreferredWidth(prefDescColWidth);

		panelSales.setLayout(new BorderLayout(0, 0));

		JScrollPane scrollPane = new JScrollPane(saleItemTable);
		scrollPane.setPreferredSize(new Dimension(453, 370));
		panelSales.add(scrollPane, BorderLayout.NORTH);

		JPanel panelSaleTotals = new JPanel();
		panelSaleTotals.setPreferredSize(new Dimension(10, 40));
		panelSaleTotals.setMinimumSize(new Dimension(10, 35));
		panelSaleTotals.setBackground(Color.LIGHT_GRAY);
		panelSales.add(panelSaleTotals, BorderLayout.SOUTH);
		panelSaleTotals.setLayout(null);

		lblSubTotalName = new JLabel("Sub Total : ");
		subTotalString = lblSubTotalName.getText();
		lblSubTotalName.setFont(saleTotalFont);
		lblSubTotalName.setBounds(145, 12, 104, 28);
		lblSubTotalName.setAlignmentX(Component.CENTER_ALIGNMENT);
		panelSaleTotals.add(lblSubTotalName);

		lblSubTotal = new JLabel("New label");
		lblSubTotal.setHorizontalAlignment(SwingConstants.TRAILING);
		lblSubTotal.setFont(saleTotalFont);
		lblSubTotal.setBounds(319, 12, 63, 28);
		panelSaleTotals.add(lblSubTotal);
		lblSubTotal.setText(currSale.getFormattedSubTotal());

		panelControls = new JPanel();
		panelControls.setPreferredSize(new Dimension(10, 186));
		panelControls.setAlignmentX(Component.LEFT_ALIGNMENT);
		panelControls.setBorder(new CompoundBorder(new EmptyBorder(0, 5, 0, 5),
				new LineBorder(new Color(0, 0, 0))));
		frmPumpDemo.getContentPane().add(panelControls);
		panelControls.setAlignmentY(Component.TOP_ALIGNMENT);
		panelControls.setLayout(new BoxLayout(panelControls,
				BoxLayout.LINE_AXIS));

		panelPumpControl = new JPanel();
		panelPumpControl.setAlignmentX(Component.LEFT_ALIGNMENT);
		panelControls.add(panelPumpControl);
		panelPumpControl.setPreferredSize(new Dimension(100, 100));
		panelPumpControl.setMaximumSize(new Dimension(420, 350));
		panelPumpControl.setBorder(new TitledBorder(UIManager
				.getBorder("InternalFrame.paletteBorder"), "Pump Controls",
				TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panelPumpControl.setBackground(SystemColor.info);
		panelPumpControl
				.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		panelPumpControl.setAlignmentY(Component.TOP_ALIGNMENT);

		btnReserve.setMargin(new Insets(2, 0, 2, 0));
		btnReserve.setHorizontalTextPosition(SwingConstants.CENTER);
		btnReserve.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				if (checkIfPumpSelected() == false) {
					return;
				} else {
					try {
						Pump pump = currSelPmpControl.getPump();
						pump.reserve("Postpay",
								getNextClientref(),
								chckbxmntmResrvClearIfZero.isSelected());

						statusText.setText(String
								.format("Pump %d : Reserved for Postpay with client reference of %s",
										pump.getNumber(),
										pump.getCurrentTransaction().getClientReference() ));
						
					} catch (EnablerException ex) {
						showEnablerError(ex);
					}
				}
			}
		});
		panelPumpControl.setLayout(new MigLayout("", "[grow][grow][56.00,fill]", "[grow,fill][grow,fill][grow,fill][][grow,fill]"));
		btnReserve.setFont(buttonFont);

		btnCancelReserve.setMargin(new Insets(2, 0, 2, 0));
		btnCancelReserve.setHorizontalTextPosition(SwingConstants.LEFT);
		btnCancelReserve.setActionCommand("Cancel Reserve");
		btnCancelReserve.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				if (checkIfPumpSelected() == false) {
					return;
				} else {
					try {
						Pump pump = currSelPmpControl.getPump();
						
		                // First make sure not a unpaid Prepay item in sales list
		                // if it is then void item which will cancel reserve
		                if ( currSale.VoidPrePayItem( pump.getCurrentTransaction() ) == false)
		                {
		                    // Not unpaid prepay so just cancel reserve
		                	pump.cancelReserve();
		                }


						statusText.setText(String.format(
								"Pump %d : Cancelled reserve", pump.getNumber()));
					} catch (EnablerException ex) {
						showEnablerError(ex);
					}
				}
			}
		});
		btnCancelReserve.setFont(buttonFont);

		btnAuthorise.setMargin(new Insets(2, 0, 2, 0));
		btnAuthorise.setFont(buttonFont);
		btnAuthorise.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				if (checkIfPumpSelected() == false) {
					return;
				} else {
					if (currSale.ContainsPrepayItems() == true) {
						JOptionPane.showMessageDialog(frmPumpDemo,
								"Please process the Prepay transaction.",
								frmPumpDemo.getTitle(),
								JOptionPane.INFORMATION_MESSAGE);
						return;
					}
					
					try {
						Pump pump = currSelPmpControl.getPump();
						String clientref;
						
						// If we have previously reserved then use original reference
						if ( pump.isCurrentTransaction() &&
							 pump.getCurrentTransaction().getState() == TransactionState.RESERVED &&
							 pump.getCurrentTransaction().getHistoryData().getReservedByID() == forecourt.getTerminal() ) {
								
							clientref = pump.getCurrentTransaction().getClientReference();
						}
						else {
							clientref = getNextClientref();
						}
							
							
						pump.authoriseWithLimits("Postpay",
								clientref, -1,
								new PumpAuthoriseLimits());

						if (pump.getCurrentTransaction() == null) {
							statusText.setText(String.format(
									"Pump %d : Authorised for Postpay with no client reference",
									pump.getNumber()
								));
						} else {
							statusText.setText(String.format(
									"Pump %d : Authorised for Postpay with client reference of %s",
									pump.getNumber(),
									pump.getCurrentTransaction().getClientReference()
								));
						}
						
					} catch (EnablerException ex) {
						showEnablerError(ex);
					}
				}
			}
		});

		btnToggleBlock.setMargin(new Insets(2, 0, 2, 0));
		btnToggleBlock.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				if (checkIfPumpSelected() == false) {
					return;
				} else {
					Pump pump = currSelPmpControl.getPump();
					String reasonMsg = null;
					if (pump.isBlocked()) {
						reasonMsg = "Manual Unblock";
						try {
							pump.setBlock(false, reasonMsg);
							statusText.setText(String.format(
									"Pump %d : Unblocked", pump.getNumber()));
						} catch (EnablerException ex) {
							showEnablerError(ex);
						}
					} else {
						reasonMsg = "Manual Block";
						try {
							pump.setBlock(true, reasonMsg);
							statusText.setText(String.format(
									"Pump %d : Blocked", pump.getNumber()));
						} catch (EnablerException ex) {
							showEnablerError(ex);
						}
					}
				}
			}
		});
		btnToggleBlock.setFont(buttonFont);

		btnAuthWithLimits.setMargin(new Insets(2, 0, 2, 0));
		btnAuthWithLimits.setIconTextGap(0);
		btnAuthWithLimits.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				if (checkIfPumpSelected() == false) {
					return;
				} else {
					// this code should be removed once Pump Server fixed
					if (currSale.ContainsPrepayItems() == true) {
						JOptionPane.showMessageDialog(frmPumpDemo,
								"Please process the Prepay transaction.",
								frmPumpDemo.getTitle(),
								JOptionPane.INFORMATION_MESSAGE);
						return;
					}
					
					Pump pump = currSelPmpControl.getPump();					
					PumpAuthoriseLimits authoriseLimits = new PumpAuthoriseLimits();
					ClientInfo clientInfo = new ClientInfo();
					AuthoriseDialog authoriseDialog = new AuthoriseDialog(pump, false,
							authoriseLimits, clientInfo);
					authoriseDialog.setLocationRelativeTo(frmPumpDemo);
					authoriseDialog.setVisible(true);

					// if user has a preset authorise the pump
					if (authoriseLimits.getQuantity() != 0
							|| authoriseLimits.getValue() != 0) {
						try {
							pump.authoriseWithLimits(clientInfo.activity,
									clientInfo.reference,
									clientInfo.attendantId, authoriseLimits);
						} catch (EnablerException ex) {
							showEnablerError(ex);
						}
					}
				}
			}
		});
		btnAuthWithLimits.setFont(buttonFont);

		JButton btnTransaction = new JButton("Transactions");
		btnTransaction.setMinimumSize(new Dimension(107, 26));
		btnTransaction.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				if (checkIfPumpSelected() == false) {
					return;
				} else {
					Pump pmp = currSelPmpControl.getPump();
					showTransactionStack(pmp);
				}
			}
		});
		btnTransaction.setFont(buttonFont);
		btnTransaction.setMargin(new Insets(2, 0, 2, 0));

		panelPumpControl.add(btnReserve, "cell 0 0,growx");
		panelPumpControl.add(btnCancelReserve, "cell 1 0,growx");
		panelPumpControl.add(btnToggleBlock, "cell 2 0,growx");
		panelPumpControl.add(btnAuthorise, "cell 0 1,growx");
		panelPumpControl.add(btnAuthWithLimits, "cell 1 1,growx");
		btnCancelAuthorise.setFont(buttonFont);

		btnCancelAuthorise.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (checkIfPumpSelected() == false) {
					return;
				} else {
					try {
						Pump pump = currSelPmpControl.getPump();
						pump.cancelAuthorise();

						statusText.setText(String.format(
								"Pump %d : Cancelled authorisation",
								pump.getNumber()));
					} catch (EnablerException ex) {
						showEnablerError(ex);
					}
				}
			}
		});
		btnCancelAuthorise.setMargin(new Insets(2, 0, 2, 0));
		panelPumpControl.add(btnCancelAuthorise, "cell 2 1");

		btnPause.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (checkIfPumpSelected() == false) {
					return;
				} else {
					try {
						Pump pump = currSelPmpControl.getPump();
						pump.pauseDelivery();

						statusText.setText(String.format(
								"Pump %d : Paused Delivery", pump.getNumber()));
					} catch (EnablerException ex) {
						showEnablerError(ex);
					}
				}
			}
		});
		btnPause.setFont(buttonFont);
		btnPause.setMargin(new Insets(2, 0, 2, 0));
		panelPumpControl.add(btnPause, "cell 0 2,growx");

		btnResume.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				if (checkIfPumpSelected() == false) {
					return;
				} else {
					try {
						Pump pump = currSelPmpControl.getPump();
						pump.resumeDelivery();

						statusText.setText(String.format(
								"Pump %d : Resumed Delivery", pump.getNumber()));
					} catch (EnablerException ex) {
						showEnablerError(ex);
					}
				}
			}
		});
		btnResume.setFont(buttonFont);
		btnResume.setMargin(new Insets(2, 0, 2, 0));
		panelPumpControl.add(btnResume, "cell 1 2,growx");

		panelPumpControl.add(btnTransaction, "cell 2 2,growx");
		btnStop.setFont(buttonFont);
		
				btnStop.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						if (checkIfPumpSelected() == false) {
							return;
						} else {
							try {
								Pump pump = currSelPmpControl.getPump();
								if (pump.getState() != PumpState.MANUAL_PUMP) {
									pump.stop();
									statusText.setText(String.format(
											"Pump %d : Stopped Delivery",
											pump.getNumber()));
								} else {
									showManualTransactionDialog(pump);
								}
							} catch (EnablerException ex) {
								showEnablerError(ex);
							}
						}
					}
				});
				
				JButton btnLegacyPrepay = new JButton("Legacy Prepay");
				btnLegacyPrepay.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						
						if (checkIfPumpSelected() == false) {
							return;
						} else {
		
							Pump pump = currSelPmpControl.getPump();
		
							if (pump.getState() != PumpState.LOCKED) {
								JOptionPane.showMessageDialog(frmPumpDemo,
										"Cannot reserve a delivering pump for prepay",
										frmPumpDemo.getTitle(),
										JOptionPane.INFORMATION_MESSAGE);
								return;
							}
							
							try {
								pump.reserve("PrepayV3",
											  getNextClientref() , true,
											  ReservedType.PREPAY );
								
								PumpAuthoriseLimits authoriseLimits = new PumpAuthoriseLimits();
								PrepayDialog prepayDialog = new PrepayDialog(pump,
										authoriseLimits);
								prepayDialog.setLocationRelativeTo(frmPumpDemo);
								prepayDialog.setVisible(true);
							
								/**
								 * If user has entered a value add a prepay item to the
								 * sale. The transaction will be authorised once this is
								 * paid for. If no value has been entered cancel reserve
								 * on pump and return
								 */
								if (authoriseLimits.getValue() != 0) {
									String saleDescription = String.format(
											"Prepay for pump %d", pump.getNumber());
									currSale.addPrepaySaleItem(pump, authoriseLimits,
											saleDescription, pump.getCurrentTransaction() );
									lblSubTotalName.setText(subTotalString);
								} else {
									pump.cancelReserve();
									return;
								}
							} catch (EnablerException ex) {
								showEnablerError(ex);
							}
							
						}
					}
				});
				
				btnLegacyPrepay.setFont(buttonFont);
				panelPumpControl.add(btnLegacyPrepay, "cell 0 3,alignx center");
				
				JButton btnLegacyPreauth = new JButton("Legacy PreAuth");
				btnLegacyPreauth.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						
						if (checkIfPumpSelected() == false) {
							return;
						} else {
		
							Pump pump = currSelPmpControl.getPump();
							
							try {
								pump.reserve("PreAuthV3",
											  getNextClientref() , true,
											  ReservedType.PREAUTH );
								
								PumpAuthoriseLimits authoriseLimits = new PumpAuthoriseLimits();
								ClientInfo clientInfo = new ClientInfo();
								
								AuthoriseDialog authoriseDialog = new AuthoriseDialog(pump, true,
										authoriseLimits, clientInfo);
								
								authoriseDialog.setLocationRelativeTo(frmPumpDemo);
								authoriseDialog.setVisible(true);

								// if user has a preauth value then authorise the pump
								if ( authoriseLimits.getValue() != 0) {
									try {
										
										pump.authoriseWithLimits( clientInfo.activity,
												clientInfo.reference,
												clientInfo.attendantId, authoriseLimits);
										
									} catch (EnablerException ex) {
										showEnablerError(ex);
									}
								}
								else {
									pump.cancelReserve();
									return;
							 	}
							} catch (EnablerException ex) {
								showEnablerError(ex);
							}
							
						}
						
					}
				});

				btnLegacyPreauth.setFont(buttonFont);
				panelPumpControl.add(btnLegacyPreauth, "cell 1 3,growx");
				
				
				btnPrepay.setFont(buttonFont);
				
						btnPrepay.addActionListener(new ActionListener() {
							public void actionPerformed(ActionEvent e) {
								if (checkIfPumpSelected() == false) {
									return;
								} else {
				
									Pump pump = currSelPmpControl.getPump();
				
									if (pump.getState() != PumpState.LOCKED) {
										JOptionPane.showMessageDialog(frmPumpDemo,
												"Cannot reserve a delivering pump for prepay",
												frmPumpDemo.getTitle(),
												JOptionPane.INFORMATION_MESSAGE);
										return;
									}
				
									try {
										pump.reserve("Prepay",
												getNextClientref(), true);
										
										PumpAuthoriseLimits authoriseLimits = new PumpAuthoriseLimits();
										PrepayDialog prepayDialog = new PrepayDialog(pump,
												authoriseLimits);
										prepayDialog.setLocationRelativeTo(frmPumpDemo);
										prepayDialog.setVisible(true);
				
										/**
										 * If user has entered a value add a prepay item to the
										 * sale. The transaction will be authorised once this is
										 * paid for. If no value has been entered cancel reserve
										 * on pump and return
										 */
										if (authoriseLimits.getValue() != 0) {
											String saleDescription = String.format(
													"Prepay for pump %d", pump.getNumber());
											currSale.addPrepaySaleItem(pump, authoriseLimits,
													saleDescription, pump.getCurrentTransaction() );
											lblSubTotalName.setText(subTotalString);
										} else {
											pump.cancelReserve();
											return;
										}
				
									} catch (EnablerException ex) {
										showEnablerError(ex);
									}
								}
							}
						});
						panelPumpControl.add(btnPrepay, "cell 2 3");
				btnStop.setMargin(new Insets(2, 0, 2, 0));
				panelPumpControl.add(btnStop, "flowx,cell 4 0 1 4,growx");

		panelTransactionControl = new JPanel();
		panelTransactionControl.setMaximumSize(new Dimension(110, 200));
		panelControls.add(panelTransactionControl);
		panelTransactionControl.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		panelTransactionControl.setAlignmentY(Component.TOP_ALIGNMENT);
		panelTransactionControl.setAlignmentX(Component.LEFT_ALIGNMENT);
		panelTransactionControl.setPreferredSize(new Dimension(35, 180));
		panelTransactionControl.setBorder(new TitledBorder(UIManager
				.getBorder("InternalFrame.paletteBorder"), "Transaction",
				TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panelTransactionControl.setBackground(SystemColor.info);
		panelTransactionControl.getInsets(new Insets(5, 5, 5, 5));
		GridBagLayout gbl_panelTransactionControl = new GridBagLayout();
		gbl_panelTransactionControl.columnWidths = new int[] { 115, 0 };
		gbl_panelTransactionControl.rowHeights = new int[] { 34, 34, 34, 34, 0,
				0 };
		gbl_panelTransactionControl.columnWeights = new double[] { 1.0,
				Double.MIN_VALUE };
		gbl_panelTransactionControl.rowWeights = new double[] { 1.0, 0.0, 0.0,
				0.0, 1.0, Double.MIN_VALUE };
		panelTransactionControl.setLayout(gbl_panelTransactionControl);

		JButton btnStack = new JButton("Stack");
		btnStack.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					Pump pump = currSelPmpControl.getPump();
					if (pump.isCurrentTransaction()) {
						pump.stackCurrentTransaction();
					}
				} catch (EnablerException ex) {
					showEnablerError(ex);
				}
			}
		});
		btnStack.setMinimumSize(new Dimension(87, 26));
		btnStack.setPreferredSize(new Dimension(87, 26));
		btnStack.setFont(buttonFont);
		btnStack.setMaximumSize(new Dimension(67, 29));
		GridBagConstraints gbc_btnStack = new GridBagConstraints();
		gbc_btnStack.ipady = 2;
		gbc_btnStack.insets = new Insets(5, 5, 5, 0);
		gbc_btnStack.gridx = 0;
		gbc_btnStack.gridy = 0;
		panelTransactionControl.add(btnStack, gbc_btnStack);

		JButton btnToSale = new JButton("To Sale");
		btnToSale.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				Pump pump = currSelPmpControl.getPump();
				try {
					currSale.addFuelTransaction(pump.getCurrentTransaction());
				} catch (EnablerException ex) {
					showEnablerError(ex);
				}
			}
		});
		btnToSale.setMinimumSize(new Dimension(87, 26));
		btnToSale.setPreferredSize(new Dimension(87, 26));
		btnToSale.setFont(buttonFont);
		btnToSale.setActionCommand("");
		GridBagConstraints gbc_btnToSale = new GridBagConstraints();
		gbc_btnToSale.ipady = 2;
		gbc_btnToSale.insets = new Insets(5, 5, 5, 0);
		gbc_btnToSale.gridx = 0;
		gbc_btnToSale.gridy = 1;
		panelTransactionControl.add(btnToSale, gbc_btnToSale);

		JButton btnDriveOff = new JButton("Drive off");
		btnDriveOff.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				// gone !! now face the music
				clearCurrentTransaction(TransactionClearTypes.DRIVE_OFF);
			}
		});

		btnDriveOff.setMinimumSize(new Dimension(85, 26));
		btnDriveOff.setMaximumSize(new Dimension(101, 26));
		btnDriveOff.setPreferredSize(new Dimension(87, 26));
		btnDriveOff.setFont(buttonFont);
		GridBagConstraints gbc_btnDriveOff = new GridBagConstraints();
		gbc_btnDriveOff.ipady = 2;
		gbc_btnDriveOff.insets = new Insets(5, 5, 5, 0);
		gbc_btnDriveOff.gridx = 0;
		gbc_btnDriveOff.gridy = 2;
		panelTransactionControl.add(btnDriveOff, gbc_btnDriveOff);

		JButton btnTestDel = new JButton("Test Delivery");
		btnTestDel.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				clearCurrentTransaction(TransactionClearTypes.TEST);
			}
		});
		btnTestDel.setMargin(new Insets(1, 3, 1, 3));
		btnTestDel.setPreferredSize(new Dimension(87, 26));
		btnTestDel.setMinimumSize(new Dimension(85, 26));
		btnTestDel.setMaximumSize(new Dimension(101, 26));
		btnTestDel.setFont(buttonFont);
		btnTestDel.setAlignmentY(Component.TOP_ALIGNMENT);
		btnTestDel.setActionCommand("");
		GridBagConstraints gbc_btnTestDel = new GridBagConstraints();
		gbc_btnTestDel.ipady = 2;
		gbc_btnTestDel.insets = new Insets(5, 5, 5, 0);
		gbc_btnTestDel.gridx = 0;
		gbc_btnTestDel.gridy = 3;
		panelTransactionControl.add(btnTestDel, gbc_btnTestDel);

		panelForecourt = new JPanel();
		panelForecourt.setBorder(new TitledBorder(UIManager
				.getBorder("InternalFrame.paletteBorder"), "Forecourt",
				TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panelControls.add(panelForecourt);
		panelForecourt.setPreferredSize(new Dimension(100, 100));
		panelForecourt.setMaximumSize(new Dimension(303, 350));
		panelForecourt.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		panelForecourt.setBackground(SystemColor.info);
		panelForecourt.setAlignmentY(0.0f);
		panelForecourt.setAlignmentX(0.0f);
		GridBagLayout gbl_panelForecourt = new GridBagLayout();
		gbl_panelForecourt.columnWidths = new int[] { 93, 93, 93, 0 };
		gbl_panelForecourt.rowHeights = new int[] { 52, 52, 52, 0 };
		gbl_panelForecourt.columnWeights = new double[] { 0.0, 0.0, 0.0, Double.MIN_VALUE };
		gbl_panelForecourt.rowWeights = new double[] { 0.0, 0.0, 0.0, Double.MIN_VALUE };
		panelForecourt.setLayout(gbl_panelForecourt);

		JButton buttonAuthAll = new JButton(
				"<html>Authorise All <br>Calling<html>");
		buttonAuthAll.setToolTipText("Only Calling Pumps");
		buttonAuthAll.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				// Authorise all calling pumps
				for (Pump pump : forecourt.getPumps()) {
					if (pump.getState() == PumpState.CALLING) {
						try {
							pump.authoriseNoLimits("AllAuthorise", "", -1);
						} catch (EnablerException ex) {
							showEnablerError(ex);
						}
					}
				}
			}
		});
		buttonAuthAll.setMargin(new Insets(1, 3, 1, 3));
		buttonAuthAll.setPreferredSize(new Dimension(41, 25));
		buttonAuthAll.setMinimumSize(new Dimension(0, 0));
		buttonAuthAll.setMaximumSize(new Dimension(0, 0));
		buttonAuthAll.setFont(buttonFont);
		buttonAuthAll.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		buttonAuthAll.setAlignmentX(0.5f);
		GridBagConstraints gbc_buttonAuthAll = new GridBagConstraints();
		gbc_buttonAuthAll.fill = GridBagConstraints.BOTH;
		gbc_buttonAuthAll.insets = new Insets(5, 5, 5, 5);
		gbc_buttonAuthAll.gridx = 0;
		gbc_buttonAuthAll.gridy = 0;
		panelForecourt.add(buttonAuthAll, gbc_buttonAuthAll);

		JButton buttonPricingProfile = new JButton(
				"<html>Pricing and <br>Profiles<html>");
		buttonPricingProfile.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				showGradePricingDialog();
			}
		});
		buttonPricingProfile.setMargin(new Insets(1, 3, 1, 3));
		buttonPricingProfile.setFont(buttonFont);
		GridBagConstraints gbc_buttonPricingProfile = new GridBagConstraints();
		gbc_buttonPricingProfile.fill = GridBagConstraints.BOTH;
		gbc_buttonPricingProfile.insets = new Insets(5, 5, 5, 5);
		gbc_buttonPricingProfile.gridx = 1;
		gbc_buttonPricingProfile.gridy = 0;
		
		panelForecourt.add(buttonPricingProfile, gbc_buttonPricingProfile);

		JButton buttonMessage = new JButton("Message");
		buttonMessage.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				showMessageDialog();
			}
		});
		buttonMessage.setFont(buttonFont);
		GridBagConstraints gbc_buttonMessage = new GridBagConstraints();
		gbc_buttonMessage.fill = GridBagConstraints.BOTH;
		gbc_buttonMessage.insets = new Insets(5, 5, 5, 0);
		gbc_buttonMessage.gridx = 2;
		gbc_buttonMessage.gridy = 0;
		panelForecourt.add(buttonMessage, gbc_buttonMessage);

		JButton buttonAllStop = new JButton("Stop");
		buttonAllStop.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					// stop all pumps on the forecourt
					forecourt.stop();
				} catch (EnablerException ex) {
					showEnablerError(ex);
				}
			}
		});
		buttonAllStop.setPreferredSize(new Dimension(41, 32));
		buttonAllStop.setMinimumSize(new Dimension(0, 0));
		buttonAllStop.setMaximumSize(new Dimension(0, 0));
		buttonAllStop.setMargin(new Insets(1, 3, 1, 3));
		buttonAllStop.setFont(buttonFont);
		GridBagConstraints gbc_buttonAllStop = new GridBagConstraints();
		gbc_buttonAllStop.fill = GridBagConstraints.BOTH;
		gbc_buttonAllStop.insets = new Insets(5, 5, 5, 5);
		gbc_buttonAllStop.gridx = 0;
		gbc_buttonAllStop.gridy = 1;
		panelForecourt.add(buttonAllStop, gbc_buttonAllStop);

		buttonLookupTransactions = new JButton(
				"<html>Lookup<br>Transactions<html>");
		buttonLookupTransactions.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				showLookupTransactionDialog();
			}
		});
		buttonLookupTransactions.setMargin(new Insets(1, 3, 1, 3));
		buttonLookupTransactions.setFont(buttonFont);
		GridBagConstraints gbc_buttonLookupTransactions = new GridBagConstraints();
		gbc_buttonLookupTransactions.insets = new Insets(5, 5, 5, 5);
		gbc_buttonLookupTransactions.gridx = 1;
		gbc_buttonLookupTransactions.gridy = 1;
		panelForecourt.add(buttonLookupTransactions, gbc_buttonLookupTransactions);

		buttonAttendants = new JButton("Attendants");
		buttonAttendants.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent arg0) {
				if (forecourt.getAttendants().getCount() == 0) {
					showPumpDemoError("No Attendents configured");
					return;
				} else {
					showAttendantsDialog();
				}
			}
		});
		buttonAttendants.setFont(buttonFont);
		GridBagConstraints gbc_buttonAttendants = new GridBagConstraints();
		gbc_buttonAttendants.fill = GridBagConstraints.BOTH;
		gbc_buttonAttendants.insets = new Insets(5, 5, 5, 0);
		gbc_buttonAttendants.gridx = 2;
		gbc_buttonAttendants.gridy = 1;
		panelForecourt.add(buttonAttendants, gbc_buttonAttendants);

		JButton buttonPumpLights = new JButton("<html>Toggle Pump<br>Lights");
		buttonPumpLights.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					forecourt.setPumpLights(!forecourt.getPumpLightState());
				} catch (EnablerException ex) {
					showEnablerError(ex);
				}
			}
		});
		buttonPumpLights.setMargin(new Insets(1, 3, 1, 3));
		buttonPumpLights.setHorizontalAlignment(SwingConstants.LEADING);
		buttonPumpLights.setFont(buttonFont);
		GridBagConstraints gbc_buttonPumpLights = new GridBagConstraints();
		gbc_buttonPumpLights.fill = GridBagConstraints.BOTH;
		gbc_buttonPumpLights.insets = new Insets(5, 5, 5, 5);
		gbc_buttonPumpLights.gridx = 0;
		gbc_buttonPumpLights.gridy = 2;
		panelForecourt.add(buttonPumpLights, gbc_buttonPumpLights);

		buttonTanks = new JButton("Tanks");
		buttonTanks.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				showTanksDialog();
			}
		});
		buttonTanks.setMargin(new Insets(1, 3, 1, 3));
		buttonTanks.setFont(buttonFont);
		GridBagConstraints gbc_buttonTanks = new GridBagConstraints();
		gbc_buttonTanks.fill = GridBagConstraints.BOTH;
		gbc_buttonTanks.insets = new Insets(5, 5, 5, 5);
		gbc_buttonTanks.gridx = 1;
		gbc_buttonTanks.gridy = 2;
		panelForecourt.add(buttonTanks, gbc_buttonTanks);

		JButton buttonTerminal = new JButton("Terminals");
		buttonTerminal.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				TerminalsDialog terminalsDialog = new TerminalsDialog(forecourt);
				terminalsDialog.setLocationRelativeTo(frmPumpDemo);
				terminalsDialog.setVisible(true);
			}
		});
		buttonTerminal.setFont(buttonFont);
		GridBagConstraints gbc_buttonTerminal = new GridBagConstraints();
		gbc_buttonTerminal.insets = new Insets(5, 5, 5, 0);
		gbc_buttonTerminal.fill = GridBagConstraints.BOTH;
		gbc_buttonTerminal.gridx = 2;
		gbc_buttonTerminal.gridy = 2;
		panelForecourt.add(buttonTerminal, gbc_buttonTerminal);

		panelProducts = new JPanel();
		panelProducts.setBorder(new TitledBorder(UIManager
				.getBorder("InternalFrame.paletteBorder"), "Products",
				TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panelProducts.setAlignmentY(Component.TOP_ALIGNMENT);
		panelProducts.setAlignmentX(Component.LEFT_ALIGNMENT);
		panelProducts.setPreferredSize(new Dimension(10, 200));
		panelProducts.setBackground(SystemColor.info);
		panelProducts.setMaximumSize(new Dimension(109, 200));
		panelControls.add(panelProducts);
		GridBagLayout gbl_panelProducts = new GridBagLayout();
		gbl_panelProducts.columnWidths = new int[] { 0, 0, 0 };
		gbl_panelProducts.rowHeights = new int[] { 0, 0, 0, 0, 0 };
		gbl_panelProducts.columnWeights = new double[] { 0.0, 0.0,
				Double.MIN_VALUE };
		gbl_panelProducts.rowWeights = new double[] { 0.0, 0.0, 0.0, 0.0,
				Double.MIN_VALUE };
		panelProducts.setLayout(gbl_panelProducts);

		JButton btnOil = new JButton("Oil");
		btnOil.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				try {
					currSale.addNormalSaleItem("Oil 1 Litre", 1, 1.67);
					lblSubTotalName.setText(subTotalString);
				} catch (EnablerException ex) {
					showEnablerError(ex);
				}
			}
		});
		btnOil.setPreferredSize(new Dimension(69, 26));
		btnOil.setMaximumSize(new Dimension(69, 26));
		btnOil.setAlignmentY(Component.TOP_ALIGNMENT);
		btnOil.setFont(buttonFont);
		btnOil.setMargin(new Insets(1, 1, 1, 1));
		GridBagConstraints gbc_btnOil = new GridBagConstraints();
		gbc_btnOil.ipady = 4;
		gbc_btnOil.ipadx = 12;
		gbc_btnOil.fill = GridBagConstraints.HORIZONTAL;
		gbc_btnOil.insets = new Insets(5, 5, 5, 5);
		gbc_btnOil.gridx = 0;
		gbc_btnOil.gridy = 0;
		panelProducts.add(btnOil, gbc_btnOil);

		JButton btnCandy = new JButton("Candy");
		btnCandy.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					currSale.addNormalSaleItem("Candy Bar 300g", 1, 2.5);
					lblSubTotalName.setText(subTotalString);
				} catch (EnablerException ex) {
					showEnablerError(ex);
				}
			}
		});
		btnCandy.setFont(buttonFont);
		btnCandy.setMargin(new Insets(1, 1, 1, 1));
		GridBagConstraints gbc_btnCandy = new GridBagConstraints();
		gbc_btnCandy.fill = GridBagConstraints.BOTH;
		gbc_btnCandy.insets = new Insets(5, 4, 5, 0);
		gbc_btnCandy.gridx = 1;
		gbc_btnCandy.gridy = 0;
		panelProducts.add(btnCandy, gbc_btnCandy);

		JButton btnCoke = new JButton("Coke");
		btnCoke.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					currSale.addNormalSaleItem("Coke Bottle 850ml", 1, 2.05);
					lblSubTotalName.setText(subTotalString);
				} catch (EnablerException ex) {
					showEnablerError(ex);
				}
			}
		});
		btnCoke.setPreferredSize(new Dimension(69, 26));
		btnCoke.setMaximumSize(new Dimension(69, 26));
		btnCoke.setMargin(new Insets(1, 1, 1, 1));
		btnCoke.setFont(buttonFont);
		btnCoke.setAlignmentY(0.0f);
		GridBagConstraints gbc_btnCoke = new GridBagConstraints();
		gbc_btnCoke.ipady = 4;
		gbc_btnCoke.insets = new Insets(5, 5, 5, 5);
		gbc_btnCoke.gridx = 0;
		gbc_btnCoke.gridy = 1;
		panelProducts.add(btnCoke, gbc_btnCoke);

		JButton btnPaper = new JButton("Paper");
		btnPaper.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					currSale.addNormalSaleItem("The Times", 1, 1.05);
					lblSubTotalName.setText(subTotalString);
				} catch (EnablerException ex) {
					showEnablerError(ex);
				}
			}
		});
		btnPaper.setMargin(new Insets(1, 1, 1, 1));
		btnPaper.setFont(buttonFont);
		GridBagConstraints gbc_btnPaper = new GridBagConstraints();
		gbc_btnPaper.fill = GridBagConstraints.BOTH;
		gbc_btnPaper.insets = new Insets(5, 4, 5, 0);
		gbc_btnPaper.gridx = 1;
		gbc_btnPaper.gridy = 1;
		panelProducts.add(btnPaper, gbc_btnPaper);

		JButton button = new JButton("");
		button.setMinimumSize(new Dimension(33, 26));
		button.setPreferredSize(new Dimension(69, 26));
		button.setMaximumSize(new Dimension(69, 26));
		button.setMargin(new Insets(1, 1, 1, 1));
		button.setFont(buttonFont);
		button.setAlignmentY(0.0f);
		GridBagConstraints gbc_button = new GridBagConstraints();
		gbc_button.ipady = 5;
		gbc_button.ipadx = 4;
		gbc_button.insets = new Insets(5, 5, 5, 5);
		gbc_button.gridx = 0;
		gbc_button.gridy = 2;
		panelProducts.add(button, gbc_button);

		JButton button_1 = new JButton("");
		button_1.setMargin(new Insets(1, 1, 1, 1));
		button_1.setFont(buttonFont);
		GridBagConstraints gbc_button_1 = new GridBagConstraints();
		gbc_button_1.fill = GridBagConstraints.BOTH;
		gbc_button_1.insets = new Insets(5, 4, 5, 0);
		gbc_button_1.gridx = 1;
		gbc_button_1.gridy = 2;
		panelProducts.add(button_1, gbc_button_1);

		JButton button_2 = new JButton("");
		button_2.setMinimumSize(new Dimension(33, 26));
		button_2.setPreferredSize(new Dimension(69, 26));
		button_2.setMaximumSize(new Dimension(69, 26));
		button_2.setMargin(new Insets(1, 1, 1, 1));
		button_2.setFont(buttonFont);
		button_2.setAlignmentY(0.0f);
		GridBagConstraints gbc_button_2 = new GridBagConstraints();
		gbc_button_2.ipady = 5;
		gbc_button_2.ipadx = 4;
		gbc_button_2.insets = new Insets(5, 5, 5, 5);
		gbc_button_2.gridx = 0;
		gbc_button_2.gridy = 3;
		panelProducts.add(button_2, gbc_button_2);

		JButton button_3 = new JButton("");
		button_3.setMargin(new Insets(1, 1, 1, 1));
		button_3.setFont(buttonFont);
		GridBagConstraints gbc_button_3 = new GridBagConstraints();
		gbc_button_3.fill = GridBagConstraints.BOTH;
		gbc_button_3.insets = new Insets(5, 4, 5, 0);
		gbc_button_3.gridx = 1;
		gbc_button_3.gridy = 3;
		panelProducts.add(button_3, gbc_button_3);

		panelPayment = new JPanel();
		panelPayment.setBorder(new TitledBorder(UIManager
				.getBorder("InternalFrame.paletteBorder"), "Payment",
				TitledBorder.LEADING, TitledBorder.TOP, null, null));
		panelControls.add(panelPayment);
		panelPayment.setPreferredSize(new Dimension(10, 200));
		panelPayment.setMaximumSize(new Dimension(111, 200));
		panelPayment.setBackground(SystemColor.info);
		panelPayment.setAlignmentY(0.0f);
		panelPayment.setAlignmentX(0.0f);
		GridBagLayout gbl_panelPayment = new GridBagLayout();
		gbl_panelPayment.columnWidths = new int[] { 99, 0 };
		gbl_panelPayment.rowHeights = new int[] { 26, 135, 0 };
		gbl_panelPayment.columnWeights = new double[] { 0.0, Double.MIN_VALUE };
		gbl_panelPayment.rowWeights = new double[] { 0.0, 0.0, Double.MIN_VALUE };
		panelPayment.setLayout(gbl_panelPayment);

		buttonVoidItem = new JButton("Void Item");
		buttonVoidItem.setEnabled(false);
		buttonVoidItem.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				/**
				 * Cancel(void) all user selected sale items
				 */
				EventList<SaleItem> selected = saleItemSelectionModel
						.getSelected();
				for (SaleItem saleItem : selected) {
					try {
						currSale.voidItem(saleItem);
					} catch (EnablerException ex) {
						showEnablerError(ex);
					}
				}
				saleItemSelectionModel.clearSelection();
			}
		});
		buttonVoidItem.setMinimumSize(new Dimension(32, 38));
		buttonVoidItem.setAlignmentY(Component.TOP_ALIGNMENT);
		buttonVoidItem.setPreferredSize(new Dimension(39, 32));
		buttonVoidItem.setMaximumSize(new Dimension(39, 32));
		buttonVoidItem.setMargin(new Insets(1, 1, 1, 1));
		buttonVoidItem.setFont(buttonFont);
		GridBagConstraints gbc_buttonVoidItem = new GridBagConstraints();
		gbc_buttonVoidItem.fill = GridBagConstraints.BOTH;
		gbc_buttonVoidItem.insets = new Insets(25, 5, 5, 5);
		gbc_buttonVoidItem.gridx = 0;
		gbc_buttonVoidItem.gridy = 0;
		panelPayment.add(buttonVoidItem, gbc_buttonVoidItem);

		JButton buttonClear = new JButton("Clear");
		buttonClear.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				try {
					currSale.clearSales();
					lblSubTotalName.setText(subTotalString);

				} catch (EnablerException ex) {
					showEnablerError(ex);
				}
			}
		});
		buttonClear.setAlignmentY(Component.TOP_ALIGNMENT);
		buttonClear.setPreferredSize(new Dimension(69, 26));
		buttonClear.setMaximumSize(new Dimension(69, 26));
		buttonClear.setMargin(new Insets(1, 1, 1, 1));
		buttonClear.setFont(buttonFont);
		GridBagConstraints gbc_buttonClear = new GridBagConstraints();
		gbc_buttonClear.fill = GridBagConstraints.VERTICAL;
		gbc_buttonClear.anchor = GridBagConstraints.WEST;
		gbc_buttonClear.insets = new Insets(5, 5, 28, 5);
		gbc_buttonClear.gridx = 0;
		gbc_buttonClear.gridy = 1;
		panelPayment.add(buttonClear, gbc_buttonClear);

		JButton buttonCash = new JButton("Pay");
		final String cashString = "Cash :";
		buttonCash.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {

				// process Sale
				processSale();
				lblSubTotalName.setText(cashString);
			}
		});
		buttonCash.setMargin(new Insets(1, 1, 1, 1));
		buttonCash.setFont(buttonFont);
		GridBagConstraints gbc_buttonCash = new GridBagConstraints();
		gbc_buttonCash.ipadx = 10;
		gbc_buttonCash.anchor = GridBagConstraints.EAST;
		gbc_buttonCash.fill = GridBagConstraints.VERTICAL;
		gbc_buttonCash.insets = new Insets(5, 5, 28, 5);
		gbc_buttonCash.gridx = 0;
		gbc_buttonCash.gridy = 1;
		panelPayment.add(buttonCash, gbc_buttonCash);

		panelStatusBar = new JPanel();
		panelStatusBar.setMinimumSize(new Dimension(10, 5));
		panelStatusBar.setPreferredSize(new Dimension(10, 4));
		panelStatusBar.setBorder(null);
		panelStatusBar.setAlignmentY(Component.TOP_ALIGNMENT);
		panelStatusBar.setAlignmentX(Component.LEFT_ALIGNMENT);
		FlowLayout fl_panelStatusBar = (FlowLayout) panelStatusBar.getLayout();
		fl_panelStatusBar.setVgap(10);
		fl_panelStatusBar.setAlignment(FlowLayout.LEFT);
		frmPumpDemo.getContentPane().add(panelStatusBar);

		statusText = new JLabel("");
		statusText.setForeground(Color.RED);
		statusText.setFont(statusFont);
		statusText.setPreferredSize(new Dimension(930, 20));
		panelStatusBar.add(statusText);
		statusText.setAlignmentY(Component.TOP_ALIGNMENT);
		statusText.setMinimumSize(new Dimension(950, 20));
		statusText.setBackground(new Color(153, 204, 51));

	}

	private String  getNextClientref()
	{
		return Integer.toString( myTransClientRef++ );
	}
	
	private void setWindowsStates() {

		boolean isPmpSelect = false;
		boolean isCurrTransCompleted = false;

		if (forecourt.isConnected()) {

			if (currSelPmpControl != null) {
				isPmpSelect = true;
			}

			if (isPmpSelect
					&& (currSelPmpControl.getPump().getCurrentTransaction() != null)) {
				if (currSelPmpControl.getPump().getCurrentTransaction()
						.getState() == TransactionState.COMPLETED)
					isCurrTransCompleted = true;
			}

			// Enable pump control box when a pump is selected
			if (isPmpSelect) {
				enableChildren(panelPumpControl, true);
			} else {
				enableChildren(panelPumpControl, false);
			}

			// Enable delivery box if we have a current completed
			// transaction
			if (isCurrTransCompleted) {
				enableChildren(panelTransactionControl, true);
			} else {
				enableChildren(panelTransactionControl, false);
			}

			setPumpButtons();

			// Enable group boxes and Logoff menu item if connected to the
			// server
			if (forecourt.isConnected()) {
				enableChildren(panelProducts, true);
				enableChildren(panelForecourt, true);
				enableChildren(panelPayment, true);

				mntmLogoff.setEnabled(true);

				// but disable Void item button always
				buttonVoidItem.setEnabled(false);
			}
		} else {
			enableChildren(panelPumpControl, false);
			enableChildren(panelProducts, false);
			enableChildren(panelForecourt, false);
			enableChildren(panelPayment, false);

			mntmLogoff.setEnabled(false);
		}

	}

	private void setPumpButtons() {

		boolean enable = true;

		if (currSelPmpControl != null) {
			if (currSelPmpControl.getPump().getState() == PumpState.MANUAL_PUMP) {
				enable = false;
				btnStop.setText("Manual Transaction");
			} else {
				btnStop.setText("Stop");
			}
			btnToggleBlock.setEnabled(enable);
			btnReserve.setEnabled(enable);
			btnCancelReserve.setEnabled(enable);
			btnAuthorise.setEnabled(enable);
			btnCancelAuthorise.setEnabled(enable);
			btnPause.setEnabled(enable);
			btnResume.setEnabled(enable);
			btnAuthWithLimits.setEnabled(enable);
			btnPrepay.setEnabled(enable);
		}
	}

	private void enablePanels(boolean isEnabled) {
		enableChildren(panelControls, isEnabled);
		panelControls.setEnabled(isEnabled);
	}

	private void enableChildren(JComponent parent, boolean isEnabled) {
		for (Component component : parent.getComponents()) {
			enableChildren((JComponent) component, isEnabled);
			component.setEnabled(isEnabled);

		}
	}

	private void initPumpControls() {

		/**
		 * Add all pump controls to pump panel. <br>
		 * First, dispose all existing PumpControls so they immediately remove
		 * all links to forecourt pumps from a previous session.
		 * 
		 */
		if (panelPumps.getComponentCount() > 0) {

			for (int i = 0; i < panelPumps.getComponentCount(); i++) {

				PumpControl pumpControl = (PumpControl) panelPumps
						.getComponent(i);
				pumpControl.dispose();
			}

			panelPumps.removeAll();
			panelPumps.revalidate();
			panelPumps.repaint();
		}

		for (final Pump pump : forecourt.getPumps()) {

			pump.addPumpEventListener(new Pump.PumpEventAdapter() {
				/*
				 * (non-Javadoc)
				 * 
				 * @see
				 * itl.enabler.api.Pump.PumpEventAdapter#onTransactionEvent(
				 * itl.enabler.api.events.pump.PumpTransactionEventArgs)
				 */
				@Override
				public void onTransactionEvent(PumpTransactionEventArgs ev) {
					
					// Completed Transaction
					if ( ev.getEventType() == TransactionEventType.CLEARED ) {
						
						currSale.RemovePrepayTrans(ev.getTransactionId());
					}
					
					SwingUtilities.invokeLater(new Runnable() {

						@Override
						public void run() {
							setWindowsStates();
						}
					});
				}

				/*
				 * (non-Javadoc)
				 * 
				 * @see
				 * itl.enabler.api.Pump.PumpEventAdapter#onJournalEvent(itl.
				 * enabler.api.events.pump.JournalEventArgs)
				 */
				@Override
				public void onJournalEvent(final JournalEventArgs ev) {

					SwingUtilities.invokeLater(new Runnable() {

						@Override
						public void run() {
							getStatusText().setText(
									String.format("Pump %d - %s",
											pump.getNumber(), ev.getMessage()));

						}
					});
				}

			});

			final PumpControl pumpControl = new PumpControl(pump,
					pumpControlSettings);
			pumpControl.addMouseListener(new MouseAdapter() {

				/**
				 * User has selected this pump. Deselect the previously selected
				 * pump. Check for ongoing transactions. If there are no ongoing
				 * transactions check pump state and decide what to do.
				 */
				@Override
				public void mouseClicked(MouseEvent mouseEvent) {
					super.mouseClicked(mouseEvent);

					PumpControl prevSelPmpCntrl = currSelPmpControl;
					currSelPmpControl = pumpControl;
					currSelPmpControl.setSelected(true);
					if (prevSelPmpCntrl != null) {
						prevSelPmpCntrl.setSelected(false);
					}
					Pump currPmp = currSelPmpControl.getPump();
					statusText.setText(String.format("Selected Pump %d",
							currPmp.getNumber()));

					/**
					 * Check if there is current transaction. If no than decide
					 * what to do based on the pump state. If there is no
					 * current transaction and user double clicks on show
					 * Transaction stack for the pump.
					 */
					if (currPmp.isCurrentTransaction()) {

						Transaction currTransaction = currPmp
								.getCurrentTransaction();
						/**
						 * We have a transaction. Check the pump transaction
						 * stack. If stack is empty and current transaction has
						 * completed normally add it to a sale. For prepays, see
						 * if there is any refund to be paid. Else Display a
						 * list of stacked transactions.
						 */
						if (currPmp.getTransactionStack().getCount() == 0) {

							try {
								if (currTransaction.getState() == TransactionState.COMPLETED) {
									
									if (currTransaction.getHistoryData()
											.getCompletionReason() == CompletionReason.NORMAL) {
										
										if (currTransaction.getClientActivity().contains("Prepay") == true &&
												currTransaction.getDeliveryType() != DeliveryTypes.AVAILABLE_PREPAY_REFUND	) 
										{
											double refund = currSale.processPrepayComplete(currTransaction);
											String refundMsg = null;
											if (refund > 0) {
												refundMsg = String
														.format("Refund : %s",
																NumberFormat
																		.getCurrencyInstance()
																		.format(refund));
											} else {
												refundMsg = "No Refund";
											}
											
											JOptionPane.showMessageDialog( frmPumpDemo,
											                               refundMsg,
											                               frmPumpDemo
											                               .getTitle(),
											                               JOptionPane.INFORMATION_MESSAGE);
										} 
										else {
											if ( currTransaction.getDeliveryType() == DeliveryTypes.AVAILABLE_PREAUTH ) 
											{
												// Handle legacy preauth
												currSale.processPreauthComplete(currTransaction);
												
												String preAuthMsg = null;
												
												preAuthMsg ="PreAuth transaction id:" + Integer.toString( currTransaction.getId() ) + " cleared";
												
												JOptionPane.showMessageDialog( frmPumpDemo,
												                               preAuthMsg,
												                               frmPumpDemo
												                               .getTitle(),
												                               JOptionPane.INFORMATION_MESSAGE);
											}
											else 
											{
												currSale.addFuelTransaction(currTransaction);
												lblSubTotalName.setText(subTotalString);
											}
										}
										
									}
									else if (currTransaction.getHistoryData()
											.getCompletionReason() == CompletionReason.ZERO) 
									{
										String message = new String(
												"This is a ZERO transaction, press OK to continue");
										JOptionPane.showMessageDialog(
												frmPumpDemo, message,
												frmPumpDemo.getTitle()
														+ ": Zero Transaction",
												JOptionPane.INFORMATION_MESSAGE);
										
										// add the zero fuel transaction to the sale window
										currSale.addFuelTransaction(currTransaction);
										lblSubTotalName.setText(subTotalString);
									}
									else if (currTransaction.getHistoryData()
											.getCompletionReason() == CompletionReason.NOT_COMPLETE) 
									{
										; // ignore transactions that are incomplete
									} 
									else 
									{
										String message = String
												.format("This is a %s transaction, press OK to continue",
														currTransaction
																.getHistoryData()
																.getCompletionReason()
																.toString());
										JOptionPane.showMessageDialog(
												frmPumpDemo,
												message,
												frmPumpDemo.getTitle()
														+ ": Error Transaction",
												JOptionPane.INFORMATION_MESSAGE);
										showTransactionStack(currPmp);
									}
								}
							} catch (EnablerException ex) {
								showEnablerError(ex);
							}
						} else {
							showTransactionStack(currPmp);
						}
					} else {
						if (currPmp.getState() == PumpState.CALLING) {

							// Authorise the pump
							try {
								currPmp.authoriseNoLimits("", "", -1);
							} catch (EnablerException ex) {
								showEnablerError(ex);
							}
						} else if (currPmp.getState() == PumpState.LOCKED) {
							if (mouseEvent.getClickCount() == 2) {
								showTransactionStack(currPmp);
							}
						}
					}
					setWindowsStates();
				}
			});

			panelPumps.add(pumpControl);
		}
	}

	/**
	 * Show a login dialog to start a new Enabler session on the Forecourt. This
	 * dialog is displayed as soon as : <br>
	 * The user invokes the Pump Demo OR <br>
	 * Immediately after the user logs out of a session using the 'Logoff' menu
	 * item on the main window of the Pump Demo OR <br>
	 * A client is disconnected from the server due to the connection being
	 * broken. (Eg. Server restart) <br>
	 * The 'Logon' button logs in to the Enabler and the 'Exit App' button exits
	 * the Pump Demo.
	 */
	private void showLogonDialog() {
		
		if (connectRunning) return;	// already connected		

		LogonDialog dlg = new LogonDialog(frmPumpDemo);
		dlg.setLocationRelativeTo(frmPumpDemo);
		dlg.setVisible(true);

		if (dlg.result == true) {
			server = dlg.server;
			terminalID = dlg.terminalID;
			password = dlg.password;
			active = dlg.active;
			forecourt.connectAsync(dlg.server, dlg.terminalID, "Pump Demo",
					new String(dlg.password), dlg.active);
			Arrays.fill(password, '0'); // for strong security
		}
		dlg.dispose();

	}

	private void showTransactionStack(Pump currPmp) {

		// If dialog is already showing for a pump do not show again
		Window[] windows = frmPumpDemo.getOwnedWindows();
		for (Window window : windows) {
			if (window.getClass() == PumpTransactionDialog.class) {
				PumpTransactionDialog dialog = (PumpTransactionDialog) window;
				if (dialog.isVisible()
						&& dialog.getTitle().endsWith(
								String.format("Pump %d", currPmp.getNumber()))) {
					return;
				}
			}
		}
		PumpTransactionDialog pumpTransactionDialog = new PumpTransactionDialog(
				this, currPmp, currSale);
		pumpTransactionDialog.setLocationRelativeTo(frmPumpDemo);
		pumpTransactionDialog.setVisible(true);
	}

	private void showLookupTransactionDialog() {

		LookupTransactionDialog lookupTransDialog = new LookupTransactionDialog(
				this);
		lookupTransDialog.setLocationRelativeTo(frmPumpDemo);
		lookupTransDialog.setVisible(true);
		Transaction transaction = lookupTransDialog.getTransaction();
		if (transaction != null) {
			TransactionDetailsDialog detailsDialog = new TransactionDetailsDialog(
					this, transaction);
			lookupTransDialog.dispose();

			detailsDialog.setLocationRelativeTo(frmPumpDemo);
			detailsDialog.setVisible(true);
		} else {
			lookupTransDialog.dispose();
		}
	}

	private void showGradePricingDialog() {
		GradePricingDialog gradePricingDialog = new GradePricingDialog(this,
				forecourt);
		gradePricingDialog.setLocationRelativeTo(frmPumpDemo);
		gradePricingDialog.setVisible(true);
	}

	private void showTanksDialog() {
		TanksDialog tanksDialog = new TanksDialog(this, forecourt);
		tanksDialog.setLocationRelativeTo(frmPumpDemo);
		tanksDialog.setVisible(true);
	}

	private void showAttendantsDialog() {
		AttendantsDialog attendantsDialog = new AttendantsDialog(this,
				forecourt);
		attendantsDialog.setLocationRelativeTo(frmPumpDemo);
		attendantsDialog.setVisible(true);
	}

	private void showMessageDialog() {
		MessageDialog messageDialog = new MessageDialog(this, forecourt);
		messageDialog.setLocationRelativeTo(frmPumpDemo);
		messageDialog.setVisible(true);
	}

	private void showAboutDialog() {
		AboutDialog aboutDialog = new AboutDialog(this, forecourt);
		aboutDialog.setLocationRelativeTo(frmPumpDemo);
		aboutDialog.setVisible(true);
	}

	private void getHardwareInfo() {
		if (forecourt.isConnected()) {
			
			try {
				
				HardwareInf hwi = forecourt.getHardwareInfo();
				EnablerInterface[] eis = hwi.GetConfiguredInterfaces(EnablerInterfaceType.PCI);
			
				for (EnablerInterface ei : eis) {						
					logDialog.logEntry("Configured Interface "+ei.getID()+" ("+ei.getType().toString()+") "+ei.getFirmwareVersion()+" - Status:"+ei.getStatus().toString());					
				}
				
			} catch (EnablerException e) {
				logDialog.logEntry("Error getting hardware interfaces: "+e.getMessage());
			}
			
		} else {
			logDialog.logEntry("Not Connected to Server");
		}
	}

	private void showManualTransactionDialog(Pump pump) {
		ManualTransaction manualTransaction = new ManualTransaction();
		ManualTransactionDialog dialog = new ManualTransactionDialog(
				manualTransaction);
		dialog.setLocationRelativeTo(frmPumpDemo);
		dialog.setVisible(true);
		try {

			pump.logManualTransaction(1, manualTransaction.value,
					manualTransaction.volume, 0, manualTransaction.price, 1, 0,
					0, 0);

		} catch (EnablerException ex) {
			showEnablerError(ex);
		}
	}

	private boolean checkIfPumpSelected() {

		// Check a pump is selected
		if (currSelPmpControl == null) {
			String msg = "Please select a pump";
			JOptionPane.showMessageDialog(frmPumpDemo, msg,
					frmPumpDemo.getTitle(), JOptionPane.INFORMATION_MESSAGE);
			return false;
		}
		return true;
	}

	/**
	 * Lock and clear a transaction using specified type
	 */
	private void clearCurrentTransaction(
			TransactionClearTypes transactionClearType) {

		try {

			Pump pump = currSelPmpControl.getPump();
			Transaction curreTransaction = pump.getCurrentTransaction();

			// Get a lock before doing anything
			curreTransaction.getLock();
			curreTransaction.clear(transactionClearType);
		} catch (EnablerException ex) {
			showEnablerError(ex);
		}
	}

	private void processSale() {
		try {
			currSale.makePayment(this);
		} catch (EnablerException ex) {
			showEnablerError(ex);
		}
	}

	Forecourt forecourt = new Forecourt();
 ;
	PumpControlSettings pumpControlSettings = new PumpControlSettings();

	Sale currSale = new Sale(forecourt);
	JLabel lblSubTotal;
	PumpControl currSelPmpControl = null;
	int myTransClientRef = 1;

	// Save initial logon params
	String server;
	int terminalID;
	char[] password;
	boolean active;

	// parent for all dialogs
	JFrame frmPumpDemo;

	JLabel lblSubTotalName;
	String subTotalString;
	private JPanel panelPumps;
	private JPanel panelLayout;
	private JPanel panelControls;
	private JPanel panelStatusBar;
	private JPanel panelSales;
	private JPanel panelPumpControl;
	private JPanel panelTransactionControl;
	private JPanel panelForecourt;
	private JPanel panelProducts;
	private JPanel panelPayment;
	private JLabel statusText;
	private JTable saleItemTable;
	private JButton buttonVoidItem;
	private JButton buttonAttendants;
	private JButton buttonLookupTransactions;

	private JButton buttonTanks;
	private LogFrame logDialog = null;
	private JButton btnToggleBlock = new JButton("Toggle Block");
	private JButton btnAuthorise = new JButton("Authorise");
	private JButton btnCancelReserve = new JButton("Cancel Reserve");
	private JButton btnReserve = new JButton("Reserve");
	private JButton btnAuthWithLimits = new JButton("Authorise Limits");
	private JButton btnCancelAuthorise = new JButton("Cancel Authorise");
	private JButton btnPause = new JButton("Pause");
	private JButton btnResume = new JButton("Resume");
	private JButton btnStop = new JButton("Stop");
	private JButton btnPrepay = new JButton("Prepay");
	private JMenuItem mntmLogoff = new JMenuItem("Logoff");

	private Font defaultFont = new Font("Dialog", Font.PLAIN, 12);
	private Font buttonFont = new Font("Dialog", Font.PLAIN, 12);
	private Font statusFont = new Font("Dialog", Font.BOLD, 14);
	private Font saleTotalFont = new Font("Dialog", Font.BOLD, 17);
    
	boolean connectRunning = false;
}
