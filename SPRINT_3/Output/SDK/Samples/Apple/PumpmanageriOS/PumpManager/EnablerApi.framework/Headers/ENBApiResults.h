//
//  Api.h
//  libEnabler
//
//  Created by ITL on 16/04/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#ifndef libEnabler_Api_h
#define libEnabler_Api_h

/*!
 Result of API method call
 */
typedef NS_ENUM( NSUInteger, ENBApiResult)
{
    /// 
    /// Method was successful
    /// <value>0</value>
    ENBApiResultOk,
    /// 
    /// This fuel transaction is already locked by another terminal.
    /// 
    ENBApiResultTransactionAlreadyLocked,          //  1
    /// 
    /// Cannot unlock fuel transaction. This fuel transaction is not locked.
    /// 
    ENBApiResultTransactionNotLocked,            //  2
    /// 
    /// Cannot unlock/lock fuel transaction. This fuel transaction is locked by another terminal.
    /// 
    ENBApiResultTransactionNotLockedByYou,       //  3
    /// 
    /// This type of fuel transaction cannot be cleared from the pump.
    /// 
    ENBApiResultCannotClearTransactionType,       //  4
    /// 
    /// This session has already logged on.
    /// 
    ENBApiResultSessionAlreadyLoggedOn,        //  5
    /// 
    /// A terminal with this number has already logged on.
    /// 
    ENBApiResultTerminalIdAlreadyLoggedOn,    //  6
    /// 
    /// This terminal is not logged on to the Enabler.
    /// 
    ENBApiResultNotLoggedOn,                    //  7
    /// 
    /// The terminal ID must be greater than zero.
    /// 
    ENBApiResultBadTerminalNumber,              //  8
    /// 
    /// Fuel Transaction stacking is not allowed by the current site or pump mode.
    /// 
    ENBApiResultStackingNotAllowed,             //  9
    /// 
    /// There is no current fuel transaction to stack.
    /// 
    ENBApiResultNoCurrentTransaction,              // 10
    /// 
    /// The fuel transaction stack on this pump has reached the maximum number of transactions allowed by configuration.
    /// 
    ENBApiResultStackFull,                       // 11
    /// 
    /// Pump is not installed (e.g. is on a disabled loop).
    /// 
    ENBApiResultPumpNotInstalled,
    /// 
    /// Pump is offline; not currently responding to Enabler.
    /// 
    ENBApiResultPumpNotResponding,
    /// 
    /// A fuel delivery is currently outstanding on the pump. It must be cleared (paid) or stacked.
    /// 
    ENBApiResultHasCurrentTransaction,
    /// 
    /// This pump is already reserved by V3 client.
    /// 
    ENBApiResultPumpIsReserved,
    /// 
    /// This pump is not reserved for a prepay.
    /// 
    ENBApiResultNotReservedForPrepay,          // 16
    /// 
    /// This pump is not reserved by this terminal.
    /// 
    ENBApiResultNotReservedByYou,              // 17
    /// 
    /// No hoses are configured on the pump.
    /// 
    ENBApiResultInvalidHoseNumber,              // 18
    /// 
    /// A invalid authorization limit has been specified.
    /// 
    ENBApiResultInvalidLimit,                    // 19
    /// 
    /// Invalid pump number.
    /// 
    ENBApiResultInvalidPumpNumber,              // 20
    /// 
    /// This transaction has already been reserved.
    /// 
    ENBApiResultTransactionAlreadyReserved,     // 21
    /// 
    /// This transaction is in an invalid state to be stacked or reinstated.
    /// Only completed transactions can be stacked and only cleared Transactions with delivery data can be reinstated.
    /// 
    ENBApiResultCannotStackTransactionType,      // 22
    /// 
    /// This pump is unavailable (e.g. doing a delivery).
    /// 
    ENBApiResultPumpNotAvailable,               // 23
    /// 
    /// The active forecourt mode does not allow postpays on this pump.
    /// 
    ENBApiResultPostPaysNotAllowed,             // 24
    /// 
    /// The active forecourt mode does not allow prepays on this pump.
    /// 
    ENBApiResultPrepaysNotAllowed,              // 25
    /// 
    /// The active forecourt mode does not allow preauths on this pump.
    /// 
    ENBApiResultPreauthoriseNotAllowed,             // 26
    /// 
    /// Deprecated. Previously indicated the pump has not been reserved.
    /// 
    ENBApiResultNotReserved,                     // 27
    /// 
    /// Unable to connect to Pump Server.
    /// Pump server is not running, network connection is broken or the wrong address is being used to connect.
    /// 
    ENBApiResultNotConnectToPumpServer,             // 28
    /// 
    /// The connection went offline while communicating with Enabler Pump Server.
    /// 
    ENBApiResultErrorWithPumpServer,                 // 29
    /// 
    /// Information result; not an error.
    /// It indicates a successful log on, but that one or more pumps that this terminal had reserved previously have been unreserved.
    /// 
    ENBApiResultReservesRemoved,                 // 30
    /// 
    /// Information result; not an error.
    /// It indicates a successful log on, but that some locks this terminal had previously were removed.
    /// 
    ENBApiResultLocksRemoved,                    // 31
    /// 
    /// One or more pumps the reserve was removed and transaction locks have been removed.
    /// 
    ENBApiResultReservesAndLocksRemoved,       // 32
    /// 
    /// The Enabler has logged this client session off, most likely because the server was stopped.
    /// 
    ENBApiResultPumpServerForcedLogOff,              // 33
    /// 
    /// Information result; not an error.
    /// It indicates a successful log on, but that some locks or reserves this terminal had have been removed.
    /// 
    ENBApiResultPreAuthLockFound,               // 34
    /// 
    /// This transaction has already been locked by this terminal.
    /// 
    ENBApiResultTransactionAlreadyLockedByYou,              // 35
    /// 
    /// Deprecated.
    /// 
    ENBApiResultReserved36,                               // 36 No longer used
    /// 
    /// The pump cannot be authorized because the configured maximum number of deliveries are already in progress (see Enabler configuration).
    /// 
    ENBApiResultTooManyPumpsDelivering,                  // 37
    /// 
    /// The specified attendant is already logged onto this pump.
    /// 
    ENBApiResultAttendantAlreadyLoggedOn,                // 38
    /// 
    /// A different attendant has already logged onto this pump.
    /// 
    ENBApiResultPumpAlreadyLoggedOn,           // 39
    /// 
    /// Attendant log off failed because no attendant is logged onto the pump.
    /// 
    ENBApiResultPumpNotLoggedOn,               // 40
    /// 
    /// Attendant log off failed because the Attendant parameter did not match the Attendant currently logged onto the pump.
    /// 
    ENBApiResultAttendantNotLoggedOntoPump = 41,  // 41
    /// 
    /// Cannot log the attendant onto the pump because attendant mode is not allowed for the current site or pump mode.
    /// 
    ENBApiResultAttendantModeNotPermitted,     // 42
    /// 
    /// The attendant is not logged onto any pumps.
    /// 
    ENBApiResultAttendantNotLoggedOn,          // 43
    /// 
    /// An attempt to log a manual delivery against a non-manual pump was made.
    /// 
    ENBApiResultPumpNotManual,              // 44
    /// 
    /// The manual transaction details logged against this pump contained bad data.
    /// 
    ENBApiResultBadTransactionData,                // 45
    /// 
    /// The requested transaction ID given was not found.
    /// 
    ENBApiResultTransactionNotFound,               // 46
    /// 
    /// This result code is no longer used.
    /// 
    ENBApiResultCannotFreeCurrentTransaction,     // 47
    /// 
    /// The UPS being monitored on the server has switched over to battery.
    /// 
    ENBApiResultPumpServerOnBattery,                 // 48
    /// 
    /// The UPS being monitored on the server has switched back to mains power.
    /// 
    ENBApiResultPumpServerOnMains,                   // 49
    /// 
    /// The UPS being monitored on this machine has switched over to battery.
    /// 
    ENBApiResultTerminalOnBattery,              // 50
    /// 
    /// The UPS being monitored on this machine has switched back to mains power.
    /// 
    ENBApiResultTerminalOnMains,                // 51
    /// 
    /// This type of pump does not support preset functionality.
    /// 
    ENBApiResultPresetNotSupported,             // 52
    /// 
    /// Not used.
    /// 
    ENBApiResultIncompatiblePumpServer,                // 53
    /// 
    /// The authorization limit is too small and cannot be set at the pump.
    /// 
    ENBApiResultLimitationTooSmall,             // 54
    /// 
    /// The authorization limit is above the allocation limit defined for the Grade  - authorization failed.
    /// 
    ENBApiResultLimitationExceedsAllocationLimit,      // 55
    /// 
    /// Price level not supported by this pump.
    /// 
    ENBApiResultPriceLevelNotSupportedByPump, // 56
    /// 
    /// OPT has not been claimed.
    /// 
    ENBApiResultOPTNotClaimed,                          // 57
    /// 
    /// The Enabler reconnected after it was shutdown.
    /// 
    ENBApiResultPumpServerReconnected,                 // 58
    /// 
    /// Database ID provided could not be found in the database.
    /// 
    ENBApiResultIdNotMatched,                    // 59
    /// 
    /// Attendant password verification failed.
    /// 
    ENBApiResultIncorrectPassword,                // 60
    /// 
    /// This result is returned when the Attendant is still logged on.
    /// 
    ENBApiResultAttendantStillLoggedOn,         // 61
    /// 
    /// Indicates the method called is not yet implemented.
    /// 
    ENBApiResultNotImplemented,                   // 62
    /// 
    /// Indicates that the Attendant has no period in a suitable state to close.
    /// For example this result would be returned if the Attendant's period had already been closed.
    /// 
    ENBApiResultAttendantPeriodNotClosed,       // 63
    /// 
    /// Attendant log off not permitted because the attendant still has some transactions that have been completed but not cleared
    /// 
    ENBApiResultAttendantHasTransactions,          // 64
    /// 
    /// Specified Attendant was not found in the database.
    /// 
    ENBApiResultAttendantNotFound,               // 65
    /// 
    /// Indicates that the Attendant may not log on because they have a previous period that has not yet been reconciled.
    /// 
    ENBApiResultAttendantPeriodNotReconciled,   // 66
    /// 
    /// Indicates the Attendant GetAmount method to retrieve the initial float has failed because no initial float has yet been entered.
    /// 
    ENBApiResultAttendantHasNoInitialFloat,    // 67
    /// 
    /// Client attempted to cancel a transaction during delivery.
    /// 
    ENBApiResultCannotCancelDuringTransaction,      // 68
    /// 
    /// The operation is not support by the pump.
    /// 
    ENBApiResultNotSupportedByPump,             // 69
    /// 
    /// The call failed due to an internal error - please refer to ITL support.
    /// 
    ENBApiResultException,                         // 70
    /// 
    /// A price change or price set is pending for this pump.
    /// 
    ENBApiResultPriceChangePending,              // 71
    /// 
    /// The Enabler cannot accept client connections (logons) because it has not finished loading configuration from the database, or has been unable to connect to the database server yet.
    /// This should be a temporary condition and retrying in a short time should result in success.
    /// 
    ENBApiResultPumpServerNotReady,                   // 72
    /// 
    /// This API result value is reserved.
    /// 
    ENBApiResultPumpServerDatabaseError,              // 73
    /// 
    /// The pump cannot be authorized because it is disabled.
    /// The pump is disabled because either the pump or all the hoses on the pump have been disabled directly
    /// or because all the hoses on the pump are linked to a disabled tank or grade.
    /// 
    ENBApiResultPumpIsBlocked,					  // 74
    /// 
    /// All the hoses selected in the authorization request are disabled or are linked to a disabled grade or tank object.
    /// 
    ENBApiResultAllSelectedHosesBlocked,	      // 75
    /// 
    /// The pump cannot be authorized because either:
    /// - the calling hose id is known and is disabled.
    /// - the calling hose id is unknown and one or more hoses on the pump are disabled. The authorization must be declined to prevent the possibility of a disabled hose delivering fuel.
    /// Note this error can only be returned if the pump is already calling when the authorize attempt is made.
    /// 
    ENBApiResultHoseIsBlocked,					  // 76
    /// 
    /// Unable to toggle fallback mode. Site mode doesn't support fallback or system is not in fallback state.
    /// 
    ENBApiResultFallbackModeUnableToToggle,           // 77
    /// 
    /// Fallback mode is enabled.
    /// 
    ENBApiResultFallbackModeEnabled,					  // 78
    /// 
    /// Fallback mode id disabled.
    /// 
    ENBApiResultFallbackModeDisabled,                   // 79
    /// 
    /// Fallback mode is currently inactive as the system has started.
    /// 
    ENBApiResultFallbackModeInactiveAtStartUp,           // 80
    
    
    /// 
    /// The Pump not in delivering state.
    /// 
    ENBApiResultPumpNotDelivering,				            // 81
    /// 
    /// The item requested was not found.
    /// 
    ENBApiResultRequestedItemNotFound,                    // 82
    /// 
    /// Error parsing XML from Enabler.
    /// 
    ENBApiResultResponseXmlError,                        // 83
    
    /// 
    /// Invalid Terminal ID or password on Connect.
    /// 
    ENBApiResultInvalidCredentials,                      // 84
    
    /// 
    /// Invalid parameter passed to method.
    /// 
    ENBApiResultInvalidParameter,                        //85
    
    /// 
    /// The Terminal is not permitted access to this function.
    /// 
    ENBApiResultAccessDenied,                             // 86 Permissions denied
    
    /// 
    /// The Enabler database is current offline.
    /// 
    ENBApiResultDatabaseOffline,                         // 87 Pump server database is offline
    
    /// 
    /// Required parameter is missing.
    /// 
    ENBApiResultMissingParameter,                       //  88 Required parameter missing
    
    /// 
    /// Client reference must match previous reserve on pump.
    /// 
    ENBApiResultInvalidClientReference,                  //  89 Client reference must match previous reserve on pump
    
    /// 
    /// Client reference or activity is too long, maximum 32 chars.
    /// 
    ENBApiResultClientFieldsTooLong,                    //  90
    
    /// 
    /// Pump has been stopped so cannot be resumed.
    /// 
    ENBApiResultPumpStopped,                            //  91
    
    /// 
    /// This Terminal does not have permission to control forecourt.
    /// 
    ENBApiResultTerminalNoPermissionControl,            // 92
    
    /// 
    /// This pump was never authorized or a delivery has already started.
    /// 
    ENBApiResultPumpNotAuthorised,                      // 93
    
    /// 
    /// The pump was not paused when trying to resume a delivery.
    /// 
    ENBApiResultPumpNotPaused,                          // 94
    
    /// 
    /// Pump already paused when Pausing a delivery.
    /// 
    ENBApiResultPumpAlreadyPaused,                      // 95
    
    
    /// 
    /// Attendant is blocked.
    /// 
    ENBApiResultAttendantIsBlocked,                     // 96
    
    /// 
    /// New authorizations are not allowed when system is running on UPS battery.
    /// 
    ENBApiResultSystemOnUpsBattery,                     // 97
    
    /// 
    /// DataBase queue is too large. (Enabler Embedded Only). This stops Authorizations until queue is reduced.
    /// Contact ITL support if this happens.
    /// 
    ENBApiResultDataBaseQueueTooLarge,                  // 98
    
    /// 
    /// The message was not acknowledged by receiving terminal so is assumed to be not received.
    /// 
    ENBApiResultMessageNotAcknowledged,                     // 99
    
    // **************************
    // Locally generated errors
    
    /// 
    /// Error connecting to the Enabler.
    /// 
    ENBApiResultConnectError = 500,
    
    /// 
    /// Timeout waiting for a response from command.
    /// 
    ENBApiResultCommandTimeout
    
} ;






#endif
