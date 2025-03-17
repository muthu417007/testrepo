trigger Event_Trigger on Event (before delete) {
      if(Trigger.isBefore){
        System.debug('Inside the Trigger');
        EventHelper.NoDeleteEvent(Trigger.Old);
    }
}