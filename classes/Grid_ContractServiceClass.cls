/**
 * Class to implement the contract service
 *
 * @Author  Salesforce
 *
 */
public with sharing class Grid_ContractServiceClass {

  /**
   * @description auto populate contract data from the opportunity
   * @param opportunity 
   * @return void
  **/
  public static void updateContract(List<Contract> contracts) {
    Set<Id> contractIds = new Set<Id>();
    for (Contract c : contracts) {
      contractIds.add(c.Id);
      setNextCheckPointAuditDate(c);
      setScheda231DeliveryNextCheckPointAuditDate(c);
    }

    Map<id, Contract> contractsWithQuotesAndOpportunities = new Map<ID, Contract>(
      [
        SELECT
          Id,
          vlocity_cmt__QuoteId__r.Status,
          vlocity_cmt__OpportunityId__r.Grid_StartContractDate__c,
          vlocity_cmt__OpportunityId__r.Grid_EndContractDate__c,
          OwnerId
        FROM Contract
        WHERE Id IN :contractIds
      ]
    );
    List<Quote> quotes = new List<Quote>();
    List<Opportunity> opportunities = new List<Opportunity>();
    for (Contract c : contracts) {
      if (c.Status == 'Contract Signed') {
        contractsWithQuotesAndOpportunities.get(c.Id)
          .vlocity_cmt__QuoteId__r.Status = 'Finalized';
        contractsWithQuotesAndOpportunities.get(c.Id)
          .vlocity_cmt__OpportunityId__r.Grid_StartContractDate__c = c.startDatee__c;
        contractsWithQuotesAndOpportunities.get(c.Id)
          .vlocity_cmt__OpportunityId__r.Grid_EndContractDate__c = c.Enddatee__c;
        quotes.add(
          contractsWithQuotesAndOpportunities.get(c.Id).vlocity_cmt__QuoteId__r
        );
        opportunities.add(
          contractsWithQuotesAndOpportunities.get(c.Id)
            .vlocity_cmt__OpportunityId__r
        );
      } else if (c.Status == 'Contract Rejected') {
        contractsWithQuotesAndOpportunities.get(c.Id)
          .vlocity_cmt__QuoteId__r.Status = 'Rejected';
        quotes.add(
          contractsWithQuotesAndOpportunities.get(c.Id).vlocity_cmt__QuoteId__r
        );
      }
    }
    update quotes;
    update opportunities;
  }

  public static void updateInsertContract(List<Contract> contracts) {
    for (Contract c : contracts) {
      checkExpiredOnDate(c);
    }
  }
  
    /**
   * @description add contract owner to Account Team
   * @param contract 
   * @return void
  **/
  public static void updateAccountTeam(List<Contract> oldContractList) {
    List<AccountTeamMember> newAccountTeamMembers = new List<AccountTeamMember>();
    for (Contract oldContract : oldContractList) {
        AccountTeamMember newATM = new AccountTeamMember();
        newATM.accountId = oldContract.accountId;
        newATM.userId = oldContract.ownerId;
        newATM.accountAccessLevel = 'Edit';
        newATM.caseAccessLevel = 'None';
        newATM.opportunityAccessLevel = 'None';
        newAccountTeamMembers.add(newATM);
    }
    if(!newAccountTeamMembers.isEmpty()){
      insert newAccountTeamMembers;
    }
  }

  /**
   * @description calculates the next check point audit date
   * @param contract 
   * @return void
  **/
  private static void setNextCheckPointAuditDate(Contract c) {
    if (c.Status == 'Internal Review') {
      Date todaysDate = system.today();
      Date marchDate = Date.newInstance(todaysDate.year(), 3, 31);
      Date septembreDate = Date.newInstance(todaysDate.year(), 9, 30);
      Date deadLineDate;
      if (todaysDate <= marchDate) {
        c.Grid_Scheda231NextCheckpointAuditDate__c = marchDate;
        deadLineDate = marchDate;
      } else if (todaysDate > marchDate && todaysDate <= septembreDate) {
        c.Grid_Scheda231NextCheckpointAuditDate__c = septembreDate;
        deadLineDate = septembreDate;
      } else if (todaysDate > septembreDate) {
        c.Grid_Scheda231NextCheckpointAuditDate__c = marchDate.addYears(1);
        deadLineDate = marchDate.addYears(1);
      }
      if (c.Scheda_231_status__c == 'Open') {
        DateTime reminder25Before = DateTime.newInstance(
          deadLineDate.year(),
          deadLineDate.month(),
          deadLineDate.day() - 25
        );
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('subject', Label.Grid_ContractSchedaReminderSubject);
        inputs.put('body', Label.Grid_ContractSchedaReminderBody);
        inputs.put('isReminder', true);
        inputs.put('dueDate', deadLineDate);
        inputs.put('contract', c);
        if (system.today().daysBetween(deadLineDate) <= 10) {
          inputs.put('reminderDate', system.now());
        } else {
          inputs.put('reminderDate', reminder25Before);
        }
        Flow.Interview.Create_Reminder_Task myFlow = new Flow.Interview.Create_Reminder_Task(
          inputs
        );
        myFlow.start();
      }
    }
  }

        /**
   * @description calculates the scheda 231 delivery next check point audit date
   * @param contract 
   * @return void
  **/
  private static void setScheda231DeliveryNextCheckPointAuditDate(Contract c) {
    if (c.Status == 'Activated') {
      Date todaysDate = system.today();
      Date marchDate = Date.newInstance(todaysDate.year(), 3, 31);
      Date septembreDate = Date.newInstance(todaysDate.year(), 9, 30);
      Date deadLineDate;
      if (todaysDate <= marchDate) {
        c.Grid_Scheda231DeliveryNextCheckpoint__c = marchDate;
        deadLineDate = marchDate;
      } else if (todaysDate > marchDate && todaysDate <= septembreDate) {
        c.Grid_Scheda231DeliveryNextCheckpoint__c = septembreDate;
        deadLineDate = septembreDate;
      } else if (todaysDate > septembreDate) {
        c.Grid_Scheda231DeliveryNextCheckpoint__c = marchDate.addYears(1);
        deadLineDate = marchDate.addYears(1);
      }
      if (c.Grid_Scheda231DeliveryStatus__c == 'Open (red)') {
        DateTime reminder25Before = DateTime.newInstance(
          deadLineDate.year(),
          deadLineDate.month(),
          deadLineDate.day() - 25
        );
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('subject', Label.Grid_ContractSchedaDeliveryReminderSubject);
        inputs.put('body', Label.Grid_ContractSchedaDeliveryReminderBody);
        inputs.put('isReminder', true);
        inputs.put('dueDate', deadLineDate);
        inputs.put('contract', c);
        if (system.today().daysBetween(deadLineDate) <= 10) {
          inputs.put('reminderDate', system.now());
        } else {
          inputs.put('reminderDate', reminder25Before);
        }
        Flow.Interview.Create_Reminder_Task myFlow = new Flow.Interview.Create_Reminder_Task(
          inputs
        );
        myFlow.start();
      }
    }
  }
  /**
   * @description send a reminder if the contract deal expires
   * @param contract 
   * @return void
  **/
  private static void checkExpiredOnDate(Contract c) {
    if (c.Deal_Expires_on__c < system.today()) {
      Map<String, Object> inputs = new Map<String, Object>();
      inputs.put('subject', Label.Grid_ContractOffreExpiredSubject);
      inputs.put('body', Label.Grid_ContractOffreExpiredBody);
      inputs.put('isReminder', true);
      inputs.put('contract', c);
      inputs.put('reminderDate', system.now());

      Flow.Interview.Create_Reminder_Task myFlow = new Flow.Interview.Create_Reminder_Task(
        inputs
      );
      myFlow.start();
    }
  }

    /**
   * Queries related Grid_ContractTeamMember__c records for the given Contracts and returns a Map
   * of Contract Ids to a List of related User Ids.
   *
   * @param contracts The List of Contracts to query related Grid_ContractTeamMember__c records for.
   * @return A Map of Contract Ids to a List of related User Ids.
   */
  public static void notifyContractTeamMembers(List<Contract> contracts) {
    Map<Id, List<Id>> contractToUserIdsMap = new Map<Id, List<Id>>();

    Set<Id> contractIds = new Set<Id>();
    for (Contract contract : contracts) {
        contractIds.add(contract.Id);
    }

    Map<Id, Id> contractOwners = new Map<Id, Id>();
    for (Contract contract : contracts) {
        contractOwners.put(contract.Id, contract.OwnerId);
    }

    // Perform SOQL query to get related Grid_ContractTeamMember__c records
    List<Grid_ContractTeamMember__c> gridContractTeamMembers = [
        SELECT Id, Grid_User__c, Grid_Contract__c
        FROM Grid_ContractTeamMember__c
        WHERE Grid_Contract__c IN :contractIds
    ];

    // Iterate over the Grid_ContractTeamMember__c records and populate the Map
    for (Grid_ContractTeamMember__c gridContractTeamMember : gridContractTeamMembers) {
        Id contractId = gridContractTeamMember.Grid_Contract__c;
        Id userId = gridContractTeamMember.Grid_User__c;
        if (!contractToUserIdsMap.containsKey(contractId)) {
            contractToUserIdsMap.put(contractId, new List<Id>{userId});
        } else {
            contractToUserIdsMap.get(contractId).add(userId);
        }
    }

    for(Contract c : contracts){
      List<Id> userIDs = new List<Id>();
      if(UserInfo.getUserId() != c.OwnerId){
        userIDs.add(c.OwnerId);
      }
      if(!userIDs.isEmpty()){
        invokeSendNotificationFlow(userIDs,c.Id);
      }
    }

    for (Id contractId : contractToUserIdsMap.keySet()) {
      List<Id> userIDs = contractToUserIdsMap.get(contractId);
      if(!userIDs.isEmpty()){
        invokeSendNotificationFlow(userIDs,contractId);
      }
    }
  }


  private static void invokeSendNotificationFlow(List<Id> userIDs,Id contractId) {
    String title = Label.contract_update_notification_title;
    String body = Label.contract_update_notification_body;
    Map<String, Object> inputs = new Map<String, Object>();
    inputs.put('title', title);
    inputs.put('body', body);
    inputs.put('userIDs', userIDs);
    inputs.put('recordId',contractId);
    // Create a new instance of the flow and pass in the input variables
    Flow.Interview.Send_Notification_To_Users flow = new Flow.Interview.Send_Notification_To_Users(
      inputs
    );
    // Start the flow
    flow.start();
  }

  /**
   * @description Notify the new owner that the contract is assigned to him
   * @param contracts
   * @return void
  **/
  public static void notifyNewOwner(List<Contract> newContractList) {
    for (Contract newContract : newContractList) {
      if (newContract.Status == 'Handover') {
        List<Id> userIDs = new List<Id>();
        userIDs.add(newContract.OwnerId);
        String title = Label.contract_update_notification_title;
        String body = Label.contract_assignment;
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('title', title);
        inputs.put('body', body);
        inputs.put('userIDs', userIDs);
        inputs.put('recordId',newContract.Id);
        // Create a new instance of the flow and pass in the input variables
        Flow.Interview.Send_Notification_To_Users flow = new Flow.Interview.Send_Notification_To_Users(
          inputs
        );
        // Start the flow
        flow.start();
      }
    }
  }
  /**
* This Method to add the public group user in the Delivery Team Members related list
* of Contract when status is equal to handover
*
* @Author  Salesforce
*
*/
public static void getUsersFromPublicGroup(List<Contract> contracts) {
        
  String publicGroupName = 'Delivery Group'; //public group name
  Id publicGroupId;
  List<Group> publicGroups = [SELECT Id FROM Group WHERE Type = 'Regular' AND Name = :publicGroupName];
  if (!publicGroups.isEmpty()) {
      publicGroupId = publicGroups[0].Id;
      // use the publicGroupId variable in groupMembers code
  } 
  
  Set<Id> userIds = new Set<Id>();
  List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroupId];
  for (GroupMember gm : groupMembers) {
      if (gm.UserOrGroupId.getSObjectType() == Schema.User.SObjectType) {
          userIds.add(gm.UserOrGroupId);
      }
  }
  List<User> users = [SELECT Id, Name FROM User WHERE Id IN :userIds];
  
  // Query existing delivery team members for the contracts in the list
  Map<Id, Set<Id>> existingDevTeamsMap = new Map<Id, Set<Id>>();
  for (Grid_DeliveryTeamMembers__c devTeam : [SELECT Id, Grid_Contract__c, Grid_Delivery_Team_User__c FROM Grid_DeliveryTeamMembers__c WHERE Grid_Contract__c IN :contracts]) {
      if (!existingDevTeamsMap.containsKey(devTeam.Grid_Delivery_Team_User__c)) {
          existingDevTeamsMap.put(devTeam.Grid_Delivery_Team_User__c, new Set<Id>());
      }
      existingDevTeamsMap.get(devTeam.Grid_Delivery_Team_User__c).add(devTeam.Grid_Contract__c);
  }
  
  List<Grid_DeliveryTeamMembers__c> devTeamsToUpdate = new List<Grid_DeliveryTeamMembers__c>();
  for (Contract con : contracts) {
      for (User user : users) {
          if (existingDevTeamsMap.containsKey(user.Id) && existingDevTeamsMap.get(user.Id).contains(con.Id)) {
              // If a record already exists with the same user and contract Id, don't add it again
              continue;
          }
          Grid_DeliveryTeamMembers__c devTeam = new Grid_DeliveryTeamMembers__c();
          devTeam.Grid_Delivery_Team_User__c = user.Id;
          devTeam.Grid_Contract__c = con.Id;
          devTeamsToUpdate.add(devTeam);
      }
  }
  
  if (!devTeamsToUpdate.isEmpty()) {
      insert devTeamsToUpdate;
  }
}
/**
* This Method to Update status to Closed/Under Warranty of Contract when status is equal to Activated
* 
*
* @Author  Salesforce
*
*/
     public static void updateContractStatus(List<Contract> contractsToUpdate) {
  
        for (Contract contract : contractsToUpdate) {
            if (contract.Grid_Total_planned_quantity__c == contract.Grid_Total_Actual_quantity__c) {
                contract.Status = 'Closed/under warranty';
        }
        
    }
    
}

