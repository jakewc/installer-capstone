using System;
using System.Collections.Generic;
using System.Text;
using System.Windows;
using System.Windows.Controls;

using ITL.Enabler.API;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Dialog to enter message to send to another or ALL terminals.
    /// </summary>
    public partial class SendMessage : Window
    {
        public SendMessage()
        {
            InitializeComponent();
        }

         /// <summary>
        /// Return terminal ID or -1 if invalid
        /// </summary>
        public int TerminalID
        {
            get
            {
                int TermID = -1;
                Int32.TryParse(textbox_terminalID.Text, out TermID);
                return TermID;
            }
            set
            {
                textbox_terminalID.Text = value.ToString();
            }
        }

        public int NotificationID
        {
            get
            {
                int notID = 1;
                Int32.TryParse(textbox_notID.Text, out notID);
                return notID;
            }
            set
            {
                textbox_notID.Text = value.ToString();
            }
        }

        public String Message
        {
            get{ return textbox_message.Text; }
            set{ textbox_message.Text = value; }
        }


        private void button_send_Click(object sender, RoutedEventArgs e)
        {
            this.DialogResult = true;
        }
    }
}
