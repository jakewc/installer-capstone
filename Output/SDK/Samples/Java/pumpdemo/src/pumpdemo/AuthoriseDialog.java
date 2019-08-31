package pumpdemo;

import itl.enabler.api.Attendant;
import itl.enabler.api.Hose;
import itl.enabler.api.ProductCollection;
import itl.enabler.api.Pump;
import itl.enabler.api.PumpAuthoriseLimits;
import itl.enabler.api.Transaction;

import java.awt.BorderLayout;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import javax.swing.border.TitledBorder;

import java.awt.Font;

import javax.swing.JTextField;

import net.miginfocom.swing.MigLayout;

import java.awt.Dimension;

import javax.swing.ImageIcon;
import javax.swing.JOptionPane;
import javax.swing.UIManager;
import javax.swing.JCheckBox;
import javax.swing.JRadioButton;
import javax.swing.ButtonGroup;
import javax.swing.SwingConstants;

import ca.odell.glazedlists.BasicEventList;
import ca.odell.glazedlists.EventList;
import ca.odell.glazedlists.swing.EventComboBoxModel;
import ca.odell.glazedlists.swing.EventListModel;
import ca.odell.glazedlists.swing.EventSelectionModel;

import javax.swing.JScrollPane;
import javax.swing.JList;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.event.ItemListener;
import java.awt.event.ItemEvent;
import java.awt.Color;

import javax.swing.border.LineBorder;
import javax.swing.JLabel;
import javax.swing.JComboBox;

