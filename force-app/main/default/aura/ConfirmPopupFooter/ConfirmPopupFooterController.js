({
    confirmAction : function(component, event, helper) {
        component.set("v.isConfirmRemove",true);
        component.find("confirmOverlay").notifyClose();
    },
    cancelAction : function(component, event, helper) {
        component.set("v.isConfirmRemove",false);
        component.find("confirmOverlay").notifyClose();
    }
})