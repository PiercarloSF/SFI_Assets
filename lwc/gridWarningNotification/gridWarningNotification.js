import { LightningElement, api } from "lwc";

export default class GridWarningNotification extends LightningElement {
  @api message;

  get showNotification() {
    return this.message !== undefined && this.message !== "";
  }
}