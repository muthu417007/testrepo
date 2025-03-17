import { LightningElement, api, track } from 'lwc';
import { registerListener, fireEvent } from 'c/supubsub';

export default class SU_Pagination extends LightningElement {
    @api pagesizeadvfiltr = 10;
    showRecommendation = false;
    showAdvanceSearch = false;
    @api showPageSize = false;
    @api showPageFIlter = false;
    @api totalresults;
    @api totalpages;
    @api resultsectioncontainer;
    flag = true;
    disableNext = false;
    storeTotalPage = 0;
    showPageClass
    @api finallang;
    @api counter;
    @api endpointpagination;
    @api pagenum;
    @api pagesize;
    showResultPerPage = true;
    @api paginationlist;
    @api responselistdata;
    @api mergedresults;
    @track paginationClass="su__pagination-row footerClass"
    @api eventCode;
    @api translationObject;
    get disablePrevious() {
        return ((this.pagenum) == 1) ? true : false;
    }
    get nextPageNo() {
        return this.finallang.Next ? this.finallang.Next : 'Next';
    }
    get pageGreaterThanFour() {
        if ((this.pagenum) <= 4) {
            return false;
        }
        else {
            return true;
        }
    }
    get pageGreaterThanEqualToOne() {
        if (
            (this.totalpages - 1) == this.counter ||
            (this.totalpages - 2) == this.counter ||
            (this.totalpages - 3) == this.counter ||
            (this.pagenum == this.storeTotalPage) ||
            (this.disablePrevious == true) ||
            (this.pagenum == this.storeTotalPage - 1) ||
            (this.pagenum == this.storeTotalPage - 2) ||
            (this.pagenum == this.storeTotalPage - 3) ||
            (this.totalpages - 1 == this.pagenum) || (this.totalpages - 2 == this.pagenum) || (this.totalpages - 3 == this.pagenum) ||
            (this.storeTotalPage - 1 == this.pagenum) || (this.storeTotalPage - 2 == this.pagenum) || (this.storeTotalPage - 3 == this.pagenum)
        ) {
            return false;
        }
        else {
            return true;
        }
    }

    connectedCallback() {
        registerListener('sendpaginationdata' + this.eventCode, this.receivedPaginationData, this);
        registerListener('bigscreen' + this.eventCode, this.cssChangeForPagination, this);
    }
    cssChangeForPagination(bigscreenevent) {
        if (bigscreenevent === true) {
            this.paginationClass = "su__pagination-row footerClass su__d-flex su__justify-content-end "
        } else if (bigscreenevent === false) {
            this.paginationClass = "su__pagination-row footerClass"
        }


    }
    receivedPaginationData(data) {
        this.pagesizeadvfiltr = data.resultsPerPage;
    }
    
    closeResultPerPage() {
        this.showAdvanceSearch = !this.showAdvanceSearch;
        if(this.template.querySelector('[data-id="formBlock"]')) {
            this.template.querySelector('[data-id="formBlock"]').classList.add('mainFormDiv');
        }
    }
    toggleResultsPerPage() {
        this.showAdvanceSearch = !this.showAdvanceSearch;
        if(this.template.querySelector('[data-id="formBlock"]')) {
            if (this.showAdvanceSearch) {
                this.template.querySelector('[data-id="formBlock"]').classList.remove('mainFormDiv');
            }
            else {
                this.template.querySelector('[data-id="formBlock"]').classList.add('mainFormDiv');
            }
        }
        
    }
    onSelectChange(event) {
        if (this.resultsectioncontainer) {
            this.resultsectioncontainer.scrollTop = 0;
        }
        var selectedChange = event.currentTarget.dataset.accesskey;
        this.pagesizeadvfiltr = selectedChange;
        this.toggleResultsPerPage();
        this.pagesize = this.pagesizeadvfiltr;
        this.pagenum = 1;
        var sendData = { "pagesizeadvfiltr": this.pagesizeadvfiltr, "pagesize": this.pagesize, "pageNum": this.pagenum };
        fireEvent(null, "selectchange"+this.eventCode, sendData);
        if (this.totalpages) {
            this.storeTotalPage = this.totalpages;
        }
        this.flag = true;
    }
    
