import { LightningElement, api  } from 'lwc';
import getPlaceDetails from '@salesforce/apex/BWC_LocationController.getPlaceDetails';
import getPlaceDetailsByLatLong from '@salesforce/apex/BWC_LocationController.getPlaceDetailsByLatLong';


export default class Bwc_StoreLocator extends LightningElement {

    productImage = '';
    productDescription = '';
    zoomLevel = 10;
    listView = 'hidden';
    //listView = 'visible';
    mapMarkers;
    mapLoaded = false;
    markersTitle = 'Coordinates for Centering';
    //currentLatitude = 35.213989;
    currentLatitude;
    //currentLongitude = -80.9886174;
    currentLongitude;
    currentLoc;
    storePoints = [];
    storeInfoOpened = false;
    storeOfferOpened = false;
    searchingStoreDetails = true;
    hasStore = false;
    mobmapview = false;
    storeInfo;
    currentPlaceId;
    storeDirection;
    offerMode = false;
    minWidthAdded = false;
    zipLocation;

    get storeListView() {
        if (!this.searchingStoreDetails && this.mobmapview) {
            return true;
        } else {
            return false;
        }
    }

    connectedCallback() {
        this.handleUseCurrentLocation();
        this.mapLoaded = true;
    }

    renderedCallback() {
        if (!this.minWidthAdded) {
            const style = document.createElement('style');
            style.innerText = `.slds-map {
                            min-width: 0 !important;
                            }`;
            this.template.querySelector('lightning-map').appendChild(style);
            this.minWidthAdded = true;
        }
    }


    handleMobMapView() {
        this.mobmapview = !this.mobmapview;
        // if(this.mobmapview) {
        //     this.template.querySelector('lightning-map').classList.add('map-max-height');
        // } else {
        //     this.template.querySelector('lightning-map').classList.remove('map-max-height');
        // }
    }

    setMapMarkers() {
        this.mapMarkers = this.storePoints.map((item, index) => {
            return {
                location: item.location,
                title: item.title,
                description: item.description
            }
        });
    }

    locationSearchHandler(e) {
        if (e.detail && e.detail.item && e.detail.item.place_id) {
            this.getGeoLocation(e.detail.item.place_id);
            this.currentLoc = e.detail.item.main_text;
        } else {
            console.error('Invalid search', e);
        }
    }

    handleStoreInfo(e) {
        let storeId = e.currentTarget.dataset.id;
        this.storeInfo = this.storePoints.filter(item => item.id == storeId)[0];
        this.handleStoreInfoModal();
    }

    handleStoreInfoModal() {
        if (this.storeOfferOpened) {
            this.storeOfferOpened = false;
        }
        this.storeInfoOpened = !this.storeInfoOpened;
        if (this.storeInfoOpened) {
            const body = document.body;
            body.style.height = '100vh';
            body.style.overflowY = 'hidden';
        } else {
            const body = document.body;
            body.style.height = '';
            body.style.overflowY = '';
        }
    }

    handleStoreOffer(e) {
        let storeId = e.currentTarget.dataset.id;
        this.storeInfo = this.storePoints.filter(item => item.id == storeId)[0];
        this.handleStoreOfferModal(true);
    }

    handleStoreOfferModal(offerMode) {
        if (this.storeInfoOpened) {
            this.storeInfoOpened = false;
        }
        this.offerMode = offerMode;
        this.storeOfferOpened = !this.storeOfferOpened;
        if (this.storeOfferOpened) {
            const body = document.body;
            body.style.height = '100vh';
            body.style.overflowY = 'hidden';
        } else {
            const body = document.body;
            body.style.height = '';
            body.style.overflowY = '';
        }
    }

    scheduleAppointment(e) {
        let storeId = e.currentTarget.dataset.id;
        this.storeInfo = this.storePoints.filter(item => item.id == storeId)[0];
        this.handleStoreOfferModal(false);
    }

