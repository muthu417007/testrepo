@isTest
public class ProcessOrderResponseWrapperTest {
    @isTest
    public static void testWrapper() {
        // Create test data
        ProcessOrderResponseWrapper wrapper = new ProcessOrderResponseWrapper();
        ProcessOrderResponseWrapper.X_MESSAGES_ITEMs messageItem = new ProcessOrderResponseWrapper.X_MESSAGES_ITEMs();
        messageItem.MESSAGE_TEXT = 'Order processed successfully.';
        List<ProcessOrderResponseWrapper.X_MESSAGES_ITEMs> messageItems = new List<ProcessOrderResponseWrapper.X_MESSAGES_ITEMs>();
        messageItems.add(messageItem);
        ProcessOrderResponseWrapper.X_MESSAGESs messages = new ProcessOrderResponseWrapper.X_MESSAGESs();
        messages.X_MESSAGES_ITEM = messageItems;
        wrapper.X_MESSAGES = messages;
        ProcessOrderResponseWrapper.X_HEADER_RECs headerRec = new ProcessOrderResponseWrapper.X_HEADER_RECs();
        headerRec.HEADER_ID = '12345';
        headerRec.FLOW_STATUS_CODE = 'COMPLETED';
        headerRec.ORDER_NUMBER = 'ORD-12345';
        wrapper.X_HEADER_REC = headerRec;
        ProcessOrderResponseWrapper.X_LINE_TBL_ITEMs lineItem = new ProcessOrderResponseWrapper.X_LINE_TBL_ITEMs();
        lineItem.LINE_ID = '1';
        lineItem.ORDERED_ITEM = 'Product A';
        List<ProcessOrderResponseWrapper.X_LINE_TBL_ITEMs> lineItems = new List<ProcessOrderResponseWrapper.X_LINE_TBL_ITEMs>();
        lineItems.add(lineItem);
        ProcessOrderResponseWrapper.X_LINE_TBLs lineTbl = new ProcessOrderResponseWrapper.X_LINE_TBLs();
        lineTbl.X_LINE_TBL_ITEM = lineItems;
        wrapper.X_LINE_TBL = lineTbl;

        // Test the values of the wrapper object
        System.assertEquals('Order processed successfully.', wrapper.X_MESSAGES.X_MESSAGES_ITEM[0].MESSAGE_TEXT);
        System.assertEquals('12345', wrapper.X_HEADER_REC.HEADER_ID);
        System.assertEquals('COMPLETED', wrapper.X_HEADER_REC.FLOW_STATUS_CODE);
        System.assertEquals('ORD-12345', wrapper.X_HEADER_REC.ORDER_NUMBER);
        System.assertEquals('1', wrapper.X_LINE_TBL.X_LINE_TBL_ITEM[0].LINE_ID);
        System.assertEquals('Product A', wrapper.X_LINE_TBL.X_LINE_TBL_ITEM[0].ORDERED_ITEM);
    }
}