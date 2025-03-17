@RestResource(urlMapping='/case/*')
global class GeDelivers {
	@HttpPost
    global static wrapper doPost()
    {
        wrapper w = new wrapper();
        w.text='success';
		return w;        
    }
    
    global class wrapper
    {
        public String text {get;set;}
    }
}