    getGeoLocation(placeId) {
        this.searchingStoreDetails = true;
        this.hasStore = false;
        getPlaceDetails({ placeId: placeId })
            .then(response => {
                if (response.success && response.data.length > 0) {
                    this.searchingStoreDetails = false;
                    this.hasStore = true;
                    this.setStoreInfo(response);
                } else {
                    this.searchingStoreDetails = false;
                    this.storePoints = [];                    
                    this.setMapMarkers();
                    this.handleUseCurrentLocation();
                    console.log('No locations.');
                }
            }).catch(error => {
                console.error('error : ', error);
            });
    }

    getCurrentGeoLocation(lat, lon) {
        this.searchingStoreDetails = true;
        this.hasStore = false;
        getPlaceDetailsByLatLong({ latValue: lat, lonValue: lon })
            .then(response => {
                if (response.success && response.data.length > 0) {
                    this.searchingStoreDetails = false;
                    this.hasStore = true;
                    this.setStoreInfo(response);
                } else {
                    this.searchingStoreDetails = false;
                    this.storePoints = [];                   
                    this.setMapMarkers();
                    this.handleUseCurrentLocation();
                    console.log('No locations.');
                }
            }).catch(error => {
                console.error('error : ', error);
            });
    }

    setStoreInfo(response) {
        this.storePoints = response.data.map((item, index) => {
            return {
                location: {
                    Street: item.store.ShippingStreet ? item.store.ShippingStreet : '',
                    City: item.store.ShippingCity ? item.store.ShippingCity : '',
                    State: item.store.ShippingState ? item.store.ShippingState : ''
                },
                title: item.store.Doing_Business_As_DBA__c ? item.store.Doing_Business_As_DBA__c : '',
                address: item.store.ShippingStreet + ', ' + item.store.ShippingCity + ', ' + item.store.ShippingState + ', ' + item.store.ShippingPostalCode,
                description: '',
                email: 'test@test.com',
                phone: item.store.Phone ? item.store.Phone : '',
                phoneLink: item.store.Phone ? 'tel:' + item.store.Phone : '',
                weblink: item.store.Website ? item.store.Website : '',
                distance: item.dist ? Math.round(item.dist * 100) / 100 : '',
                storeStatus: item.storeHours ?  this.getStoreTimingStatus(item.storeHours) : '',
                promoName: item.storePromotion ? item.storePromotion[0].promotionname : '',
                promoCode: item.storePromotion ? item.storePromotion[0].promotiontext : '',
                promoTerms: item.storePromotion ? item.storePromotion[0].promotionTerms : '',
                disablePromoCode: item.storePromotion ? false : true,
                servicesOffered: null,
                img: item.store.Seller_Logo__c ? item.store.Seller_Logo__c : '',
                direction: this.getStoreDirection(item.store),
                acceptAppointment: item.store.AcceptAppointment__c,
                storeService: item.storeService ? item.storeService : [],
                ind: index + 1,
                id: item.store.Id ? item.store.Id : ''
            }
        });
        this.storePoints.sort((a, b) => (a.distance > b.distance) ? 1 : ((b.distance > a.distance) ? -1 : 0));
        this.setMapMarkers();
    }

    getStoreDirection(storeInfo) {
        let dest = storeInfo.Party_Name__c + ', ' + storeInfo.ShippingStreet + ', ' + storeInfo.ShippingCity + ', ' + storeInfo.ShippingState + ', ' + storeInfo.ShippingPostalCode;
        return 'https://www.google.com/maps/dir/?api=1&origin=' + encodeURIComponent(this.currentLoc) + '&destination=' + encodeURIComponent(dest) + '&travelmode=driving';
    }

