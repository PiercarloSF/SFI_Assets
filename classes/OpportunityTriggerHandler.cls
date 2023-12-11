/**
 * Class to implement the trigger handler for Opportunity Object
 *
 * @Author  Salesforce
 *
 */
public class OpportunityTriggerHandler extends TriggerHandler {

  Map<Id, Opportunity> newOppMap = new Map<Id, Opportunity>();
  Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
  List<Opportunity> opportunities = new List<Opportunity>();

  public OpportunityTriggerHandler() {
    this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
    this.oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
  }

  public override void beforeInsert() {
    Grid_AutoNumberUtil.handleOpportunityAutoNumber(Trigger.new);
    Grid_OpportunityServiceClass.updateOpportunity(Trigger.new);
    Grid_OpportunityServiceClass.setOpportunityRenewal(Trigger.new);


  }

  public override void beforeUpdate() {
    for (Id newOppId : newOppMap.keySet()) {
      if (
        newOppMap.get(newOppId).StageName !=
        oldOppMap.get(newOppId).StageName ||
        newOppMap.get(newOppId).Grid_TypeOfOpportunity__c !=
        oldOppMap.get(newOppId).Grid_TypeOfOpportunity__c ||
        newOppMap.get(newOppId).Grid_OpportunityCurrency__c !=
        oldOppMap.get(newOppId).Grid_OpportunityCurrency__c ||
        newOppMap.get(newOppId).Grid_Scheda231Status__c !=
        oldOppMap.get(newOppId).Grid_Scheda231Status__c ||
        newOppMap.get(newOppId).Grid_Country__c !=
        oldOppMap.get(newOppId).Grid_Country__c
      ) {
        opportunities.add(newOppMap.get(newOppId));
      }
    }
    if(!opportunities.isEmpty()) {
      Grid_OpportunityServiceClass.updateOpportunity(opportunities);

    }
  }
}