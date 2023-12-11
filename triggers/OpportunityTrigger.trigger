trigger OpportunityTrigger on Opportunity (before insert, before update, before delete) {
  new OpportunityTriggerHandler().run();
}