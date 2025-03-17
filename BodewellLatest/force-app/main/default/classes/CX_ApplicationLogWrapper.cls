/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        11.05.2021
 * @description    Wrapper class for application log
 * @testClass      CX_LoggerTest
 */
public class CX_ApplicationLogWrapper {
    public String source { get; set; }
    public String sourceFunction { get; set; }
    public String referenceId { get; set; }
    public String referenceInfo { get; set; }
    public String logMessage { get; set; }
    public String payload { get; set; }
    public Exception ex { get; set; }
    public String debugLevel { get; set; }
    public String logCode { get; set; }
    public Long timer { get; set; }
}