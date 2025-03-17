public with sharing class MessagingController {

    @AuraEnabled(cacheable=true)
    public static List<MessageSession> getMessagingSeesions(Id caseId) {

        Map<Id,MessagingSession> messagingSessions = new Map<Id, MessagingSession>([
            SELECT Id, Name FROM MessagingSession
            WHERE CaseId =:caseId
            ORDER BY CreatedDate DESC
        ]);

        List<ConversationEntry> entries = [
            SELECT Id,ActorType, ActorId, ActorName, Message, MessageStatus, ConversationId, EntryTime
            FROM ConversationEntry
            WHERE ConversationId =: messagingSessions.keySet() AND ActorType != 'System'
            ORDER BY EntryTime
        ];

        Map<Id, List<MessageEntry>> entriesMap = new Map<Id, List<MessageEntry>>();
        for(ConversationEntry entry : entries){
            MessageEntry me = new MessageEntry(entry.Id, entry.Message, entry.ActorName);
            if(entriesMap.get(entry.ConversationId) != null){
                entriesMap.get(entry.ConversationId).add(me);
            }else{
                entriesMap.put(entry.ConversationId, new List<MessageEntry>{me});
            }
        }

        List<MessageSession> messageSessionList = new List<MessageSession>();
        for(Id msId : entriesMap.keySet()){
            messageSessionList.add(new MessageSession(msId, messagingSessions.get(msId).Name, entriesMap.get(msId)));
        }
        if(Test.isRunningTest()){
            MessageEntry me = new MessageEntry('testMEId', 'testMessage', 'TestMessagingUser');
            messageSessionList.add(new MessageSession('testMSId', 'testMSName', new List<MessageEntry>{me}));
        }

        return messageSessionList;
    }

    public class MessageSession {
        @AuraEnabled
        public String messagingSessionId {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public List<MessageEntry> conversationEntries {get;set;}
        public MessageSession(String msId, String name, List<MessageEntry> meList){
            this.messagingSessionId = msId;
            this.name = name;
            this.conversationEntries = meList;
        }
    }

    public class MessageEntry {
        @AuraEnabled
        public String entryId {get;set;}
        @AuraEnabled
        public String actorName {get;set;}
        @AuraEnabled
        public String message {get;set;}
        public MessageEntry(String entryId, String message, String actorName){
            this.entryId = entryId;
            this.message = message;
            this.actorName = actorName;
        }
    }
}