import {LightningElement, api, wire, track} from "lwc";
import {getRecord} from "lightning/uiRecordApi";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import deliveryPlanUpdated from "@salesforce/label/c.deliveryPlanUpdated";
import ErrorUpdatingDelivery from "@salesforce/label/c.ErrorUpdatingDelivery";

import getDeliveryPlans from "@salesforce/apex/Grid_DeliveryPlanController.getDeliveryPlans";
import updateDeliveryPlan from "@salesforce/apex/Grid_DeliveryPlanController.updateDeliveryPlan";

const FIELDS = ['Contract.vlocity_cmt__QuoteId__r.Grid_NumberOfHardwareProducts__c'];
const ONE_TIME = 'One time';
const MONTHLY = 'Monthly';

export default class ModifyDeliveryPlanInContract extends LightningElement {
    @api recordId;
    deliveryPlans;
    @track cardTitle = 'Generate Delivery Plan V2';
    version = 2;
    @track showModal = true;
    @track templateClass = 'template-visible';
    showInputs;
    cantGenerateDeliveryPlan;
    deliveryPlanId;
    scheduleFrequency;
    scheduleCount;
    startDate;
    endDate;


    @wire(getDeliveryPlans, {cId: "$recordId", Cversion: "$version"})
    wiredDeliveryPlans({error, data}) {
        this.deliveryPlans = data;
        if (data && data[0]) {
            this.deliveryPlanId = data[0].Id;
        } else if (error) {
            this.error = error;
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        this.scheduleFrequency = this.template.querySelector('lightning-input-field[data-name="Grid_ScheduleFrequency__c"]');
        this.scheduleCount = this.template.querySelector('lightning-input-field[data-name="Grid_ScheduleCount__c"]');
        this.startDate = this.template.querySelector('lightning-input-field[data-name="Grid_StartDate__c"]');
        let modifiedStartDate = this.startDate.value.replace(/-\d{2}$/, '-01');
        const recordInput = {
            fields: {
                Id: this.deliveryPlanId,
                Grid_ScheduleCount__c: this.scheduleCount.value,
                Grid_ScheduleFrequency__c: this.scheduleFrequency.value,
                Grid_StartDate__c: this.startDate.value,
                Grid_IsCloned__c: false,
                Grid_Start_Month__c: this.convertToMonth(new Date(modifiedStartDate).getMonth())
            }
        };
        if (this.scheduleFrequency.value === MONTHLY) {
            recordInput.fields.Grid_StartDate__c = modifiedStartDate;
        }
        updateDeliveryPlan({deliveryPlanId: this.deliveryPlanId, fieldsToUpdate: recordInput.fields})
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: deliveryPlanUpdated,
                        variant: 'success'
                    })
                );
                this.handleClose();
                location.reload();

            })
            .catch((error) => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: ErrorUpdatingDelivery + error,
                        variant: 'error'
                    })
                );
            });
    }
    scheduleFrequencyChanged(event) {
        const countField = this.template
            .querySelector('lightning-input-field[data-name="Grid_ScheduleCount__c"]');
        this.templateClass = 'template-visible';
        if (event.target.value === ONE_TIME) {
            countField.disabled = true;
            countField.value = 1;
        } else {
            countField.disabled = false;
            countField.value = '';
        }
    }

    renderedCallback() {
        const countField = this.template.querySelector('lightning-input-field[data-name="Grid_ScheduleCount__c"]');
        if (countField && this.deliveryPlans[0]?.Grid_ScheduleFrequency__c === "One time") {
            countField.disabled = true;
        }
    }

    @wire(getRecord, {recordId: "$recordId", fields: FIELDS}) loadDeliveryPlan(payload) {
        if (payload.data && payload.data.fields) {
            if (payload.data.fields.vlocity_cmt__QuoteId__r.value.fields.Grid_NumberOfHardwareProducts__c.value > 0) {
                this.showInputs = true;
                this.cantGenerateDeliveryPlan = undefined;
            } else if (payload.data.fields.vlocity_cmt__QuoteId__r.value.fields.Grid_NumberOfHardwareProducts__c.value == 0) {
                this.showInputs = false;
                this.cantGenerateDeliveryPlan = "You cannot generete a delivery plan if you don't have any hardware products added to the cart";
            }
        }
    }

    handleClose() {
        this.showModal = false;
        const event = new CustomEvent('close');
        this.dispatchEvent(event)
    }

    convertToMonth(number) {
        const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];
        return monthNames[number - 1] || '';
    }

}