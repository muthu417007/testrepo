@isTest
public class BWC_CalendarResponseWrapperTest {
    @isTest
    public static void testWrapper() {
        // Create test data
        BWC_CalendarResponseWrapper.CalendarDate date1 = new BWC_CalendarResponseWrapper.CalendarDate();
        date1.stdate = '2023-10-21';
        date1.available = true;

        BWC_CalendarResponseWrapper.CalendarDate date2 = new BWC_CalendarResponseWrapper.CalendarDate();
        date2.stdate = '2023-10-22';
        date2.available = false;

        List<BWC_CalendarResponseWrapper.CalendarDate> calendarDates = new List<BWC_CalendarResponseWrapper.CalendarDate>();
        calendarDates.add(date1);
        calendarDates.add(date2);

        BWC_CalendarResponseWrapper wrapper = new BWC_CalendarResponseWrapper();
        wrapper.success = true;
        wrapper.error = null;
        wrapper.responseMessage = 'Success';
        wrapper.calendar_dates = calendarDates;
        wrapper.zipcode = '12345';
        wrapper.state = 'CA';
        wrapper.mode = 'Delivery';
        wrapper.deliveryAgent = 'Agent A';
        wrapper.typeOfCall = 'Outbound';
        wrapper.startDate = '2023-10-20';
        wrapper.vendorCode = 'V123';
        wrapper.accountNo = 'A456';
        wrapper.noOfDays = 2;

        // Test the values of the wrapper object
        System.assertEquals(true, wrapper.success);
        System.assertEquals(null, wrapper.error);
        System.assertEquals('Success', wrapper.responseMessage);
        System.assertEquals(calendarDates, wrapper.calendar_dates);
        System.assertEquals('12345', wrapper.zipcode);
        System.assertEquals('CA', wrapper.state);
        System.assertEquals('Delivery', wrapper.mode);
        System.assertEquals('Agent A', wrapper.deliveryAgent);
        System.assertEquals('Outbound', wrapper.typeOfCall);
        System.assertEquals('2023-10-20', wrapper.startDate);
        System.assertEquals('V123', wrapper.vendorCode);
        System.assertEquals('A456', wrapper.accountNo);
        System.assertEquals(2, wrapper.noOfDays);
    }
}