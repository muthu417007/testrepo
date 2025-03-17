public without sharing class PS_UserProvisioningService {

    private static final String STATUS_ACTIVE = 'Active';
    private static final String LINK_STATE_LINKED = 'linked';

    public PS_UserProvisioningService() {
    }

    public void createNewUserProvRequests(Map<Id, User> newUsers, Map<Id, User> oldUsers) {
        Map<Id, User> changedUsers = new Map<Id, User>();
        for (User newUser : newUsers.values()) {
            User oldUser = oldUsers.get(newUser.Id);
            if (oldUser.FirstName != newUser.FirstName ||
                    oldUser.LastName != newUser.LastName ||
                    oldUser.Email != newUser.Email) {

                changedUsers.put(newUser.Id, newUser);
            }
        }

        Set<Id> connectedAppIds = new Set<Id>();
        for (BigCommerce_Connection__c connection : PS_BigCommerceConnectionConfigHelper.getAllBigCommerceConnectionConfig()) {
            connectedAppIds.add(connection.Connected_App_Id__c);
        }

        List<UserProvAccount> userProvAccounts = [
                SELECT Id,ConnectedAppId,ExternalUserId,SalesforceUserId
                FROM UserProvAccount
                WHERE SalesforceUserId IN :changedUsers.keySet()
                AND ConnectedAppId IN :connectedAppIds
        ];

        List<UserProvisioningRequest> userProvisioningRequests = new List<UserProvisioningRequest>();
        for (UserProvAccount userProvAccount : userProvAccounts) {
            UserProvisioningRequest request = new UserProvisioningRequest();
            request.ApprovalStatus = 'NotRequired';
            request.ConnectedAppId = userProvAccount.ConnectedAppId;
            request.ExternalUserId = userProvAccount.ExternalUserId;
            request.Operation = 'Update';
            request.SalesforceUserId = userProvAccount.SalesforceUserId;
            request.State = 'New';
            request.UserProvAccountId = userProvAccount.Id;

            userProvisioningRequests.add(request);
        }

        insert userProvisioningRequests;
    }

    public Map<Id, String> getConnectedAppIdToExternalIdMap(Id sfUserId, Set<Id> connectedAppIds) {
        Map<Id, String> connectedAppIdToExternalId = new Map<Id, String>();

        for (UserProvAccount userProvAccount : [
                SELECT ConnectedAppId,ExternalUserId
                FROM UserProvAccount
                WHERE SalesforceUserId = :sfUserId
                AND LinkState = :LINK_STATE_LINKED
                AND Status = :STATUS_ACTIVE
                AND ConnectedAppId IN :connectedAppIds
        ]) {
            connectedAppIdToExternalId.put(userProvAccount.ConnectedAppId,userProvAccount.ExternalUserId);
        }

        return connectedAppIdToExternalId;
    }
}