({
    createUid: function (component) {
        var result = this.generateRandomUidFunc() + this.generateRandomUidFunc() + '-' + this.generateRandomUidFunc() + '-' + this.generateRandomUidFunc() + '-' + this.generateRandomUidFunc() + this.generateRandomUidFunc() + this.generateRandomUidFunc();
        return result;
    },
    generateRandomUidFunc: function () {
        return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
    },
    doInitilization: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get("c.FetchFields");
        action.setParams({
            "GlobalAction": component.get("v.GlobalAction"),
        })
        action.setCallback(this, function (a) {
            var stateStatus = a.getState();
            var result = a.getReturnValue();
            var fieldList = JSON.parse(result.fieldList);
            var fieldInfo = JSON.parse(result.fieldInfo);
            var defaultValues = JSON.parse(result.defaultValues);
            if(result !== null && result !== ''){
                var resultToPass = [];
                fieldList.forEach(function(x){
                    var def = '';
                    defaultValues.forEach(function(d){
                        if(x.layoutComponents[0].value == d.field)
                        def = d.defaultValue;
                        if(d.defaultValue.indexOf('FirstName') > -1 && x.layoutComponents[0].value.indexOf('First_Name') > -1)
                            def = fieldInfo.FirstName;
                        if(d.defaultValue.indexOf('LastName') > -1 && x.layoutComponents[0].value.indexOf('Last_Name') > -1)
                            def = fieldInfo.LastName;
                        if(d.defaultValue.indexOf('Email') > -1 && x.layoutComponents[0].value.indexOf('Email__c') > -1)
                            def = fieldInfo.Email;
                    })
                     resultToPass.push({"value": x.layoutComponents[0].value, "required": x.required, "defaultValue": def, "type": x.layoutComponents[0].details.type, "label": x.label})
                });
                component.set("v.fieldsArray",resultToPass);
                var CaseUid = helper.createUid();
                component.set("v.CaseUid",CaseUid);
                component.set("v.isLoaded", true);

            }
        })
        
        $A.enqueueAction(action);
    },
    handleSaveSuccess: function (component, event, helper) {
    },
    handleUploadFinished: function (component, event, helper) {
        
        var uploadedFiles = event.getParam("files");
        var filename = [];
        var fileIds = [];
        if((Array.from(component.get("v.getFileNames")).filter(function(x){ if(uploadedFiles.find(function(r){if(r.name == x) return r;})) return x;})).length == 0){
            for (var k in uploadedFiles) {
                filename.push(uploadedFiles[k].name);
                fileIds.push(uploadedFiles[k].documentId);
            }
            var tempNames = Array.from(component.get("v.getFileNames"));
            var tempId = Array.from(component.get("v.getFileIds"));
            tempNames = tempNames.concat(filename);
            tempId = tempId.concat(fileIds);
            component.set("v.getFileNames", []);
            component.set("v.getFileIds", []);
            component.set("v.getFileNames", tempNames);
            component.set("v.getFileIds", tempId);
        }
    },
    handleOnSubmit: function(component, event, helper) {
        component.set("v.showSpinner",true);
        var eventFields = JSON.parse(JSON.stringify(event.getParam("fields")));
        var isValidation = false;
        Array.from(component.get("v.fieldsArray")).map(function(x){
            if (x.required && !eventFields[x.value]) {
                component.set("v.showSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!!",
                    "message": "Please fill required fields then submit form",
                    "type": "info"
                });
                event.preventDefault();
                toastEvent.fire();
                isValidation = true;
            }
        })
        if(!isValidation){
            event.preventDefault();
            var confirmationArray = [{ "Issue_Question_Request__c": eventFields["Question__c"], "Description": eventFields["Description"] }];
            component.set("v.confirmationArray", []);
            component.set("v.confirmationArray", confirmationArray);
            var fieldIds = component.get("v.getFileIds") || [];
            var action = component.get("c.SaveCase");
            action.setParams({
                 "GlobalAction": component.get("v.GlobalAction"),
                "suCase": eventFields,
                "fileIds": fieldIds
            })
            action.setCallback(this, function (a) {
                var stateStatus = a.getState();
                component.set("v.showMessage", true);
                var result = JSON.parse(a.getReturnValue());
                var recordId = result.recordID;
                var caseNumber = result.caseNumber;
                var analyticsCmp = component.find("SuAnalytics");
                if(component.get("v.conversionString") != component.get("v.searchString") || !component.get("v.conversion"))
                    var auramethodResult1 = analyticsCmp.analytics('search',{searchString: component.get("v.searchString"),result_count: component.get("v.conversionData").result_count ,page_no: "1","platformId":component.get("v.conversionData").platformId,"filter": ""});
                
                var auramethodResult = analyticsCmp.analytics('caseCreated', { 'caseUid': component.get("v.CaseUid") });
                var communityUrl = window.location.href.split('/s/')[0] + '/s/case/' + recordId;
                component.set("v.caseRedirectUrl", communityUrl);
                
                if (result !== null && result !== '') {
                    component.set("v.showSpinner", false);
                    component.set("v.caseNumber", caseNumber);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "has to be defined due to toast event validation, but isn't used.",
                        "messageTemplate": "Your case '{0}' has been created successfully.",
                        "messageTemplateData": [{
                            label: component.get("v.caseNumber"),
                            url: component.get("v.caseRedirectUrl")
                        }],
                        "type": 'success'
                    });
                    toastEvent.fire();
                }
            })
            $A.enqueueAction(action);
        }
        
    },
    getSplice: function (newProduct,event) {
        var ind=newProduct.findIndex(res=>res.type==event)    
        if(ind>-1)
            newProduct.splice(ind,1)
            },
    getResults: function (component, event, helper) {
        
        
        var defaultValues = component.get("v.DefaultAggregation");
        var newProduct = component.get("v.newProduct");
        ////////////////for product///
        var data=event.getParam("value");
        var dataa=event.getSource().get("v.fieldName")
        if (event.getSource().get("v.fieldName") == 'Product_Platform__c' && event.getParam("value") =='') {
            // var ind=newProduct.findIndex(res=>res.type=='Service_category_flat')    
            //if(ind>-1)
            newProduct=[]
            newProduct = JSON.stringify(newProduct);
            component.set("v.aggregationFilter", newProduct)
            var child = component.find("listResults");
            var data = { "searchString": component.get("v.searchString"), "pageSize": 10, "aggregation": newProduct };
            child.suggestedResult(data);
            
        }
        if (event.getSource().get("v.fieldName") == 'Product_Platform__c' && event.getParam("value") !='') {
            
            var check = false;
            this.getSplice(newProduct,'Service_Products_category_nested')
            newProduct.push({ 'type': 'Service_Products_category_nested', 'filter':[],'children':[{"childName":event.getParam("value"),"level":"2","path":["All"]}] })
            newProduct = JSON.stringify(newProduct);
            component.set("v.aggregationFilter", newProduct)
            var child = component.find("listResults");
            var data = { "searchString": component.get("v.searchString"), "pageSize": 10, "aggregation": newProduct };
            child.suggestedResult(data);
            
        }
        if (event.getSource().get("v.fieldName") == 'User_Type_Support_Center__c' && event.getParam("value") =='')
        {
            this.getSplice(newProduct,'User_Type_category_flat')
            newProduct = JSON.stringify(newProduct);
            component.set("v.aggregationFilter", newProduct)
            var child = component.find("listResults");
            var data = { "searchString": component.get("v.searchString"), "pageSize": 10, "aggregation": newProduct };
            child.suggestedResult(data);                 
        }
        ////////////////for User Type///
        if (event.getSource().get("v.fieldName") == 'User_Type_Support_Center__c' && event.getParam("value") !='') {
            // var newProduct = [];
            var check = false;
            this.getSplice(newProduct,'User_Type_category_flat')
            newProduct.push({ 'type': 'User_Type_category_flat', 'filter':[event.getParam("value")] })
            newProduct = JSON.stringify(newProduct);
            component.set("v.aggregationFilter", newProduct)
            var child = component.find("listResults");
            var data = { "searchString": component.get("v.searchString"), "pageSize": 10, "aggregation": newProduct };
            child.suggestedResult(data);
            
        }
        if (event.getSource().get("v.fieldName") == 'Access_route__c' && event.getParam("value") =='')
        {
            this.getSplice(newProduct,'Access_Route_category_flat')
            newProduct = JSON.stringify(newProduct);
            component.set("v.aggregationFilter", newProduct)
            var child = component.find("listResults");
            var data = { "searchString": component.get("v.searchString"), "pageSize": 10, "aggregation": newProduct };
            child.suggestedResult(data);                 
        }
        ////////////////for Access Route///
        if (event.getSource().get("v.fieldName") == 'Access_route__c' && event.getParam("value") !='') {
            //  var newProduct = [];
            this.getSplice(newProduct,'Access_Route_category_flat')
            newProduct.push({ 'type': 'Access_Route_category_flat', 'filter':[event.getParam("value")] })
            newProduct = JSON.stringify(newProduct);
            component.set("v.aggregationFilter", newProduct)
            var child = component.find("listResults");
            var data = { "searchString": component.get("v.searchString"), "pageSize": 10, "aggregation": newProduct };
            child.suggestedResult(data);
            
        }
        
        if (event.getSource().get("v.fieldName") == 'Question__c' || event.getSource().get("v.fieldName") == 'Model_Number__c') {
            if(event.getParam("value").length)
                if(defaultValues && defaultValues.length){
                    defaultValues = defaultValues.split(',');
                    var defaultAggregation = [{ 'type': '_type', 'filter': defaultValues}]
                    }
            if(defaultValues)
                component.set("v.aggregationFilter", defaultValues)
                var timer = component.get('v.timer');
            clearTimeout(timer);
            
            timer = window.setTimeout(
                $A.getCallback(function() {
                    if(event.getSource().get("v.fieldName") == 'Question__c' )
                    {
                        component.set("v.Subject",event.getParam("value"));
                        var searchstring = component.get("v.Subject");
                        component.set("v.searchString", searchstring);
                    }
                    else
                    {
                        var searchstring = component.get("v.Subject")?(component.get("v.Subject")+event.getParam("value")):event.getParam("value");
                        component.set("v.searchString", searchstring);
                    }
                    
                    var child = component.find("listResults");
                    var data = { "searchString": component.get("v.searchString"), "pageSize": 10, "aggregation": component.get("v.aggregationFilter") };
                    child.suggestedResult(data);
                    clearTimeout(timer);
                }), 400);
            
            component.set('v.timer', timer);
            
        }
        
    },
    handleOpenResults: function (component, event, helper) {
        var componentAttr = event.getParam("listComponentData");
        var title = componentAttr.title;
        var key = componentAttr.accessKey;
        var dataLink = componentAttr.href;
        if(componentAttr && !componentAttr.conversion){
            var conversionData = JSON.parse(JSON.stringify(componentAttr));
            if(conversionData.conversionString)
                component.set("v.conversionString", conversionData.conversionString); 
            component.set("v.conversionData", conversionData);
            if(conversionData.conversion)
                component.set("v.conversion", true);
        }else{
            component.set("v.searchResultId", '');
            component.set("v.searchResultId", key);
            component.set("v.searchResultUrl", dataLink);
            component.set("v.searchResultTitle", title);
            component.set("v.ModalOpen", true);
            component.set("v.resolvedResult", false);
            if(componentAttr.conversion)
                component.set("v.conversion", true);
            if(componentAttr.conversionString)
                component.set("v.conversionString", componentAttr.conversionString); 
            
        }
    },
    handleResolved: function (component, event, helper) {
        var title = component.get("v.searchResultTitle");
        var subject = component.get("v.searchString");
        var artLink = component.get("v.searchResultId");
        var childCmp = component.find("SuAnalytics");
        var auramethodResult = childCmp.analytics('caseDeflection',{'t': title,"searchString":subject,"url":artLink});
        component.set("v.resolvedResult", true);
    },
    handleUnResolved: function (component, event, helper) {
        component.set("v.resolvedResult", true);
    }
})