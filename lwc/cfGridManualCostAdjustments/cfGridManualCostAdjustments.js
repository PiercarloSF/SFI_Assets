import { FlexCardMixin } from "vlocity_cmt/flexCardMixin";
    import { CurrentPageReference } from 'lightning/navigation';
    import {interpolateWithRegex, interpolateKeyValue, loadCssFromStaticResource } from "vlocity_cmt/flexCardUtility";
    
          import { LightningElement, api, track, wire } from "lwc";
          import pubsub from "vlocity_cmt/pubsub";
          import { getRecord } from "lightning/uiRecordApi";
          
          import data from "./definition";
          
          import styleDef from "./styleDefinition";
              
          export default class cfGridManualCostAdjustments extends FlexCardMixin(LightningElement){
              currentPageReference;        
              @wire(CurrentPageReference)
              setCurrentPageReference(currentPageReference) {
                this.currentPageReference = currentPageReference;
              }
              @api debug;
              @api recordId;
              @api objectApiName;
              
              @track record;
              @track _sessionApiVars = {};
              @track Label={CPQCartPricing:"Pricing",
        OneTime:"One Time",
        Recurring:"Recurring",
        RecurringMonthly:"Recurring Monthly",
        Usage:"Usage",
        RecurringYearly:"Recurring Yearly",
        CPQPriceWaterfall:"Price Waterfall",
        CPQAdjustPricing:"Adjust Pricing"
        };
              pubsubEvent = [];
              customEvent = [];
              
              connectedCallback() {
                super.connectedCallback();
                this.setThemeClass(data);
                this.setStyleDefinition(styleDef);
                data.Session = {} //reinitialize on reload
                
                
                this.customLabels = this.Label;
                      
                          this.fetchUpdatedCustomLabels();
                      
                this.setDefinition(data);
 this.registerEvents();
                
                
              }
              
              disconnectedCallback(){
                super.disconnectedCallback();
                    
                    

                  this.unregisterEvents();
              }

              registerEvents() {
                
        this.pubsubEvent[0] = {
          [interpolateWithRegex(`cpq_chargetype_change`,this._allMergeFields,this._regexPattern,"noparse")]: this.handleEventAction.bind(this, data.events[0],0),
[interpolateWithRegex(`cpq_adjustment_apply_click`,this._allMergeFields,this._regexPattern,"noparse")]: this.handleEventAction.bind(this, data.events[1],1),
[interpolateWithRegex(`cpq_adjustment_delete_click`,this._allMergeFields,this._regexPattern,"noparse")]: this.handleEventAction.bind(this, data.events[2],2),
[interpolateWithRegex(`cpq_adjustment_apply`,this._allMergeFields,this._regexPattern,"noparse")]: this.handleEventAction.bind(this, data.events[3],3)
        };
        this.pubsubChannel0 = interpolateWithRegex(`cpq_${this.recordId}`,this._allMergeFields,this._regexPattern,"noparse");
        pubsub.register(this.pubsubChannel0,this.pubsubEvent[0]);

              }

              unregisterEvents(){
                pubsub.unregister(this.pubsubChannel0,this.pubsubEvent[0]);

              }
            
              renderedCallback() {
                super.renderedCallback();
                
              }
          }