/**
 * @description - When User Clicks on Event Record excluding profiles on Metadata, Rule will display.
 */
public class TaskHelper {
    /**
     * @description NoDeleteEvent
     * @return nothing
     */
       public static void noDeleteTask (List<Task> tasks){
         Id profileId=userinfo.getProfileId();
        string profileName;
       List<profile> profileList = [SELECT Id, Name FROM profile WHERE Id = :ProfileId];
        //Handling Null Pointer Exception
        if (!profilelist.isempty()){
            profileName = ProfileList[0].Name;
            }
        List<String> profiles=new List<String>();
        for(EmailDeleteProfile__mdt adu:[select Label from EmailDeleteProfile__mdt])
        {
            profiles.add(adu.Label);
        }      
        for(Task t : tasks){
             if(!profiles.contains(profilename)){
              t.adderror('You Do not have the Permission to Delete the Task');
                  }
        }

}
}