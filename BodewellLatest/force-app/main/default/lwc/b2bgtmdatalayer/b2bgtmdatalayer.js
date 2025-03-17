// This object must be the same of the one in B2B_GTM.js
const GTM_EVENTS_NAMES = {
    'addtocart': 'add_to_cart',
    'add_shipping_info': 'checkout_add_shipping_info',
    'add_payment_info': 'checkout_add_payment_info',
    'checkout': 'checkout_begin_ua',
    'begin_checkout': 'checkout_begin_a4',
    // 'checkoutoption': 'checkout_option', // cannot be implemented with standard checkout Flow screens.
    'clicks': 'product_clicks',
    'detailimpressions': 'product_detail_impression',
    'impressions': 'product_impressions',
    'purchase': 'purchase',
    'removefromcart': 'remove_from_cart',
    'ts_checkout': 'ts_checkout',
    'view_cart': 'view_cart',
    'add_to_wishlist': 'add_to_wishlist'
};

const GTM_EVENTS = {
    'add_to_cart': 'addtocart',
    'checkout_add_shipping_info': 'add_shipping_info',
    'checkout_add_payment_info': 'add_payment_info',
    'checkout_begin_ua': 'checkout',
    'checkout_begin_a4': 'begin_checkout',
    // 'checkout_option: 'checkoutoption', cannot be implemented with standard checkout Flow screens.
    'product_clicks': 'clicks',
    'product_detail_impression': 'detailimpressions',
    'product_impressions': 'impressions',
    'purchase': 'purchase',
    'remove_from_cart': 'removefromcart',
    'ts_checkout': 'ts_checkout',
    'view_cart': 'view_cart',
    'add_to_wishlist' : 'add_to_wishlist'
};

const BRAND = 'TROTEC';
const AFFILIATION = 'TROTEC ONLINE COMMERCE';

/**
 * Wrapper object used to map Commerce data to the GTM layer.
 * It applies to products, Cart and Order Items.
 */
class GTMProduct {
    constructor(id, name, currency, price, brand, category, variant, list, position, quantity, fromList, absoluteUrl) {
        this.id = id;
        this.name = name;
        this.currency = currency;
        this.price = price;
        this.brand = brand;
        this.category = category;
        this.variant = variant;
        this.list = list;
        this.position = position;
        this.quantity = quantity;
        this.fromList = fromList;
        this.absoluteUrl = absoluteUrl;
        this.coupon = null;
    }
}

/** GTM ADD TO CART
 *
 * EXAMPLE:
 *
 * {
 *  'event': 'addtocart',
 *  'ecommerce': {
 *      'currencyCode': 'EUR',
 *      'add': { // 'add' actionFieldObject measures.
 *         'products': [{ //  adding a product to a shopping cart.
 *             'name': 'Triblend Android T-Shirt',
 *      'id': '12345',
 *      'price': '15.25',
 *      'brand': 'Google',
 *      'category': 'Apparel',
 *      'variant': 'Gray',
 *      'quantity': 1
 *      }]
 *   }
 * }
 * }
 */

class GTMAddToCartData {
    name = '';
    id = '';
    price = '';
    brand = '';
    category = '';
    variant = '';
    quantity = 0;

    constructor(product) {
        // One of them must be given.
        if (!product.name || !product.id) {
            throw new Error('Value missing to build GTMAddToCartData: no Product Name and no Product ID given.');
        }

        this.name = product.name;
        this.id = product.id;
        this.price = product.price;
        this.brand = product.brand || BRAND;
        this.category = product.category;
        this.variant = product.variant;
        this.quantity = product.quantity;
    }
}
class AddToCartEvent {
    NAME = GTM_EVENTS.add_to_cart;

    data = {
        event: this.NAME,
        ecommerce: {
            currencyCode: '',
            add: {
                products: []
            }
        }
    };

