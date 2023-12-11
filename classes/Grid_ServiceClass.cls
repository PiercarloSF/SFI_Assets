/**
 * Class to implement the service class
 *
 * @Author  Salesforce
 *
 */
public class Grid_ServiceClass {
  /**
   * @description get Price books
   * @return Map<String, Id>
   **/
  public static Map<String, Id> getPriceBook() {
    Map<String, Id> mapPriceBook = new Map<String, Id>();
    List<PriceBook2> prs = new List<PriceBook2>();
    for (PriceBook2 pr : [SELECT Id, Name, CurrencyIsoCode FROM Pricebook2]) {
      mapPriceBook.put(pr.Name, pr.id);
    }
    return mapPriceBook;
  }
  /**
   * @description get Price lists
   * @return Map<String, List<vlocity_cmt__PriceList__c>>
   **/
  public static Map<String, List<vlocity_cmt__PriceList__c>> getPriceList() {
    Map<String, List<vlocity_cmt__PriceList__c>> mapPriceList = new Map<String, List<vlocity_cmt__PriceList__c>>();
    List<vlocity_cmt__PriceList__c> prs = new List<vlocity_cmt__PriceList__c>();
    for (vlocity_cmt__PriceList__c pr : [
      SELECT Id, Name, CurrencyIsoCode
      FROM vlocity_cmt__PriceList__c
    ]) {
      if (mapPriceList.containsKey(pr.CurrencyIsoCode)) {
        mapPriceList.get(pr.CurrencyIsoCode).add(pr);
      } else {
        mapPriceList.put(
          pr.CurrencyIsoCode,
          new List<vlocity_cmt__PriceList__c>{ pr }
        );
      }
    }
    return mapPriceList;
  }
  /**
   * @description get Record type record based on the object type and record type name
   * @param String obj SObjectType
   * @param String rcdType RecrodType Name
   * @return Map<String, List<vlocity_cmt__PriceList__c>>
   **/
  public static RecordType getRecordType(String obj, String rcdType) {
    return [
      SELECT Id
      FROM RecordType
      WHERE Name = :rcdType AND SobjectType = :obj
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
  }

      /**
     * 
     * This method fetches the Grid_ContractNotification__c value from the
     * Grid_Configuration__mdt custom metadata type and returns it as an integer.
     *
     * @return the Grid_ContractNotification__c value 
     */
    @AuraEnabled(cacheable=true)
    public static Integer fetchGridContractNotification() {
        Grid_Configuration__mdt config = [
            SELECT Grid_ContractNotification__c
            FROM Grid_Configuration__mdt
            LIMIT 1
        ];
        return (config != null) ? Integer.valueOf(config.Grid_ContractNotification__c) : null;
    }

    public static Map<String, String> getPicklistFieldValues (String objectApiName, String fieldApiName) {
      Map<String, String> pickListValuesMap = new  Map<String, String>();
      Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectApiName);
      Schema.DescribeSObjectResult res = convertToObj.getDescribe();
      Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(fieldApiName).getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for( Schema.PicklistEntry pickListVal : ple){
          pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
      }     
      return pickListValuesMap;
    }

  /**
   * @description prepare to delete product schedules 
   * @param List<Deliveryplan__c>  delivery plan list
   * @return Map<Id, List<ProductSchedule__c>> deliveryPlanToProductSchedulesMap 
  **/
  public static Map<Id, List<ProductSchedule__c>>  getDeliveryPlanToProductSchedules(List<Deliveryplan__c> lstDeliveryPlan) {
    set<Id> deliveryIds = new Set<Id>();
    Map<Id, List<ProductSchedule__c>> deliveryPlanToProductSchedulesMap = new Map<Id, List<ProductSchedule__c>>();
    List<ProductSchedule__c> productToadd = new List<ProductSchedule__c>();
    for (DeliveryPlan__c dlp : lstDeliveryPlan) {
      deliveryIds.add(dlp.Id);
    }
    List<ProductSchedule__c> productSchedules = [SELECT
      ID,
      Grid_Delivery_Plan__c,
      Grid_Version__c,
      Grid_Delivery_Plan__r.Grid_Version__c
      FROM ProductSchedule__c
      WHERE Grid_Delivery_Plan__c IN : deliveryIds
      ];
      for (ProductSchedule__c pt : productSchedules) {
        if (pt.Grid_Version__c == pt.Grid_Delivery_Plan__r.Grid_Version__c) {
          productToadd.add(pt);
        }
        deliveryPlanToProductSchedulesMap.put(pt.Grid_Delivery_Plan__c, productToadd);
      }
      return deliveryPlanToProductSchedulesMap;
  }
}