/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        22.06.2021
 * @description    Wrapper class for the Contact creation process
 */
public with sharing class CX_ContactCreationWrapper {
    public String street { get; set; }
    public String zip { get; set; }
    public String phone { get; set { phone = CX_Utils.removeNumberFormatting(value); } }
    public String email { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public Boolean unknownAddress { get; set; }
    public Boolean usePhoneField { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String country { get; set; }
}