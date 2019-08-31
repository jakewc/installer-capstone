//
//  ForecourtPublic.h
//  EnablerApi
//
//  Created by ITL on 8/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

@import Foundation;

#import "ENBForecourtStates.h"
#import "ENBSessionPublic.h"

@class ENBForecourt;

#import "ENBPumpPublic.h"
#import "ENBGradePublic.h"
#import "ENBTransactionPublic.h"
#import "ENBApiResults.h"
/*!
 *  Protocol used to fire events from the Forecourt.
 */
@protocol ENBForecourtDelegate
@optional

/**
 *  This event is fired when a server connection error occurs and connection is lost
 */
- (void)onServerEvent;
@end


/*!
 *  A class containing information about the Enabler Server.
 */
@interface ENBServerInformation : NSObject

/**
 *  Gets the name if the server that is running the Enabler
 */
@property (readonly)NSString* ServerName;
/**
 *  Gets the version of the Enabler server
 */
@property (readonly)NSString* ServerVersion;
/**
 *  Gets the name of the OS platform running the Enabler
 */
@property (readonly)NSString* ServerPlatform;
/**
 *  Gets the version of the OS platform running the Enabler
 */
@property (readonly)NSString* ServerPlatformVersion;
/**
 *  Gets up time of the Enabler
 */
@property (readonly)long ServerUptime;
/**
 *  Gets the version string of the Enabler API running on the server
 */
@property (readonly)NSString* APIVersion;

@end

/*!
 *  The main class for the Enabler API forecourt model
 */
@interface ENBForecourt : NSObject


/**
 *  Read only collection of grades
 */
@property ENBGradeCollection * grades;

/**
 *  Returns connected state of the forecourt
 */
@property (readonly) BOOL isConnected;

/**
 *  Read only collection of pumps
 */
@property ENBPumpCollection * pumps;

/**
 *  Returns ServerInformation object for the connected server
 */
@property ENBServerInformation* serverInformation;

/*!
 *  Reference to the underlying ENBSession object.
 */
@property (readonly) ENBSession * session;

/**
 *  Returns the site name configured in the Enabler
 */
@property (readonly)NSString* siteName;

/**
 *  Returns the terminal ID of the terminal logged on to under this session
 */
@property (readonly)NSInteger terminalID;


/**
 *  The method will create a connection with the Enabler
 *
 *  @param serverAddress  Address of server to connect to. This can either be the hose name or an IP address
 *  @param terminalID A number to identify the client application
 *  @param terminalName   A name to identify the client application, Can be empty string or null
 *  @param password       Password associated with TerminalNumber in Enabler configuration
 *  @param active         This is set to true if the Terminalnumber is monitored for automatic fall back when all other active terminals are offline.
 *  @param asyncHandler   When set to a completion block the command will run asyncronously. nil to run command synchronously.
 *
 *  @return Returns connection result refer to APIResult.
 */
-(int)connectToServer:(NSString*) serverAddress
       withTerminalID:(int) terminalID
     withTerminalName:(NSString *) terminalName
         withPassword:(NSString*) password
        setToFallback:(BOOL) active
           Completion:(EnablerHandler)asyncHandler;

/**
 *  This method disconnects the client application from the Enabler
 *
 *  @param message Optional message that will be logged
 *
 *  @return Returns disconnection result refer to APIResult
 */
-(int)disconnectWithMessage:(NSString*) message;

/*!
 *  Adds a delegate to list of delegates called on Forecourt events.
 *
 *  @param delegate The delegate to add
 */
-(void)addDelegate:(id<ENBForecourtDelegate>) delegate;

/*!
 *  Removes the passed delegate from the list of delegates called on Forecourt events.
 *
 *  @param delegate The delegate to remove.
 */
-(void)removeDelegate:(id<ENBForecourtDelegate>) delegate;

/**
 *  Returns the culture specific error string for the passed API result Code
 *
 *  @param resultCode API result code
 *
 *  @return Error message for API code
 */
+ (NSString*)getResultString:(ENBApiResult) resultCode;

/**
 *  Returns the culture specific string resource from framework
 *
 *  @param resourceName Name of resource to get
 *
 *  @return String containing the requested string resource
 */
+ (NSString*)getResourceString:(NSString*) resourceName;

/**
 *  Returns a fuel transaction using Transaction ID.
 * 
 * @param transactionID The transaction ID of the transaction to retrieve
 *
 *  @return Returns ENBTransaction * or nil if not found
 */
- (ENBTransaction *)getTransactionById:(int) transactionID;

/**
 *  Returns a fuel transaction using Transaction client reference.
 *
 * @param clientReference A unique reference supplied by the client application to the original Authorize.
 *
 *  @return Returns ENBTransaction * or nil if not found
 */
- (ENBTransaction *)getTransactionByReference:(NSString *) clientReference;

/**
 *  This method allows clients to stop all installed pumps
 *
 *  @return Returns API result
 */
- (int)stop;

@end