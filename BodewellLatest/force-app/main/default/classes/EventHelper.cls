/**
 * @description - When User Clicks on Event Record excluding profiles on Metadata, Rule will display.
 */
public class EventHelper {
    /**
     * @description NoDeleteEvent
     * @return nothing
     */
    public static void noDeleteEvent (List<Event> events){
         Id profileId=userinfo.getProfileId();
        string profileName;
        List<profile> profileList = [SELECT Id, Name FROM profile WHERE Id = :ProfileId];
        //Handling Null Pointer Exception
        if (!profilelist.isempty()){
            profileName = profileList[0].Name;
            }
         List<String> profiles=new List<String>();
        for(EmailDeleteProfile__mdt adu:[select Label from EmailDeleteProfile__mdt])
        {
            profiles.add(adu.Label);
        }
       
        for(Event t : events){
          if(!profiles.contains(profileName)){
              t.adderror('You Do not have the Permission to Delete the Event');
                  }
        }
            
            
}

}