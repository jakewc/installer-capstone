//
//  Public header for Enabler Session states 
//
//  Created by ITL on 8/05/15.
//  Copyright (c) 2015 Integration Technologies Ltd. All rights reserved.
//

/*!
 *  Type of request to be made when using the sendReceiveXmlRequestofType method.
 */
typedef NS_ENUM( NSUInteger, ENBRequestType){
    /*!
     *  The request is only wrapped in the header information and root element <Operation>
     */
    ENBRequestTypeNone,
    /*!
     *  A DataRequest. The supplied XML is wrapped in the header and <Operation><DataRequest> XML.
     */
    ENBRequestTypeDataRequest,
    /*!
     *  A CommandRequest. The supplied XML is wrapped in the header and <Operation><Command> XML.
     */
    ENBRequestTypeCommandRequest
};
