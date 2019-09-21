package pumpdemo;

import itl.enabler.api.EnablerException;
import itl.enabler.api.Forecourt;
import itl.enabler.api.Grade;
import itl.enabler.api.Profile;
import itl.enabler.api.types.GradeType;

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
import javax.swing.UIManager;
import javax.swing.SwingConstants;

import ca.odell.glazedlists.BasicEventList;
import ca.odell.glazedlists.EventList;
import ca.odell.glazedlists.swing.EventComboBoxModel;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.Color;
import javax.swing.border.LineBorder;
import javax.swing.JComboBox;

import pumpdemo.gradeprofile.GradeItem;
import pumpdemo.gradeprofile.ProfileItem;
import javax.swing.JLabel;
import java.awt.Component;
import javax.swing.Box;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.text.NumberFormat;
import java.text.ParseException;

@SuppressWarnings("serial")
public class GradePricingDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();
	private Forecourt forecourt;

	@SuppressWarnings("rawtypes")
	private JComboBox comboBoxGradeItem = new JComboBox();
	@SuppressWarnings("rawtypes")
	private JComboBox comboBoxPriceLevel = new JComboBox();;
	@SuppressWarnings("rawtypes")
	private JComboBox comboBoxProfileItem = new JComboBox();

	private JTextField textFieldPrice = new JTextField();

	private EventList<ProfileItem> profileItemEventList = new BasicEventList<ProfileItem>();
	private EventComboBoxModel<ProfileItem> comboBoxModelProfileItem = new EventComboBoxModel<ProfileItem>(
			profileItemEventList);

	private EventList<GradeItem> gradeItemEventList = new BasicEventList<GradeItem>();
	private EventComboBoxModel<GradeItem> comboBoxModelGradeItem = new EventComboBoxModel<GradeItem>(
			gradeItemEventList);

	private EventList<String> priceLevelEventList = new BasicEventList<String>();
	private EventComboBoxModel<String> comboBoxModelPriceLevel = new EventComboBoxModel<String>(
			priceLevelEventList);
	private JButton btnApplyMode = new JButton("Apply Mode");

	private final void displayGradePrices() {
		GradeItem gradeItem = (GradeItem) comboBoxModelGradeItem
				.getSelectedItem();
		Grade grade = gradeItem.getGrade();

		textFieldPrice.setEnabled(false);

		if (grade.getGradeType() == GradeType.BASE
				|| grade.getGradeType() == GradeType.FIXED_BLEND) {
			String priceLevelStr = (String) comboBoxModelPriceLevel
					.getSelectedItem();
			if (priceLevelStr != null) {
				int priceLevel = Integer.parseInt(priceLevelStr);

				textFieldPrice.setText(String.format("%.4f", gradeItem
						.getGrade().getPrice(priceLevel)));
				textFieldPrice.setEnabled(true);
			}
		} else {
			textFieldPrice.setText("");
		}
	}

	private void setProfiles() {

		profileItemEventList.clear();
		for (Profile profile : forecourt.getSiteProfiles()) {
			profileItemEventList.add(new ProfileItem(profile));
		}
	}

	private final void disposeEventResources() {

		gradeItemEventList.dispose();
		comboBoxModelGradeItem.dispose();
		profileItemEventList.dispose();
		comboBoxModelProfileItem.dispose();
		priceLevelEventList.dispose();
		comboBoxModelPriceLevel.dispose();
	}

	/**
	 * Create the dialog.
	 * 
	 * @param app
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public GradePricingDialog(final MainWindow app, final Forecourt fcourt) {
		addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent arg0) {
				disposeEventResources();
				dispose();
			}
		});

		this.forecourt = fcourt;

		setLocationByPlatform(true);
		setModalityType(ModalityType.APPLICATION_MODAL);

		setProfiles();

		for (Grade grade : fcourt.getGrades()) {
			gradeItemEventList.add(new GradeItem(grade));
		}

		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);

		setResizable(false);
		setTitle("Grade Pricing and Site Profiles");
		setBounds(100, 100, 431, 308);
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
				JPanel panelSiteProfile = new JPanel();
				panelSiteProfile.setBorder(new TitledBorder(new LineBorder(
						new Color(0, 0, 0)), "Site Profile",
						TitledBorder.LEADING, TitledBorder.TOP, null,
						new Color(0, 0, 0)));
				panelValues.add(panelSiteProfile, BorderLayout.NORTH);
				panelSiteProfile.setLayout(new MigLayout("",
						"[180.00:180.00][114.00][grow,fill]", "[]"));
				{
					comboBoxProfileItem = new JComboBox();
					comboBoxProfileItem.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent arg0) {
							if (comboBoxModelProfileItem.getSelectedItem() != null) {
								int newModeID = ((ProfileItem) comboBoxModelProfileItem
										.getSelectedItem()).getProfile()
										.getId();

								/**
								 * Disable apply button if current forecourt
								 * mode is selected
								 */
								if (forecourt.getCurrentMode().getId() == newModeID) {
									btnApplyMode.setEnabled(false);
								} else {
									btnApplyMode.setEnabled(true);
								}
							}
						}
					});
					panelSiteProfile.add(comboBoxProfileItem, "cell 0 0,grow");
					comboBoxProfileItem.setModel(comboBoxModelProfileItem);
					if (comboBoxProfileItem.getItemCount() > 0) {

						try {
							// Select current mode
							comboBoxProfileItem.setSelectedIndex(forecourt
									.getCurrentMode().getId() - 1);
						} catch (IllegalArgumentException ex) {

							// ignore and show blank
						}
					}
				}
				{
					btnApplyMode.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent arg0) {
							if (comboBoxModelProfileItem.getSelectedItem() != null) {
								int newModeID = ((ProfileItem) comboBoxModelProfileItem
										.getSelectedItem()).getProfile()
										.getId();
								if (forecourt.getCurrentMode().getId() != newModeID) {
									try {
										forecourt.setCurrentMode(newModeID);
									} catch (EnablerException ex) {
										app.showEnablerError(ex);
									}
								}
								setProfiles();
								if (comboBoxProfileItem.getItemCount() > 0) {

									// Select current mode
									comboBoxProfileItem
											.setSelectedIndex(forecourt
													.getCurrentMode().getId() - 1);
								}
							}
						}
					});
					btnApplyMode.setFont(new Font("Tahoma", Font.BOLD, 11));
					panelSiteProfile.add(btnApplyMode, "cell 2 0");
				}
			}
			{
				Component rigidArea = Box
						.createRigidArea(new Dimension(387, 20));
				rigidArea.setPreferredSize(new Dimension(387, 25));
				rigidArea.setMinimumSize(new Dimension(387, 25));
				rigidArea.setMaximumSize(new Dimension(387, 25));
				panelValues.add(rigidArea, BorderLayout.CENTER);
			}
			{
				JPanel panelGradePricing = new JPanel();
				panelGradePricing.setFont(new Font("Dialog", Font.PLAIN, 12));
				panelGradePricing.setBorder(new TitledBorder(new LineBorder(
						new Color(122, 138, 153)), "Grade Pricing",
						TitledBorder.LEADING, TitledBorder.TOP, null,
						new Color(0, 0, 0)));
				panelGradePricing.setPreferredSize(new Dimension(10, 110));
				panelGradePricing.setMinimumSize(new Dimension(10, 30));
				panelValues.add(panelGradePricing, BorderLayout.SOUTH);
				panelGradePricing.setLayout(new MigLayout("",
						"[147.00][grow][]", "[][]"));
				{
					JLabel lblGrade = new JLabel("Grade");
					lblGrade.setFont(new Font("Tahoma", Font.BOLD, 13));
					panelGradePricing.add(lblGrade, "cell 0 0,alignx center");
				}
				{
					JLabel lblPriceLevel = new JLabel("Price Level");
					lblPriceLevel.setFont(new Font("Tahoma", Font.BOLD, 13));
					panelGradePricing.add(lblPriceLevel,
							"cell 1 0,alignx center");
				}
				{
					JLabel lblPrice = new JLabel("Price");
					lblPrice.setFont(new Font("Tahoma", Font.BOLD, 13));
					panelGradePricing.add(lblPrice, "cell 2 0,alignx center");
				}
				{
					comboBoxPriceLevel.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent e) {
							displayGradePrices();
						}
					});
					panelGradePricing.add(comboBoxPriceLevel, "cell 1 1,grow");
					comboBoxPriceLevel.setModel(comboBoxModelPriceLevel);
				}
				{
					comboBoxGradeItem.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent e) {

							textFieldPrice.setEnabled(false);

							/**
							 * clear all price levels of previously selected
							 * grade (if any)
							 */
							priceLevelEventList.clear();

							if (comboBoxModelGradeItem.getSelectedItem() != null) {
								GradeItem gradeItem = (GradeItem) comboBoxModelGradeItem
										.getSelectedItem();
								Grade grade = gradeItem.getGrade();

								for (int priceLevel = 1; priceLevel <= grade
										.getPriceLevelCount(); priceLevel++) {
									priceLevelEventList.add(String.format("%d",
											priceLevel));
								}
								comboBoxPriceLevel.setSelectedIndex(0);
							}
						}
					});
					panelGradePricing.add(comboBoxGradeItem, "cell 0 1,grow");
					comboBoxGradeItem.setModel(comboBoxModelGradeItem);
					comboBoxGradeItem.setSelectedIndex(0);

				}
				{
					textFieldPrice
							.setHorizontalAlignment(SwingConstants.TRAILING);
					textFieldPrice.setFont(new Font("Dialog", Font.BOLD, 16));
					panelGradePricing
							.add(textFieldPrice, "flowx,cell 2 1,grow");
					textFieldPrice.setColumns(5);
				}
				{
					JButton btnApplyPrice = new JButton("Apply Price");
					btnApplyPrice.addActionListener(new ActionListener() {
						public void actionPerformed(ActionEvent e) {
							/**
							 * Get user selection for grade, priceLevel and set
							 * grade price if changed
							 */
							GradeItem gradeItem = (GradeItem) comboBoxModelGradeItem
									.getSelectedItem();
							Grade grade = gradeItem.getGrade();

							if (grade.getGradeType() == GradeType.BASE
									|| grade.getGradeType() == GradeType.FIXED_BLEND) {

								// get PriceLevel
								String priceLevelStr = (String) comboBoxModelPriceLevel
										.getSelectedItem();
								if (priceLevelStr != null) {
									int priceLevel = Integer
											.parseInt(priceLevelStr);
									try {
										// get Price
										Double price = NumberFormat
												.getNumberInstance()
												.parse(textFieldPrice.getText())
												.doubleValue();

										if (grade.getPrice(priceLevel) != price) {
											grade.setPrice(priceLevel, price);
										}
									} catch (NumberFormatException ex) {
										app.showPumpDemoError("Invalid Price");
										return;
									} catch (IndexOutOfBoundsException ex) {
										app.showPumpDemoError("Invalid Price Level");
										return;
									} catch (ParseException ex) {
										app.showPumpDemoError("Invalid Price");
										return;
									} catch (EnablerException ex) {
										app.showEnablerError(ex);
										return;
									}
								}
							}
						}
					});
					btnApplyPrice.setFont(new Font("Tahoma", Font.BOLD, 11));
					panelGradePricing.add(btnApplyPrice, "cell 2 1");
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
				JButton btnCancelButton = new JButton("");
				btnCancelButton.addActionListener(new ActionListener() {
					public void actionPerformed(ActionEvent e) {
						disposeEventResources();
						dispose();
					}
				});
				btnCancelButton.setBackground(UIManager
						.getColor("Button.background"));
				btnCancelButton.setIcon(new ImageIcon(GradePricingDialog.class
						.getResource("/pumpdemo/images/exit.png")));
				btnCancelButton.setMinimumSize(new Dimension(65, 60));
				btnCancelButton.setPreferredSize(new Dimension(65, 60));
				buttonPane.add(btnCancelButton, "cell 2 0");
			}
		}

		// after constucting dialog display grade prices to the user
		displayGradePrices();
	}
}