    constructor(product) {
        let ecommerceData = this.data.ecommerce;

        ecommerceData.currencyCode = product.currency;
        ecommerceData.add.products.push(new GTMAddToCartData(product));
    }
}
// END Add to cart event

/** GTM REMOVE FROM CART
 * Measure the removal of a product from a shopping cart.
 *
 * {
 *  'event': 'removefromcart',
 *  'ecommerce': {
 *      'remove': { // 'remove' actionFieldObject measures.
 *          'products': [{ //  removing a product to a shopping cart.
 *              'name': 'Triblend Android T-Shirt',
 *              'id': '12345',
 *              'price': '15.25',
 *              'brand': 'Google',
 *              'category': 'Apparel',
 *              'variant': 'Gray',
 *              'quantity': 1
 *          }]
 *      }
 *  }
 * }
 *
 */

// SAME AS GTMAddToCartData !
class GTMRemoveFromCartData {
    name = '';
    id = '';
    price = '';
    brand = '';
    category = '';
    variant = '';
    quantity = 0;

    constructor(product) {
        // One of them must be given.
        if (!product.name || !product.id) {
            throw new Error('Value missing to build GTMAddToCartData: no Product Name and no Product ID given.');
        }

        this.name = product.name;
        this.id = product.id;
        this.price = product.price;
        this.brand = product.brand || BRAND;
        this.category = product.category;
        this.variant = product.variant;
        this.quantity = product.quantity;
    }
}
class RemoveFromCartEvent {
    NAME = GTM_EVENTS.remove_from_cart;

    data = {
        event: this.NAME,
        ecommerce: {
            remove: {
                products: []
            }
        }
    };

    constructor(product) {
        let ecommerceData = this.data.ecommerce;

        ecommerceData.remove.products.push(new GTMRemoveFromCartData(product));
    }
}
// END Remove from cart event

/** GTM VIEW CART EVENT A4
 * {
    "event": "view_cart",
    "ecommerce": {
        "items": [{
            "item_name": "Finnish magical parka",
            "item_id": "mp1122",
            "price": "31.10",
            "item_brand": "PARKA4LIFE",
            "item_category": "Apparel",
            "item_category2": "Coats",
            "item_category3": "Parkas",
            "item_category4": "Unisex",
            "item_variant": "Navy blue",
            "quantity": "3"
        }]
    }
*/

class GTMA4ItemData {
    item_name = '';
    item_id = '';
    price = '';
    item_brand = '';
    item_category = '';
    item_variant = '';
    quantity = 0;

    constructor(product) {
        // One of them must be given.
        if (!product.name || !product.id) {
            throw new Error('Value missing to build GTMA4ItemData: no Product Name and no Product ID given.');
        }

        this.item_name = product.name;
        this.item_id = product.id;
        this.price = product.price;
        this.item_brand = product.brand || BRAND;
        this.item_category = product.category;
        this.item_variant = product.variant;
        this.quantity = product.quantity;
    }
}
class GTMA4Event {
    NAME;

    data = {
        event: '',
        ecommerce: {
            items: []
        }
    };

    constructor(eventName, products) {
        this.NAME = eventName;

        this.data.event = this.NAME;

        let ecommerceData = this.data.ecommerce;

        products.forEach((product) => {
            ecommerceData.items.push(new GTMA4ItemData(product));
        });
    }
}
// END GTMA4Event

class GTMA4ShippingEvent {
    NAME = GTM_EVENTS.checkout_add_shipping_info;

    data = {
        event: this.NAME,
        ecommerce: {
            shipping_tier: '',
            items: []
        }
    };

    constructor(shippingInfo, products) {
        let ecommerceData = this.data.ecommerce;

        ecommerceData.shipping_tier = shippingInfo;

        products.forEach((product) => {
            ecommerceData.items.push(new GTMA4ItemData(product));
        });
    }
}
// END GTMA4ShippingEvent

class GTMA4PaymentEvent {
    NAME = GTM_EVENTS.checkout_add_payment_info;

