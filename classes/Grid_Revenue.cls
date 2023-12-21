public with sharing class Grid_Revenue {
    @AuraEnabled
    public String productId;
    @AuraEnabled
    public String productName;
    @AuraEnabled
    public Decimal totalRevenues;
    @AuraEnabled
    public List<String> periods;
    @AuraEnabled
    public List<Grid_RevenueSchedule__c> revenueSchedules;
    @AuraEnabled
    public Boolean showActuals;
    @AuraEnabled
    public String title;
    @AuraEnabled
    public String objectName;
    @AuraEnabled
    public String status;
}