//******************************************************************************************
// Author:       Yogesh Sharma
// Company:      TCS
// Created Date: 27/04/2023
//******************************************************************************************
//@description : Wrapper Class to handle Service Area Suggestion requests
public class RG_SuggestionAddressPayload 
{
    public List<Predictions> predictions;
    public String status;
 
    public class Predictions {
        public String description;
        public String place_id;
        public Structured_formatting structured_formatting;
    }

    public class Structured_formatting {
        public String main_text;
        public String secondary_text;
    }
}