    data = {
        event: this.NAME,
        ecommerce: {
            payment_type: '',
            items: []
        }
    };

    constructor(paymentInfo, products) {
        let ecommerceData = this.data.ecommerce;

        ecommerceData.payment_type = paymentInfo;

        products.forEach((product) => {
            ecommerceData.items.push(new GTMA4ItemData(product));
        });
    }
}
// END GTMA4PaymentEvent

// GTM Purchase Event
// {
//     event: 'purchase',
//     ecommerce: {
//         currencyCode: 'EUR',
//         purchase: {
//             actionField: {
//                 id: 'T12345',
//                 affiliation: 'Online Store',
//                 revenue: '35.43',
//                 tax: '4.90',
//                 shipping: '5.99',
//                 coupon: 'SUMMER_SALE'
//             },
//             products: [
//                 {
//                     name: 'Triblend Android T-Shirt',
//                     id: '12345',
//                     price: '15.25',
//                     brand: 'Google',
//                     category: 'Apparel',
//                     variant: 'Gray',
//                     quantity: 1,
//                     coupon: ''
//                 }
//             ]
//         }
//     }
// };

class GTMPurchaseEvent {
    NAME = GTM_EVENTS.purchase;

    data = {
        event: this.NAME,
        ecommerce: {
            currencyCode: '',
            purchase: {
                actionField: {
                    id: '',
                    affiliation: '',
                    revenue: '',
                    tax: '',
                    shipping: '',
                    coupon: ''
                },
                products: []
            }
        }
    };

    /**
     * 
     * @param {GTMOrder} orderInfo 
     */
    constructor(orderInfo, orderItems) {
        let ecommerceData = this.data.ecommerce;

        ecommerceData.currencyCode = orderInfo.currency;
        ecommerceData.purchase.actionField.id = orderInfo.orderNumber;
        ecommerceData.purchase.actionField.affiliation = AFFILIATION;
        ecommerceData.purchase.actionField.revenue = orderInfo.totalAmount;
        ecommerceData.purchase.actionField.tax = orderInfo.totalTax;
        ecommerceData.purchase.actionField.shipping = orderInfo.shippingAmount;
        ecommerceData.purchase.actionField.coupon = orderInfo.coupon;

        orderItems.forEach((orderItem) => {
            ecommerceData.purchase.products.push(orderItem);
        });
    }
}
// END GTM Purchase Event

/*
* PRODUCT IMPRESSIONS
* Measures product impressions and also tracks a standard pageview for the tag configuration.
* Product impressions are sent by pushing an impressions object containing one or more impressionFieldObjects.
* 
* 
* EXAMPLE OF Ecommerce Impression Event
    {
        'event':'impressions',
        'ecommerce': {
            'currencyCode': 'EUR', // Local currency is optional.
            'impressions': [
                {
                    'name': 'Triblend Android T-Shirt',       // Name or ID is required.
                    'id': '12345',
                    'price': '15.25',
                    'brand': 'Google',
                    'category': 'Apparel',
                    'variant': 'Gray',
                    'list': 'Search Results',
                    'position': 1
                }] 
            }
        }
    }
* 
*/
class GTMProductImpressionData {
    name = '';
    id = '';
    price = '';
    brand = '';
    category = '';
    variant = '';
    list = '';
    position = 0;

    constructor(product) {
        // One of them must be given.
        if (!product.name || !product.id) {
            throw new Error('Value missing to build GTMProductImpressionData: no Product Name and no Product ID given.');
        }

        this.name = product.name;
        this.id = product.id;
        this.price = product.price;
        this.brand = product.brand || BRAND;
        this.category = product.category;
        this.variant = product.variant;
        this.list = product.list;
        this.position = product.position;
    }
}

class ProductImpressionsEvent {
    NAME = GTM_EVENTS.product_impressions;

    data = {
        event: this.NAME,
        ecommerce: {
            currencyCode: '',
            impressions: []
        }
    };

