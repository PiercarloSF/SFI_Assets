import { LightningElement, api, wire, track } from "lwc";
import { getRecord} from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import getDeliveryPlans from "@salesforce/apex/Grid_DeliveryPlanController.getDeliveryPlans";
//const FIELDS = [ 'Contract.vlocity_cmt__QuoteId__r.Grid_NumberOfHardwareProducts__c'];
//const STATUS_FIELDS = ['Contract.Status'];

export default class ModifyDeliveryPlanInContract extends LightningElement {
  @api recordId;
  //@track deliveryPlans;
  @track showmodal=true;
  @track cardTitle='Generate/Refresh';
  //contractStatus;
  //version;

  showInputs;
  //cantGenerateDeliveryPlan;
  /*
  connectedCallback() {
    //retrieve contract status first before executing wiredDeliveryPlans
    if(this.contractStatus == 'Activated'){
      this.version = 2;
    }else{
      this.version = 1;
    }
  }
  */
  @wire(getRecord, { recordId: "$recordId", fields: STATUS_FIELDS })
  //contractStatus;
  //@wire(getDeliveryPlans, { cId: "$recordId" , Cversion:"$version" })
  wiredDeliveryPlans({ error, data }) {
    console.log(this.recordId);
    if (data && data[0]) {
//      this.deliveryPlans = [...data];
    } else if (error) {
      this.error = error;
    }
  }

  handleSubmit(event) {
    event.preventDefault(); 
    const fields = event.detail.fields; 
    this.template.querySelector('lightning-record-edit-form').submit(fields);
    const evt = new ShowToastEvent({
        title: "Success!",
//        message: "The Delivery Plan's record has been successfully saved.",
        variant: "success",
    });
    this.dispatchEvent(evt);
    this.showmodal=false;
  }
/*
  scheduleFrequencyChanged(event){
    const countField = this.template.querySelector('lightning-input-field[data-name="Grid_ScheduleCount__c"]');
    if(event.target.value == "One time"){
      if (countField) {
        countField.disabled = true;
        countField.value = 1;
      }
    } else {
      if (countField) {
        countField.disabled = false;
        countField.value = '';
      }
    } 
  }

  renderedCallback() {
    const countField = this.template.querySelector('lightning-input-field[data-name="Grid_ScheduleCount__c"]');
    if (countField && this.deliveryPlans[0]?.Grid_ScheduleFrequency__c === "One time") {
      countField.disabled = true;
  } 
  }
 */ 
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS }) loadDeliveryPlan(payload) {
    if(payload.data && payload.data.fields){
//    if (payload.data.fields.vlocity_cmt__QuoteId__r.value.fields.Grid_NumberOfHardwareProducts__c.value > 0) {
      this.showInputs = true;
      this.cantGenerateDeliveryPlan = undefined;
//    } else if(payload.data.fields.vlocity_cmt__QuoteId__r.value.fields.Grid_NumberOfHardwareProducts__c.value == 0) {
//      this.showInputs = false;
//      this.cantGenerateDeliveryPlan = "You cannot generete a delivery plan if you don't have any hardware products added to the cart";
//    } 
  }
  }


}