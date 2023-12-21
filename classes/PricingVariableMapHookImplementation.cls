global with sharing class PricingVariableMapHookImplementation implements vlocity_cmt.VlocityOpenInterface{

    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)  
    {
        try
        {
            System.debug('____ PricingVariableMapHookImplementation ' + methodName);

            if (methodName.equalsIgnoreCase('calculate.PreInvoke'))
            {
                // dump the input
                System.debug('--- calculate.PreInvoke input: ' + input);
            }
            else if (methodName.equalsIgnoreCase('calculate.PostInvoke'))
            {                
                // log the output
                System.debug('--- calculate.PostInvoke output: ' + JSON.serialize(output));

                // Retrieve the pricing variable map from the output
                Map<String, Object> pricingVariableCodeToValueMap = (Map<String, Object>)output.get('pricingVariableMap');

                // Retrieve the pricing log data map from the output
                Map<String, Object> pricingLogDataMap = (Map<String, Object>)output.get('pricingLogDataMap');

                // Retrieve the isRoot flag from the input
                Boolean isRoot = (Boolean)input.get('isRoot');
                System.debug('****isRoot: ' + isRoot);

                // Get the Line quantity value
                Decimal LINE_QUANTITY = (Decimal)pricingVariableCodeToValueMap.get('LINE_QUANTITY');
                System.debug('****LINE_QUANTITY: ' + LINE_QUANTITY);
				
				/**** YEARLY CHARGE (start) ****/
				// Get the REC_YEAR_STD_PRC pricing variable value 
                Decimal REC_YEAR_STD_PRC = (Decimal)pricingVariableCodeToValueMap.get('REC_YEAR_STD_PRC');
                System.debug('****REC_YEAR_STD_PRC: ' + REC_YEAR_STD_PRC);

                // Get the ROLLUP_REC_YEAR_STD_PRC_TOTAL pricing variable value 
                Decimal ROLLUP_REC_YEAR_STD_PRC_TOTAL = (Decimal)pricingVariableCodeToValueMap.get('ROLLUP_REC_YEAR_STD_PRC_TOTAL');
                System.debug('****ROLLUP_REC_YEAR_STD_PRC_TOTAL: ' + ROLLUP_REC_YEAR_STD_PRC_TOTAL);
                
                // Calculate the Recurring Total Yearly
                Decimal REC_YEAR_STD_PRC_TOTAL = (REC_YEAR_STD_PRC + ROLLUP_REC_YEAR_STD_PRC_TOTAL) * LINE_QUANTITY;
                System.debug('****REC_YEAR_STD_PRC_TOTAL: ' + REC_YEAR_STD_PRC_TOTAL);
                
                // Save the new REC_YEAR_STD_PRC_TOTAL rounded to 2 decimals in the pricing variable map of the line item
                pricingVariableCodeToValueMap.put('REC_YEAR_STD_PRC_TOTAL', REC_YEAR_STD_PRC_TOTAL.setScale(2, RoundingMode.HALF_UP));

                // Set the new pricing details information for the REC_YEAR_STD_PRC_TOTAL
                pricingLogDataMap.put('REC_YEAR_STD_PRC_TOTAL', 
                    new Map<String, Object>{
                        'format'=>'[{0} ({1}) x {2} ({3})] + Rollup {4} ({5})',
                        'data'=>new List<String>{'REC_YEAR_STD_PRC',                            // replaces {0}
                                                  String.valueOf(REC_YEAR_STD_PRC),             // replaces {1}
                                                 'LINE_QUANTITY',                               // replaces {2}
                                                 String.valueOf(LINE_QUANTITY),                 // replaces {3}
                                                 'REC_YEAR_STD_PRC_TOTAL',                      // replaces {4}
                                                 String.valueOf(ROLLUP_REC_YEAR_STD_PRC_TOTAL)  // replaces {5}
                                             }});
                System.debug('****pricingLogDataMap PRC: ' + pricingLogDataMap);
                
                if (isRoot)
                {
                    Decimal EFF_REC_YEAR_STD_PRC_TOTAL = REC_YEAR_STD_PRC_TOTAL;
                    pricingVariableCodeToValueMap.put('EFF_REC_YEAR_STD_PRC_TOTAL', EFF_REC_YEAR_STD_PRC_TOTAL.setScale(2, RoundingMode.HALF_UP));
                    System.debug('****isRoot EFF_REC_YEAR_STD_PRC_TOTAL: ' + EFF_REC_YEAR_STD_PRC_TOTAL);
                }
				/**** YEARLY CHARGE (end) ****/
                
				/**** YEARLY COST (start) ****/
				// Get the REC_YEAR_STD_CST pricing variable value 
                Decimal REC_YEAR_STD_CST = (Decimal)pricingVariableCodeToValueMap.get('REC_YEAR_STD_CST');
                System.debug('****REC_YEAR_STD_CST: ' + REC_YEAR_STD_CST);

                // Get the ROLLUP_REC_YEAR_STD_CST_TOTAL pricing variable value 
                Decimal ROLLUP_REC_YEAR_STD_CST_TOTAL = (Decimal)pricingVariableCodeToValueMap.get('ROLLUP_REC_YEAR_STD_CST_TOTAL');
                System.debug('****ROLLUP_REC_YEAR_STD_CST_TOTAL: ' + ROLLUP_REC_YEAR_STD_CST_TOTAL);
                
                // Calculate the Recurring Total Yearly
                Decimal REC_YEAR_STD_CST_TOTAL = (REC_YEAR_STD_CST + ROLLUP_REC_YEAR_STD_CST_TOTAL) * LINE_QUANTITY;
                System.debug('****REC_YEAR_STD_CST_TOTAL: ' + REC_YEAR_STD_CST_TOTAL);
                
                // Save the new REC_YEAR_STD_CST_TOTAL rounded to 2 decimals in the pricing variable map of the line item
                pricingVariableCodeToValueMap.put('REC_YEAR_STD_CST_TOTAL', REC_YEAR_STD_CST_TOTAL.setScale(2, RoundingMode.HALF_UP));

                // Set the new pricing details information for the REC_YEAR_STD_CST_TOTAL
                pricingLogDataMap.put('REC_YEAR_STD_CST_TOTAL', 
                    new Map<String, Object>{
                        'format'=>'[{0} ({1}) x {2} ({3})] + Rollup {4} ({5})',
                        'data'=>new List<String>{'REC_YEAR_STD_CST',                            // replaces {0}
                                                  String.valueOf(REC_YEAR_STD_CST),             // replaces {1}
                                                 'LINE_QUANTITY',                               // replaces {2}
                                                 String.valueOf(LINE_QUANTITY),                 // replaces {3}
                                                 'REC_YEAR_STD_CST_TOTAL',                      // replaces {4}
                                                 String.valueOf(ROLLUP_REC_YEAR_STD_CST_TOTAL)  // replaces {5}
                                             }});
                System.debug('****pricingLogDataMap CST: ' + pricingLogDataMap);
                
                if (isRoot)
                {
                    Decimal EFF_REC_YEAR_STD_CST_TOTAL = REC_YEAR_STD_CST_TOTAL;
                    pricingVariableCodeToValueMap.put('EFF_REC_YEAR_STD_CST_TOTAL', EFF_REC_YEAR_STD_CST_TOTAL.setScale(2, RoundingMode.HALF_UP));
                    System.debug('****isRoot EFF_REC_YEAR_STD_CST_TOTAL: ' + EFF_REC_YEAR_STD_CST_TOTAL);
                }
				/**** YEARLY COST (end) ****/
                
                /**** ONE TIME COST - ORDER ITEM (start) ****/
                // Get the Grid_OT_STD_CST pricing variable value 
				Decimal Grid_OT_STD_CST_Temp = (Decimal)pricingVariableCodeToValueMap.get('Grid_OT_STD_CST');
                Decimal Grid_OT_STD_CST = Grid_OT_STD_CST_Temp == null ? 0 : Grid_OT_STD_CST_Temp;
                System.debug('****Grid_OT_STD_CST: ' + Grid_OT_STD_CST);

                // Get the Grid_ROLLUP_OT_STD_CST_TOTAL pricing variable value 
				Decimal Grid_ROLLUP_OT_STD_CST_TOTAL_Temp = (Decimal)pricingVariableCodeToValueMap.get('Grid_ROLLUP_OT_STD_CST_TOTAL');
                Decimal Grid_ROLLUP_OT_STD_CST_TOTAL = Grid_ROLLUP_OT_STD_CST_TOTAL_Temp == null ? 0 : Grid_ROLLUP_OT_STD_CST_TOTAL_Temp;
                System.debug('****Grid_ROLLUP_OT_STD_CST_TOTAL: ' + Grid_ROLLUP_OT_STD_CST_TOTAL);
                
                // Calculate the Recurring Total Yearly
                Decimal Grid_OT_STD_CST_TOTAL = (Grid_OT_STD_CST + Grid_ROLLUP_OT_STD_CST_TOTAL) * LINE_QUANTITY;
                System.debug('****Grid_OT_STD_CST_TOTAL: ' + Grid_OT_STD_CST_TOTAL);
                
                // Save the new Grid_OT_STD_CST_TOTAL rounded to 2 decimals in the pricing variable map of the line item
                pricingVariableCodeToValueMap.put('Grid_OT_STD_CST_TOTAL', Grid_OT_STD_CST_TOTAL.setScale(2, RoundingMode.HALF_UP));

                // Set the new pricing details information for the Grid_OT_STD_CST_TOTAL
                pricingLogDataMap.put('Grid_OT_STD_CST_TOTAL', 
                    new Map<String, Object>{
                        'format'=>'[{0} ({1}) x {2} ({3})] + Rollup {4} ({5})',
                        'data'=>new List<String>{'Grid_OT_STD_CST',                            // replaces {0}
                                                  String.valueOf(Grid_OT_STD_CST),             // replaces {1}
                                                 'LINE_QUANTITY',                               // replaces {2}
                                                 String.valueOf(LINE_QUANTITY),                 // replaces {3}
                                                 'Grid_OT_STD_CST_TOTAL',                      // replaces {4}
                                                 String.valueOf(Grid_ROLLUP_OT_STD_CST_TOTAL)  // replaces {5}
                                             }});
                System.debug('****pricingLogDataMap CST: ' + pricingLogDataMap);
                
                if (isRoot)
                {
                    Decimal Grid_EFF_OT_STD_CST_TOTAL = Grid_OT_STD_CST_TOTAL;
                    pricingVariableCodeToValueMap.put('Grid_EFF_OT_STD_CST_TOTAL', Grid_EFF_OT_STD_CST_TOTAL.setScale(2, RoundingMode.HALF_UP));
                    System.debug('****isRoot Grid_EFF_OT_STD_CST_TOTAL: ' + Grid_EFF_OT_STD_CST_TOTAL);
                }
				/**** ONE TIME COST - ORDER ITEM (end) ****/
				
                /**** RECURRING MONTHLY COST - ORDER ITEM (start) ****/
                // Get the Grid_REC_MNTH_STD_CST pricing variable value 
				Decimal Grid_REC_MNTH_STD_CST_Temp = (Decimal)pricingVariableCodeToValueMap.get('Grid_REC_MNTH_STD_CST');
                Decimal Grid_REC_MNTH_STD_CST = Grid_REC_MNTH_STD_CST_Temp == null ? 0 : Grid_REC_MNTH_STD_CST_Temp;
                System.debug('****Grid_REC_MNTH_STD_CST: ' + Grid_REC_MNTH_STD_CST);

                // Get the Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL pricing variable value 
				Decimal Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL_Temp = (Decimal)pricingVariableCodeToValueMap.get('Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL');
                Decimal Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL = Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL_Temp == null ? 0 : Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL_Temp;
                System.debug('****Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL: ' + Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL);
                
                // Calculate the Recurring Total Yearly
                Decimal Grid_REC_MNTH_STD_CST_TOTAL = (Grid_REC_MNTH_STD_CST + Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL) * LINE_QUANTITY;
                System.debug('****Grid_REC_MNTH_STD_CST_TOTAL: ' + Grid_REC_MNTH_STD_CST_TOTAL);
                
                // Save the new Grid_OT_STD_CST_TOTAL rounded to 2 decimals in the pricing variable map of the line item
                pricingVariableCodeToValueMap.put('Grid_REC_MNTH_STD_CST_TOTAL', Grid_REC_MNTH_STD_CST_TOTAL.setScale(2, RoundingMode.HALF_UP));

                // Set the new pricing details information for the Grid_OT_STD_CST_TOTAL
                pricingLogDataMap.put('Grid_REC_MNTH_STD_CST_TOTAL', 
                    new Map<String, Object>{
                        'format'=>'[{0} ({1}) x {2} ({3})] + Rollup {4} ({5})',
                        'data'=>new List<String>{'Grid_REC_MNTH_STD_CST',                            // replaces {0}
                                                  String.valueOf(Grid_REC_MNTH_STD_CST),             // replaces {1}
                                                 'LINE_QUANTITY',                               // replaces {2}
                                                 String.valueOf(LINE_QUANTITY),                 // replaces {3}
                                                 'Grid_REC_MNTH_STD_CST_TOTAL',                      // replaces {4}
                                                 String.valueOf(Grid_ROLLUP_REC_MNTH_STD_CST_TOTAL)  // replaces {5}
                                             }});
                System.debug('****pricingLogDataMap CST: ' + pricingLogDataMap);
                
                if (isRoot)
                {
                    Decimal Grid_EFF_REC_MNTH_STD_CST_TOTAL = Grid_REC_MNTH_STD_CST_TOTAL;
                    pricingVariableCodeToValueMap.put('Grid_EFF_REC_MNTH_STD_CST_TOTAL', Grid_EFF_REC_MNTH_STD_CST_TOTAL.setScale(2, RoundingMode.HALF_UP));
                    System.debug('****isRoot Grid_EFF_REC_MNTH_STD_CST_TOTAL: ' + Grid_EFF_REC_MNTH_STD_CST_TOTAL);
                }
				/**** RECURRING MONTHLY COST - ORDER ITEM (end) ****/
            }
            return true;
        }
        catch (Exception ex)
        {
            System.debug('--- Exception: ' + ex.getMessage());
            System.debug('--- Stack Trace: ' + ex.getStackTraceString());
            throw ex;
        }
    }
}