    setPagination(pagesize, pagenum) {
        var pageNumber = parseInt(pagenum);
        var total = this.totalresults;
        this.totalpages = Math.ceil(total / pagesize);
        var pageList = [];
        if (this.totalresults == 0) {
            pageList.push(pageNumber - (pageNumber - this.counter), (pageNumber + 1) - (pageNumber - this.counter), (pageNumber + 2) - (pageNumber - this.counter), (pageNumber + 3) - (pageNumber - this.counter))
            this.paginationlist = pageList;
        }
        if (this.totalpages > 0) {
            if (this.totalpages <= 4) {
                var counter = 1;
                for (; counter <= this.totalpages; counter++) {
                    pageList.push(counter);
                }
                this.paginationlist = pageList;
            }
            else {
                if (pageNumber == this.counter + 4) {
                    this.counter = pageNumber;
                }
                if (this.counter == pageNumber) {
                    for (var i = pageNumber; i <= this.totalpages; i++) {
                        if (i == pageNumber + 4) {
                            this.endpointpagination = i - 1;
                            break;
                        }
                        if ((i) == this.totalpages) {
                            pageList.push(i);
                            this.endpointpagination = this.totalpages;
                            break;
                        }
                        pageList.push(i);
                    }
                    this.paginationlist = pageList;
                }
                else {
                    if (pageNumber - (pageNumber - this.counter) == this.endpointpagination) {
                        pageList.push(pageNumber - (pageNumber - this.counter));
                    }
                    else if ((pageNumber + 1) - (pageNumber - this.counter) == this.endpointpagination) {
                        pageList.push(pageNumber - (pageNumber - this.counter), (pageNumber + 1) - (pageNumber - this.counter))

                    }
                    else if ((pageNumber + 2) - (pageNumber - this.counter) == this.endpointpagination) {
                        pageList.push(pageNumber - (pageNumber - this.counter), (pageNumber + 1) - (pageNumber - this.counter), (pageNumber + 2) - (pageNumber - this.counter))
                    }
                    else if ((pageNumber + 3) - (pageNumber - this.counter) == this.endpointpagination) {
                        pageList.push(pageNumber - (pageNumber - this.counter), (pageNumber + 1) - (pageNumber - this.counter), (pageNumber + 2) - (pageNumber - this.counter), (pageNumber + 3) - (pageNumber - this.counter))
                    }
                    this.paginationlist = pageList;
                }
            }
        }
        this.disableEnableActions(pageNumber);
    }
    disableEnableActions(pageNumber) {
        let buttons = this.template.querySelectorAll('[data-id="paginationButton"]');
        buttons.forEach(bun => {
            if (bun.value == pageNumber) {
                // bun.style = "background:#0070d2;color:#fff";
                bun.classList.add('paging_new') ;

            } else {
                // bun.style = "background:white;color:#808080";
                bun.classList.add('newPageActiveBtn');
            }
        });

    }
    renderedCallback() {
        if (this.totalpages) {
            this.storeTotalPage = this.totalpages;
        }
        if (this.pagenum == this.totalpages || this.pagenum == this.storeTotalPage) {
            this.disableNext = true;
        }
        else {
            this.disableNext = false;
        }
        if (this.pagenum < this.storeTotalPage) {
            this.disableNext = false;
        }
        let buttons = this.template.querySelectorAll('[data-id="paginationButton"]');
        buttons.forEach(bun => {
            if (bun.value == this.pagenum) {
                bun.classList.add('paging_new') ;
             //    bun.classList.remove('newPageActiveBtn')
 
             } else {
                 // bun.style = "background:white;color:#808080;outline:1px solid red";
                  bun.classList.remove('paging_new') ;
                 bun.classList.add('newPageActiveBtn');
             }
        });
    }

    pageChanged(event) {
        if(this.resultsectioncontainer){
        this.resultsectioncontainer.scrollTop = 0;
        }
        if(event.currentTarget.dataset.id == 'previous-page') {

            if (this.counter == parseInt(this.pagenum)) {
                this.counter = this.counter - 4;
                this.endpointpagination = this.counter + 3;
            }
            this.pagenum = parseInt(this.pagenum) - 1;
            this.setPagination(this.pagesize, this.pagenum)

            var sendData = { "counter": this.counter, "endpointpagination": this.endpointpagination, "pageNum": this.pagenum };
            fireEvent(null, "previousbuttoncalled"+this.eventCode, sendData);

        } else if(event.currentTarget.dataset.id == 'previous-Dots') {

            if (this.pagenum != 5) {
                this.pagenum = parseInt(this.pagenum) - (parseInt(this.pagenum) - this.counter) - 1;
            } else {
                this.pagenum = 4;
            }
            this.counter = this.counter - 4;
            this.setPagination(this.pagesize, this.pagenum)
            this.endpointpagination = this.pagenum;
            var sendData = { "pagenum": this.pagenum, "counter": this.counter, "endpointpagination": this.endpointpagination };
            fireEvent(null, "previousPagesDots"+this.eventCode, sendData);
            this.disableEnableActions(this.pagenum);

        } else if(event.currentTarget.dataset.id == 'next-Dots') {

            this.pagenum = parseInt(this.pagenum) - (parseInt(this.pagenum) - this.counter) + 4;
            if (this.pagenum == this.endpointpagination + 1) {
                this.counter = this.pagenum;
            }
            this.setPagination(this.pagesize, this.pagenum);
            var sendData = { "pageNum": this.pagenum, "counter": this.counter };
            fireEvent(null, "nextPageDots"+this.eventCode, sendData);

        } else if(event.currentTarget.dataset.id == 'next-page') {

            if (this.totalpages) {
                this.storeTotalPage = this.totalpages;
            }
            this.pagenum = parseInt(this.pagenum) + 1;
            if (this.pagenum == this.endPointPagination + 1) {
                this.counter = this.pagenum;
            }
            this.setPagination(this.pageSize, this.pagenum)
            var sendData = { "pageNum": this.pagenum, "counter": this.counter };
            fireEvent(null, "nextpageclicked"+this.eventCode, sendData);

        } else {
            // clicked pagination
            if (this.totalpages) {
                this.storeTotalPage = this.totalpages;
            }
            this.pagenum = parseInt(event.target.value);
            this.disableEnableActions(this.pagenum);
            fireEvent(null, "processme"+this.eventCode, this.pagenum);
            if (this.pagenum == this.totalpages) {
                this.totalresults = true;
                this.disableNext = true;
            }
            if (this.pagenum < this.storeTotalPage) {
                this.disableNext = false;
            }
        }
    }

}