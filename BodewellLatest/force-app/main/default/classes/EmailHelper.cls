/**
 * @description - When User Clicks on Event Record excluding profiles on Metadata, Rule will display.
 */
public class EmailHelper {
    /**
     * @description NoDeleteEvent
     * @return nothing
     */
public static void noDeleteEmail (List<EmailMessage> emails){
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
    for(EmailMessage t : emails){ 
            if(!profiles.contains(profilename)){
              t.adderror('You Do not have necessary Permission to Delete the Email');
                  }                
     }
}
}