/**
* This Method is to create the revenue schedule version 2 for the contract when the contract is activated
* 
*
* @Author  Salesforce
*
*/

  public static void createHWRevenueScheduleVersion2(
    List<Revenue__c> revenueList,
    Set<Id> contractIds
  ) {

    date revSchedStart;
    date revSchedEnd;
    String revSchedName;
    List<String> prodSchedNames;
    Integer deliveryPlanCount;
    List<Grid_RevenueSchedule__c> revSchedList = new List<Grid_RevenueSchedule__c>();
    Map<Id, List<vlocity_cmt__ContractLineItem__c>> listContractLineItemMap = new Map<Id, List<vlocity_cmt__ContractLineItem__c>>();
    List<vlocity_cmt__ContractLineItem__c> listContractLineItemtem = new List<vlocity_cmt__ContractLineItem__c>();
    Map<String, ProductSchedule__c> prodSchedMap = new Map<String, ProductSchedule__c>();
    Integer nMonths;
    Date tempDate;
    Double sum = 0;
    String psName;
    List<ProductSchedule__c> prodSchedOfYear = new List<ProductSchedule__c>();
    listContractLineItemtem = [ 
      SELECT
        Id,
        vlocity_cmt__ContractId__c,
        vlocity_cmt__Product2Id__r.Name,
        vlocity_cmt__Product2Id__r.Grid_IsChild__c,
        vlocity_cmt__Product2Id__r.Grid_Category__c,
        vlocity_cmt__OneTimeTotal__c,
        Grid_RecurringTotalYearly__c,    
        vlocity_cmt__RecurringTotal__c,  
        Grid_ParentItemId__c,  
        OpenMeterFormula__c,  
        CurrencyIsoCode
      FROM vlocity_cmt__ContractLineItem__c
      WHERE vlocity_cmt__ContractId__c IN :contractIds AND vlocity_cmt__Product2Id__r.Grid_Category__c IN ('Hardware') AND vlocity_cmt__Product2Id__r.Grid_IsChild__c = true
    ];

    for (vlocity_cmt__ContractLineItem__c clItem : listContractLineItemtem) {
      if (listContractLineItemMap.containsKey(clItem.vlocity_cmt__ContractId__c)) {
        listContractLineItemMap.get(clItem.vlocity_cmt__ContractId__c).add(clItem);
      } else {
        listContractLineItemMap.put(
          clItem.vlocity_cmt__ContractId__c,
          new List<vlocity_cmt__ContractLineItem__c>{ clItem }
        );
      }
    }
    for (Revenue__c rev : revenueList) {
      double plannedAmount;
      string metric;
      List<Grid_RevenueSchedule__c> revSchedToDelete = [
        SELECT Id, Grid_Revenue__c, Grid_Category__c
        FROM Grid_RevenueSchedule__c
        WHERE Grid_Revenue__c = :rev.Id AND Grid_Category__c IN ('Hardware')
      ];
      if(!revSchedToDelete.isEmpty()){
        try {
          delete revSchedToDelete;
        } catch (DmlException e) {
          System.debug('cannot delete existing hardware revenue schedules');
        }
      }

      List<Deliveryplan__c> contractDeliveryPlan = [
        SELECT Id, Grid_Contract__c, Grid_ScheduleCount__c, Grid_ScheduleFrequency__c,Grid_Version__c
        FROM Deliveryplan__c
        WHERE Grid_Contract__c =: rev.Grid_Contract__c AND Grid_Version__c = 2
      ];
      List<vlocity_cmt__ContractLineItem__c> contractLineItemByRevenue = listContractLineItemMap.get(
        rev.Grid_Contract__c
      );
      if (listContractLineItemMap.size() > 0) {
        for (vlocity_cmt__ContractLineItem__c clItem : contractLineItemByRevenue) {
          List<ProductSchedule__c> prodSchedList = [
            SELECT Id, Name, Grid_PlannedAmn__c, Grid_ContractLine__c
            FROM ProductSchedule__c
            WHERE Grid_ContractLine__c =: clItem.ID
            AND Grid_Version__c = 2
          ];
          for (ProductSchedule__c ps : prodSchedList) {
            prodSchedMap.put(ps.Name, ps);
          }
          // for each contracted year
          for (integer i = 0; i < rev.Grid_Count__c; i++) {
            sum = 0;
            revSchedStart = i > 0 ? revSchedStart.addYears(1) : rev.Grid_StartDate__c;
            revSchedEnd = revSchedStart.addYears(1)<rev.Grid_EndDate__c ? revSchedStart.addYears(1) : rev.Grid_EndDate__c;
            revSchedName = DateTime.newInstance(         
              revSchedStart.year(),
              revSchedStart.month(),
              revSchedStart.day()
              ).format('YYYY');
            deliveryPlanCount = Integer.valueOf(contractDeliveryPlan[0].Grid_ScheduleCount__c);
            if(contractDeliveryPlan[0].Grid_ScheduleFrequency__c == 'Monthly'){
              if (i==0){  // first year
                tempDate = Date.newInstance(rev.Grid_StartDate__c.year(),12,31);
                nMonths = rev.Grid_StartDate__c.monthsBetween(tempDate)+1;
                for(Integer j=0; j<nMonths; j++){
                  psName = DateTime.newInstance(         
                    revSchedStart.year(),
                    revSchedStart.month()+j,
                    revSchedStart.day()
                    ).format('MMM-yyyy');
                  sum = prodSchedMap.containsKey(psName)? sum + prodSchedMap.get(psName).Grid_PlannedAmn__c : sum;
                }
              } else if (i>0 && i<rev.Grid_Count__c-1){  
                for(Integer j=0; j<12; j++){
                  tempDate = Date.newInstance(revSchedStart.year(),1,1);
                  psName = DateTime.newInstance(         
                    tempDate.year(),
                    tempDate.month()+j,
                    tempDate.day()
                    ).format('MMM-yyyy');
                  sum = prodSchedMap.containsKey(psName)? sum + prodSchedMap.get(psName).Grid_PlannedAmn__c : sum;
                }
              } else if (i == rev.Grid_Count__c-1) { 
                tempDate = Date.newInstance(rev.Grid_EndDate__c.year(),1,1); 
                nMonths = tempDate.monthsBetween(rev.Grid_EndDate__c)+1; 
                for(Integer j=0; j<nMonths; j++){
                  psName = DateTime.newInstance(         
                    tempDate.year(),
                    tempDate.month()+j,
                    tempDate.day()
                    ).format('MMM-yyyy');
                  sum = prodSchedMap.containsKey(psName)? sum + prodSchedMap.get(psName).Grid_PlannedAmn__c : sum;
                }
              } 
            }
            // if delivery plan is yearly
            else if(contractDeliveryPlan[0].Grid_ScheduleFrequency__c == 'Yearly'){
              psName = DateTime.newInstance(         
                revSchedStart.year(),
                revSchedStart.month(),
                revSchedStart.day()
                ).format('YYYY');
              sum = prodSchedMap.containsKey(psName)? prodSchedMap.get(psName).Grid_PlannedAmn__c : 0;
            }
            // if delivery plan is one-time
            else if(contractDeliveryPlan[0].Grid_ScheduleFrequency__c == 'One Time'){
              sum = 0;
              for(String key : prodSchedMap.keySet()){
                if(key.contains(revSchedStart.year()+'')){
                  sum = prodSchedMap.get(key).Grid_PlannedAmn__c;
                }
              }
            }

            // filling revenue schedule fields for that clitem and year
            plannedAmount = sum;
            metric = 'One Time';
            String model;
            if(!String.isBlank(clItem.OpenMeterFormula__c)){
              model = clItem.OpenMeterFormula__c;
            }
            // create revenue schedule
            revSchedList.add(
              new Grid_RevenueSchedule__c(
                Name = revSchedName,
                Grid_ContractLine__c = clItem.Id,
                Grid_Category__c = clItem.vlocity_cmt__Product2Id__r.Grid_Category__c,
                Grid_Metric__c = metric,
                Grid_Model__c = model,
                Grid_PlannedAmount__c = plannedAmount,
                Grid_StartDate__c = revSchedStart,
                Grid_EndDate__c = revSchedEnd,
                Grid_Version__c = 2,
                Grid_Revenue__c = rev.Id,
                CurrencyIsoCode = clItem.CurrencyIsoCode
              )
            );
          }
        }
      }
    }
    if (revSchedList.size() > 0){
      insert revSchedList;
    }
  }
}