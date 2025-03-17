({
    init: function (component, event, helper) {
        var idsJson = sessionStorage.getItem('ccicasesearch--recordIds'); 
        var caseId = idsJson.toString();
        console.log(caseId.length);
        caseId=caseId.replace('"', '');
        caseId=caseId.replace('"', '');
        console.log('caseId in custom search',caseId);
        var pageReference = component.get("v.pageReference");
        console.log('pageReference',pageReference);
        console.log('pageReference ccicasesearchcaseid',pageReference.attributes.ccicasesearchcaseid);
        var pageReferencephcase = component.get("v.pageReferencephcase");
        console.log('pageReferencephcase',pageReferencephcase);
        component.set('v.mycolumns', [
            { label: 'Activity Type', fieldName: 'c_activity_type', type: 'text'},
            { label: 'Notes', fieldName: 'notes', type: 'text'},
            { label: 'StartDate', fieldName: 'date_created', type: 'text'},
            { label: 'DueDate', fieldName: 'due_date', type: 'text'}
        ]);
         component.set('v.mycolumnsnext', [
            { label: 'Activity Type', fieldName: 'c_activity_type', type: 'text'},
            { label: 'Activity Sub-Type', fieldName: 'TypeOfConcession', type: 'text'},
            { label: 'Notes', fieldName: 'notes', type: 'text',wrapText: true },
            { label: 'Status', fieldName: 'status_id', type: 'text'},
            { label: 'Start Date', fieldName: 'date_created', type: 'text'},
            { label: 'Created By', fieldName: 'created_by', type: 'text'}
        ]);
           
        helper.getresponse(component,caseId);
        
    },
    getfscallhistory: function (component, event, helper) {
         sessionStorage.setItem('type', JSON.stringify('fscall'));
         var navServices = component.find("navServices");
        // Uses the pageReference definition in the init handler
        var pageReferences = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__callhistory'
            },
            state: {
                "firstName":"Test"
            }
        };
        component.set("v.pageReferences", pageReferences);
        console.log('pageReferencse in Source',pageReferences);
        console.log('handle click pagrefs',pageReferences)
        event.preventDefault();
        navServices.navigate({
            type: 'standard__component',
            attributes: {
                componentName: 'c__callhistory'
            },
            state: {
                "firstName":"Test"
            }
        });
    },
    getcccallhistory: function (component, event, helper) {
          sessionStorage.setItem('type', JSON.stringify('cccall'));
         var navServices = component.find("navServices");
        // Uses the pageReference definition in the init handler
        var pageReferences = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__callhistory'
            },
            state: {
                "firstName":"Test"
            }
        };
        component.set("v.pageReferences", pageReferences);
        console.log('pageReferencse in Source',pageReferences);
        console.log('handle click pagrefs',pageReferences)
        event.preventDefault();
        navServices.navigate({
            type: 'standard__component',
            attributes: {
                componentName: 'c__callhistory'
            },
            state: {
                "firstName":"Test"
            }
        });
    }
})