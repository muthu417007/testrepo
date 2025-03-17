trigger Email_Trigger on EmailMessage (before delete) {
     if(Trigger.isBefore){
        System.debug('Inside the Trigger');
        EmailHelper.NoDeleteEmail(Trigger.Old);
    }
}