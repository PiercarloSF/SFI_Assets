export const OMNIDEF = {"userTimeZone":-420,"userProfile":"System Administrator","userName":"pdrimaco-46235232234@industryapps.edu","userId":"005Hp00000fifjTIAQ","userCurrencyCode":"USD","timeStamp":"2023-10-12T10:39:12.317Z","sOmniScriptId":"a29Hp00000AASSrIAP","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"trackingCustomData":{},"timeTracking":false,"stylesheet":{"newportRtl":"","newport":"","lightningRtl":"","lightning":""},"stepChartPlacement":"right","ssm":false,"showInputWidth":false,"seedDataJSON":{},"saveURLPatterns":{},"saveObjectId":"%ContextId%","saveNameTemplate":null,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveContentEncoded":false,"rtpSeed":false,"pubsub":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge"}],"message":{},"lkObjName":null,"knowledgeArticleTypeQueryFieldsMap":{},"hideStepChart":false,"errorMessage":{"custom":[]},"enableKnowledge":false,"elementTypeToHTMLTemplateMapping":{},"disableUnloadWarn":true,"currencyCode":"","consoleTabTitle":null,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"SObject","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":true,"allowCancel":true},"prefillJSON":"{}","lwcId":"f18a15f0-f126-40a2-613a-7f4050fb3ada","labelMap":{"ValidationMessage":"ValidationStep:ValidationMessage","AdditionalMessage":"ValidationStep:AdditionalMessage","noDiscountsFound":"ValidationStep:noDiscountsFound","ErrorMessages":"HandleErrors:ErrorMessages","Messaging3":"Step3:Messaging3","DoneAction":"DoneAction","refreshContractRecordPage":"refreshContractRecordPage","ValidationStep":"ValidationStep","HandleErrors":"HandleErrors","Grid_RollBackIsFrameAgreedActivated":"Grid_RollBackIsFrameAgreedActivated","Grid_UpdateRecordTypeContract":"Grid_UpdateRecordTypeContract","ActivateFrameAgreementIP":"ActivateFrameAgreementIP","Grid_UpdateIsFrameAgreedActivated":"Grid_UpdateIsFrameAgreedActivated","Step3":"Step3","FrameAgreementInputs":"FrameAgreementInputs","ExtractContractDetails":"ExtractContractDetails"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"None","ssm":false,"showPersistentComponent":[false,false],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"ExtractContractDetails","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"dataRaptor Input Parameters":[{"inputParam":"Id","element":"ContextId"}],"controlWidth":12,"bundle":"ExtractFrameContractForActivation","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"ExtractContractDetails","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"ExtractContractDetails","lwcId":"lwc0"},{"type":"Set Values","propSetMap":{"wpm":false,"validationRequired":"None","ssm":false,"showPersistentComponent":[false,false],"show":null,"pubsub":false,"message":{},"label":"FrameAgreementInputs","elementValueMap":{"isFrameActivated":true,"isEligible":"=%FrameContract:ProfitLoss% && %FrameContract:SignedContract%","activationStatus":"Activated"},"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"FrameAgreementInputs","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"FrameAgreementInputs","lwcId":"lwc1"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"isEligible","data":"true","condition":"<>"}],"operator":"AND"}},"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":"0","previousLabel":"Previous","nextWidth":"0","nextLabel":"Next","message":{},"label":"Step3","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","allowSaveForLater":false,"HTMLTemplateId":"","uiElements":{"Step3":""},"aggElements":{}},"offSet":0,"name":"Step3","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Validation","rootIndex":2,"response":null,"propSetMap":{"validateExpression":{"group":{"rules":[{"field":"isEligible","data":"true","condition":"="}],"operator":"AND"}},"show":null,"messages":[{"value":true,"type":"Warning","text":"","active":false},{"value":false,"type":"Requirement","text":"You  cannot active the contract until you checked the mandatory fields","active":true}],"label":"Messaging3","hideLabel":true,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":""},"name":"Messaging3","level":1,"JSONPath":"Step3:Messaging3","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bMessaging":true,"lwcId":"lwc20-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"Step3","lwcId":"lwc2"},{"type":"DataRaptor Post Action","propSetMap":{"wpm":false,"validationRequired":"Submit","ssm":false,"showPersistentComponent":[true,false],"show":null,"sendJSONPath":"","sendJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postTransformBundle":"","postMessage":"Done","message":{},"label":"Grid_UpdateIsFrameAgreedActivated","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","bundle":"Grid_UpdateIsFrameAgreedActivated","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"Grid_UpdateIsFrameAgreedActivated","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"bDataRaptorPostAction":true,"JSONPath":"Grid_UpdateIsFrameAgreedActivated","lwcId":"lwc3"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"None","useContinuation":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[false,false],"show":null,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"preTransformBundle":"","postTransformBundle":"","chainable":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"ActivateFrameAgreementIP","integrationProcedureKey":"ActivateFrameAgreement_Quote","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{"parentObjectName":"Quote","originalContractId":"%originalContractId%","activationStatus":"%activationStatus%","Id":"%ContextId%"},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"ActivateFrameAgreementIP","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"ActivateFrameAgreementIP","lwcId":"lwc4"},{"type":"DataRaptor Post Action","propSetMap":{"wpm":false,"validationRequired":"Submit","ssm":false,"showPersistentComponent":[false,false],"show":null,"sendJSONPath":"","sendJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postTransformBundle":"","postMessage":"Done","message":{},"label":"Grid_UpdateRecordTypeContract","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"bundle":"Grid_UpdateRecordTypeContract","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"Grid_UpdateRecordTypeContract","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"bDataRaptorPostAction":true,"JSONPath":"Grid_UpdateRecordTypeContract","lwcId":"lwc5"},{"type":"DataRaptor Post Action","propSetMap":{"wpm":false,"validationRequired":"Submit","ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"result:error","data":"","condition":"<>"}],"operator":"AND"}},"sendJSONPath":"","sendJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postTransformBundle":"","postMessage":"Done","message":{},"label":"Grid_RollBackIsFrameAgreedActivated","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","bundle":"Grid_RollBackIsFrameAgreedActivated","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"Grid_RollBackIsFrameAgreedActivated","level":0,"indexInParent":6,"bHasAttachment":false,"bEmbed":false,"bDataRaptorPostAction":true,"JSONPath":"Grid_RollBackIsFrameAgreedActivated","lwcId":"lwc6"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"result:error","data":"","condition":"<>"}],"operator":"AND"}},"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","message":{},"label":"Step2","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"HandleErrors":""},"aggElements":{}},"offSet":0,"name":"HandleErrors","level":0,"indexInParent":7,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Validation","rootIndex":7,"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"validateExpression":{"group":{"rules":[{"field":"sucess","data":"false","condition":"="}],"operator":"AND"}},"trackingCustomData":{},"timeTracking":false,"ssm":false,"showInputWidth":false,"show":null,"seedDataJSON":{},"saveURLPatterns":{},"saveObjectId":"%ContextId%","saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveContentEncoded":false,"rtpSeed":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge"}],"messages":[{"value":true,"type":"Success","text":"","active":false},{"value":false,"type":"Requirement","text":"%result:error%","active":true}],"message":{},"label":"ErrorMessages","knowledgeArticleTypeQueryFieldsMap":{},"hideStepChart":false,"hideLabel":true,"enableKnowledge":false,"elementTypeToHTMLTemplateMapping":{},"disOnTplt":false,"controlWidth":12,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"SObject","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":true,"Type__c":{"type":"typeahead-excluded-input","label":"Validation"},"HTMLTemplateId":""},"name":"ErrorMessages","level":1,"JSONPath":"HandleErrors:ErrorMessages","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bMessaging":true,"lwcId":"lwc70-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"HandleErrors","lwcId":"lwc7"},{"type":"Step","propSetMap":{"validationRequired":true,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"isMasterAgreement","data":"false","condition":"="},{"field":"deactivatedDscntValidation","data":null,"condition":"<>"},{"group":{"rules":[{"field":"modifiedDscntValidation","data":null,"condition":"<>"}],"operator":"OR"}}],"operator":"AND"}},"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","label":"ValidationStep","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","HTMLTemplateId":"","uiElements":{"ValidationStep":""},"aggElements":{"noDiscountsFound":"","AdditionalMessage":""}},"offSet":0,"name":"ValidationStep","level":0,"indexInParent":8,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Formula","rootIndex":8,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"mask":null,"label":"validation","inputWidth":12,"hideGroupSep":false,"hide":true,"expression":"true","disOnTplt":false,"dateFormat":"MM-dd-yyyy","dataType":null,"controlWidth":12,"HTMLTemplateId":""},"name":"noDiscountsFound","level":1,"JSONPath":"ValidationStep:noDiscountsFound","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc80-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Formula","rootIndex":8,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"mask":null,"label":"AdditionalMessage","inputWidth":12,"hideGroupSep":false,"hide":true,"expression":"String('Please Click next for Activating the Contract')","disOnTplt":false,"dateFormat":"MM-dd-yyyy","dataType":null,"controlWidth":12,"HTMLTemplateId":""},"name":"AdditionalMessage","level":1,"JSONPath":"ValidationStep:AdditionalMessage","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bFormula":true,"lwcId":"lwc81-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Validation","rootIndex":8,"response":null,"propSetMap":{"validateExpression":{"group":{"rules":[{"field":"modifiedDscntValidation","data":null,"condition":"<>"}],"operator":"AND"}},"show":{"group":{"rules":[{"field":"modifiedDscntValidation","data":null,"condition":"<>"}],"operator":"AND"}},"messages":[{"value":true,"type":"Success","text":"%modifiedDscntValidation%. %AdditionalMessage%","active":true},{"value":false,"type":"Requirement","text":"","active":false}],"label":"ValidationMessage","hideLabel":true,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":""},"name":"ValidationMessage","level":1,"JSONPath":"ValidationStep:ValidationMessage","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bMessaging":true,"lwcId":"lwc82-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"ValidationStep","lwcId":"lwc8"},{"type":"Remote Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[true,false],"show":null,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"refreshContractRecordPage","remoteClass":"Grid_SFIAllRemoteAction","redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"refreshContractRecordPage","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{"recordId":"%cartId%"},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"refreshContractRecordPage","level":0,"indexInParent":9,"bHasAttachment":false,"bEmbed":false,"bRemoteAction":true,"JSONPath":"refreshContractRecordPage","lwcId":"lwc9"},{"type":"Done Action","propSetMap":{"wpm":false,"validationRequired":"Submit","type":"SObject","ssm":false,"source":"%ContextId%","show":null,"redirectTemplateUrl":"vlcMobileConfirmation.html","redirectPageName":"mobileDone","pubsub":false,"message":{},"label":"DoneAction","disOnTplt":false,"controlWidth":12,"consoleTabLabel":"New","Outcome":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"DoneAction","level":0,"indexInParent":10,"bHasAttachment":false,"bEmbed":false,"JSONPath":"DoneAction","lwcId":"lwc10"}],"bReusable":true,"bpVersion":10,"bpType":"ActivateFrameAgreement","bpSubType":"Quote","bpLang":"English","bHasAttachment":false,"lwcVarMap":{}};