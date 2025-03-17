/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        18.05.2021
 * @description    Class used to keep Voice Call queries
 */
public inherited sharing class CX_VoiceCallDAO {
    private static final CX_VoiceCallDAO INSTANCE = new CX_VoiceCallDAO();

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        18.05.2021
     * @description    Returns the singleton instance
     * @return         CX_VoiceCallDAO - a CX_VoiceCallDAO singleton instance
     */
	public static CX_VoiceCallDAO getInstance() {
		return INSTANCE;
	}

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        18.05.2021
     * @description    Returns the ongoing voice call for a record
     * @param          Id - Record Id
     * @return         List<VoiceCall> - A list of ongoing voice calls for the record
     */
    public List<VoiceCall> getOngoingVoiceCall(Id recordId) {
        return [
            SELECT
                RelatedRecordId,
                CallStartDateTime,
                CallEndDateTime,
                CallDurationInSeconds,
                CallDisposition,
                VendorCallKey
            FROM 
                VoiceCall
            WHERE
                Id = :recordId
                AND CallDisposition IN ('in-progress', 'new')
        ];
    }
}