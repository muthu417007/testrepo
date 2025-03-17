public class EinsteinOCR {
    public static String VISION_API = 'https://api.einstein.ai/v2/vision/ocr';

    public static string extractText(String imageUrl, String token, String model) {

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(VISION_API);
        req.setHeader('content-type', 'multipart/form-data; charset="UTF-8"; boundary="1ff13444ed8140c7a32fc4e6451aa76d"');
        req.setHeader('Authorization', 'Bearer '+ token);
        req.setHeader('Cache-Control', 'no-cache');

        string form64 = '';
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('sampleLocation', imageUrl);
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('task', 'text');
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('modelId', model);
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);

        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        req.setBodyAsBlob(formBlob);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Content-Length', contentLength);
        req.setTimeout(60*1000);

        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        return res.getBody();
    }
}