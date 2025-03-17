import { LightningElement,api,track,wire } from 'lwc';
import CASECOMMENT_OBJECT from '@salesforce/schema/CaseComment';
import PARENTID from '@salesforce/schema/CaseComment.ParentId';
import COMMENTBODY from '@salesforce/schema/CaseComment.CommentBody';

import createCaseComment from '@salesforce/apex/su_vf_console.SUVFConsoleController.createCaseComment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SU_CreateCaseComment extends LightningElement {
   
    @api caseId;
    @api caseComm;
    @api eventCode;
    
    @track parent;
    //@track comment = this.caseComm;
     @track checkBoxVal=false;

  
    handleIndChange(event) {
        this.caseComm = event.target.value;
    }
headerCheckoxChanged(event){
        this.checkBoxVal = event.target.checked;
    }
   

    handleClick() {
        createCaseComment({ caseId : this.caseId,comment:this.caseComm,isPublic: this.checkBoxVal})
            .then(result => {
                this.message = result;
                this.error = undefined;
                this.result = this.message;
                if(this.message !== undefined) {
                    //this.rec.ParentId = '';
                    //this.rec.CommentBody = '';
                   
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Case Comment created',
                            variant: 'success',
                        }),
                    );
                }
                // gza('linkSharingViaCaseComment', {
                //     caseId: caseId,
                //     id: result._id,
                //     caseNumber: $scope.caseNumber,
                //     subject: $scope.caseSubject,
                //     searchString: $scope.searchString || $scope.caseSubject,
                //     object: result.objName,
                //     url: result.href,
                //     title: result.highlight.TitleToDisplayString.length ? result.highlight.TitleToDisplayString[0] : '',
                //     author: window.user 
                // });
                fireEvent(null, 'trackAnalytics'+this.eventCode, {type:'linkSharingViaCaseComment', objToSend: {
                    caseId: caseId,
                    id: result._id,
                    caseNumber: $scope.caseNumber,
                    subject: $scope.caseSubject,
                    searchString: $scope.searchString || $scope.caseSubject,
                    object: result.objName,
                    url: result.href,
                    title: result.highlight.TitleToDisplayString.length ? result.highlight.TitleToDisplayString[0] : '',
                    author: window.user 
                }});
            })
            .catch(error => {
                console.log(error);
                this.error = error;
                var mssg = ''
                if(error!= '' && error.body != null && error.body.message != undefined && error.body.message != '' && error.body.message != null){
                    mssg = error.body.message;
                }else{
                    mssg = this.error;
                }
                if(this.message == undefined){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: mssg,
                            variant: 'error',
                        }),
                    );
                }
                this.message = undefined;
            });
    }
}