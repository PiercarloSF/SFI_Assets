public with sharing class Grid_OrderProductServiceClass {
    public static void checkSumOfOrderProductQuantities(Id orderId) {
        Set<Id> contractLineItemProductIds = new Set<Id>();
        Map<Id, Decimal> contractLineItemQuantities = new Map<Id, Decimal>();
        Map<Id, Decimal> contractLineItemQuantitiesSummed = new Map<Id, Decimal>();


        // Retrieve contract id from order
        Id contractId = [
                SELECT Id, ContractId
                FROM Order
                WHERE Id = :orderId
        ].ContractId;

        // Retrieve the Order Products
        List<OrderItem> orderProducts = [
                SELECT Id, Quantity ,OrderId ,Product2.Id,Product2.Name
                FROM OrderItem
                WHERE OrderId = :orderId
        ];

        // Retrieve the Contract Line Item IDs associated with the Order Products
        for (OrderItem orderProduct : orderProducts) {
            if(orderProduct.Product2 != null) contractLineItemProductIds.add(orderProduct.Product2.Id);
        }

        // Query the contract line items associated to order product and store the quantity inside contractLineItemQuantities
        System.debug('Contract line items');
        for (vlocity_cmt__ContractLineItem__c contractLineItem : [
                SELECT Id, vlocity_cmt__Quantity__c, vlocity_cmt__Product2Id__r.Id,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__ContractId__c
                FROM vlocity_cmt__ContractLineItem__c
                WHERE vlocity_cmt__Product2Id__r.Id IN :contractLineItemProductIds AND vlocity_cmt__ContractId__c = :contractId
        ]) {
            System.debug('product name : ' + contractLineItem.vlocity_cmt__Product2Id__r.Name + ' quantity : ' + contractLineItem.vlocity_cmt__Quantity__c);
            contractLineItemQuantities.put(contractLineItem.vlocity_cmt__Product2Id__r.Id, contractLineItem.vlocity_cmt__Quantity__c);
        }

        // Query the Contract Line Items and calculate the total quantities of associated Order Products
        System.debug('Order products sum of quantities');
        for (AggregateResult result : [ 
                SELECT Product2.Id productId, SUM(Quantity) sumQuantity
                FROM OrderItem
                WHERE Product2.Id IN :contractLineItemProductIds AND Order.ContractId = :contractId
                GROUP BY Product2.Id
        ]) {
            Id contractLineItemProductId = (Id) result.get('productId');
            Decimal sumQuantity = (Decimal) result.get('sumQuantity');
            System.debug('product Id : ' + contractLineItemProductId + ' quantity : ' + sumQuantity);
            contractLineItemQuantitiesSummed.put(contractLineItemProductId, sumQuantity);
        }
        // Perform quantity verification and display error messages
        System.debug('Comparing quantities');
        String message = 'You have exceeded the quantity of the following products: ';
        for (OrderItem orderProduct : orderProducts) {
            Decimal contractLineItemQuantity = contractLineItemQuantities.get(orderProduct.Product2.Id);
            Decimal contractLineItemQuantitySummed = contractLineItemQuantitiesSummed.get(orderProduct.Product2.Id);
            if (contractLineItemQuantity != null && contractLineItemQuantitySummed != null && contractLineItemQuantity < contractLineItemQuantitySummed) {
                message += orderProduct.Product2.Name + ' by ' + (contractLineItemQuantitySummed - contractLineItemQuantity) + ' units. ';
                System.debug(message);
            }
        }
        // output.put('quantityChecked', true);
    }
}