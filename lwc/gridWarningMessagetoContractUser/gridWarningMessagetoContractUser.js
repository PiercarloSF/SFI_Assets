import { LightningElement, api, wire } from "lwc";
import Grid_Warning_Message_In_Contract from "@salesforce/label/c.Grid_Warning_Message_In_Contract";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import fetchGridContractNotification from "@salesforce/apex/Grid_ServiceClass.fetchGridContractNotification";

import CONTRACT_FIRST_NAME_FIELD from "@salesforce/schema/Contract.Owner.FirstName";
import CONTRACT_LAST_NAME_FIELD from "@salesforce/schema/Contract.Owner.LastName";
import CONTRACT_PROFILE_FIELD from "@salesforce/schema/Contract.Owner.Profile.Name";

const FIELDS = [
  "Contract.Grid_InHandoverDate__c",
  CONTRACT_FIRST_NAME_FIELD,
  CONTRACT_LAST_NAME_FIELD,
  CONTRACT_PROFILE_FIELD
];

export default class GridWarningMessagetoContractUser extends LightningElement {
  htmlLabels = { Grid_Warning_Message_In_Contract };
  @api recordId;
  @api showWarning;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS }) getRecord(
    payload
  ) {
    if (payload.data && !this.shouldHideComponent(payload.data)) {
      fetchGridContractNotification()
        .then((gridContractNotification) => {
          if (this.checkWarning(payload.data, gridContractNotification)) {
            this.showWarning = true;
          }
        })
        .catch((error) => console.log(error));
    } else {
      this.showWarning = false;
    }
    console.log("refreshed");
  }

  shouldHideComponent(data) {
    const firstName = getFieldValue(data, CONTRACT_FIRST_NAME_FIELD);
    const lastName = getFieldValue(data, CONTRACT_LAST_NAME_FIELD);
    const profile = getFieldValue(data, CONTRACT_PROFILE_FIELD);
    return (
      firstName !== "Contract" &&
      lastName !== "Supervisor" &&
      profile === "Client Manager"
    );
  }

  checkWarning(data, gridContractNotification) {
    if (
      data &&
      gridContractNotification !== null &&
      data.fields.Grid_InHandoverDate__c.value
    ) {
      const today = new Date();
      const gridInHandoverDate = new Date(
        data.fields.Grid_InHandoverDate__c.value
      );
      const gridInHandoverDateAfterXDays = new Date(gridInHandoverDate);
      gridInHandoverDateAfterXDays.setDate(
        gridInHandoverDate.getDate() + gridContractNotification
      );
      if (today >= gridInHandoverDateAfterXDays) {
        return true;
      }
    }
    return false;
  }
}