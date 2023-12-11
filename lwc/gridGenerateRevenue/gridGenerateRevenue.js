import { LightningElement, wire, api, track } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getRevenueSchedules from "@salesforce/apex/Grid_RevenueScheduleController.getRevenueSchedules";
import generateRevenue from "@salesforce/apex/Grid_RevenueScheduleController.generateRevenue";
import refreshRevenueSchedulesV2 from "@salesforce/apex/Grid_RevenueScheduleController.refreshRevenueSchedulesV2";
import getContractStatus from "@salesforce/apex/Grid_RevenueScheduleController.getContractStatus";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from "lightning/platformResourceLoader";
import { updateRecord } from "lightning/uiRecordApi";
import productName from "@salesforce/label/c.product_name";
import model from "@salesforce/label/c.model";
import totalRevenues from "@salesforce/label/c.total_revenues";
import metric from "@salesforce/label/c.metric";
import totalCount from "@salesforce/label/c.total_count";
import totalCheck from "@salesforce/label/c.total_check";
import exceededAmount from "@salesforce/label/c.exceededAmount";
import updatingAmountError from "@salesforce/label/c.updatingAmountError";
import exportRevenueSchedules from "@salesforce/label/c.exportRevenueSchedules";
import generateRevenueSchedules from "@salesforce/label/c.generateRevenueSchedules";
import errorGeneratingRevenues from "@salesforce/label/c.errorGeneratingRevenues";
import refreshRevenueScheduleV2Success from "@salesforce/label/c.refreshRevenueScheduleV2Success";
import refreshRevenueScheduleV2 from "@salesforce/label/c.refreshRevenueScheduleV2";
import successfulyGeneratingRevenues from "@salesforce/label/c.successfulyGeneratingRevenues";
import revenueSchedulesUpdated from "@salesforce/label/c.revenueSchedulesUpdated";
import deliveryPlanTerms from "@salesforce/resourceUrl/deliveryPlanTerms";
import doNotModifyRevenueCalculation from "@salesforce/label/c.doNotModifyRevenueCalculation";


