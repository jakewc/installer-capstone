//
//  PumpAuthorise.h
//  EnablerApi
//
//  Created by ITL on 2/06/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//


/*!
 *  Product collection for Authorize
 */
@interface ENBProductCollection : NSObject <NSFastEnumeration>

/**
 *  Number of the product
 */
@property (readonly) NSInteger count;

/*!
 *  Get a product by its index in the product collection.
 *
 *  @param index    index of product
 *
 *  @return Returns the product or nil if not found.
 */
- (int)getByIndex:(int)index;

/**
 *  Add a product
 *
 *  @param product id of product to add
 */
- (void)addProduct:(int)product;

/*!
 *  Remove a product
 *
 *  @param product    id of product to remove
 */
- (void)removeProduct:(int)product;

/*!
 *  Remove all products
 *
 */
- (void)removeAll;

@end

/*!
 *  Object used to set Authorization limits
 *
 */
@interface ENBPumpAuthoriseLimits : NSObject

/*!
 *  The value limit or 0 for no limit.
 */
@property (readwrite) NSDecimalNumber* value;

/*!
 *  The quantity limit or 0 for no limit.
 */
@property (readwrite) NSDecimalNumber* quantity;

/*!
 *  Price level limit or 0 no limit.
 */
@property (readwrite) int              level;

/*!
 *  Authorization timeout in seconds or 0 use system settings.
 */
@property (readwrite) int              authoriseTimeout;

/*!
 *  Fuelling timeout in seconds or 0 use system settings.
 */
@property (readwrite) int              fuellingTimeout;

/*!
 *  List of allowed products for authorization. If 0 products then all products are allowed.
 */
@property (readonly)  ENBProductCollection * products;

@end
