public without sharing class  PA_DisablePortalUsers implements Queueable {
   
    Id UserId;
    
    public PA_DisablePortalUsers(ID UserId){
        this.UserId = UserId;
    }
    
    public void execute(QueueableContext context) {
        system.debug('@@@@ JIT PA - Inside Class Disable User: ' +UserId);
        PA_ODPATransformation.disablePortalUser(UserId);
    }
}