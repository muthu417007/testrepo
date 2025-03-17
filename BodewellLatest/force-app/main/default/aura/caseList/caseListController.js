({
    init: function (component, event, helper) {
        var pageReferencephone = component.get("v.pageReferencephone");
        console.log('pageReferencephone',pageReferencephone);
        var value;
 		component.set('v.mycolumns', [
            { label: 'Case Number', fieldName: 'ref_no', type: 'text'},
            { label: 'Opened On', fieldName: 'created', type: 'text'},
            { label: 'Status', fieldName: 'status_id', type: 'text'},
            { label: 'FirstName', fieldName: 'first_name', type: 'text'},
            { label: 'LastName', fieldName: 'last_name', type: 'text'}
            
        ]);
        if(sessionStorage.getItem('ccicasesearch--phone') != null)
        {
            console.log("inside ccicasesearch--phone");
           var phonenum=sessionStorage.getItem('ccicasesearch--phone');
            
            phonenum=phonenum.replace('"','');
            phonenum=phonenum.replace('"','');
            var url ='https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnectmain?phoneNumber='+phonenum; 
         	helper.getresponse(component,url); 
            //helper.action1(component,phonenum);
            sessionStorage.removeItem('ccicasesearch--phone');
        }
        else if(sessionStorage.getItem('ccicasesearch--firstname')!=null && sessionStorage.getItem('ccicasesearch--lastname')!=null && sessionStorage.getItem('ccicasesearch--zipcode')!=null)
        {
            console.log("inside init");
             var firstname= sessionStorage.getItem('ccicasesearch--firstname');
            console.log("firstname",firstname);
            
            firstname=firstname.replace('"','');
            firstname=firstname.replace('"','');
            var lastname = sessionStorage.getItem('ccicasesearch--lastname');
            console.log('lastname',lastname);
            
            lastname=lastname.replace('"','');
            lastname=lastname.replace('"','');
            var zipcode = sessionStorage.getItem('ccicasesearch--zipcode');
            console.log('zipcode',zipcode);
            
            zipcode=zipcode.replace('"','');
            zipcode=zipcode.replace('"','');
            var url1="https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnectmain?firstname="+firstname+"&lastname="+lastname+"&zipcode="+zipcode;
            console.log("calling getresp");
            helper.getresponse(component,url1); 
            console.log("calling action2");
            //helper.action2(component,firstname,lastname,zipcode);  
             
            
        }
        else if(sessionStorage.getItem('ccicasesearch--street')!=null && sessionStorage.getItem('ccicasesearch--lastname')!=null && sessionStorage.getItem('ccicasesearch--zipcode')!=null)
        {
            var street= sessionStorage.getItem('ccicasesearch--street');
            console.log("street",street);
            
            street=street.replace('"','');
            street=street.replace('"','');
            var lastname = sessionStorage.getItem('ccicasesearch--lastname');
            console.log('lastname',lastname);
            
            lastname=lastname.replace('"','');
            lastname=lastname.replace('"','');
            var zipcode = sessionStorage.getItem('ccicasesearch--zipcode');
            console.log('zipcode',zipcode);
            sessionStorage.removeItem('ccicasesearch--zipcode'); 
            zipcode=zipcode.replace('"','');
            zipcode=zipcode.replace('"','');
            
            var url2='https://m553135n3h.execute-api.us-east-1.amazonaws.com/Prod/RPCconnectmain?street='+street+'&lastname='+lastname+'&zipcode='+zipcode;
            helper.getresponse(component,url2);  
            //helper.action3(component,street,firstname,lastname);  
        }
            else{
                console.log("no values");
            }
        
    },
    handleRowAction: function (component, event, helper) {
        console.log("event",event.target.id);
        var caseID=event.target.id;
        var check =caseID.search("-");
        if(check>=1){
            console.log("caseID sending to case-details",caseID);
        	sessionStorage.setItem('ccicasesearch--recordIds', JSON.stringify(caseID));
          var navServicephcase = component.find("navServicephcase");
            var pageReferencephcase = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__customSearchResultsList'
                            }
                        };
            component.set("v.pageReferencephcase", pageReferencephcase);
            event.preventDefault();
            navServicephcase.navigate(pageReferencephcase);
        }
       
        
},
home: function (component, event, helper) {
          var navEvt = $A.get('e.force:navigateToURL');
          navEvt.setParams({url: '/'});
          navEvt.fire();
    }
})