@SuppressWarnings("serial")
public class AuthoriseDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();

	@SuppressWarnings("rawtypes")
	private JList listHoses;
	private EventList<Hose> hoseEventList = new BasicEventList<Hose>();
	private EventSelectionModel<Hose> hoseSelectionModel = new EventSelectionModel<Hose>(
			hoseEventList);
	private EventList<Attendant> attendantEventList = new BasicEventList<Attendant>();
	private EventComboBoxModel<Attendant> attendantSelectionModel = new EventComboBoxModel<Attendant>(
			attendantEventList);

	private JTextField textFieldLimit;
	private JRadioButton rdbtnPriceLevel1;
	private JRadioButton rdbtnPriceLevel2;
	private JRadioButton rdbtnMoney;
	private JRadioButton rdbtnVolume;
	private final ButtonGroup buttonGroupPriceLevel = new ButtonGroup();
	private final ButtonGroup buttonGroupLimit = new ButtonGroup();
	JCheckBox chckbxAllHoses;
	private JTextField textFieldRef;
	private JTextField textFieldActivity;
	private JTextField textFieldAuthTimeout;
	private JTextField textFieldFuelTimeout;

	/**
	 * Create the dialog.
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public AuthoriseDialog(Pump pump, Boolean bPreAuth,
			final PumpAuthoriseLimits authoriseLimits,
			final ClientInfo clientInfo) {
		setLocationByPlatform(true);
		setModalityType(ModalityType.APPLICATION_MODAL);

		for (Hose hose : pump.getHoses()) {
			hoseEventList.add(hose);
		}

		for (Attendant attendant : pump.getForecourt().getAttendants()) {
			attendantEventList.add(attendant);
		}

		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);

		setResizable(false);
		setTitle("Authorise Transaction");
		setBounds(100, 100, 407, 445);
		getContentPane().setLayout(new BorderLayout());
		{
			JPanel panelAuthInfo = new JPanel();
			panelAuthInfo.setBorder(new EmptyBorder(5, 5, 5, 5));
			getContentPane().add(panelAuthInfo, BorderLayout.CENTER);
			panelAuthInfo.setLayout(new BorderLayout(0, 0));
			{
				JPanel panelClient = new JPanel();
				panelClient.setPreferredSize(new Dimension(200, 10));
				panelClient.setMinimumSize(new Dimension(200, 10));
				panelClient.setBorder(new TitledBorder(new LineBorder(
						new Color(0, 0, 0)), "Client Information",
						TitledBorder.LEADING, TitledBorder.TOP, null,
						new Color(0, 0, 0)));
				panelAuthInfo.add(panelClient, BorderLayout.WEST);
				panelClient.setLayout(new MigLayout("", "[][][grow]",
						"[41.00][35.00]"));
				{
					JLabel lblClientReference = new JLabel("Reference");
					panelClient.add(lblClientReference, "cell 0 0");
				}
				{
					textFieldRef = new JTextField();
					textFieldRef.setHorizontalAlignment(SwingConstants.LEFT);
					textFieldRef.setText("1");
					panelClient.add(textFieldRef, "cell 2 0,growx");
					textFieldRef.setColumns(10);
				}
				{
					JLabel lblActivity = new JLabel("Activity");
					panelClient.add(lblActivity, "cell 0 1,alignx left");
				}
				{
					textFieldActivity = new JTextField();
					textFieldActivity.setText("PRESET");
					panelClient.add(textFieldActivity, "cell 2 1,growx");
					textFieldActivity.setColumns(10);
				}
				
				// For Legacy PreAuth transaction use reserved details 
				if ( bPreAuth ) {
					Transaction trans = pump.getCurrentTransaction();
					if ( trans != null ) {
						textFieldRef.setText( trans.getClientReference() );
						textFieldActivity.setText( trans.getClientActivity() );
						textFieldRef.setEnabled(false);
						textFieldActivity.setEnabled(false);
					}
				}

			}
			{
				JPanel panelTimeout = new JPanel();
				panelTimeout.setBorder(new TitledBorder(new LineBorder(
						new Color(0, 0, 0)), "Timeout", TitledBorder.LEADING,
						TitledBorder.TOP, null, Color.BLACK));
				panelTimeout.setPreferredSize(new Dimension(170, 10));
				panelAuthInfo.add(panelTimeout, BorderLayout.EAST);
				panelTimeout.setLayout(new MigLayout("",
						"[70px:100.00,grow][grow][]", "[41][35]"));
				{
					JLabel lblAuthorisation = new JLabel("Authorise");
					panelTimeout.add(lblAuthorisation, "cell 0 0");
				}
				{
					textFieldAuthTimeout = new JTextField();
					textFieldAuthTimeout
							.setHorizontalAlignment(SwingConstants.RIGHT);
					textFieldAuthTimeout.setText("0");
					panelTimeout.add(textFieldAuthTimeout, "cell 1 0,growx");
					textFieldAuthTimeout.setColumns(10);
				}
				{
					JLabel lblSec = new JLabel("sec");
					panelTimeout.add(lblSec, "cell 2 0");
				}
				{
					JLabel lblFuelling = new JLabel("Fuelling");
					panelTimeout.add(lblFuelling, "cell 0 1");
				}
				{
					textFieldFuelTimeout = new JTextField();
					textFieldFuelTimeout
							.setHorizontalAlignment(SwingConstants.RIGHT);
					textFieldFuelTimeout.setText("0");
					panelTimeout.add(textFieldFuelTimeout, "cell 1 1,growx");
					textFieldFuelTimeout.setColumns(10);
				}
				{
					JLabel lblSec_1 = new JLabel("sec");
					panelTimeout.add(lblSec_1, "cell 2 1");
				}
			}
		}
		contentPanel.setPreferredSize(new Dimension(10, 200));
		contentPanel.setBackground(UIManager.getColor("Button.background"));
		contentPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.NORTH);
		contentPanel.setLayout(new BorderLayout(0, 0));
		{
			JPanel panelValues = new JPanel();
			panelValues.setPreferredSize(new Dimension(200, 10));
			contentPanel.add(panelValues, BorderLayout.WEST);
			panelValues.setLayout(new BorderLayout(0, 0));
			{
				JPanel panelLimit = new JPanel();
				panelLimit.setFont(new Font("Dialog", Font.PLAIN, 12));
				panelLimit.setBorder(new TitledBorder(new LineBorder(new Color(
						0, 0, 0)), "Limit", TitledBorder.LEADING,
						TitledBorder.TOP, null, new Color(0, 0, 0)));
				panelLimit.setPreferredSize(new Dimension(10, 100));
				panelLimit.setMinimumSize(new Dimension(10, 30));
				panelValues.add(panelLimit, BorderLayout.NORTH);
				panelLimit.setLayout(new MigLayout("", "[][][grow]",
						"[center][][][][][]"));
				{
					rdbtnMoney = new JRadioButton("Money");
					rdbtnMoney.setSelected(true);
					buttonGroupLimit.add(rdbtnMoney);
					panelLimit.add(rdbtnMoney, "cell 0 0");
				}
				{
					rdbtnVolume = new JRadioButton("Volume");
					
					if ( ! bPreAuth )
					{
						buttonGroupLimit.add(rdbtnVolume);
						panelLimit.add(rdbtnVolume, "cell 0 1");
					}
					
				}
				{
					textFieldLimit = new JTextField();
					textFieldLimit
							.setHorizontalAlignment(SwingConstants.TRAILING);
					textFieldLimit.setText("10.00");
					textFieldLimit.setFont(new Font("Dialog", Font.BOLD, 16));
					panelLimit.add(textFieldLimit,
							"cell 1 0 1 2,alignx center,growy");
					textFieldLimit.setColumns(5);
				}
			}
			{
				JPanel panelPriceLevel = new JPanel();
				panelPriceLevel.setBorder(new TitledBorder(new LineBorder(
						new Color(0, 0, 0)), "Price Level",
						TitledBorder.LEADING, TitledBorder.TOP, null,
						new Color(0, 0, 0)));
				panelValues.add(panelPriceLevel, BorderLayout.CENTER);
				panelPriceLevel.setLayout(new MigLayout("", "[]", "[][]"));
				{
					rdbtnPriceLevel1 = new JRadioButton("Use Price Level 1");
					rdbtnPriceLevel1.setSelected(true);
					buttonGroupPriceLevel.add(rdbtnPriceLevel1);
					panelPriceLevel.add(rdbtnPriceLevel1, "cell 0 0");
				}
				{
					rdbtnPriceLevel2 = new JRadioButton("Use Price Level 2");
					buttonGroupPriceLevel.add(rdbtnPriceLevel2);
					panelPriceLevel.add(rdbtnPriceLevel2, "cell 0 1");
				}
			}
		}
		{
			JPanel panelHoses = new JPanel();
			panelHoses.setPreferredSize(new Dimension(170, 100));
			panelHoses.setBorder(new TitledBorder(new LineBorder(new Color(99,
					130, 191)), "Allowed Hoses", TitledBorder.LEADING,
					TitledBorder.TOP, null, Color.BLACK));
			contentPanel.add(panelHoses, BorderLayout.EAST);
			panelHoses.setLayout(new BorderLayout(0, 0));
			{
				JScrollPane scrollPane = new JScrollPane();
				panelHoses.add(scrollPane, BorderLayout.CENTER);

				EventListModel<Hose> hoseListModel = new EventListModel<Hose>(
						hoseEventList);
				listHoses = new JList(hoseListModel);
				listHoses.setSelectionModel(hoseSelectionModel);
				listHoses.setEnabled(false);
				listHoses.setFont(new Font("Dialog", Font.PLAIN, 12));
				listHoses.setBackground(Color.WHITE);

				scrollPane.setViewportView(listHoses);
			}
		}
		{
			JPanel buttonPane = new JPanel();
			buttonPane.setPreferredSize(new Dimension(10, 85));
			buttonPane.setBorder(new EmptyBorder(0, 0, 0, 9));
			getContentPane().add(buttonPane, BorderLayout.SOUTH);
			buttonPane.setLayout(new MigLayout("alignx right", "[grow][]10[]",
					"[73.00][73.00]"));
			{
				chckbxAllHoses = new JCheckBox("Allow All Hoses");
				chckbxAllHoses.setIconTextGap(5);
				chckbxAllHoses
						.setHorizontalTextPosition(SwingConstants.LEADING);
				chckbxAllHoses.setSelected(true);
				chckbxAllHoses.addItemListener(new ItemListener() {
					public void itemStateChanged(ItemEvent e) {
						if (e.getStateChange() == ItemEvent.SELECTED) {
							listHoses.setEnabled(false);
							listHoses.setBackground(Color.LIGHT_GRAY);
						} else {
							listHoses.setEnabled(true);
							listHoses.setBackground(Color.WHITE);
						}
					}
				});
				chckbxAllHoses.setFont(new Font("Dialog", Font.BOLD, 14));
				chckbxAllHoses.setMinimumSize(new Dimension(112, 34));
				chckbxAllHoses.setMaximumSize(new Dimension(132, 34));
				chckbxAllHoses.setPreferredSize(new Dimension(132, 34));
				buttonPane.add(chckbxAllHoses, "cell 0 0");
			}
			{
				JButton btnOKButton = new JButton("");
				btnOKButton.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {

						// get limit value
						double limitValue = 0;
						try {
							limitValue = Double.parseDouble(textFieldLimit
									.getText());
						} catch (NumberFormatException ex) {
							JOptionPane.showMessageDialog(getParent(),
									"Invalid Limit Value", getTitle(),
									JOptionPane.ERROR_MESSAGE);
						}

						// init Auth limits
						authoriseLimits.setQuantity(0);
						authoriseLimits.setValue(0);

						// get user selections
						if (rdbtnMoney.isSelected()) {
							authoriseLimits.setValue(limitValue);
						} else {
							authoriseLimits.setQuantity(limitValue);
						}

						if (rdbtnPriceLevel1.isSelected()) {

							// levels internally start with 1
							authoriseLimits.setLevel(1);
						} else {
							authoriseLimits.setLevel(2);
						}

						// get timeout values
						int authTimeoutValue = 0;
						int fuelTimeoutValue = 0;
						try {
							authTimeoutValue = Integer
									.parseInt(textFieldAuthTimeout.getText());
							fuelTimeoutValue = Integer
									.parseInt(textFieldFuelTimeout.getText());
						} catch (NumberFormatException ex) {
							JOptionPane.showMessageDialog(getParent(),
									"Invalid Timeout Value", getTitle(),
									JOptionPane.ERROR_MESSAGE);
						}
						authoriseLimits.setAuthoriseTimeout(authTimeoutValue);
						authoriseLimits.setFuellingTimeout(fuelTimeoutValue);

						// get client activity reference and attendant values
						clientInfo.activity = textFieldActivity.getText();
						clientInfo.reference = textFieldRef.getText();
						Attendant attendant = (Attendant) attendantSelectionModel
								.getSelectedItem();
						if (attendant != null) {
							clientInfo.attendantId = attendant.getId();
						} else {
							clientInfo.attendantId = -1;
						}

						// If all products are selected no need to specify
						if (chckbxAllHoses.isSelected()) {
							authoriseLimits.getProducts().clearAll();
						} else {

							EventList<Hose> selected = hoseSelectionModel
									.getSelected();
							if (selected.size() == 0) {
								JOptionPane.showMessageDialog(getParent(),
										"No Hose selected", getTitle(),
										JOptionPane.ERROR_MESSAGE);
								return;
							} else { // check user selections and add grade ID's
								ProductCollection productCollection = authoriseLimits
										.getProducts();
								for (Hose hose : selected) {
									productCollection.addProduct(hose
											.getGrade().getId());
								}
								authoriseLimits.setProducts(productCollection);
							}
						}

						// exit finally
						hoseSelectionModel.dispose();
						attendantSelectionModel.dispose();
						dispose();

					}
				});
				btnOKButton.setIcon(new ImageIcon(AuthoriseDialog.class
						.getResource("/pumpdemo/images/OK.png")));
				btnOKButton.setMaximumSize(new Dimension(65, 60));
				btnOKButton.setMinimumSize(new Dimension(65, 60));
				btnOKButton.setPreferredSize(new Dimension(65, 60));
				buttonPane.add(btnOKButton, "cell 1 0 1 2");
			}
			{
				JButton btnCancelButton = new JButton("");
				btnCancelButton.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						hoseSelectionModel.dispose();
						attendantSelectionModel.dispose();
						authoriseLimits.setQuantity(0);
						authoriseLimits.setValue(0);
						dispose();
					}
				});
				btnCancelButton.setBackground(UIManager
						.getColor("Button.background"));
				btnCancelButton.setIcon(new ImageIcon(AuthoriseDialog.class
						.getResource("/pumpdemo/images/Cancel.png")));
				btnCancelButton.setMinimumSize(new Dimension(65, 60));
				btnCancelButton.setPreferredSize(new Dimension(65, 60));
				buttonPane.add(btnCancelButton, "cell 2 0 1 2");
			}
			{
				JLabel lblAttendant = new JLabel("Attendant");
				lblAttendant.setFont(new Font("Dialog", Font.BOLD, 14));
				buttonPane.add(lblAttendant, "flowx,cell 0 1");
				if ( bPreAuth ) {
					lblAttendant.setVisible(false);
				}
			}
			{
				JComboBox comboBoxAttendant = new JComboBox(
						attendantSelectionModel);
				comboBoxAttendant.setPreferredSize(new Dimension(125, 25));
				buttonPane.add(comboBoxAttendant, "cell 0 1");
				if ( bPreAuth ) {
					comboBoxAttendant.setVisible(false);
				}
			}
		}
	}
}

class ClientInfo {
	String activity;
	String reference;
	int attendantId;
}
