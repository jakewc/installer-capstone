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
    /// Dialog to allow the grade prices and site modes to be changed.
    /// </summary>
    public partial class GradePricingDialog : Window
    {
        Forecourt _Forecourt;

        class GradeItem
        {
            public Grade _Grade;
            public override string ToString()
            {
                return _Grade.Name;
            }
            public GradeItem(Grade grade) { _Grade = grade; }
        };

        class ProfileItem
        {
            public Profile _Profile;
            public override string ToString()
            {
                return _Profile.Name;
            }
            public ProfileItem(Profile profile) { _Profile = profile; }
        };

        public GradePricingDialog(Forecourt forecourt)
        {
            _Forecourt = forecourt;

            InitializeComponent();

            foreach (Grade grade in _Forecourt.Grades)
            {
                comboBox_grade.Items.Add(new GradeItem(grade));
            }
            comboBox_grade.SelectedIndex = 0;

            SetProfiles();
        }

        /// <summary>
        /// Initialise Site mode list box and select current.
        /// </summary>
        private void SetProfiles()
        {
            Int32 CurrentIndex=-1;
            comboBox_profile.Items.Clear();

            // Load Combo box with profiles
            for ( Int32 Index = 0; Index<_Forecourt.SiteProfiles.Count; Index++ )
            {
                Profile profile = _Forecourt.SiteProfiles[Index];

                comboBox_profile.Items.Add(new ProfileItem(profile));
                if (profile.Id == _Forecourt.CurrentMode.Id)
                {
                    // Save index of current profile
                    CurrentIndex = Index;
                }
            }

            // Select CurrentIndex of current mode
            if (CurrentIndex >= 0)
            {
                // Set Current profile as selected
                comboBox_profile.SelectedIndex = CurrentIndex;
            }
        }

        private void comboBox_grade_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            textBox_pricelevel.IsEnabled = false;

            comboBox_pricelevel.Items.Clear();

            if (comboBox_grade.SelectedItem != null)
            {
                GradeItem gradeItem = comboBox_grade.SelectedItem as GradeItem;
                Grade grade = gradeItem._Grade;

                for (int pl = 0; pl < grade.PriceLevelCount; pl++)
                {
                    comboBox_pricelevel.Items.Add(_Forecourt.Settings.PriceLevels[pl].Name);
                }

                // This will cause proce to be displayed via event
                comboBox_pricelevel.SelectedIndex = 0;
            }
        }

        void DisplayGradePrice()
        {
            GradeItem gradeItem = comboBox_grade.SelectedItem as GradeItem;
            Grade grade = gradeItem._Grade;

            textBox_pricelevel.IsEnabled = false;

            if (grade.GradeType == GradeType.Base || grade.GradeType == GradeType.FixedBlend)
            {
                if (comboBox_pricelevel.SelectedIndex != -1)
                {
                    int PriceLevel = comboBox_pricelevel.SelectedIndex + 1;

                    textBox_pricelevel.IsEnabled = true;
                    textBox_pricelevel.Text = gradeItem._Grade.GetPrice(PriceLevel).ToString("f3");
                }
            }
            else
                textBox_pricelevel.Text = "";
        }

        /// <summary>
        /// Apply mode change button clicked.
        /// 
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_apply_mode_Click(object sender, RoutedEventArgs e)
        {
            if (comboBox_profile.SelectedItem != null)
            {
                ProfileItem profileItem = comboBox_profile.SelectedItem as ProfileItem;
                Profile profile = profileItem._Profile;

                if (_Forecourt.CurrentMode.Id != profile.Id)
                {
                    try
                    {
                        _Forecourt.SetCurrentMode(profile.Id);
                    }
                    catch (EnablerException Ex)
                    {
                        MessageBox.Show(this, "Enabler error(SetCurrentMode) : " + Forecourt.GetResultString(Ex.ResultCode));
                    }
                }

                SetProfiles();

            }
        }

        /// <summary>
        /// Apply price button clicked.
        /// Validate and set price on selected grade for selected price level.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_apply_price_Click(object sender, RoutedEventArgs e)
        {
            if (comboBox_grade.SelectedItem != null)
            {
                GradeItem gradeItem = comboBox_grade.SelectedItem as GradeItem;
                Grade grade = gradeItem._Grade;

                if (grade.GradeType == GradeType.Base || grade.GradeType == GradeType.FixedBlend)
                {
                    if (comboBox_profile.SelectedItem != null)
                    {
                        int PriceLevel = comboBox_pricelevel.SelectedIndex + 1;

                        Decimal price1;

                        if (!Decimal.TryParse(textBox_pricelevel.Text, out price1))
                        {
                            MessageBox.Show("Invalid price");
                            return;
                        }

                        // Set price if changed
                        if (grade.GetPrice(PriceLevel) != price1)
                        {
                            try
                            {
                                grade.SetPrice(PriceLevel, price1);
                            }
                            catch (EnablerException Ex)
                            {
                                MessageBox.Show(this, "Enabler error : " + Forecourt.GetResultString(Ex.ResultCode));
                            }
                        }
                    }

                }
            }
        }

        private void comboBox_pricelevel_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            DisplayGradePrice();
        }

    }
}
