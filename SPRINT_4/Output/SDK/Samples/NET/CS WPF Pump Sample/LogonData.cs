using System;
using System.Collections.Generic;
using Microsoft.Win32;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Class to load and save Logon data in registry.
    /// </summary>
    class LogonData
    {
        public LogonData()
        {
            RegistryKey currentUser = RegistryKey.OpenRemoteBaseKey(RegistryHive.CurrentUser, "");
            RegistryKey pumpDemoWPFKeys = currentUser.CreateSubKey(MainWindow.MyRegistryKey, RegistryKeyPermissionCheck.ReadSubTree );
            
            Server = (string)pumpDemoWPFKeys.GetValue("Server", "127.0.0.1", RegistryValueOptions.None );
            TerminalID = (int)pumpDemoWPFKeys.GetValue("TerminalID", 2, RegistryValueOptions.None );
            Password = (string)pumpDemoWPFKeys.GetValue("Password", "password", RegistryValueOptions.None);
            UseSSL = (int)pumpDemoWPFKeys.GetValue("UseSSL", 0, RegistryValueOptions.None) > 0;
            Active = Convert.ToBoolean(pumpDemoWPFKeys.GetValue("Active", "True", RegistryValueOptions.None));
            AutoConnect = false;
        }

#region properties
        public string Server{ get;  set; }
        
        /// <summary>
        /// Return terminal ID or -1 if invalid
        /// </summary>
        public int TerminalID{ get; set; }
       
        public string Password{ get; set; }

        public bool Active{ get; set; }

        public bool AutoConnect { get; set; }

        public bool UseSSL { get; set; }
#endregion

        public void SaveConnectSettings()
        {
            // persist the values to the registry for the next logon
            RegistryKey currentUser = RegistryKey.OpenRemoteBaseKey(RegistryHive.CurrentUser, "");
            RegistryKey pumpDemoWPFKeys = currentUser.CreateSubKey(MainWindow.MyRegistryKey, RegistryKeyPermissionCheck.ReadWriteSubTree);
            pumpDemoWPFKeys.SetValue("Server", Server);
            pumpDemoWPFKeys.SetValue("TerminalID", TerminalID);
            pumpDemoWPFKeys.SetValue("Password", Password);
            pumpDemoWPFKeys.SetValue("Active", Active);
            // Not UI configurable, so we do not save for now
            //pumpDemoWPFKeys.SetValue("UseSSL", UseSSL ? 1 : 0);
        }
    }

}
