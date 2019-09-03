package pumpdemo;

import itl.enabler.api.Forecourt;
import itl.enabler.api.Terminal;
import itl.enabler.api.Terminal.TerminalEventListener;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.FlowLayout;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.ListCellRenderer;
import javax.swing.border.EmptyBorder;
import java.awt.SystemColor;
import java.awt.Toolkit;
import javax.swing.JScrollPane;
import javax.swing.border.LineBorder;
import java.awt.Color;
import javax.swing.JList;

import ca.odell.glazedlists.BasicEventList;
import ca.odell.glazedlists.EventList;
import ca.odell.glazedlists.swing.EventListModel;

import java.awt.Font;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.util.EventObject;

@SuppressWarnings("serial")
public class TerminalsDialog extends JDialog {

	private final JPanel contentPanel = new JPanel();

	// event list that hosts terminal info
	private EventList<Terminal> terminalEventList = new BasicEventList<Terminal>();

	/**
	 * Create the dialog.
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public TerminalsDialog(Forecourt forecourt) {
		setModal(true);
		setModalityType(ModalityType.APPLICATION_MODAL);

		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		setResizable(false);
		setTitle("Terminals");
		setIconImage(Toolkit.getDefaultToolkit().getImage(
				TerminalsDialog.class
						.getResource("/pumpdemo/images/ITLLogo.png")));
		setBounds(100, 100, 230, 251);
		getContentPane().setLayout(new BorderLayout());
		contentPanel.setBackground(Color.LIGHT_GRAY);
		contentPanel.setBorder(new EmptyBorder(5, 5, 5, 5));
		getContentPane().add(contentPanel, BorderLayout.CENTER);
		contentPanel.setLayout(new BorderLayout(0, 0));
		{
			JScrollPane scrollPane = new JScrollPane();
			scrollPane.setViewportBorder(new LineBorder(new Color(0, 0, 0)));
			scrollPane.setBackground(SystemColor.info);
			contentPanel.add(scrollPane, BorderLayout.CENTER);
			{
				EventListModel<Terminal> terminalEventListModel = new EventListModel<Terminal>(
						terminalEventList);
				final JList listTerminals = new JList(terminalEventListModel);
				listTerminals.setFont(new Font("Dialog", Font.PLAIN, 12));
				listTerminals.setBackground(Color.WHITE);
				TerminalListRenderer terminalListRenderer = new TerminalListRenderer();
				listTerminals.setCellRenderer(terminalListRenderer);

				scrollPane.setViewportView(listTerminals);

				for (Terminal terminal : forecourt.getTerminals()) {
					terminal.addTerminalEventListener(new TerminalEventListener() {

						// dynamically update terminal info
						@Override
						public void OnTerminalStatus(EventObject ev) {
							listTerminals.repaint();
						}
					});
					terminalEventList.add(terminal);
				}
			}
		}
		{
			JPanel buttonPane = new JPanel();
			buttonPane.setLayout(new FlowLayout(FlowLayout.RIGHT));
			getContentPane().add(buttonPane, BorderLayout.SOUTH);
			{
				JButton okButton = new JButton("Exit");
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

	/**
	 * defines how to display an entry in the list of terminals
	 * 
	 */
	private class TerminalListRenderer extends JLabel implements
			ListCellRenderer<Terminal> {

		@Override
		public Component getListCellRendererComponent(
				JList<? extends Terminal> list, Terminal terminal, int index,
				boolean isSelected, boolean cellHasFocus) {

			String displayString = String.format("%d : %s, : %s",
					terminal.getId(), terminal.getName(),
					terminal.isOnline() == true ? "Online" : "Offline");
			Color foregroundColor = terminal.isOnline() == true ? Color.BLUE
					: Color.RED;

			setOpaque(true);
			setForeground(foregroundColor);
			setText(displayString);

			return this;
		}
	}
}
