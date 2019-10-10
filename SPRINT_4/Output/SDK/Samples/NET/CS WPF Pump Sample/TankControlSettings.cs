using System;
using Microsoft.Win32;

using ITL.Enabler.WPFControls;

namespace ITL.Enabler.Samples
{
    /// <summary>
    /// Class to hold the Tank control settings
    /// Saves and loads settings from registry
    /// </summary>
    public class TankControlSettings
    {
        const string TankControlRegistry = @"TankControl";

        /// <summary>
        /// Enumeration of if tanks control should be loaded
        /// </summary>
        public enum Loaded { Not, Gauged, All };

#region Properties
        public Loaded LoadControl { get; set; }
        /// <summary>
        /// The style of the tank control
        /// </summary>
        public TankControlStyle Style{ get; set; }
        /// <summary>
        /// All Tanks in one control or separate controls
        /// </summary>
        public bool  AllInOne{ get; set; }
        /// <summary>
        /// Size of control (default 150 )
        /// </summary>
        public Double Size{ get; set; }
#endregion

        public TankControlSettings()
        {
            LoadControl = Loaded.All;
            Style = TankControlStyle.ChartOnly;
            AllInOne = false;
            Size = 150;
        }

        public void Load(RegistryKey RootSettingsKey)
        {
            try
            {
                RegistryKey TankSettingsKey = RootSettingsKey.OpenSubKey(TankControlRegistry);

                LoadControl = (Loaded)Convert.ToInt32(TankSettingsKey.GetValue("Loaded"));
                Style = (TankControlStyle)Convert.ToInt32(TankSettingsKey.GetValue("Style"));
                AllInOne = Convert.ToBoolean(TankSettingsKey.GetValue("AllInOne"));
                
                Size = Convert.ToDouble(TankSettingsKey.GetValue("Size"));
                if (Size < 50) Size = 150;
            }
            catch (Exception) { };

        }

        public void Save(RegistryKey RootSettingsKey)
        {
            try
            {
                RegistryKey TankSettingsKey = RootSettingsKey.CreateSubKey(TankControlRegistry, RegistryKeyPermissionCheck.ReadWriteSubTree);

                TankSettingsKey.SetValue("Loaded", (int)LoadControl);
                TankSettingsKey.SetValue("Style", (int)Style);
                TankSettingsKey.SetValue("AllInOne", AllInOne);
                TankSettingsKey.SetValue("Size", Size);
            }
            catch (Exception) { };

        }



    }
}