    handleUseCurrentLocation() {
        if (localStorage.getItem("zipcode") === null) {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(position => {
                    this.currentLatitude = position.coords.latitude;
                    this.currentLongitude = position.coords.longitude;
                    this.currentLoc = this.currentLatitude + ',' + this.currentLongitude;
                    this.getCurrentGeoLocation(this.currentLatitude, this.currentLongitude);
                    this.mapMarkers = [{
                        location: {
                            Latitude: position.coords.latitude,
                            Longitude: position.coords.longitude
                        },
                        mapIcon: {
                            path: 'M 125,5 155,90 245,90 175,145 200,230 125,180 50,230 75,145 5,90 95,90 z',
                            fillColor: 'blue',
                            fillOpacity: .8,
                            strokeWeight: 0,
                            scale: .10,
                            anchor: { x: 122.5, y: 115 }
                        }
                    }];
                });
            }
        } else {
            let zipCodeInfo = JSON.parse(localStorage.getItem('zipcode'));
            let ziplocation = {
                Street: zipCodeInfo.City,
                City: zipCodeInfo.City,
                State: zipCodeInfo.State
            };
            this.currentLoc = zipCodeInfo.City + ',' + zipCodeInfo.State + ',' + zipCodeInfo.Country;
            this.zipLocation = zipCodeInfo.Zipcode;
            this.mapMarkers = [{
                location: ziplocation,
                mapIcon: {
                    path: 'M 125,5 155,90 245,90 175,145 200,230 125,180 50,230 75,145 5,90 95,90 z',
                    fillColor: 'blue',
                    fillOpacity: .8,
                    strokeWeight: 0,
                    scale: .10,
                    anchor: { x: 122.5, y: 115 }
                }
            }];
        }



    }

    getNextDate(today, input) {
        let tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);
        let tomorrowinfo = input.filter(item => item.dayOfWeek == tomorrow.toLocaleString('en-us', { weekday: 'long' }))[0];
        if (tomorrowinfo.type == 'Holiday') {
            this.getNextDate(tomorrow);
        } else {
            return tomorrowinfo;
        }
    }

    formatAMPM(date) {
        var hours = date.getHours();
        var minutes = date.getMinutes();
        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0' + minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        return strTime;
    }

    getStoreTimingStatus(input) {
        let currentD = new Date();
        let currentinfo = input.filter(item => item.dayOfWeek == currentD.toLocaleString('en-us', { weekday: 'long' }))[0];
        let nextdayinfo = this.getNextDate(currentD, input);
        let nextstart = nextdayinfo.strStartTime.split(':');
        let nextstartTime = new Date();
        nextstartTime.setHours(nextstart[0], nextstart[1]);
        let nextDayOfWeek = nextdayinfo.dayOfWeek.substring(0, 3);
        if (currentinfo.type == 'Holiday') {
            return {
                isOpened: false,
                isClosing: false,
                isOpening: false,
                nextDayStarting: this.formatAMPM(nextstartTime)
            }

        } else {
            let start = currentinfo.strStartTime.split(':');
            let end = currentinfo.strEndTime.split(':');
            let startTime = new Date();
            startTime.setHours(start[0], start[1]);
            let nearStartTime = new Date();
            nearStartTime.setHours(Number(start[0]) - 1, start[1]);
            let endTime = new Date();
            endTime.setHours(end[0], end[1]);
            let nearEndTime = new Date();
            nearEndTime.setHours(Number(end[0]) - 1, end[1]);
            if (currentD >= startTime && currentD < endTime && currentD > nearEndTime) {
                return {
                    isOpened: true,
                    isClosing: true,
                    isOpening: false,
                    closingTime: this.formatAMPM(endTime),
                    nextDayStarting: this.formatAMPM(nextstartTime),
                    nextDayOfWeek: nextDayOfWeek
                }
            } else if (currentD >= startTime && currentD < endTime) {
                return {
                    isOpened: true,
                    isClosing: false,
                    isOpening: false,
                    closingTime: this.formatAMPM(endTime),
                }
            } else if (currentD < startTime && currentD >= nearStartTime) {
                return {
                    isOpened: false,
                    isClosing: false,
                    isOpening: true,
                    openingTime: this.formatAMPM(startTime),
                    nextDayStarting: this.formatAMPM(nextstartTime),
                    nextDayOfWeek: nextDayOfWeek
                }
            } else {
                return {
                    isOpened: false,
                    isClosing: false,
                    isOpening: false,
                    nextDayStarting: this.formatAMPM(nextstartTime),
                    nextDayOfWeek: nextDayOfWeek
                }
            }
        }
    }
}