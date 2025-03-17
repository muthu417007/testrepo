public class ImageContentExtractor
{
    static string apiUrl='https://api.einstein.ai/v2/vision/ocr';
    static string token='';

    public static List<String> getImageText(String imageUrl){

        List<String> detectedText = new List<String>();
        String value = '';
        if(string.isNotBlank(imageUrl)){
            token = new EinsteinController().getAccessToken();
            String response = EinsteinOCR.extractText(imageUrl, token, 'OCRModel');

            EinsteinOCRResponse plateRespone = EinsteinOCRResponse.parse(response);
            if(plateRespone.probabilities!=null){
                for(EinsteinOCRResponse.Probability prob : plateRespone.probabilities){
                    detectedText.add(prob.label);
                }
            }
        }
        return detectedText;
    }
}