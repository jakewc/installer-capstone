using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;

using ITL.Enabler.API;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Dialog to show the online/offline status of all terminals in listBox
    /// </summary>
    public partial class TerminalsDialog : Window
    {
        Terminal _SelectedTerminal = null;

        public TerminalsDialog(Forecourt forecourt)
        {
            InitializeComponent();

            this.DataContext = forecourt.Terminals;
        }

 
        private void button_exit_Click(object sender, RoutedEventArgs e)
        {
            this.Close();
        }

        private void listbox_terminals_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (listbox_terminals.SelectedItem != null)
            {
                _SelectedTerminal = listbox_terminals.SelectedItem as Terminal;
            }
            else
            {
                _SelectedTerminal = null;
            }

            
        }

  
    }
}
