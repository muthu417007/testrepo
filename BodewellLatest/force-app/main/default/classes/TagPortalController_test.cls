@isTest 
private class TagPortalController_test {
    static testMethod void test1() {
        PageReference myVfPage = Page.tagPortal;
        Test.setCurrentPage(myVfPage);
    
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('t','ymNORJny_mwhm3EhjT_ROKZet_vSzTYg~be3tSLUSSq9fF7exVBMxJlHMBH8p2rMAFrlsjBpKwOdsYjuZERDGw**');
        TagPortalController pc = new TagPortalController ();
        pc.username = 'test';
        pc.password = 'test';
        pageReference p1 = pc.login();
    }
}