    constructor(product) {
        let ecommerceData = this.data.ecommerce;

        ecommerceData.currencyCode = product.currency;
        ecommerceData.impressions.push(new GTMProductImpressionData(product));
    }
}
// END Product Impressions

/**
 * Product Detail Impressions
 * Measure a view of product details. This example assumes the detail view occurs on pageload,
 * and also tracks a standard pageview of the details page.
 *
 * {
 *  'event': 'detailimpressions',
 *  'ecommerce': {
 *      'detail': {
 *          'actionField': {
 *              'list': 'Apparel Gallery'
 *           },
 *          // 'detail' actions have an optional list property.
 *          'products': [
 *              {
 *                  'name': 'Triblend Android T-Shirt', // Name or ID is required.
 *                  'id': '12345',
 *                  'price': '15.25',
 *                  'brand': 'Google',
 *                  'category': 'Apparel',
 *                  'variant': 'Gray'
 *              }
 *          ]
 *      }
 *  }
 * }
 */
class GTMProductDetailImpressionData {
    name = '';
    id = '';
    price = '';
    brand = '';
    category = '';
    variant = '';

    constructor(product) {
        // One of them must be given.
        if (!product.name || !product.id) {
            throw new Error('Value missing to build GTMProductDetailImpressionData: no Product Name and no Product ID given.');
        }

        this.name = product.name;
        this.id = product.id;
        this.price = product.price;
        this.brand = product.brand || BRAND;
        this.category = product.category;
        this.variant = product.variant;
    }
}

class ProductDetailImpressionEvent {
    NAME = GTM_EVENTS.product_detail_impression;

    data = {
        event: this.NAME,
        ecommerce: {
            detail: {
                actionField: {
                    list: 'Product Listing Page'
                },
                products: []
            }
        }
    };

    constructor(product) {
        let ecommerceData = this.data.ecommerce;

        ecommerceData.detail.products.push(new GTMProductDetailImpressionData(product));
    }
}
// END Product Detail Impressions

/**
 * Product Clicks
 * When a user clicks on a product link. Use the event callback datalayer variable to handle navigation
 * after the ecommerce data has been sent to Google Analytics.
 * 
 * {
 *  'event': 'clicks',
 *  'ecommerce': {
 *      'click': {
 *          'actionField': {
 *              'list': 'Search Results' // Optional list property.
 *          },
    *      'products': [{
                'name': productObj.name, // Name or ID is required.
                'id': productObj.id,
                'price': productObj.price,
                'brand': productObj.brand,
                'category': productObj.cat,
                'variant': productObj.variant,
                'position': productObj.position
                }]
            }
        },
    'eventCallback': function() {
        document.location = productObj.url
    }
    }
 * 
 */
class GTMProductClicksData {
    name = '';
    id = '';
    price = '';
    brand = '';
    category = '';
    variant = '';
    position = 0;

    constructor(product) {
        // One of them must be given.
        if (!product.name || !product.id) {
            throw new Error('Value missing to build GTMProductDetailImpressionData: no Product Name and no Product ID given.');
        }

        this.name = product.name;
        this.id = product.id;
        this.price = product.price;
        this.brand = product.brand || BRAND;
        this.category = product.category;
        this.variant = product.variant;
        this.position = product.position;
    }
}
class ProductClicksEvent {
    NAME = GTM_EVENTS.product_clicks;

    data = {
        event: this.NAME,
        ecommerce: {
            click: {
                actionField: {
                    list: 'Search Results' // Optional list property.
                },
                products: []
            }
        },
        eventCallback: function () {
            document.location = '';
        }
    };

    constructor(product) {
        let ecommerceData = this.data.ecommerce;

        ecommerceData.click.actionField.list = product.fromList;
        ecommerceData.click.products.push(new GTMProductClicksData(product));
        ecommerceData.eventCallback = function () {
            document.location = product.absoluteUrl;
        };
    }
}
// END Product Clicks

