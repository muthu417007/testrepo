public class PA_CreatePortalUser implements Queueable {
   
    User existingUserDetails;
    
    public PA_CreatePortalUser(User existingUserDetails){
        this.existingUserDetails = existingUserDetails;
    }
    
    public void execute(QueueableContext context) {
        system.debug('@@@@ JIT PA - Inside Class Create User: ' +existingUserDetails);
        PA_ODPATransformation.createNewPortalUser(existingUserDetails);
    }
}