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
    /// This is the Event Logging window
    /// We link up with all the events on the forecourt objects so we trap all events and 
    /// display formatted a message in list box.
    /// </summary>
    public partial class LogDialog : Window
    {
        Forecourt _Forecourt;
        bool _ShowTotals = false;

        public LogDialog(Forecourt forecourt )
        {
            _Forecourt = forecourt;

            InitializeComponent();

            LinkUpEvents();
        }

        /// <summary>
        /// When window unloads then remove out event links.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Window_Unloaded(object sender, RoutedEventArgs e)
        {
            RemoveEvents();
        }

        /// <summary>
        /// Link up to all events on forecourt and forecourt collections.
        /// </summary>
        void LinkUpEvents()
        {
            _Forecourt.OnServerEvent += new EventHandler(_Forecourt_OnServerEvent);
            _Forecourt.OnServerJournalEvent += new EventHandler<ServerJournalEventArgs>(_Forecourt_OnServerJournalEvent);
            _Forecourt.OnServerPowerEvent += new EventHandler(_Forecourt_OnServerPowerEvent);
            _Forecourt.OnMessageReceived += new EventHandler<MessageReceivedEventArgs>(_Forecourt_OnMessageReceived);
            _Forecourt.OnStatusChange += new EventHandler<ForecourtStatusEventArgs>(_Forecourt_OnStatusChange);
            _Forecourt.OnTagRead += new EventHandler<TagReadEventArgs>(_Forecourt_OnTagRead);
            _Forecourt.OnConfigChange += new EventHandler<ConfigChangeEventArgs>(_Forecourt_OnConfigChange); 

            // Pump handlers
            _Forecourt.Pumps.OnHoseEvent += new EventHandler<PumpHoseEventArgs>(pump_OnHoseEvent);
            _Forecourt.Pumps.OnTransactionEvent += new EventHandler<PumpTransactionEventArgs>(pump_OnTransactionEvent);
            _Forecourt.Pumps.OnPriceChange += new EventHandler(pump_OnPriceChange);
            _Forecourt.Pumps.OnStatusChange += new EventHandler<PumpStatusEventArgs>(pump_OnStatusChange);
            _Forecourt.Pumps.OnJournalEvent += new EventHandler<JournalEventArgs>(pump_OnJournalEvent);
            _Forecourt.Pumps.OnFuellingProgress += new EventHandler<FuellingProgressEventArgs>(Pumps_OnFuellingProgress);

            //Grade
            _Forecourt.Grades.OnPriceChange += new EventHandler<GradePriceChangeEventArgs>(Grades_OnPriceChange);
            _Forecourt.Grades.OnGradeStatus += new EventHandler(Grades_OnGradeStatus);

            // Tank handlers
            _Forecourt.Tanks.OnAlarm += new EventHandler<TankAlarmEventArgs>(tank_OnAlarm);
            _Forecourt.Tanks.OnGaugeLevelChanged += new EventHandler(tank_OnGaugeLevelChanged);
            _Forecourt.Tanks.OnLevelChanged += new EventHandler(tank_OnLevelChanged);
            _Forecourt.Tanks.OnStatusChanged += new EventHandler<TankStatusEventArgs>(Tanks_OnStatusChanged);

            // Terminal handlers
            _Forecourt.Terminals.OnTerminalStatus += new EventHandler(term_OnTerminalStatus);

            // Attendant handlers
            _Forecourt.Attendants.OnLogOff += new EventHandler<AttendantLogOnOffEventArgs>(atten_OnLogOff);
            _Forecourt.Attendants.OnLogOn += new EventHandler<AttendantLogOnOffEventArgs>(atten_OnLogOn);
            _Forecourt.Attendants.OnStatusChanged += new EventHandler<AttendantStatusEventArgs>(Attendants_OnStatusChanged);
            _Forecourt.Attendants.OnTagRead += new EventHandler<TagReadEventArgs>(Attendants_OnTagRead);
            _Forecourt.Attendants.OnPeriodStateChange += new EventHandler(Attendants_OnPeriodStateChange);
            // Fallback
            _Forecourt.Fallback.OnModeChange += new EventHandler(Fallback_OnModeChange);
            _Forecourt.Fallback.OnActiveClientChange += new EventHandler(Fallback_OnActiveClientChange);
        }


        /// <summary>
        /// Remove all event links.
        /// </summary>
        void RemoveEvents()
        {
            _Forecourt.OnServerEvent -= _Forecourt_OnServerEvent;
            _Forecourt.OnServerJournalEvent -= _Forecourt_OnServerJournalEvent;
            _Forecourt.OnServerPowerEvent -= _Forecourt_OnServerPowerEvent;
            _Forecourt.OnMessageReceived -= _Forecourt_OnMessageReceived;
            _Forecourt.OnStatusChange -= _Forecourt_OnStatusChange;
            _Forecourt.OnTagRead -= _Forecourt_OnTagRead;
            _Forecourt.OnConfigChange -= _Forecourt_OnConfigChange;

            _Forecourt.Pumps.OnHoseEvent -= pump_OnHoseEvent;
            _Forecourt.Pumps.OnTransactionEvent -= pump_OnTransactionEvent;
            _Forecourt.Pumps.OnPriceChange -= pump_OnPriceChange;
            _Forecourt.Pumps.OnStatusChange -= pump_OnStatusChange;
            _Forecourt.Pumps.OnJournalEvent -= pump_OnJournalEvent;
            _Forecourt.Pumps.OnFuellingProgress -= Pumps_OnFuellingProgress;

            _Forecourt.Tanks.OnAlarm -= tank_OnAlarm;
            _Forecourt.Tanks.OnGaugeLevelChanged -= tank_OnGaugeLevelChanged;
            _Forecourt.Tanks.OnLevelChanged -= tank_OnLevelChanged;
            _Forecourt.Tanks.OnStatusChanged -= Tanks_OnStatusChanged;

            _Forecourt.Terminals.OnTerminalStatus -= term_OnTerminalStatus;

            _Forecourt.Attendants.OnLogOff -= atten_OnLogOff;
            _Forecourt.Attendants.OnLogOn -= atten_OnLogOn;
            _Forecourt.Attendants.OnStatusChanged -= Attendants_OnStatusChanged;
            _Forecourt.Attendants.OnPeriodStateChange -= Attendants_OnPeriodStateChange;
            _Forecourt.Attendants.OnTagRead -= Attendants_OnTagRead;
        }

  
        void LogEntry(String Message)
        {
             this.Dispatcher.BeginInvoke((Action)(() =>
            {
                // Clear list when over 1MB
                if ( TextBox_log.Text.Length > 1000000 )
                    TextBox_log.Clear();

                String line = DateTime.Now.ToString("HH:mm:ss - ") + Message;
                
                TextBox_log.AppendText(line + "\r\n" );

                if (Menu_Latest.IsChecked)
                    TextBox_log.ScrollToEnd();
            }
            ));
        }


        #region Forecourt events
        void _Forecourt_OnServerPowerEvent(object sender, EventArgs e)
        {
            LogEntry(string.Format("Forecourt Server power event : Power:{0}, Battery State:{1}", 
                _Forecourt.UpsState.PowerState.ToString(), 
                _Forecourt.UpsState.BatteryState.ToString()
                ));
        }

        void _Forecourt_OnServerJournalEvent(object sender, ServerJournalEventArgs e)
        {
            LogEntry(string.Format("Forecourt Journal event Devid:{0} DevNum:{1} DevType:{2} Level:{3} Message:{4}", 
                e.DeviceId, e.DeviceNumber, e.DeviceType.ToString(), e.Level, e.Message ));
        }

        void _Forecourt_OnServerEvent(object sender, EventArgs e)
        {
            LogEntry(string.Format("Forecourt Server event Connection:{0}", _Forecourt.IsConnected?"Online":"Offline" ));
        }

        void _Forecourt_OnTagRead(object sender, TagReadEventArgs e)
        {
            LogEntry(string.Format("Forecourt Tag read  Attendant:{0} Pump:{1} Reader:{2} Tag ID:{3} Tag Type:{4} Tag data:{5}", e.AttendantId, e.PumpNumber, e.TagReaderID, e.TagId, e.TagType, e.TagData ));
        }

        void _Forecourt_OnStatusChange(object sender, ForecourtStatusEventArgs e)
        {
            switch (e.EventType)
            {
                case ForecourtStatusEventType.CurrentModeID:
                    LogEntry(string.Format("Forecourt Site mode changed to {0}", _Forecourt.CurrentMode ));
                    break;

                case ForecourtStatusEventType.PumpLights:
                    LogEntry(string.Format("Forecourt lights on:{0}", _Forecourt.PumpLightsOn ));
                    break;

                default:
                    LogEntry(string.Format("Forecourt Status change Type:{0}", e.EventType.ToString()));
                    break;
            }
        }

        void _Forecourt_OnMessageReceived(object sender, MessageReceivedEventArgs e)
        {
            LogEntry(string.Format("Forecourt Message source:{0} Id:{1} Message:{2}", e.SourceTerminalId, e.NotificationId, e.NotificationString));
        }


        void _Forecourt_OnConfigChange(object sender, ConfigChangeEventArgs e)
        {
            LogEntry(string.Format("Forecourt config change Action:{0} Type:{1} Id:{2}",
                e.ActionType.ToString(), 
                e.DataType.ToString(), 
                e.Id  
                ));
        }


        #endregion

        #region Grade events
        void Grades_OnGradeStatus(object sender, EventArgs e)
        {
            Grade grade = sender as Grade;

            LogEntry(string.Format("Grade {0} Status change event", grade.Number ));
        }

        void Grades_OnPriceChange(object sender, GradePriceChangeEventArgs e)
        {
            Grade grade = sender as Grade;

            LogEntry(string.Format("Grade {0} Price change event, priceLevel:{1} Price:{2}", grade.Number, e.PriceLevel, e.UnitPrice));
        }
        #endregion

        #region Tank events
        void tank_OnLevelChanged(object sender, EventArgs e)
        {
            Tank tank =  sender as Tank;
            LogEntry(string.Format("Tank {0} Level change event, Theo. Volume:{1}", tank.Number, tank.TheoreticalVolume));
        }

        void tank_OnGaugeLevelChanged(object sender, EventArgs e)
        {
            Tank tank = sender as Tank;
            LogEntry(string.Format("Tank {0} Gauge level event, Volume:{1} Non TC Volume:{2} Temp:{3}, ProbeStatus:{4}", 
                    tank.Number, 
                    tank.GaugeReading.Volume,
                    tank.GaugeReading.NonCompensatedVolume,
                    tank.GaugeReading.Temperature,
                    tank.GaugeReading.ProbeStatus.ToString()
                    ));
        }

        void tank_OnAlarm(object sender, TankAlarmEventArgs e)
        {
            Tank tank = sender as Tank;
            LogEntry(string.Format("Tank {0} Alarm Number:{1} State:{2}", tank.Number, e.AlarmType, tank.GetAlarm(e.AlarmType) ));


        }

        void Tanks_OnStatusChanged(object sender, TankStatusEventArgs e)
        {
            Tank tank = sender as Tank;

            switch (e.EventType)
            {
                case TankStatusEventType.Blocked:
                    LogEntry(string.Format("Tank {0} Status Block:{1}", tank.Number, tank.IsBlocked.ToString() ));
                    break;

                case TankStatusEventType.AutoBlocking:
                    LogEntry(string.Format("Tank {0} Status AutoBlocking:{1}", tank.Number, tank.IsAutoBlocking.ToString()));
                    break;

            }
        }

        #endregion

        #region Pump Events
        void pump_OnStatusChange(object sender, PumpStatusEventArgs e)
        {
            string status = "";
            Pump pump = sender as Pump;

            switch (e.EventType)
            {
                case PumpStatusEventType.State: status = "State change to " + pump.State.ToString(); break;
                case PumpStatusEventType.Blocked: status = string.Format("Block changed to {0} Reason:{1}",pump.IsBlocked, pump.BlockedReasons); break;
                case PumpStatusEventType.PumpLights: status = "Pump lights to " + pump.PumpLightsOn.ToString(); break;
                case PumpStatusEventType.CurrentMode: status = "Pump mode "; break;
                case PumpStatusEventType.FuelFlow: status = "Fuel flow " + pump.FuelFlow.ToString(); break;
            }

            LogEntry(string.Format("Pump {0} Status change event:{1}", pump.Number, status ));
        }

        void pump_OnPriceChange(object sender, EventArgs e)
        {
            Pump pump = sender as Pump;
            LogEntry(string.Format("Pump {0} Price change event:{1}", pump.Number, pump.PriceChangeStatus.ToString()));
        }

        void pump_OnTransactionEvent(object sender, PumpTransactionEventArgs e)
        {
            Pump pump = sender as Pump;
            Transaction t = e.Transaction;

            switch (e.EventType)
            {
                case TransactionEventType.Completed:
                    LogEntry(string.Format("Pump {0} Transaction ID:{1} event:{2} reason:{3} - Quantity:{4:N03} Value:{5:C} Price:{6:C} Type:{7} Ratio:{8:N02} Meter Quantity:{9:N03} Meter Value:{10:C}",
                        pump.Number,
                        e.TransactionId,
                        e.EventType.ToString(),
                        t.HistoryData.CompletionReason.ToString(),
                        t.DeliveryData.Quantity,
                        t.DeliveryData.Money,
                        t.DeliveryData.UnitPrice,
                        t.DeliveryType.ToString(),
                        t.Blend.Ratio,
                        t.DeliveryData.QuantityTotal,
                        t.DeliveryData.MoneyTotal
                        ));

                    // If blend ration > 0 then Log the blend information
                    if (t.Blend.Ratio > 0)
                    {
                        LogEntry(string.Format("Pump {0} Transaction ID:{1} - Base grade 1 - Quantity:{2:N03} Value:{3:C} Price:{4:C} Meter Quantity:{5:N03} Meter Value:{6:C}",
                            pump.Number,
                            e.TransactionId,
                            t.Blend.Base1.Quantity,
                            t.Blend.Base1.Money,
                            t.Blend.Base1.UnitPrice,
                            t.Blend.Base1.QuantityTotal,
                            t.Blend.Base1.MoneyTotal
                            ));

                        LogEntry(string.Format("Pump {0} Transaction ID:{1} - Base grade 2 - Quantity:{2:N03} Value:{3:C} Price:{4:C} Meter Quantity:{5:N03} Meter Value:{6:C}",
                            pump.Number,
                            e.TransactionId,
                            t.Blend.Base2.Quantity,
                            t.Blend.Base2.Money,
                            t.Blend.Base2.UnitPrice,
                            t.Blend.Base2.QuantityTotal,
                            t.Blend.Base2.MoneyTotal
                            ));


                    }


                    break;

                case TransactionEventType.Authorised:
                    LogEntry(string.Format("Pump {0} Transaction ID:{1} Authorised:{2}", pump.Number, e.TransactionId, t.AuthoriseData.Reason.ToString() ));
                    break;

                case TransactionEventType.Cleared:
                    LogEntry(string.Format("Pump {0} Transaction ID:{1} Cleared  Type:{2}", pump.Number, e.TransactionId, t.DeliveryType.ToString()));
                    break;

                case TransactionEventType.ClientActivityChanged:
                    LogEntry(string.Format("Pump {0} Transaction ID:{1} ClientActivityChanged activity:{2}", pump.Number, e.TransactionId, t.ClientActivity ));
                    break;

                default:
                    LogEntry(string.Format("Pump {0} Transaction ID:{1} event:{2}", pump.Number, e.TransactionId, e.EventType.ToString()));
                    break;

            }
        }

        void Pumps_OnFuellingProgress(object sender, FuellingProgressEventArgs e)
        {
            if (_ShowTotals)
            {
                Pump pump = sender as Pump;
                LogEntry(string.Format("Pump {0} Running total quantity:{1} value:{2}", pump.Number, e.Volume, e.Value ));
            }
        }

        void pump_OnHoseEvent(object sender, PumpHoseEventArgs e)
        {
            Pump pump = sender as Pump;
            switch (e.EventType)
            {
                case HoseEventType.Block:
                    LogEntry(string.Format("Pump {0} Hose {1} event:{2} Reason:{3}", pump.Number, e.HoseNumber, 
                        e.EventType.ToString(),
                        pump.Hoses.GetByNumber(e.HoseNumber).BlockedReasons
                        ));
                    break;
                default:
                    LogEntry(string.Format("Pump {0} Hose {1} event:{2}", pump.Number, e.HoseNumber, e.EventType.ToString()));
                    break;
            }
        }
        void pump_OnJournalEvent(object sender, JournalEventArgs e)
        {
            Pump pump = sender as Pump;

            LogEntry(string.Format("Pump {0} Journal event id:{1} type:{2} level:{3} message:{4}", 
                pump.Number, e.Id, e.JournalType.ToString(), e.Level, e.Message ));
        }
        #endregion

        #region Terminal events
        void term_OnTerminalStatus(object sender, EventArgs e)
        {
            Terminal term = sender as Terminal;
            LogEntry(string.Format("Terminal {0} Status:{1}", term.Id, term.IsOnline?"Online":"Offline" ));
        }
        #endregion

        #region Attendant Events
        void atten_OnLogOn(object sender, AttendantLogOnOffEventArgs e)
        {
            Attendant atten = sender as Attendant;
            LogEntry(string.Format("Attendant {0}/{1} LogOn  Pump:{2} Tag:{3}", atten.Number, atten.Name, e.PumpNumber, e.TagId));
        }

        void atten_OnLogOff(object sender, AttendantLogOnOffEventArgs e)
        {
            Attendant atten = sender as Attendant;
            LogEntry(string.Format("Attendant {0}/{1} LogOff  Pump:{2} ", atten.Number, atten.Name, e.PumpNumber));
        }

        void Attendants_OnStatusChanged(object sender, AttendantStatusEventArgs e)
        {
            Attendant atten = sender as Attendant;
            if (e.EventType == AttendantStatusEventType.Blocked)
            {
                LogEntry(string.Format("Attendant {0} Blocked:{1} Reason:{2}", atten.Number, atten.IsBlocked, atten.BlockReason ));
            }
        }

        void Attendants_OnPeriodStateChange(object sender, EventArgs e)
        {
            Attendant atten = sender as Attendant;
            string State = "";

            switch( atten.PeriodState )
            {
                case AttendantPeriodState.None   : State = "None"; break;
                case AttendantPeriodState.Open: State = "Open"; break;
                case AttendantPeriodState.Closed: State = "Closed"; break;
                case AttendantPeriodState.Reconciled: State = "Reconciled"; break;
            }
            LogEntry(string.Format("Attendant {0} period state change: {1}", atten.Number, State));
        }

        void Attendants_OnTagRead(object sender, TagReadEventArgs e)
        {
            Attendant atten = sender as Attendant;
            LogEntry(string.Format("Attendant {0} Tag Read Pump:{1} TagReader:{2} TagData:{3}", atten.Number, e.PumpNumber, e.TagReaderID, e.TagData));
        }



        #endregion
        #region Fallback Events

        void Fallback_OnActiveClientChange(object sender, EventArgs e)
        {
            LogEntry(string.Format("Fallback clients changed {0}", _Forecourt.Fallback.ActiveClients ));
        }

        void Fallback_OnModeChange(object sender, EventArgs e)
        {
            LogEntry(string.Format("Fallback mode changed {0}  Manual state {1}", _Forecourt.Fallback.Mode.ToString(), _Forecourt.Fallback.ManualFallbackState.ToString() ));
        }
        #endregion

        #region Utility
        private void Menu_Copy_Click(object sender, RoutedEventArgs e)
        {
            TextBox_log.Copy();
        }

        private void Menu_Clear_Click(object sender, RoutedEventArgs e)
        {
            TextBox_log.Clear();
        }

        private void Menu_Latest_Click(object sender, RoutedEventArgs e)
        {
            if ( Menu_Latest.IsChecked )
                TextBox_log.ScrollToEnd();
        }

        private void Menu_Totals_Click(object sender, RoutedEventArgs e)
        {
            _ShowTotals = Menu_Totals.IsChecked;

        }
        #endregion
    }
}
