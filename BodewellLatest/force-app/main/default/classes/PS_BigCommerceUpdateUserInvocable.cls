public with sharing class PS_BigCommerceUpdateUserInvocable {

    private static final String PUT_METHOD = 'PUT';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String APPLICATION_JSON = 'application/json';
    private static final String X_AUTH_TOKEN = 'X-Auth-Token';
    
    private static final String DEALER_ADMIN_PROFILE='Air and Water Dealer Admin';
    private static final String DEALER_NONADMIN_PROFILE='Air and Water Dealer';
	private static final String DISTRIBUTOR_ADMIN_PROFILE='Air and Water Distributor Admin';
    private static final String PLUMBER_ADMIN_PROFILE='Air and Water Plumber Admin';
    private static final String PLUMBER_PROFILE='Air and Water Plumber';
    private static final String DISTRIBUTOR_NONADMIN_PROFILE='Air and Water Distributor';
    
    private static final String ELITE_PARTNER='Elite Partner';
    private static final String PREMIER_PARTNER='Premier Partner';
    private static final String PRO_SOLUTIONS_PARTNER='Pro Solutions Partner';
    private static final String ELITE_LIFETIME='Elite Lifetime';
    private static final String MEMBER='Member';
    private static final Integer BC_MAX_API_LIMIT=10;
 

    public class UpdateUserPUTCalloutInput {
        @InvocableVariable(Required=true)
        public String endpoint;
        @InvocableVariable(Required=true)
        public String authToken;
        @InvocableVariable(Required=true)
        public String storeHash;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String firstName;
        @InvocableVariable
        public String lastName;
        @InvocableVariable(Required=true)
        public String id;
        @InvocableVariable
        public String siteName;
        @InvocableVariable
        public String userProfile;
        @InvocableVariable
        public String dealerstatus;
    }

    @InvocableMethod(Callout=true Label='Update BigCommerce User')
    public static void updateUserPUTCallout(
            List<UpdateUserPUTCalloutInput> inputs
    ) {
        UpdateUserPUTCalloutInput singleInput = inputs.get(0);
       
        String endpoint = singleInput.endpoint;
        endpoint += String.format(
                '/stores/{0}/v3/customers',
                new List<Object>{
                        singleInput.storeHash
                }
        );

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(PUT_METHOD);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.setHeader(X_AUTH_TOKEN, singleInput.authToken);

        List<CustomerPutAPIRequestWrapper> bcInputJSON = new List<CustomerPutAPIRequestWrapper>();
        for(UpdateUserPUTCalloutInput input: inputs)
        {
                CustomerPutAPIRequestWrapper requestWrapper = new CustomerPutAPIRequestWrapper();
                requestWrapper.id = Integer.valueOf(input.id);
                requestWrapper.email = input.email;
                requestWrapper.first_name = input.firstName;
                requestWrapper.last_name = input.lastName;
                System.debug('siteConfig.QualifiedApiName: ====> '+input.siteName+'');
                System.debug(' getCustomerGroupId(input.userProfile): ====> '+ input.userProfile);
                System.debug(' getCustomerGroupId(input.dealerStatus): ====> '+ input.dealerStatus);
                System.debug(' getCustomerGroupId(input.user): ====> '+ getCustomerGroupId(input.userProfile, input.dealerStatus));
                
                if(input.siteName!=null && input.siteName.contains('Air and Water'))
                    requestWrapper.customer_group_id=Integer.valueOf(getCustomerGroupId(input.userProfile, input.dealerStatus));
            
            bcInputJSON.add(requestWrapper); 
        }
        
        for(List<CustomerPutAPIRequestWrapper> vList: chunckPayload(bcInputJSON))
        {
            	System.debug('JSON REQUEST: ======>>> '+JSON.serialize(vList));
        		request.setBody(JSON.serialize(vList));
       	 		Http http = new Http();
        		http.send(request);
        }
    }

    
    public static List<List<CustomerPutAPIRequestWrapper>> chunckPayload(List<CustomerPutAPIRequestWrapper> myList){

        List<List<CustomerPutAPIRequestWrapper>> myChunks = new List<List<CustomerPutAPIRequestWrapper>>();
        List<CustomerPutAPIRequestWrapper> currentChunk = new List<CustomerPutAPIRequestWrapper>();
        
        for (CustomerPutAPIRequestWrapper obj : myList) {
        	currentChunk.add(obj);
        	if (currentChunk.size() == BC_MAX_API_LIMIT) {
        		myChunks.add(currentChunk);
        		currentChunk = new List<CustomerPutAPIRequestWrapper>();
				}
		}

		if (currentChunk.size() > 0) {
			myChunks.add(currentChunk);
		}

		System.debug('Number of chunks: ' + myChunks.size());
        return myChunks;
	}
    
    public static Integer getCustomerGroupId(String userProfile, String dealerStatus){
        if(userProfile==DISTRIBUTOR_ADMIN_PROFILE)
            return 1;
        else if(userProfile==DISTRIBUTOR_NONADMIN_PROFILE)
            return 2;
        else if(userProfile==DEALER_ADMIN_PROFILE && dealerStatus==ELITE_PARTNER)
        	return 3;
        else if(userProfile==DEALER_ADMIN_PROFILE && dealerStatus==PREMIER_PARTNER)
        	return 4;
        else if(userProfile==DEALER_ADMIN_PROFILE && dealerStatus==PRO_SOLUTIONS_PARTNER)
        	return 5;
        else if(userProfile==DEALER_NONADMIN_PROFILE && dealerStatus==ELITE_PARTNER)
        	return 6;
        else if(userProfile==DEALER_NONADMIN_PROFILE && dealerStatus==PREMIER_PARTNER)
        	return 7;
        else if(userProfile==DEALER_NONADMIN_PROFILE && dealerStatus==PRO_SOLUTIONS_PARTNER)
        	return 8;
        else if(userProfile==DEALER_NONADMIN_PROFILE && dealerStatus==MEMBER)
        	return 9;
        else if(userProfile==DEALER_ADMIN_PROFILE && dealerStatus==MEMBER)
        	return 10;
        else if(userProfile==PLUMBER_ADMIN_PROFILE && dealerStatus==MEMBER)
        	return 11;
        else if(userProfile==PLUMBER_PROFILE && dealerStatus==MEMBER)
        	return 12;
        else if(userProfile==DEALER_ADMIN_PROFILE && dealerStatus==ELITE_LIFETIME)
        	return 13;
        else if(userProfile==DEALER_NONADMIN_PROFILE && dealerStatus==ELITE_LIFETIME)
        	return 14;
        return 0;
        
    }
    
    public class CustomerPutAPIRequestWrapper {
        public Integer id;
        public String email;
        public String first_name;
        public String last_name;
        public Integer customer_group_id;
    }
}