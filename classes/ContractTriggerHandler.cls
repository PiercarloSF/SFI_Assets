/**
* Class to implement the trigger handler for Opportunity Object
*
* @Author  Salesforce
*
*/
public class ContractTriggerHandler extends TriggerHandler {
    Map<Id, Contract> newContractsMap = new Map<Id, Contract>();
    Map<Id, Contract> oldContractsMap = new Map<Id, Contract>();
    List<Contract> contracts = new List<Contract>();
    List<Contract> newContracts = new List<Contract>();
    List<Contract> oldContracts = new List<Contract>();
    
    public ContractTriggerHandler() {
        this.newContractsMap = (Map<Id, Contract>) Trigger.newMap;
        this.oldContractsMap = (Map<Id, Contract>) Trigger.oldMap;
    }
    public override void beforeInsert() {
        Grid_AutoNumberUtil.handleContractAutoNumber(Trigger.new);
        Grid_ContractServiceClass.updateInsertContract(Trigger.new);
    }
    public override void beforeUpdate() {
        List<Contract> contractsOnActivated = new List<Contract>();
        for (Id newContractId : newContractsMap.keySet()) {
            if (
                newContractsMap.get(newContractId).Status !=
                oldContractsMap.get(newContractId).Status ||
                newContractsMap.get(newContractId).Scheda_231_status__c !=
                oldContractsMap.get(newContractId).Scheda_231_status__c ||
                newContractsMap.get(newContractId).Grid_Scheda231DeliveryStatus__c !=
                oldContractsMap.get(newContractId).Grid_Scheda231DeliveryStatus__c
            ) {
                contracts.add(newContractsMap.get(newContractId));
            }
            
            if (
                newContractsMap.get(newContractId).OwnerId !=
                oldContractsMap.get(newContractId).OwnerId &&
                newContractsMap.get(newContractId).Status == 'Handover'
            ) {
                newContracts.add(newContractsMap.get(newContractId));
                oldContracts.add(oldContractsMap.get(newContractId));
            }
            if (newContractsMap.get(newContractId).Grid_Total_Actual_quantity__c!=
                oldContractsMap.get(newContractId).Grid_Total_Actual_quantity__c &&
                newContractsMap.get(newContractId).Status == 'Activated') {
                    contractsOnActivated.add(newContractsMap.get(newContractId));
                }
            
        }
        
        if(!contractsOnActivated.isEmpty()){
            Grid_ContractServiceClass.updateContractStatus(contractsOnActivated);
        }
        if (!contracts.isEmpty()) {
            Grid_ContractServiceClass.updateContract(contracts);
            Grid_ContractServiceClass.updateInsertContract(contracts);
        }
        
        if (!oldContracts.isEmpty() && !newContracts.isEmpty()){
            Grid_WithoutSharingServiceClass.updateAccountTeam(oldContracts);
            Grid_ContractServiceClass.notifyNewOwner(newContracts);
        }
        
           Grid_ContractServiceClass.notifyContractTeamMembers(Trigger.new);
           //Grid_ContractServiceClass.updateNonOwner(Trigger.new);
        
    }
    
    public override void afterUpdate() {
        List<Contract> contractsOnHandover = new List<Contract>();
        Set<Id> activatedContractIds = new Set<Id>();
        
        for (Id newContractId : newContractsMap.keySet()) {
            if (newContractsMap.get(newContractId).Status !=
                oldContractsMap.get(newContractId).Status &&
                newContractsMap.get(newContractId).Status == 'Activated') {
                    activatedContractIds.add(newContractId);
                }
            if (newContractsMap.get(newContractId).Status !=
                oldContractsMap.get(newContractId).Status &&
                newContractsMap.get(newContractId).Status == 'Handover') {
                    contractsOnHandover.add(newContractsMap.get(newContractId));
                }
        }
        if(!activatedContractIds.isEmpty()){
            Grid_WithoutSharingServiceClass.cloneDeliveryPlan(activatedContractIds);
            Grid_OrderServiceClass.cloneRevenue(activatedContractIds);
            Grid_OrderServiceClass.cloneRevenueSchedules(activatedContractIds);        
        }
        
        if(!contractsOnHandover.isEmpty()){
            Grid_ContractServiceClass.getUsersFromPublicGroup(contractsOnHandover);
            Grid_ContractPlatformEvent.callPlatformEvent(contractsOnHandover);
        }
        
    }
}