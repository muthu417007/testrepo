import { LightningElement, track } from "lwc";
import basePath from "@salesforce/community/basePath";
import getContentList from "@salesforce/apex/ManagedContentController.getContentList";

export default class ResourceVideos extends LightningElement {
  @track videos = [];
  modalOpen = false;
  videoURL;

  connectedCallback() {
    this.getVideos();
  }

  getVideos() {
    getContentList({
      page: 0,
      pageSize: "100",
      language: "en_US",
      filterby: "Resource_Video"
    })
      .then((videos) => {
        videos.forEach((video) => {
          this.videos.push({
            key: video.contentKey,
            title: video.contentNodes.Title.value,
            styling: this.getStyling(
              `${basePath}/sfsites/c${video.contentNodes.Poster?.unauthenticatedUrl}`
            ),
            videoSRC: video.contentNodes.Video_URL?.value
          });
        });
      })
      .catch((error) => {
        console.log("Error: " + JSON.stringify(error));
      });
  }

  openModal(event) {
    let key = event.currentTarget.dataset.id;
    this.videos.forEach((video) => {
      if (video.key === key) {
        this.videoURL = video.videoSRC;
      }
    });
    if (this.videoURL !== undefined) {
      this.modalOpen = true;
    }
  }

  closeModal() {
    this.videoURL = "";
    this.modalOpen = false;
  }

  getStyling(imageURL) {
    return (
      "background: url('" +
      imageURL +
      "') no-repeat top center;" +
      "-webkit-background-size: cover;" +
      "-moz-background-size: cover;" +
      "-o-background-size: cover;" +
      "background-size: cover;"
    );
  }

  get isModalOpen() {
    return this.modalOpen;
  }
}