/**
 * Wrapper object used to map Commerce data to the GTM layer.
 */
class GTMOrder {
    constructor(orderNumber, accountEmail, totalAmount, totalTax, shippingAmount, currency, paymentType, coupon, billingCountryCode) {
        this.orderNumber = orderNumber;
        this.accountEmail = accountEmail;
        this.totalAmount = totalAmount;
        this.totalTax = totalTax;
        this.shippingAmount = shippingAmount;
        this.coupon = coupon;
        this.currency = currency;
        this.paymentType = paymentType;
        this.billingCountryCode = billingCountryCode;
    }
}

/**
 * Trusted Shops event
 * {
 *  ts_checkout: {
 *      'tsCheckoutOrderNr': '2020-05-21-001', // Order ID
 *      'tsCheckoutBuyerEmail': 'mein.kunde@mail.de', // Account email
 *      'tsCheckoutOrderAmount': 4005.95,  // Order Amount
 *      'tsCheckoutOrderCurrency': 'EUR',   // Currency
 *      'tsCheckoutOrderPaymentType': 'VORKASSE',    // PaymentType
 *   }
 * }
 */
class GTMTrustedShopData {
    tsCheckoutOrderNr = '';
    tsCheckoutBuyerEmail = '';
    tsCheckoutOrderAmount = '';
    tsCheckoutOrderCurrency = '';
    tsCheckoutOrderPaymentType = '';
    tsBillingCountryCode = '';

    /**
     * 
     * @param {GTMOrder} orderData 
     */
    constructor(orderData) {
        // One of them must be given.
        if (!orderData.orderNumber && !orderData.accountEmail) {
            throw new Error('Value missing to build GTMTrustedShopData: no Order Number and no Buyer Email given.');
        }

        this.tsCheckoutOrderNr = orderData.orderNumber;
        this.tsCheckoutBuyerEmail = orderData.accountEmail;
        this.tsCheckoutOrderAmount = orderData.totalAmount;
        this.tsCheckoutOrderCurrency = orderData.currency;
        this.tsCheckoutOrderPaymentType = orderData.paymentType;
        this.tsBillingCountryCode = orderData.billingCountryCode
    }
}
class TrustedShopEvent {
    NAME = GTM_EVENTS.ts_checkout;

    data = {};

    constructor(order) {
        this.data[this.NAME] = new GTMTrustedShopData(order);
    }
}
// END Trusted Shop event

/**
 * Checkout Begin UA Event
    {
        event: 'checkout',
        ecommerce: {
            checkout: {
                actionField: { step: 1, option: 'Visa' },
                products: [
                    { 
                        name: 'Triblend Android T-Shirt',
                        id: '12345'
                        price: '15.25',
                        brand: 'Google',
                        category: 'Apparel',
                        variant: 'Gray',
                        quantity: 1
                    }
                ]
            }
        },
        eventCallback: function () {
            document.location = 'checkout.html';
        }
    };
}
*/

class GTMCheckoutBeginUAProductData {
    name = '';
    id = '';
    price = '';
    brand = '';
    category = '';
    variant = '';
    quantity = 0;

    constructor(product) {
        // One of them must be given.
        if (!product.name || !product.id) {
            throw new Error('Value missing to build GTMPCheckoutBeginData: no Product Name and no Product ID given.');
        }

        this.name = product.name;
        this.id = product.id;
        this.price = product.price;
        this.brand = product.brand || BRAND;
        this.category = product.category;
        this.variant = product.variant;
        this.quantity = product.position;
    }
}

/**
 * A checkout step with the necessary data for GTM.
 */
class GTMCheckoutStep {
    constructor(step, name, url) {
        this.step = step;
        this.name = name;
        this.url = url;
    }
}
class CheckoutBeginUAEvent {
    NAME = GTM_EVENTS.checkout_begin_ua;

