//******************************************************************************************
//Name : BDWPagedirections
//Requirement : Get redirection for 404 page not found
//******************************************************************************************
//History
//	Version				Author					Date				Detail
//  1.0					Akhil Raj			12/14/2022			Initial
//******************************************************************************************
//@description : To get redirection for 404 page not found
public class BDWPagedirections {
    //@description : get redirection for 404 page not found
	public PageReference urlRedirection() {
          string url = System.Label.Bodewell_PageNotFound_URL;
          PageReference page = new PageReference(url);
          page.setRedirect(true);
          return page;
    }
}