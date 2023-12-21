public class OrderItemTriggerHandlerCustom extends TriggerHandler {
    
    public OrderItemTriggerHandlerCustom() {}
    
    public override void beforeInsert() {
        Grid_OrderItemServiceClass.updateOrderItem(Trigger.new, true);
    }
    
    public override void beforeUpdate() {
        Grid_OrderItemServiceClass.updateOrderItem(Trigger.new, true);
    }
    
    /*
    public override void beforeInsert() {
        Grid_OrderItemServiceClass.updateOrderItem(Trigger.new, false);
    }
    
    public override void beforeUpdate() {
        Grid_OrderItemServiceClass.updateOrderItem(Trigger.new, false);
    }
	*/
}