    data = {
        event: this.NAME,
        ecommerce: {
            checkout: {
                actionField: {
                    step: 0,
                    option: ''
                },
                products: []
            }
        },
        eventCallback: function () {
            //document.location = '';
        }
    };

    /**
     *
     * @param {GTMCheckoutStep} checkoutStepData
     * @param {Array<GTMProduct>} products
     */
    constructor(checkoutStepData, products) {
        let ecommerceData = this.data.ecommerce;

        ecommerceData.checkout.actionField.step = checkoutStepData.step;
        ecommerceData.checkout.actionField.option = checkoutStepData.name;
        products.forEach((product) => {
            ecommerceData.checkout.products.push(new GTMCheckoutBeginUAProductData(product));
        });
        ecommerceData.eventCallback = function () {
            if (checkoutStepData.url != null) {
                document.location = checkoutStepData.url;
            }
        };
    }
}
/**
 * Checkout Begin A4 Event
    {
        event: 'begin_checkout',
        ecommerce: {
            items: [{
                item_name: 'Finnish magical parka',
                item_id: 'mp1122',
                price: '31.10',
                item_brand: 'PARKA4LIFE',
                item_category: 'Apparel',
                item_category2: 'Coats',
                item_category3: 'Parkas',
                item_category4: 'Unisex',
                item_variant: 'Navy blue',
                quantity: '3'
            }]
        }
    }
*/

class EventHandler {
    // Simple caching mechanism.
    #cart = null;

    static setCart(cartData) {
        if (!cartData) {
            return;
        }

        this.cart = null;
        this.cart = cartData;
        sessionStorage.setItem('t-cartInfo', JSON.stringify(cartData));
    }

    static getCart() {
        if (!this.cart) {
            this.cart = JSON.parse(sessionStorage.getItem('t-cartInfo'));
        }
        return this.cart;
    }

    static publishEvent(component, event) {
        component.dispatchEvent(
            new CustomEvent(GTM_EVENTS_NAMES[event.data.event], {
                bubbles: true,
                composed: true,
                detail: {
                    dataLayerEvent: event
                }
            })
        );
    }

    static publishProductImpressionEvent(component, gtmProduct) {
        let event = new ProductImpressionsEvent(gtmProduct);
        this.publishEvent(component, event);
    }

    static publishProductDetailImpressionEvent(component, gtmProduct) {
        let event = new ProductDetailImpressionEvent(gtmProduct);
        this.publishEvent(component, event);
    }

    static publishAddToCartEvent(component, gtmProduct) {
        let event = new AddToCartEvent(gtmProduct);
        this.publishEvent(component, event);
    }

    static publishRemoveFromCartEvent(component, gtmProduct) {
        let event = new RemoveFromCartEvent(gtmProduct);
        this.publishEvent(component, event);
    }

    static publishViewCartEvent(component, gtmProducts) {
        let event = new GTMA4Event(GTM_EVENTS.view_cart, gtmProducts);
        this.publishEvent(component, event);
    }

    static publishProductClickEvent(component, gtmProduct) {
        let event = new ProductClicksEvent(gtmProduct);
        this.publishEvent(component, event);
    }

    // Here two events are sent as per requirement.
    static publishCheckoutBeginEvents(component, gtmCheckoutStep, gtmProducts) {
        // If no products available from the "Checkout button" context, use the cached cart info.
        if (!gtmProducts) {
            gtmProducts = this.buildGTMProductsFromCache();
        }
        let eventUA = new CheckoutBeginUAEvent(gtmCheckoutStep, gtmProducts);
        this.publishEvent(component, eventUA);

        let eventA4 = new GTMA4Event(GTM_EVENTS.checkout_begin_a4, gtmProducts);
        this.publishEvent(component, eventA4);
    }

