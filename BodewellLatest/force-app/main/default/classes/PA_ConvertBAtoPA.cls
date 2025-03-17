public class PA_ConvertBAtoPA  implements Queueable  {
    
     String OriginalContactId;
     ID personAccRecordTypeId;
     User existingUserDetails;
    
     public PA_ConvertBAtoPA(String OriginalContactId, Id personAccRecordTypeId, User existingUserDetails ){
         this.OriginalContactId = OriginalContactId;
         this.personAccRecordTypeId = personAccRecordTypeId;
         this.existingUserDetails = existingUserDetails;
     }
    
     public void execute(QueueableContext context) {
        system.debug('@@@@ JIT PA - Inside Class Transform Ba to PA:ContactId: ' +OriginalContactId);
        system.debug('@@@@ JIT PA - Inside Class Transform Ba to PA:RecordtypeId: ' +personAccRecordTypeId);
        PA_ODPATransformation.convertBAtoPA(OriginalContactId, personAccRecordTypeId, existingUserDetails);
     }

}