({
	handleShowCreateForm : function(component) {
		let helper = this;
        let pageRef = component.get( 'v.pageReference' );
        let urlParamMap = {
            'objectname' : 'Visit',      // object whose create form to display
            'recordtypeid' : '',    // record type for new record (optional)
            'recordid' : ''         // id of record where button was clicked
        };
        let userId = $A.get("$SObjectType.CurrentUser.Id");
        let eventParamMap = {
                'defaultFieldValues' : {VisitorId:userId}
                };
         for ( let key in pageRef.state ) {
            let lowerKey = key.toLowerCase();
            if ( urlParamMap.hasOwnProperty( lowerKey ) ) {
                urlParamMap[lowerKey] = pageRef.state[key];
            }
        }
        //if($A.get("$Browser.isPhone")){
       /* if(component.get("v.IsPhone")==true){
            eventParamMap['navigationLocation'] = "LOOKUP",
                eventParamMap['panelOnDestroyCallback'] =  function(event){
            //var navEvent = $A.get("e.force:navigateToList");
            //navEvent.setParams({
                //"listViewId": null,
                //"listViewName": "All",
                //"scope": "Visit"
            //});
            //navEvent.fire();
            //}
            var urlEvent = $A.get("e.force:navigateToURL");
        if(urlEvent) {
            urlEvent.setParams({
                 "url": "/lightning/o/Visit/list?filterName=Recent"
            });
            urlEvent.fire();
        }
            }
             	//eventParamMap['navigationLocation'] = "LOOKUP",
            	//eventParamMap['panelOnDestroyCallback'] =  function(event) {
                    //$A.get('e.force:refreshView').fire(); }
        }*/
        if ( !$A.util.isEmpty( urlParamMap.objectname ) ) {
                eventParamMap['entityApiName'] = urlParamMap.objectname;
            }
        if ( !$A.util.isEmpty( urlParamMap.recordtypeid ) ) {
                eventParamMap['recordTypeId'] = urlParamMap.recordtypeid;
            }
        helper.enqueueAction( component, 'c.getFieldDescribeMap', {

            'objectName' : urlParamMap.objectname

        }).then( $A.getCallback( function( fieldDescribeMap ) {

            console.log( 'fieldDescribeMap', fieldDescribeMap );
        
        for ( let fieldName in pageRef.state ) {
            console.log('fieldName',fieldName);
            console.log( 'fieldDescribeMap', fieldDescribeMap )
            if ( fieldDescribeMap.hasOwnProperty( fieldName ) && fieldDescribeMap[fieldName].createable )
            eventParamMap.defaultFieldValues[fieldName] = pageRef.state[fieldName] || null;
                }
        $A.get( 'e.force:createRecord' ).setParams( eventParamMap ).fire();
            }));
	},

enqueueAction: function( component, actionName, params, options ) {

        let helper = this;

        return new Promise( function( resolve, reject ) {

            component.set( 'v.showSpinner', true );

            let action = component.get( actionName );

            if ( params ) {
                action.setParams( params );
            }

            if ( options ) {
                if ( options.background ) { action.setBackground(); }
                if ( options.storable )   { action.setStorable(); }
            }

            action.setCallback( helper, function( response ) {

                component.set( 'v.showSpinner', false );

                if ( component.isValid() && response.getState() === 'SUCCESS' ) {

                    resolve( response.getReturnValue() );
                    console.log('response',response.getReturnValue());

                } else {

                    console.error( 'Error calling action "' + actionName + '" with state: ' + response.getState() );

                    //helper.logActionErrors( response.getError() );

                    reject( response.getError() );

                }
            });

            $A.enqueueAction( action );

        });
    }
})