    static publishCheckoutShippingEvent(component, shippingInfo, gtmProducts) {
        // If no products available from the "Checkout button" context, use the cached cart info.
        if (!gtmProducts) {
            gtmProducts = this.buildGTMProductsFromCache();
        }
        let eventA4 = new GTMA4ShippingEvent(shippingInfo, gtmProducts);
        this.publishEvent(component, eventA4);

        let step = new GTMCheckoutStep(2, shippingInfo, null);
        let eventUA = new CheckoutBeginUAEvent(step, gtmProducts);
        this.publishEvent(component, eventUA);
    }

    static publishCheckoutPaymentEvent(component, paymentInfo, gtmProducts) {
        // If no products available from the "Checkout button" context, use the cached cart info.
        if (!gtmProducts) {
            gtmProducts = this.buildGTMProductsFromCache();
        }
        let eventA4 = new GTMA4PaymentEvent(paymentInfo, gtmProducts);
        this.publishEvent(component, eventA4);

        let step = new GTMCheckoutStep(3, paymentInfo, null);
        let eventUA = new CheckoutBeginUAEvent(step, gtmProducts);
        this.publishEvent(component, eventUA);
    }

    static publishTrustedShopEvent(component, gtmOrder) {
        let event = new TrustedShopEvent(gtmOrder);
        this.publishEvent(component, event);
    }

    static publishPurchaseEvent(component, gtmOrder, orderItems) {
        let gtmOrderItems = this.buildGTMProductsFromOrderItems(orderItems, gtmOrder.currency)
        let event = new GTMPurchaseEvent(gtmOrder, gtmOrderItems);
        this.publishEvent(component, event);
    }

    static publishPurchaseAndTrustedShopEvents(component, gtmOrder, orderItems) {
        let gtmOrderItems = this.buildGTMProductsFromOrderItems(orderItems, gtmOrder.currency)
        let event = new GTMPurchaseEvent(gtmOrder, gtmOrderItems);
        let tsEvent = new TrustedShopEvent(gtmOrder);

        event.data[tsEvent.NAME] = tsEvent.data[tsEvent.NAME];

        this.publishEvent(component, event);
    }
    
    static publishAddToWishlistEvent(component, gtmProduct) {
        let eventA4 = new GTMA4Event(GTM_EVENTS.add_to_wishlist, [gtmProduct]);
        this.publishEvent(component, eventA4);
    }

    static buildGTMProductsFromCache() {
        return this.getCart().items.map((cartItem) => {
            return this.buildGTMProductFromCartItem(cartItem);
        });
    }

    static buildGTMProductFromCartItem(cartItem) {
        let ci = cartItem.cartItemResult.cartItem;

        let productData = {
            sku: ci.productDetails.sku,
            name: ci.productDetails.name,
            currency: this.cart.summary.currencyIsoCode,
            unitPrice: ci.salesPrice,
            quantity: ci.quantity,
            variation: null
        };

        return new GTMProduct(
            productData.sku,
            productData.name,
            productData.currency,
            productData.unitPrice,
            BRAND,
            '',
            productData.variation,
            null,
            null,
            productData.quantity
        );
    }

    static buildGTMProductsFromOrderItems(orderItems, orderCurrency){
        return orderItems.map((oi) => {
            return this.buildGTMProductFromOrderItem(oi, orderCurrency);
        })
    }

    static buildGTMProductFromOrderItem(orderItem, orderCurrency) {
        let productData = {
            sku: orderItem.product.StockKeepingUnit,
            name: orderItem.product.Name,
            currency: orderCurrency,
            unitPrice: orderItem.totalListPrice,
            quantity: orderItem.quantity,
            variation: '',
            category: '',
            brand: BRAND,
            list: '',
            position: ''
        };

        return new GTMProduct(
            productData.sku,
            productData.name,
            productData.currency,
            productData.unitPrice,
            productData.brand,
            productData.category,
            productData.variation,
            productData.list,
            productData.position,
            productData.quantity,
            null,
            null
        );
    }
}

export { EventHandler, GTMCheckoutStep, GTMOrder, GTMProduct };