const COLUMNS = [
  {
    label: productName,
    fieldName: "productName",
    type: "text",
    sortable: false,
    initialWidth: 250,
    cellAttributes: {
      class: { fieldName: "textStyle" }
    }
  },
  {
    label: model,
    fieldName: "model",
    type: "text",
    sortable: false,
    initialWidth: 120,
    cellAttributes: {
      class: { fieldName: "textStyle" }
    }
  },
  {
    label: metric,
    fieldName: "metric",
    type: "text",
    sortable: false,
    initialWidth: 120,
    cellAttributes: {
      class: { fieldName: "textStyle" }
    }
  },
  {
    label: totalRevenues,
    fieldName: "totalRevenues",
    type: "number",
    initialWidth: 140,
    cellAttributes: {
      class: { fieldName: "textStyle" ,alignment: "left"}
    }
  },
  {
    label: totalCount,
    fieldName: "totalCount",
    type: "number",
    initialWidth: 140,
    cellAttributes: {
      class: { fieldName: "textStyle" ,alignment: "left"}
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

const PLANNED_LABEL = "Planned ";
const ACTUAL_LABEL = "Actual ";
const TEXT_STYLE_CSS_CLASS = "slds-text-title_bold";
const RED_CHECK_CSS_CLASS = "slds-text-color_error slds-theme_shade";
const SUCCESS_TITLE = "Success";
const ERROR_VARIANT = "error";
const SUCCESS_VARIANT = "success";
const TOTAL_LABEL = "TOTAL";


export default class GridGenerateRevenue extends LightningElement {
  htmlLabels = {
    exportRevenueSchedules,generateRevenueSchedules,refreshRevenueScheduleV2
  };
  pageSizeOptions = [12];
  totalRecords = 0;
  pageSize;
  totalPages;
  pageNumber = 1;
  draftValues = [];
  @api recordId;
  data = [];
  initialData = [];
  payload;
  title;
  showActuals = false;
  showGenerate = false;
  refreshLoading = false;
  objectName;
  @track empty = true;
  @wire(getRevenueSchedules, { id: "$recordId" }) setRevenueSchedules(
    payload
  ) {
    this.initialData = [];
    this.data = [];
    this.payload = payload;
    if (payload.data) {
      this.showGenerate = payload.data[0]?.objectName !== "Contract";
      const editable = payload.data[0]?.status !== "Handover";
      this.objectName = payload.data[0]?.objectName;
      this.handleDataTableColumns(payload);
      payload.data.forEach((revenue) => {
        const model = revenue?.revenueSchedules[0].Grid_QuoteLineItem__r? 
        revenue.revenueSchedules[0].Grid_QuoteLineItem__r.OpenMeterFormula__c: 
        revenue.revenueSchedules[0].Grid_ContractLine__r.OpenMeterFormula__c;
        this.empty = !revenue?.revenueSchedules?.length > 0;
        const row = {
          productId: revenue.productId,
          productName: revenue.productName,
          model: model,
          metric: revenue?.revenueSchedules[0].Grid_Metric__c,
          totalRevenues: parseFloat(revenue.totalRevenues).toFixed(2),
          totalCount: parseFloat(revenue.totalRevenues).toFixed(2),
          totalCheck: 0,
          controlEditField: editable
        };
        revenue?.revenueSchedules?.forEach((revenueSchedules) => {
          row[PLANNED_LABEL + revenueSchedules.Name] = parseFloat(revenueSchedules.Grid_PlannedAmount__c).toFixed(2);
          if(this.showActuals){
            row[ACTUAL_LABEL + revenueSchedules.Name] = parseFloat(revenueSchedules.Grid_ActualAmount__c).toFixed(2) || 0;
          }
        });
        this.data.push(row);
      });

      this.data.sort(this.sortByModel);
      
      const total = this.data.reduce((acc, curr) => {
        for (const key in curr) {
          const value = parseFloat(curr[key]);
          if (!isNaN(value)) {
            acc[key] = (acc[key] || 0) + value;
          }
        }
        return acc;
      }, {});

      const totalObject = {
        textStyle : TEXT_STYLE_CSS_CLASS,
        "productId": TOTAL_LABEL,
        "productName": TOTAL_LABEL,
        ...total
      };
      
      
      this.data.push(totalObject);    

      this.initialData = JSON.parse(JSON.stringify(this.data));
      this.totalRecords = this.data.length;
      this.pageSize = this.pageSizeOptions[0];
      this.paginationHelper();
    }else if(payload.error){
      this.dispatchEvent(
        new ShowToastEvent({
          title: ERROR_VARIANT,
          message: payload.error,
          variant: ERROR_VARIANT
        })
      );
    }
  }


  async refreshRevenueScheduleV2() {
    try {
      this.refreshLoading = true;
      await refreshRevenueSchedulesV2({ contractId: this.recordId });
      refreshApex(this.payload);
      this.dispatchEvent(
        new ShowToastEvent({
          title: SUCCESS_TITLE,
          message: refreshRevenueScheduleV2Success,
          variant: SUCCESS_VARIANT
        })
      );
    }catch(error){
      this.dispatchEvent(
        new ShowToastEvent({
          title: ERROR_VARIANT,
          message: error.body?.message ?? errorGeneratingRevenues,
          variant: ERROR_VARIANT
        })
      )
    }finally{
      this.refreshLoading = false;
    }
  }

  sortByModel(a, b) {
    // if model is null or empty, treat it as lower than any non-empty model
    if (!a.model) return 1;
    if (!b.model) return -1;
    // otherwise, compare models lexicographically
    return a.model.localeCompare(b.model);
  }

  handleDataTableColumns(payload) {
    this.columns = JSON.parse(JSON.stringify(COLUMNS));
      this.title = payload.data[0]?.title;
      this.showActuals = payload.data[0]?.showActuals;
      payload.data[0]?.periods?.forEach((name) => {
        this.columns.push({
          label: PLANNED_LABEL + name,
          fieldName: PLANNED_LABEL + name,
          type: "number",
          editable: { fieldName: "controlEditField" },
          cellAttributes: {
            class: { 
              fieldName: "textStyle",
              alignment: "left"
            }
          }
        });
        if(this.showActuals){
          this.columns.push({
            label: ACTUAL_LABEL + name,
            fieldName: ACTUAL_LABEL + name,
            type: "number",
            editable: false,
            cellAttributes: {
              class: { 
                fieldName: "textStyle",
                alignment: "left"
              }
            }
          });
        }
      });
  }
  isInlineEditing = false;
  handleCancel() {
    this.isInlineEditing = false;
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

  handleCellChange(event) {
    try {
      this.isInlineEditing = true;
      event.detail.draftValues.slice().map((draftValue) => {
        const { Id, ...rest } = Object.assign({}, draftValue);
        const rowIndex = parseInt(Id.slice(4));
        Object.assign(this.data[rowIndex], rest);
        const {
          productId,
          metric,
          totalRevenues,
          totalCount,
          totalCheck,
          ...periods
        } = this.data[rowIndex];
        const count = Object.values(periods)
          .map((period) => parseFloat(period) || 0)
          .reduce((partialSum, a) => partialSum + a, 0);
        this.data[rowIndex].totalCount = count;
        this.data[rowIndex].totalCheck =
          this.data[rowIndex].totalRevenues - this.data[rowIndex].totalCount;
        this.data[rowIndex].totalCheck != 0
          ? (this.data[rowIndex].checkColor =
              RED_CHECK_CSS_CLASS)
          : (this.data[rowIndex].checkColor = "");
      });
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: ERROR_VARIANT,
          message: error.message,
          variant: ERROR_VARIANT
        })
      );
    }
  }


  async handleSave(event) {
    const status = await getContractStatus({ id: this.recordId });
    if(this.objectName == 'Contract' && status == 'Handover'){
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: doNotModifyRevenueCalculation,
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
        const { productId, metric, totalCheck } = this.data[rowIndex];
        if (totalCheck !== 0) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: ERROR_VARIANT,
              message: exceededAmount,
              variant: ERROR_VARIANT
            })
          );
          return;
        }
        
        const objIndex = this.initialData.findIndex(
          (obj) => obj.productId === productId && obj.metric === metric
        );
        this.initialData[objIndex] = { ...this.initialData[objIndex], ...rest };
        const product = this.payload?.data?.find(
          (record) => record.productId === productId
        );
        Object.keys(rest)?.forEach(async (key) => {
          const revenueSchedule = product?.revenueSchedules.find(
            (revenueSchedule) =>  key.includes(revenueSchedule.Name) && revenueSchedule.Name
          );
          const fields = {};
          fields.Id = revenueSchedule?.Id;
          fields.Grid_PlannedAmount__c = parseFloat(rest[key]);
          const recordInput = { fields };
          try {
            await updateRecord(recordInput);
            this.dispatchEvent(
              new ShowToastEvent({
                title: SUCCESS_TITLE,
                message: revenueSchedulesUpdated,
                variant: SUCCESS_VARIANT
              })
            );
            this.draftValues = [];
            await refreshApex(this.payload);
          } catch (error) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: ERROR_VARIANT,
                message: updatingAmountError,
                variant: ERROR_VARIANT
              })
            );
          }
          
        });
      });
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: ERROR_VARIANT,
          message: error.message,
          variant: ERROR_VARIANT
        })
      );
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
      "Revenue Calculation -" + new Date().getMilliseconds() + ".xls";
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }

  async generateRevenue() {
    try {
      await generateRevenue({ qId: this.recordId });
      refreshApex(this.payload);
      this.dispatchEvent(
        new ShowToastEvent({
          title: SUCCESS_TITLE,
          message: successfulyGeneratingRevenues,
          variant: SUCCESS_VARIANT
        })
      );
    }catch(error){
      this.dispatchEvent(
        new ShowToastEvent({
          title: ERROR_VARIANT,
          message: error.body?.message ?? errorGeneratingRevenues,
          variant: ERROR_VARIANT
        })
      )
    }
  }
}