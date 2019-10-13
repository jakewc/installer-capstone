//
//  Public header for Enabler Session Object
//
//  Created by ITL on 8/05/15.
//  Copyright (c) 2015 Integration Technologies Ltd. All rights reserved.
//


#import "ENBForecourtStates.h"
#import "ENBSessionStates.h"

/*!
 *  EnablerSession protocol
 *
 *  List of delegates to be fired by EnablerSession
 */
@protocol ENBSessionDelegate
@optional
/*!
 *  This is an optional delegate that is fired when an XML event block is received. if not using the forecourt class then the application will need to
 *  respond with the SendEventAcknowlege method to acknowledge the receipt of the events. Only the last event of a block needs to be acknowledged.
 *
 *  @param xmlMessage XMl data containing the complete events message in NSData format so it can be passed directly into a NSXmlparser.
 */
-(void)didReceiveEvents:(NSData*) xmlMessage;
/*!
 *  This delegate is fired when a heartbeat has been received. If user is receiving these delegates then it is expected to  send a heartbeat
 *  in response. if delegate is not responded to then the session will automatically generate a response.
 *
 *  @param xmlMessage The XML heartbeat message that was received.
 */
-(void)didReceiveHeartBeat:(NSData*) xmlMessage;
/*!
 *  This delegate is fired if the underlying connection has disconnected
 */
-(void)didDisconnect;
@end


/*!
 *  EnablerSession interface
 */
@interface ENBSession : NSObject

/*!
 *  Indicates the connection state. The session is connected on logged in when this returns YES.
 */
@property (readonly) BOOL isConnected;

/*!
 *  Create a connection to the Pump Server at serverAddress and login with the passed parameters
 *
 *  @param serverAddress  IP address or Host name of server where Pump Server is running.
 *  @param terminalID The terminal ID for login
 *  @param terminalName   The name of the terminal/client
 *  @param password       The password for the Treminal ID
 *  @param active         YES if this terminal monitored for fallback situations.
 *  @param asyncHandler   When set to a completion block the command will run asyncronously. nil to run command synchronously.
 *
 *  @return The ApiResult of the command.
 */
-(int)connectToServer:(NSString*)   serverAddress
       withTerminalID:(int)         terminalID
     withTerminalName:(NSString*)   terminalName
         withPassword:(NSString*)   password
        setToFallback:(BOOL)        active
           Completion:(EnablerHandler)asyncHandler;

/*!
 *  Disconnect a connected session to pump server with an optional message.
 *
 *  @param message Any non empty message will be loggedin the Pump server log.
 *
 *  @return The ApiResult of the command.
 */
-(int)disconnectWithMessage:(NSString*) message;

/*!
 *  Send a XML request of type and wait for response synchronously or via a completion handler.
 *
 *  @param requestType      Type of request.
 *                          None            : The command will wrapped in the Header and Operation XML
 *                          DataRequest     : The command will be wrapped in the DataRequest XML. xmlRequestDetail contains the inside XML of the request.
 *                          CommandRequest  : The command will be wrapped in the CommandRequest XML. xmlRequestDetail contains the inside XML of the request.
 *  @param xmlRequestDetail XML details for the command
 *  @param responses        An Array of responses as a result of command. Only 1 expected with a command
 *  @param timeout          Timeout in seconds waiting for a response, Returns an CommandTimeout error on timeout
 *  @param asyncHandler     Completion handler for async operation or nil for synchronous operation
 *
 *  @return Returns the result of from the response if synchronous or 0 command started
 */
-(int)sendReceiveXmlRequestofType:(ENBRequestType)requestType
                       XmlRequest:(NSString*)xmlRequestDetail
                        Responses:(NSMutableArray *)responses
                    TimeoutInSecs:(int)timeout
                       Completion:(EnablerHandler)asyncHandler;


/*!
*  Send the a complete XML message to Pump Server without waiting for a response.
*
*  @param completeXML A complete XML message
*/
- (void) sendXmlString:(NSString *)completeXML;


/*!
 *  Used to send a Heartbeat message to pump server. If you are subscribing to the optional didReceiveHeartBeat delegate then the EnablerAPI
 *  assumes the client will respond with a SendHeartbeat.
 */
- (void) sendHeartbeat;

/*!
 *  Send an event acknowledgement.
 *
 *  If using the Forecourt object then events will be automatically acknowledged. If not using the forecourt object and
 *  events have been subscribed too then the last event in each event block needs to be acknowledged otherwise the connection will
 *  disconnected by pump server when its event queue is full.
 *
 *  @param lastEventNumber  The last event number to be received that has been handled. This is normally the last event number in a block of events.
 *                          All proceeding events up to the specified event will be marked as acknowledged.
 */
- (void) sendEventAcknowledege:(int)lastEventNumber;

/*!
 *  Used to add a reference to a class instance responding to the id<EnablerSessionDelegate> protocol so that the class
 *  will receive the fired delegates.
 *
 *  @param delegate id responding to id<EnablerSessionDelegate>
 */
-(void)addDelegate:(id<ENBSessionDelegate>) delegate;

/*!
 *  Used to remove a class instance form the delegate list, see addDelegate
 *
 *  @param delegate delegate id that been previously added to delegate
 */
-(void)removeDelegate:(id<ENBSessionDelegate>) delegate;

@end

