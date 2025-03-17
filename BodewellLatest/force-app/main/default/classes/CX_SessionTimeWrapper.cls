/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        17.05.2021
 * @description    Wrapper class for session time
 */
public with sharing class CX_SessionTimeWrapper {
    public Id caseId { get; set; }
    public Id voiceCallId { get; set; }
    public Date sessionDate { get; set; }
    public String sessionTime { get; set; }
    public Integer sessionSeconds { get; set; }
    public String status { get; set; }
    public String source { get; set; }
    public String uniqueId { get; set; }
    public Boolean isManual { get; set; }
}