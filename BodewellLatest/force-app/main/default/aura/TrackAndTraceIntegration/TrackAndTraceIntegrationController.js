({
    doInit : function(component, event, helper) 
    {
        var url = 'https://dms-erp-prd-pp.geappliances.com/dms//tracktrace'
        // Check if the tacking number attribute has a value else check if trackingNumber url param has a value
        if(component.get("v.trackingNumber")!=null && component.get("v.trackingNumber")!='')
        {
            url = 'https://dms-erp-prd-pp.geappliances.com/dms/tracktrace/orderDetails?htrackingNumber='+component.get("v.trackingNumber"); 
            //window.open(url);
        }
        else if(component.get("v.pageReference").state.trackingNumber!=null && component.get("v.pageReference").state.trackingNumber!='')
        {
            url = 'https://dms-erp-prd-pp.geappliances.com/dms/tracktrace/orderDetails?htrackingNumber='+component.get("v.pageReference").state.trackingNumber;
            //window.open(url);
        }
        component.set("v.tatURL", url);
    }
})