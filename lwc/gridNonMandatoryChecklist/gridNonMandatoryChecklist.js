import { LightningElement, wire, api, track } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";import { subscribe, unsubscribe } from "lightning/empApi";
import updateChecklist from "@salesforce/apex/Grid_NonMandatoryChecklist.updateChecklist";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import GridContractWarningMessage from "@salesforce/label/c.GridContractWarningMessage";
import GridContractErrorMessage from "@salesforce/label/c.GridContractErrorMessage";
import validate_profile_and_user from "@salesforce/label/c.validate_profile_and_user";
import GridContarctSuccessMessage from "@salesforce/label/c.GridContarctSuccessMessage";
import GridContractNotificationTitle from "@salesforce/label/c.GridContractNotificationTitle";
import GridprofitLoss from "@salesforce/label/c.GridprofitLoss";
import Gridguarantees from "@salesforce/label/c.Gridguarantees";
import GrideconomicOffer from "@salesforce/label/c.GrideconomicOffer";
import GridsignedContract from "@salesforce/label/c.GridsignedContract";
import GridtechnicalOffer from "@salesforce/label/c.GridtechnicalOffer";
import GridvariousOffers from "@salesforce/label/c.GridvariousOffers";
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name';

const FIELDS = [
  "Contract.OwnerId",
  "Contract.Status",
  "Contract.Grid_Profit_Loss__c",
  "Contract.Grid_Signed_contract_and_attachments__c",
  "Contract.Grid_Technical_offer__c"
];
export default class GridNonMandatoryChecklist extends LightningElement {
  htmlLabels = { GridContractNotificationTitle };
  @api title;
  @api recordId;
  @track showPopup = false;
  messageRecieved;
  OwnerId;
  userId = USER_ID;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS }) getContract(
    payload
  ) {
    if (
      (payload &&
        payload.data &&
        payload.data.fields.Status.value === "Handover" &&
        !payload.data.fields.Grid_Profit_Loss__c.value &&
        !payload.data.fields.Grid_Signed_contract_and_attachments__c.value &&
        !payload.data.fields.Grid_Technical_offer__c.value) ||
      this.messageRecieved
    ) {
      this.OwnerId = payload.data.fields.OwnerId.value;
      this.showPopup = true;
    } else {
      this.showPopup = false;
    }
  }

  @track checklistItems = [
    { label: GridprofitLoss, value: "profitLoss", required: true },
    { label: Gridguarantees, value: "guarantees" },
    { label: GrideconomicOffer, value: "economicOffer" },
    { label: GridsignedContract, value: "signedContract", required: true },
    { label: GridtechnicalOffer, value: "technicalOffer" },
    { label: GridvariousOffers, value: "variousOffers" }
  ];
  @track selectedItems = [];

  channelName = "/event/Grid_NotificationEvent__e";
  subscription = {};

  connectedCallback() {
    // Subscribe to the event channel
    this.subscription = subscribe(
      this.channelName,
      -1,
      this.handleNotification.bind(this)
    ).then((response) => {
      console.log("Subscribed to channel: " + this.channelName);
    });
  }

  disconnectedCallback() {
    // Unsubscribe from the event channel
    unsubscribe(this.subscription, (response) => {
      console.log("Unsubscribed from channel: " + this.channelName);
    });
  }

  handleNotification(message) {
    this.messageRecieved = false;
    if (
      message.data.payload &&
      message.data.payload.Message__c === "showPopup"
    ) {
      this.messageRecieved = true;
    }
  }

  handleCheckboxChange(event) {
    if (event.target.checked) {
      this.selectedItems.push(event.target.value);
    } else {
      this.selectedItems = this.selectedItems.filter(
        (item) => item !== event.target.value
      );
    }
  }

  @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME] })
  userDetails({ error, data }) {
    if (data) {
      this.currentUserProfileName = getFieldValue(data, PROFILE_NAME);
    } else if (error) {
      this.error = error;
    }
  }

  handleSave() {
    if ((this.OwnerId === this.userId && this.currentUserProfileName === 'Gridspertise User') || this.currentUserProfileName === 'System Administrator' ) {
      this.submitChecklist();
    } else {
      const event = new ShowToastEvent({
          title: "Submission Error",
          message: validate_profile_and_user,
          variant: "error"
        });
        this.dispatchEvent(event);
    }
  }
  submitChecklist() {
    if (
      this.selectedItems.includes("profitLoss") &&
      this.selectedItems.includes("signedContract")
    ) {
      updateChecklist({
        recordId: this.recordId,
        selectedItems: this.selectedItems
      })
        .then(() => {
          console.log("Record updated");
          const event = new ShowToastEvent({
            title: "Success",
            message: GridContarctSuccessMessage,
            variant: "success"
          });
          this.dispatchEvent(event);
          setTimeout(function () {
            window.location.reload();
          }, 3000);
        })
        .catch((error) => {
          console.error(error);
          const event = new ShowToastEvent({
            title: "Error",
            message: GridContractErrorMessage,
            variant: "error"
          });
          this.dispatchEvent(event);
        });
    } else {
      const event = new ShowToastEvent({
        title: "Warning",
        message: GridContractWarningMessage,
        variant: "warning"
      });
      this.dispatchEvent(event);
    }
  }
}