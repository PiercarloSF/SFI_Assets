import { LightningElement, wire, api, track } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getProductSchedules from "@salesforce/apex/Grid_ProductScheduelleController.getProductSchedules";
import refreshDeliveryPlan from "@salesforce/apex/Grid_ProductScheduelleController.refreshDeliveryPlan";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from "lightning/platformResourceLoader";
import { updateRecord } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import productName from "@salesforce/label/c.product_name";
import metric from "@salesforce/label/c.metric";
import total from "@salesforce/label/c.total";
import totalCount from "@salesforce/label/c.total_count";
import totalCheck from "@salesforce/label/c.total_check";
import plannedQuantity from "@salesforce/label/c.Planned_Quantity";
import salesPrice from "@salesforce/label/c.Sales_Price";
import plannedAmount from "@salesforce/label/c.Planned_Amount";
import actualQuantity from "@salesforce/label/c.ActualQuantity";
import actualAmount from "@salesforce/label/c.ActualAmount";

import exceededAmount from "@salesforce/label/c.exceededAmount";
import refreshDeliveryPlanSuccess from "@salesforce/label/c.refreshDeliveryPlanSuccess";
import refreshDeliveryPlanError from "@salesforce/label/c.refreshDeliveryPlanError";
import datatableNegativeValues from "@salesforce/label/c.datatableNegativeValues";
import productSchedulesUpdated from "@salesforce/label/c.productSchedulesUpdated";
import updatingAmountError from "@salesforce/label/c.updatingAmountError";
import noProductSchedules from "@salesforce/label/c.NoProductSchedules";
import exportDeliveryPlanTerm from "@salesforce/label/c.exportDeliveryPlanTerm";
import refreshDeliveryPlanTerm from "@salesforce/label/c.refreshDeliveryPlan";
import deliveryPlanTitle from "@salesforce/label/c.deliveryPlanTitle";
import doNotModifyDelivery from "@salesforce/label/c.doNotModifyDelivery";

import deliveryPlanTerms from "@salesforce/resourceUrl/deliveryPlanTerms";

import { subscribe, unsubscribe, onError } from 'lightning/empApi';


const COLUMNS = [
  {
    label: productName,
    fieldName: "productNameLabel",
    type: "text",
    sortable: false,
    initialWidth: 250
  },
  {
    label: metric,
    fieldName: "metric",
    type: "text",
    sortable: false,
    initialWidth: 120
  },
  {
    label: total,
    fieldName: "total",
    type: "number",
    initialWidth: 90,
    cellAttributes: {
      alignment: "left"
    }
  },
  {
    label: totalCount,
    fieldName: "totalCount",
    type: "number",
    initialWidth: 140,
    cellAttributes: {
      alignment: "left"
    }
  },
  {
    label: totalCheck,
    fieldName: "totalCheck",
    type: "number",
    initialWidth: 140,
    cellAttributes: {
      class: { fieldName: "checkColor", alignment: "left" }
    }
  }
];

const METRICS = {
  plannedQuantity,
  salesPrice,
  plannedAmount,
  actualQuantity,
  actualAmount
};

export default class ProductSchelleList extends LightningElement {
  htmlLabels = {
    noProductSchedules,
    exportDeliveryPlanTerm,
    refreshDeliveryPlanTerm
  };
  pageSizeOptions = [15];
  totalRecords = 0;
  pageSize;
  totalPages;
  pageNumber = 1;
  draftValues = [];
  @api recordId;
  data = [];
  initialData = [];
  @track empty = true;
  result;
  @track userId = Id;
  showRefreshButton = true;
  dPtitle = '';
  @track contractStatus ;
  payload;
  dpVersion;
  uniqueParam = Date.now();


