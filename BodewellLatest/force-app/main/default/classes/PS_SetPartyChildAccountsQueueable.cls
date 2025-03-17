public class PS_SetPartyChildAccountsQueueable implements Queueable {

    public List<Account> partyChildAccounts;
    public Map<Id, Account> partyAccountsById;
    public Map<Id, Account> oldAccounts;
    public Map<Id, Account> accountsToUpdateById;

    public PS_SetPartyChildAccountsQueueable(
        List<Account> partyChildAccounts, Map<Id, Account> partyAccountsById,
        Map<Id, Account> oldAccounts, Map<Id, Account> accountsToUpdateById
    ) {
        this.partyChildAccounts = partyChildAccounts;
        this.partyAccountsById = partyAccountsById;
        this.oldAccounts = oldAccounts;
        this.accountsToUpdateById = accountsToUpdateById;
    }

    public void execute(QueueableContext context) {
        PS_RelatedAccountsPropagator.setPartyChildAccountsOnParentUpdate(
            this.partyChildAccounts, this.partyAccountsById, this.oldAccounts, this.accountsToUpdateById
        );

        PS_AccountTriggerHandler.relatedAccountsPopulated = true;
        update accountsToUpdateById.values();
    }

}