import {FlexCardMixin} from "vlocity_cmt/flexCardMixin";
import {api, LightningElement, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getDataHandler} from "vlocity_cmt/utility";
import {getRecord, createRecord, updateRecord } from "lightning/uiRecordApi";

const ONE_TIME='One time';
const MONTHLY='Monthly';
const FIELDS = ["Quote.Grid_NumberOfHardwareProducts__c"];
const DP_API = 'DeliveryPlan__c';

export default class MyRecordEditForm extends FlexCardMixin(LightningElement) {
@api recordId;
@track planId;
@track showmodal= true;
@track templateClass = 'template-visible';
data;
QId;
@track cardTitle='Generate Delivery Plan';
handleSuccess (){
const evt = new ShowToastEvent({
    title: "Success!",
    message: "The Delivery Plan's record has been successfully saved.",
    variant: "success",
});
this.dispatchEvent(evt);
this.handleClose();
}

handleSubmit(event) {
    this.scheduleFrequency = this.template.querySelector('lightning-input-field[data-name="Grid_ScheduleFrequency__c"]');
    this.scheduleCount = this.template.querySelector('lightning-input-field[data-name="Grid_ScheduleCount__c"]');
    this.startDate = this.template.querySelector('lightning-input-field[data-name="Grid_StartDate__c"]');
    if (this.scheduleFrequency.value === MONTHLY) {
        event.preventDefault();
        let modifiedStartDate = this.startDate.value.replace(/-\d{2}$/, '-01');
        const fields = {
            Id : this.planId,
            Grid_ScheduleCount__c: this.scheduleCount.value,
            Grid_ScheduleFrequency__c: this.scheduleFrequency.value,
            Grid_StartDate__c: modifiedStartDate,
            Grid_Start_Month__c: this.convertToMonth(new Date(modifiedStartDate).getMonth()),
        };
        const recordInput = { apiName: DP_API, fields };
        if (!this.planId) {
            fields['Grid_Quote__c'] = this.recordId;
            createRecord( recordInput )
                .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Delivery Plan created successfully.",
                        variant: "success"
                    })
                );
                this.handleClose();
            }).catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error creating Delivery Plan:' + error,
                        variant: 'error'
                    })
                );
            });
        } else {
            fields['Id'] = this.planId;
            const recordInput = {fields};
            updateRecord(recordInput)
                .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Delivery Plan updated successfully.",
                        variant: "success"
                    })
                );
                this.handleClose();
                location.reload();
            }).catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error updating Delivery Plan: ' + error,
                        variant: 'error'
                    })
                );
            });

        }
    }
}
//Call Dataraptor
connectedCallback(){
    const options = {
            "isDebug": true,
            "chainable": false,
            "resetCache": false,
            "ignoreCache": true,
            "queueableChainable": false,
            "useQueueableApexRemoting": false
        }
       const id = {
            "QId": this.recordId
        }
        /*const datasource = JSON.stringify({
            type: 'dataraptor',
            value: {
                bundleName: 'DREFetchDeliveryPlanId',  //This will be dataraptor name
                inputMap: id,
                optionsMap: options
            }
        });*/
        const datasource = JSON.stringify({
            type: 'dataraptor',
            value: {
                bundleName: 'DREQuoteLineItemDetailsV2',  //This will be dataraptor name
                inputMap: id,
                optionsMap: options
            }
        });
        getDataHandler(datasource).then(result => {
            if(JSON.parse(result)[0].size>0)
            {
            this.planId =JSON.parse(result)[0].deliveryPlanId;
            }
        })
        .catch(() => {
        });
    }
scheduleFrequencyChanged(event) {
    const countField = this.template
        .querySelector('lightning-input-field[data-name="Grid_ScheduleCount__c"]');
    if (event.target.value === ONE_TIME) {
        countField.disabled = true;
        countField.value = 1;
    } else {
        countField.disabled = false;
        countField.value = '';
    }
}
showInputs;
cantGenerateDeliveryPlan;
@wire(getRecord, { recordId: "$recordId", fields: FIELDS }) getQuote(
  payload
) {
  if (
    payload.data &&
    payload.data.fields &&
    payload.data.fields.Grid_NumberOfHardwareProducts__c.value > 0
  ) {
    this.showInputs = true;
    this.cantGenerateDeliveryPlan = undefined;
  } else if(payload.data &&
    payload.data.fields &&
    payload.data.fields.Grid_NumberOfHardwareProducts__c.value == 0) {
    this.showInputs = false;
    this.cantGenerateDeliveryPlan =
      "You cannot generete a delivery plan if you don't have any hardware products added to the cart";
  }
}

convertToMonth(number) {
    const monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[number - 1] || '';
}
handleClose() {
    this.showmodal = false;
    const event = new CustomEvent('close');
    this.dispatchEvent(event);
    //location.reload();
}

}