  @wire(getProductSchedules, { qId: "$recordId",v: '$uniqueParam' }) setProductSchedules(
    payload
  ) {
    this.initialData = [];
    this.data = [];
    this.payload = payload;
    if (payload.error) {
      console.log(payload.error);
    }
    console.log(payload.data);
    if (payload.data) {
      this.result = payload.data;
      this.columns = JSON.parse(JSON.stringify(COLUMNS));
      this.contractStatus = payload.data[0]?.contractStatus;
      this.dpVersion = payload.data[0]?.dpVersion;
      if(this.recordId.startsWith("800")){
        this.showRefreshButton = false;
      }
      if (this.dpVersion == 2) {
        this.dPtitle = deliveryPlanTitle + 2;
      }else if(payload.data[0]){
        this.dPtitle = deliveryPlanTitle + 1;
      }
      payload.data[0]?.periods?.forEach((name) => {
        this.columns.push({
          label: name,
          fieldName: name,
          type: "number",
          editable: { fieldName: "controlEditField" },
          cellAttributes: {
            alignment: "left"
          }
        });
      });
      payload.data.forEach((deliveryPlanItem) => {
        this.empty = !deliveryPlanItem?.productSchedules?.length > 0;
        const plannedQuantity = {
          productName: deliveryPlanItem.productNameId,
          productNameLabel: deliveryPlanItem.productName,
          metric: METRICS.plannedQuantity,
          total: parseInt(deliveryPlanItem.total),
          totalCount: parseInt(deliveryPlanItem.total),
          totalCheck: 0,
          controlEditField: true
        };
        const salesPrice = {
          productName: deliveryPlanItem.productNameId,
          metric: METRICS.salesPrice,
          total:
            (deliveryPlanItem?.productSchedules[0].Grid_SalesPric__c).toFixed(
              2
            ),
          totalCount:
            (deliveryPlanItem?.productSchedules[0].Grid_SalesPric__c).toFixed(
              2
            ),
          totalCheck: 0,
          controlEditField: false
        };
        const plannedAmount = {
          productName: deliveryPlanItem.productNameId,
          metric: METRICS.plannedAmount,
          total: (
            deliveryPlanItem.total *
            deliveryPlanItem?.productSchedules[0].Grid_SalesPric__c
          ).toFixed(2),
          totalCount: (
            deliveryPlanItem.total *
            deliveryPlanItem?.productSchedules[0].Grid_SalesPric__c
          ).toFixed(2),
          totalCheck: 0,
          controlEditField: false
        };
        deliveryPlanItem?.productSchedules.forEach((productSchedule) => {
          if(productSchedule.Grid_Actual_Quantity__c !== 0 && deliveryPlanItem.productName === 'Antenna esterna RF'){
            console.log(productSchedule);
          }
        })
        const actualQuantity = {
          productName: deliveryPlanItem.productNameId,
          metric: METRICS.actualQuantity,
          total: (deliveryPlanItem?.productSchedules.reduce((accumulator, currentObject) => accumulator + currentObject.Grid_Actual_Quantity__c, 0)).toFixed(2),
          totalCount: 0,
          totalCheck: 0,
          controlEditField: false
        };
        const actualAmount = {
          productName: deliveryPlanItem.productNameId,
          metric: METRICS.actualAmount,
          total: actualQuantity.total * salesPrice.total ,
          totalCount: 0,
          totalCheck: 0,
          controlEditField: false
        };
        deliveryPlanItem?.productSchedules?.forEach((productSchedule) => {
          plannedQuantity[productSchedule.Name] = productSchedule.Grid_PlannedQuantity__c;
            if (this.dpVersion == 2) {
              actualQuantity[productSchedule.Name] = productSchedule.Grid_Actual_Quantity__c.toFixed(2);
              actualAmount[productSchedule.Name] = productSchedule.Grid_Actual_Amount__c.toFixed(2);
              }
          salesPrice[productSchedule.Name] = productSchedule.Grid_SalesPric__c.toFixed(2);
          plannedAmount[productSchedule.Name] = productSchedule.Grid_PlannedAmn__c.toFixed(2);

        });
        this.data.push(plannedQuantity);
        if (this.dpVersion == 2) {
          this.data.push(actualQuantity);
          this.data.push(actualAmount);
        }
        this.data.push(salesPrice);
        this.data.push(plannedAmount);

      });
      this.initialData = JSON.parse(JSON.stringify(this.data));

      this.totalRecords = this.data.length;
      this.pageSize = this.pageSizeOptions[0];
      this.paginationHelper();
    }
  }
  isInlineEditing = false;
  handleCellChange(event) {
    try {
      this.isInlineEditing = true;
      event.detail.draftValues.slice().map((draftValue) => {
        const { Id, ...rest } = Object.assign({}, draftValue);
        const rowIndex = parseInt(Id.slice(4));
        Object.assign(this.data[rowIndex], rest);
        const {
          productName,
          metric,
          total,
          totalCount,
          totalCheck,
          ...periods
        } = this.data[rowIndex];
        const count = Object.values(periods)
          .map((period) => parseInt(period) || 0)
          .reduce((partialSum, a) => partialSum + a, 0);
        this.data[rowIndex].totalCount = count;
        this.data[rowIndex].totalCheck =
          this.data[rowIndex].total - this.data[rowIndex].totalCount;
        this.data[rowIndex].totalCheck != 0
          ? (this.data[rowIndex].checkColor =
              "slds-text-color_error slds-theme_shade")
          : (this.data[rowIndex].checkColor = "");
      });
    } catch (error) {
      console.log(error);
    }
  }
  handleCancel() {
    this.isInlineEditing = false;
    this.paginationHelper();
  }

