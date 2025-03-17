import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import basePath from "@salesforce/community/basePath";
import getContent from "@salesforce/apex/ManagedContentController.getContent";

export default class DemoTile extends NavigationMixin(LightningElement) {
  @api contentId;
  backgroundURL;
  description;
  title;
  type;
  pageName;
  path1ContentKey;
  URL;
  btnLabel;
  modalOpen = false;

  get isModalOpen() {
    return this.modalOpen;
  }
  get isPDF(){
    return this.type === 'PDF';
  }

  @wire(getContent, {
    contentId: "$contentId",
    page: 0,
    pageSize: 1,
    language: "en_US",
    filterby: ""
  })
  results({ data, error }) {
    if (data) {
      this.title = htmlDecode(data.Title.value);
      this.description = htmlDecode(data.Tile_Description.value);
      this.type = data.Type?.value;
      this.pageName = data.Navigate_to_Page?.value;
      this.btnLabel =
        data.Button_Label_Override?.value != null
          ? data.Button_Label_Override?.value
          : "Learn More";
      this.URL = data.Video_Link?.value;
      this.backgroundURL =
        basePath + "/sfsites/c" + data.Background_Image.unauthenticatedUrl;
      this.error = undefined;
    } else if (error) {
      console.log("Error: " + JSON.stringify(error));
    }
  }

  goToFeatureDetail() {
    if (this.btnLabel !== "Coming Soon") {
      if (this.URL !== undefined) {
        this.openModal();
      } else {
        if (this.pageName === undefined) {
          this[NavigationMixin.Navigate]({
            type: "standard__managedContentPage",
            attributes: {
              contentTypeName: "Feature",
              contentKey: this.contentId
            }
          });
        } else {
          this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
              name: this.pageName
            }
          });
        }
      }
    }
  }

  get styling() {
    return (
      "background: url('" +
      this.backgroundURL +
      "') no-repeat top center;" +
      "-webkit-background-size: cover;" +
      "-moz-background-size: cover;" +
      "-o-background-size: cover;" +
      "background-size: cover;"
    );
  }

  openModal() {
    this.modalOpen = true;
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