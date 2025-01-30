({
    init: function (component, event, helper) {
        helper.initEscalationType(component, event);
        helper.isSetReadOnly(component, event);
    },

    onChangePricing: function (component, event, helper) {
        component.set("v.isChangePricing", true);
    },

    onChangeDatePeriod: function (component, event, helper) {
        var camDetail = component.get("v.camPricing");
        var periodIndex = event.getSource().get("v.name");

        camDetail.CAMYearPeriod[periodIndex].isEditRecord = true;
        component.set("v.camPricing", camDetail);
        component.set("v.isChangePricing", true);
        component.set("v.isRenewChangeDate", true);
    },

    removeCAMAirServicePeriod: function (component, event, helper) {
        var oppDetail = component.get("v.oppObject");

        if (oppDetail.popupSetting["การลบ CAM Period"].tms_Enable__c) {
            var modalBody;
            var modalFooter;
            $A.createComponents(
                [
                    ["c:ConfirmPopup", {}],
                    ["c:ConfirmPopupFooter", { isConfirmRemove: component.getReference("v.isConfirmRemove") }]
                ],
                function (content, status) {
                    if (status === "SUCCESS") {
                        modalBody = content[0];
                        modalFooter = content[1];
                        component.find("confirmOverlay").showCustomModal({
                            cssClass: "confirmModal",
                            header: "Do you want to delete record?",
                            body: modalBody,
                            footer: modalFooter,
                            showCloseButton: true,

                            closeCallback: function () {
                                console.log("You closed the alert!");
                                var isConfirm = component.get("v.isConfirmRemove");

                                if (isConfirm) {
                                    component.set("v.isChangePricing", true);
                                    var camPricing = component.get("v.camPricing");
                                    var newPeriodList = [...camPricing.CAMYearPeriod];

                                    var indexPosition = event.target.name;
                                    console.log("Delete Row ", indexPosition);

                                    // newPeriodList.splice(indexPosition, 1);
                                    newPeriodList[indexPosition].isToDeleteRecord = true;

                                    camPricing.CAMYearPeriod = newPeriodList;
                                    component.set("v.camPricing", camPricing);
                                    component.set("v.isConfirmRemove", false);
                                }
                            }
                        });
                    }
                }
            );
        } else {
            component.set("v.isChangePricing", true);
            var camPricing = component.get("v.camPricing");
            var newPeriodList = [...camPricing.CAMYearPeriod];

            var indexPosition = event.target.name;
            console.log("Delete Row ", indexPosition);

            // newPeriodList.splice(indexPosition, 1);
            newPeriodList[indexPosition].isToDeleteRecord = true;

            camPricing.CAMYearPeriod = newPeriodList;
            component.set("v.camPricing", camPricing);
        }
    },
    onBlurMeasurmentPrice: function (component, event, helper) {
        var isSelectEscalation = component.get("v.isSelectCAMEscalation");
        var isSelectAdvance = component.get("v.isSelectCAMAdvance");
        var isSelectCAMType = component.get("v.isSelectedCAMType");
        var isSelectAirService = component.get("v.isSelectedAirServiceType");
        var isEditPaymentDueDate = component.get("v.isEditPaymentDueDate");
        var camDetail = component.get("v.camPricing");
        var oppDetail = component.get("v.oppObject");

        console.log("isSelectAdvance", isSelectAdvance);
        console.log("isSelectEscalation", isSelectEscalation);
        debugger;

        if (isEditPaymentDueDate) {
            if (
                oppDetail.leaseType == "Short-Term" ||
                (oppDetail.leaseType == "Long-Term" && oppDetail.longleaseType == "ระบุราคาทุกปีตามปีสัญญา")
            ) {
                if (isSelectEscalation) {
                    helper.onChangeMeasurmentPriceEscalationHelper(component, event, true);
                }

                if (isSelectAdvance) {
                    helper.onChangeMeasurmentPriceEscalationAdvance(component, event, true);
                }
            }
            if (oppDetail.leaseType == "Long-Term" && oppDetail.longleaseType == "ระบุราคาปีปฏิทินแรก") {
                helper.onChangeMeasurmentPriceEscalationAdvance(component, event, true);
            }
        } else {
            if (isSelectEscalation) {
                helper.onChangeMeasurmentPriceEscalationHelper(component, event, true);
            }

            if (isSelectAdvance) {
                helper.onChangeMeasurmentPriceEscalationAdvance(component, event, true);
            }
        }
    },
    onChangeMeasurmentPrice: function (component, event, helper) {
        console.log("Change Price");
        component.set("v.isChangePricing", true);
        var isSelectEscalation = component.get("v.isSelectCAMEscalation");
        var isSelectAdvance = component.get("v.isSelectCAMAdvance");
        var isSelectCAMType = component.get("v.isSelectedCAMType");
        var isSelectAirService = component.get("v.isSelectedAirServiceType");
        var camDetail = component.get("v.camPricing");
        var isEditPaymentDueDate = component.get("v.isEditPaymentDueDate");
        var oppDetail = component.get("v.oppObject");

        console.log("isSelectAdvance", isSelectAdvance);
        console.log("isSelectEscalation", isSelectEscalation);
        debugger;

        if (isEditPaymentDueDate) {
            if (
                oppDetail.leaseType == "Short-Term" ||
                (oppDetail.leaseType == "Long-Term" && oppDetail.longleaseType == "ระบุราคาทุกปีตามปีสัญญา")
            ) {
                if (isSelectEscalation) {
                    helper.onChangeMeasurmentPriceEscalationHelper(component, event, false);
                }

                if (isSelectAdvance) {
                    helper.onChangeMeasurmentPriceEscalationAdvance(component, event, false);
                }
            }
            if (oppDetail.leaseType == "Long-Term" && oppDetail.longleaseType == "ระบุราคาปีปฏิทินแรก") {
                helper.onChangeMeasurmentPriceEscalationAdvance(component, event, false);
            }
        } else {
            if (isSelectEscalation) {
                helper.onChangeMeasurmentPriceEscalationHelper(component, event, false);
            }

            if (isSelectAdvance) {
                helper.onChangeMeasurmentPriceEscalationAdvance(component, event, false);
            }
        }
    },

    onCAMTypeGroup: function (component, event, helper) {
        var camPricing = component.get("v.camPricing");
        var selected = event.getSource().getLocalId();
        var oppObject = component.get("v.oppObject");
        var isEditPaymentDueDate = component.get("v.isEditPaymentDueDate");

        debugger;
        if (isEditPaymentDueDate) {
            camPricing.CAMCondition = selected;
            component.set("v.isChangePricing", true);

            if (selected === "% Escalation") {
                component.set("v.isSelectCAMAdvance", false);
                component.set("v.isDisableAddCAMPeriod", true);

                var originalEsclateCAMPricing = component.get("v.originalEsclateCAMPricing");
                var new_originalEsclateCAMPricingPeriod = [
                    ...originalEsclateCAMPricing.CAMYearPeriod_Original_Contract
                ];

                new_originalEsclateCAMPricingPeriod = new_originalEsclateCAMPricingPeriod.map(function (camRowData) {
                    if (!camRowData.isLockPeriod) {
                        camRowData.IsDisableInput = true;

                        camRowData.CAMMeasurmentList = camRowData.CAMMeasurmentList.map(function (camMeasurementRow) {
                            camMeasurementRow.Price.IsDisabled = true;
                            return camMeasurementRow;
                        });
                    }

                    return camRowData;
                });

                component.set("v.camPricing.CAMYearPeriod", new_originalEsclateCAMPricingPeriod);
            } else {
                component.set("v.isSelectCAMEscalation", false);
                component.set("v.isDisableAddCAMPeriod", false);

                var newCAMPeriodList = [...camPricing.CAMYearPeriod];

                newCAMPeriodList = newCAMPeriodList.map(function (camRowData) {
                    if (!camRowData.isLockPeriod) {
                        camRowData.IsDisableInput = false;

                        camRowData.CAMMeasurmentList = camRowData.CAMMeasurmentList.map(function (camMeasurementRow) {
                            camMeasurementRow.Price.IsDisabled = false;
                            return camMeasurementRow;
                        });
                    }

                    return camRowData;
                });

                camPricing.CAMYearPeriod = newCAMPeriodList;
                component.set("v.camPricing", camPricing);
            }
        } else {
            camPricing.CAMCondition = selected;
            component.set("v.isChangePricing", true);

            if (selected === "% Escalation") {
                component.set("v.isSelectCAMAdvance", false);
                component.set("v.isDisableAddCAMPeriod", true);

                if (component.get("v.isInitialPageWithCAM") && oppObject.camOrAirEscalationType === "% Escalation") {
                    helper.getSavedCAMDetaiHelper(component, event);
                } else {
                    if (component.get("v.isInitialPageWithCAM")) {
                        helper.setEscalatePeriodFromAdvance(component, event, camPricing);
                    } else {
                        helper.getDefaultCAMDetaiHelper(component, event);
                    }
                }
            } else {
                component.set("v.isSelectCAMEscalation", false);
                component.set("v.isDisableAddCAMPeriod", false);

                if (component.get("v.isInitialPageWithCAM") && oppObject.camOrAirEscalationType === "Advance") {
                    helper.getSavedCAMDetaiHelper(component, event);
                } else {
                    camPricing.CAMEscationRate.IsDisabled = true;
                    var newCAMPeriodList = [...camPricing.CAMYearPeriod];

                    newCAMPeriodList = newCAMPeriodList.map(function (camRowData) {
                        camRowData.IsDisableInput = false;

                        camRowData.CAMMeasurmentList = camRowData.CAMMeasurmentList.map(function (camMeasurementRow) {
                            camMeasurementRow.Price.IsDisabled = false;
                            return camMeasurementRow;
                        });

                        return camRowData;
                    });

                    camPricing.CAMYearPeriod = newCAMPeriodList;
                    component.set("v.camPricing", camPricing);
                    // helper.addCAMPeriodHelper(component, event);
                }
            }
            console.log(component.get("v.isSelectCAMEscalation"));
            console.log(component.get("v.isSelectCAMAdvance"));
        }
    },

    addCAMPeriod: function (component, event, helper) {
        helper.addCAMPeriodHelper(component, event);
        component.set("v.isChangePricing", true);
    }
});