  async handleSave(event) {
    if(this.contractStatus == 'Handover'){
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: doNotModifyDelivery,
          variant: "error"
        })
      );
      return;
    }
    this.isInlineEditing = false;
    try {
      const records = event.detail.draftValues.slice().map((draftValue) => {
        const fields = Object.assign({}, draftValue);
        const { Id, ...rest } = fields;
        const rowIndex = parseInt(Id.slice(4));
        const { productName, metric, totalCheck } = this.data[rowIndex];
        if (totalCheck !== 0) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: exceededAmount,
              variant: "error"
            })
          );
          return;
        }

        const objIndex = this.initialData.findIndex(
          (obj) => obj.productName === productName && obj.metric === metric
        );
        this.initialData[objIndex] = { ...this.initialData[objIndex], ...rest };
        const product = this.result.find(
          (record) => record.productNameId === productName
        );
        Object.keys(rest)?.forEach((key) => {
          const productSchedule = product?.productSchedules.find(
            (productSchedule) => productSchedule.Name === key
          );
          const fields = {};
          fields.Id = productSchedule?.Id;
          if (metric === METRICS.plannedQuantity) {
            fields.Grid_PlannedQuantity__c = parseInt(rest[key]);
          }
          const recordInput = { fields };
          updateRecord(recordInput)
            .then((data) => {
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Success",
                  message: productSchedulesUpdated,
                  variant: "success"
                })
              );
              this.draftValues = [];
              refreshApex(this.payload);
            })
            .catch((error) =>
              this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error",
                  message: updatingAmountError,
                  variant: "error"
                })
              )
            );
        });
      });
    } catch (error) {
      console.log(error);
    }
  }

  columnMinWidthSet = false;
  renderedCallback() {
    Promise.all([
      loadStyle(this, deliveryPlanTerms)
    ])
      .then(() => {})
      .catch((error) => {});

    if (!this.columnMinWidthSet) {
      const dataTable = this.template.querySelector(".data-table");
      if (dataTable) {
        dataTable.minColumnWidth = 140;
        this.columnMinWidthSet = true;
      }
    }
  }

  handleSearch(event) {
    const searchKey = event.target.value.toLowerCase();
    if (searchKey) {
      this.data = this.initialData.filter(
        (record) =>
          Object.values(record).filter((value) =>
            String(value).toLowerCase().includes(searchKey)
          ).length > 0
      );
    } else {
      this.paginationHelper();
    }
  }
  get bDisableFirst() {
    return this.pageNumber == 1;
  }
  get bDisableLast() {
    return (
      this.pageNumber == this.totalPages || this.pageNumber >= this.totalPages
    );
  }
  handleRecordsPerPage(event) {
    this.pageSize = event.target.value;
    this.paginationHelper();
  }
  previousPage() {
    this.pageNumber = this.pageNumber - 1;
    this.paginationHelper();
  }
  nextPage() {
    this.pageNumber = this.pageNumber + 1;
    this.paginationHelper();
  }
  firstPage() {
    this.pageNumber = 1;
    this.paginationHelper();
  }
  lastPage() {
    this.pageNumber = this.totalPages;
    this.paginationHelper();
  }
  paginationHelper() {
    const recordsToDisplay = [];
    this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
    this.pageNumber =
      this.pageNumber <= 1
        ? 1
        : this.pageNumber >= this.totalPages
        ? this.totalPages
        : this.pageNumber;
    for (
      let i = (this.pageNumber - 1) * this.pageSize;
      i < this.pageNumber * this.pageSize;
      i++
    ) {
      if (i === this.totalRecords) {
        break;
      }
      recordsToDisplay.push(Object.assign({}, this.initialData[i]));
    }
    this.data = [...recordsToDisplay];
  }

  exportDeliveryPlan() {
    let doc = "<table>";
    doc += "<style>";
    doc += "table, th, td {";
    doc += "    border: 1px solid black;";
    doc += "    border-collapse: collapse;";
    doc += "}";
    doc += "</style>";
    doc += "<tr>";
    this.columns.forEach((element) => {
      doc += "<th>" + element.fieldName + "</th>";
    });
    doc += "</tr>";
    this.initialData.forEach((record) => {
      doc += "<tr>";
      this.columns.forEach((element) => {
        const value =
          record[element.fieldName] !== undefined
            ? record[element.fieldName]
            : "";
        doc += "<th>" + value + "</th>";
      });
      doc += "</tr>";
    });
    doc += "</table>";
    var element = "data:application/vnd.ms-excel," + encodeURIComponent(doc);
    let downloadElement = document.createElement("a");
    downloadElement.href = element;
    downloadElement.target = "_self";
    downloadElement.download =
      "Delivery Plan Terms-" + new Date().getMilliseconds() + ".xls";
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }
  async refreshDeliveryPlan() {
    await refreshDeliveryPlan({ qId: this.recordId })
      .then(() => {
        refreshApex(this.payload);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: refreshDeliveryPlanSuccess,
            variant: "success"
          })
        );
      })
      .catch((error) =>
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: refreshDeliveryPlanError,
            variant: "error"
          })
        )
      );
  }
}