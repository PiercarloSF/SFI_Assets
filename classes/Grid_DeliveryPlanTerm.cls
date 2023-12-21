/**
 * Class wrapper of delivery plan terms that holds product schedules
 *
 * @Author  Salesforce
 *
 */
public class Grid_DeliveryPlanTerm {
  @AuraEnabled
  public String productNameId;
  @AuraEnabled
  public String productName;
  @AuraEnabled
  public String metric;
  @AuraEnabled
  public String total;
  @AuraEnabled
  public List<String> periods;
  @AuraEnabled
  public List<ProductSchedule__c> productSchedules;
  @AuraEnabled
  public String contractStatus;
  @AuraEnabled
  public Integer dpVersion;
}