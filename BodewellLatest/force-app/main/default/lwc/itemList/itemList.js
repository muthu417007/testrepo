import { LightningElement, api, track } from "lwc";
import getContentList from "@salesforce/apex/ManagedContentController.getContentList";
import FORM_FACTOR from "@salesforce/client/formFactor";
import { NavigationMixin } from "lightning/navigation";

export default class itemList extends NavigationMixin(LightningElement) {
  @api label;
  @api category;
  @api footnote;
  type = false;
  URL;
  @track links = [];

  modalOpen = false;

  connectedCallback() {
    this.getLinks();
  }

  get isPDF(){
    return this.type === 'PDF';
  }

  getLinks() {
    getContentList({
      page: 0,
      pageSize: "100",
      language: "en_US",
      filterby: "List_Item"
    })
      .then((links) => {
        links.forEach((link) => {
          if (this.category === link.contentNodes.Category.value)
            this.links.push({
              key: link.contentKey,
              title: htmlDecode(link.contentNodes.Title.value),
              URL: link.contentNodes.URL?.value,
              displayOrder: parseInt(link.contentNodes.Display_Order.value),
              type: link.contentNodes.Type.value
            });
          this.links.sort((a, b) => (a.displayOrder > b.displayOrder ? 1 : -1));
        });
      })
      .catch((error) => {
        console.log("Error: " + JSON.stringify(error));
      });
  }

  openModal(event) {
    let key = event.currentTarget.dataset.id;
    this.links.forEach((link) => {
      if (link.key === key) {
        this.URL = link.URL;
        this.type = link.type;
      }
    });
    if (this.URL !== undefined) {
      if ((this.isPDF && FORM_FACTOR === "Small")||this.type==="Link") {
        this[NavigationMixin.GenerateUrl]({
          type: "standard__webPage",
          attributes: {
            url: this.URL
          }
        }).then((url) => {
          window.open(url, "_blank");
        });
      } else {
        this.modalOpen = true;
      }
    }
  }

  closeModal() {
    this.modalOpen = false;
  }
}

//hack to remove html tags and get plain text from CMS.body.value
function htmlDecode(input) {
  var doc = new DOMParser().parseFromString(input, "text/html");
  let parsedstring = doc.documentElement.textContent;

  return parsedstring;
}