/**
 * Class to implement the trigger handler for Quote Object
 *
 * @Author  Salesforce
 *
 */
public class QuoteTriggerHandler extends TriggerHandler {

  private Set<Id> oppIds = new Set<Id>();
  private List<Quote> quotes = new List<Quote>();

  Map<Id, Quote> newQuoteMap = new Map<Id, Quote>();
  Map<Id, Quote> oldQuoteMap = new Map<Id, Quote>();

  public QuoteTriggerHandler() {
    this.newQuoteMap = (Map<Id, Quote>) Trigger.newMap;
    this.oldQuoteMap = (Map<Id, Quote>) Trigger.oldMap;
    for (Quote qte : (List<Quote>) Trigger.new){
      oppIds.add(qte.opportunityId);
    }
  }

  public override void beforeInsert() {
    Grid_QuoteServiceClass.updateQuote(Trigger.new, oppIds);
  }

  public override void beforeUpdate() {
    for (Quote qte : (List<Quote>) Trigger.new){
      if(newQuoteMap.get(qte.Id).Status != oldQuoteMap.get(qte.Id).Status){
        quotes.add(qte);
        oppIds.add(qte.opportunityId);
      }
    }
    if(!quotes.isEmpty()){
      Grid_QuoteServiceClass.updateOpportunityStage(Trigger.new, oppIds);
    }
    Grid_QuoteServiceClass.handleDeliveryPlanCheck(Trigger.new);
  }
}