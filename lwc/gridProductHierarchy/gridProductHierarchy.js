import { LightningElement, api,wire,track } from 'lwc';
import getLineItemsByRootId from "@salesforce/apex/Grid_ContractController.getLineItemsByRootId";
import getProductChildItemsByParentId from "@salesforce/apex/Grid_ContractController.getProductChildItemsByParentId";
import fetchGridProductHierarchyLevel from "@salesforce/apex/Grid_ContractController.fetchGridProductHierarchyLevel";


function Node(){
  this.id = "";
  this.name = "";
  this.quantity = "";
  this.actual = "";
  this.remaining = "";
  this.model = "";
  this.contractLineItemUrl = "";
  this._children;
}

export default class GridProductHierarchy extends LightningElement {
  columns = [
    {
      type: 'url',
      fieldName: 'contractLineItemUrl',
      label: 'Product Name',
      initialWidth: 400,
      typeAttributes: {
          label: { fieldName: 'name' },
          target: '_blank'
      }
    },
    {
      type: 'text',
      fieldName: 'model',
      label: 'Model',
      initialWidth: 180,
      cellAttributes: { alignment: 'center' },
    },
    {
      type: 'number',
      fieldName: 'quantity',
      label: 'Quantity',
      initialWidth: 140,
      cellAttributes: { alignment: 'center' },
    },
    {
      type: 'number',
      fieldName: 'actual',
      label: 'Actual Quantity',
      initialWidth: 160,
      cellAttributes: { alignment: 'center' },
    },
    {
      type: 'number',
      fieldName: 'remaining',
      label: 'Remaining Quantity',
      initialWidth: 160,
      cellAttributes: { alignment: 'center' },
    },
    {
      type: 'text',
      fieldName: 'oneTimeCharge',
      label: 'One Time Charge',
      initialWidth: 180,
      cellAttributes: { alignment: 'center' },
    },
    {
      type: 'text',
      fieldName: 'oneTimeTotal',
      label: 'One Time Total',
      initialWidth: 180,
      cellAttributes: { alignment: 'center' },
    },
    {
      type: 'text',
      fieldName: 'recurringCharge',
      label: 'Recurring Charge',
      initialWidth: 180,
      cellAttributes: { alignment: 'center' },
    },
    {
      type: 'text',
      fieldName: 'recurringTotal',
      label: 'Recurring Total',
      initialWidth: 180,
      cellAttributes: { alignment: 'center' },
    },
    {
      type: 'text',
      fieldName: 'recurringChargeYearly',
      label: 'Recurring Charge Yearly',
      initialWidth: 220,
      cellAttributes: { alignment: 'center' },
    },
    {
      type: 'text',
      fieldName: 'recurringTotalYearly',
      label: 'Recurring Total Yearly',
      initialWidth: 220,
      cellAttributes: { alignment: 'center' },
    },
  ];

  assignLevel(node, level) {
    node.level = level; // assign the level to the node
    if (node._children && node._children.length > 0) { // check if the node has children
      node._children.forEach(child => { // loop through the children
        this.assignLevel(child, level + 1); // assign the level to the child and its children recursively
      });
    }
  }

  deleteChildren(array, level) {
    for (let i = 0; i < array.length; i++) {
      const element = array[i];
  
      if (element.level && element.level === level) {
        delete element._children;
      }
        if (element._children && Array.isArray(element._children)) {
        this.deleteChildren(element._children, level);
      }
    }
    return array;
  }

  @api recordId;
  rootNodes=[];
  @track showTable = false;
  @wire(getLineItemsByRootId, { contractId: "$recordId" }) async getLineItemsByRootId({ error, data }) {
    if (data) {
      const productChildItemsByParentId = await getProductChildItemsByParentId({ contractId: this.recordId });
      const rootNodes = [];
      for (const rootId in data) {
        const nodesByProductId = [];
        const lineItems = data[rootId];
        this.createNodesForLineItems(lineItems, nodesByProductId);
        for(const li of lineItems){
          const node = nodesByProductId[li.vlocity_cmt__Product2Id__c];

          if (li.vlocity_cmt__Product2Id__c in productChildItemsByParentId) {
            for(const pci of productChildItemsByParentId[li.vlocity_cmt__Product2Id__c]){
              const childNode = nodesByProductId[pci.vlocity_cmt__ChildProductId__c];
              if(childNode){ 
                if(!node._children){
                  node._children = [];
                }
                node._children.push(childNode);
              }
            }
          }
          if (li.Grid_ParentItemId__c == null) { 
            rootNodes.push(node);
          } else {
              const parentNode = this.getParentNodeForLineItem(li, data, nodesByProductId);
              if (parentNode.Id != node.Id) {
                if(!parentNode._children){
                  parentNode._children = [];
                }
                parentNode._children.push(node);
              }
          }
        }
      }
      this.rootNodes = rootNodes;
      this.rootNodes.forEach(node => {
        this.assignLevel(node, 1);
      });
      const level = await fetchGridProductHierarchyLevel();
      if(level !== undefined){
        this.deleteChildren(this.rootNodes,level);
      }
      if(rootNodes.length>0){
        this.showTable = true;
      }

    } else if (error) {
      console.log(error);
    }
  };

  getParentNodeForLineItem(li, lineItemsByRootId, nodesByProductId) {
    return nodesByProductId[lineItemsByRootId[li.Grid_RootItemId__c].find(element => element.Id == li.Id).vlocity_cmt__Product2Id__c]
}

  createNodesForLineItems(lineItems, nodesByProductId) {
    for (const li of lineItems) {
      const node = new Node();
      node.id = li.Id;
      node.name = li.vlocity_cmt__Product2Id__r.Name;
      node.quantity = li.vlocity_cmt__Quantity__c;
      node.actual = li.Grid_Actual_Quantity__c;
      node.remaining = li.Grid_Remaining_Quantity__c;
      node.model = li.OpenMeterFormula__c;
      node.oneTimeCharge = li.vlocity_cmt__OneTimeCharge__c;
      node.oneTimeTotal = li.vlocity_cmt__OneTimeTotal__c;
      node.recurringCharge = li.vlocity_cmt__RecurringCharge__c;
      node.recurringTotal = li.vlocity_cmt__RecurringTotal__c;
      node.recurringChargeYearly = li.Recurring_Charge_Yearly__c;
      node.recurringTotalYearly = li.Recurring_Total_Yearly__c;
      node.contractLineItemUrl = '/lightning/r/vlocity_cmt__ContractLineItem__c/'+li.Id+'/view';
      nodesByProductId[li.vlocity_cmt__Product2Id__c] = node;
    }
  }
}