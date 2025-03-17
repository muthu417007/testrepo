@isTest
global class VRAMockCallout implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        System.debug('Inside mock class');
        //if (req.getEndpoint().endsWith('test')){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Error" : "false","StatusCode" : "200","ErrorMessage" : "","Response" : [ {"ImageName" : "1619082813674","ImageID" : "1619082813674","Imagefile" : "1619082813674","Tags" : "Geolocation","OCR" : "ote f2 f4 f5 f6 f8 to 5 8 R T K H N B.","Imagesignedlink" :"https://techsee-media.s3.eu-central-1.amazonaws.com/5f1ee30c9ba3c012119c6d24.media.techsee.me/chat-history/00001033/60813dba2fc805049a7bac2a/1619082813674-client.jpeg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA2APMJPROBIOUBM7F%2F20210524%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20210524T112713Z&X-Amz-Expires=1800&X-Amz-Signature=a522ebfaf27fb4ecb39a5831543e142257416a778bc23d650240ce4ef3d0c86e&X-Amz-SignedHeaders=host","Description" : "Test"}]}');
            res.setStatusCode(200);
            return res;
        //}else{
            //HttpResponse res = new HttpResponse();
            //res.setHeader('Content-Type', 'application/json');
            //res.setBody('Test');
            //res.setStatusCode(200);
           // return res;
        //}
    }
}