package pumpdemo;

import itl.enabler.api.Hose;
import itl.enabler.api.ProductCollection;
import itl.enabler.api.Pump;
import itl.enabler.api.PumpAuthoriseLimits;

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
import javax.swing.SwingConstants;

import ca.odell.glazedlists.BasicEventList;
import ca.odell.glazedlists.EventList;
import ca.odell.glazedlists.swing.EventListModel;
import ca.odell.glazedlists.swing.EventSelectionModel;

import javax.swing.JScrollPane;
import javax.swing.JList;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.awt.event.ItemListener;
import java.awt.event.ItemEvent;
import java.awt.Color;
import javax.swing.JLabel;

@SuppressWarnings("serial")
public class PrepayDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();

	@SuppressWarnings("rawtypes")
	private JList listHoses;
	private EventList<Hose> hoseEventList = new BasicEventList<Hose>();
	private EventSelectionModel<Hose> hoseSelectionModel = new EventSelectionModel<Hose>(
			hoseEventList);

	private JTextField textFieldLimit;
	JCheckBox chckbxAllHoses;

	/**
	 * Create the dialog.
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public PrepayDialog(Pump pump, final PumpAuthoriseLimits authoriseLimits) {
		setLocationByPlatform(true);
		setModalityType(ModalityType.APPLICATION_MODAL);
		setTitle(String.format("Prepay Authorisation for pump %d",
				pump.getNumber()));

		for (Hose hose : pump.getHoses()) {
			hoseEventList.add(hose);
		}

		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);

		setResizable(false);
		setBounds(100, 100, 407, 350);
		getContentPane().setLayout(new BorderLayout());
		contentPanel.setBackground(UIManager.getColor("Button.background"));
		contentPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		contentPanel.setLayout(new BorderLayout(0, 0));
		{
			JPanel panelValues = new JPanel();
			panelValues.setPreferredSize(new Dimension(200, 10));
			contentPanel.add(panelValues, BorderLayout.WEST);
			panelValues.setLayout(new MigLayout(" ins 100 n n n ", "[200px]",
					"[27px]"));
			{
				JLabel lblMoneyAmount = new JLabel("Money Amount ");
				lblMoneyAmount.setFont(new Font("Dialog", Font.BOLD, 14));
				panelValues.add(lblMoneyAmount,
						"flowx,cell 0 0,alignx center,aligny center");
			}
			{
				textFieldLimit = new JTextField();
				panelValues.add(textFieldLimit, "cell 2 0");
				textFieldLimit.setText("10.00");
				textFieldLimit.setHorizontalAlignment(SwingConstants.TRAILING);
				textFieldLimit.setFont(new Font("Dialog", Font.BOLD, 16));
				textFieldLimit.setColumns(5);
			}
		}
		{
			JPanel panelHoses = new JPanel();
			panelHoses.setBorder(new TitledBorder(null, "Allowed Hoses",
					TitledBorder.LEADING, TitledBorder.TOP, null, null));
			contentPanel.add(panelHoses, BorderLayout.CENTER);
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
					"[73.00]"));
			{
				chckbxAllHoses = new JCheckBox("Allow All Hoses");
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

						// set auth value
						authoriseLimits.setValue(limitValue);

						/**
						 * If all products are selected no need to specify
						 * products
						 */
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
						dispose();

					}
				});
				btnOKButton.setIcon(new ImageIcon(PrepayDialog.class
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
						hoseSelectionModel.dispose();
						dispose();
					}
				});
				btnCancelButton.setBackground(UIManager
						.getColor("Button.background"));
				btnCancelButton.setIcon(new ImageIcon(PrepayDialog.class
						.getResource("/pumpdemo/images/Cancel.png")));
				btnCancelButton.setMinimumSize(new Dimension(65, 60));
				btnCancelButton.setPreferredSize(new Dimension(65, 60));
				buttonPane.add(btnCancelButton, "cell 2 0");
			}
		}
	}
}
