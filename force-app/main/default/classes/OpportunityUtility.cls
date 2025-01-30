public class OpportunityUtility {
    public static Map<Integer,QuotationComponentDataWrapper.DatePeriod> getYearCalendarPeriod(Date startDate, Date endDate, String leaseType, String longleaseType){

        Map<Integer,QuotationComponentDataWrapper.DatePeriod> yearPeriodMap = new Map<Integer,QuotationComponentDataWrapper.DatePeriod>();
        QuotationComponentDataWrapper.DatePeriod yearPeriod;

        Integer yearRange = 0;
        if (leaseType == 'Short-Term' || (leaseType == 'Long-Term' && longleaseType == 'ระบุราคาทุกปีตามปีสัญญา')) {
            yearRange = (endDate.year()-startDate.year());
        }else if(leaseType == 'Long-Term' && longleaseType == 'ระบุราคาปีปฏิทินแรก'){
            yearRange = 1;
        }

        Date startYearDate;
        Date endYearDate;

        for(Integer yearIndex =0; yearIndex <= yearRange; yearIndex++){
            yearPeriod = new QuotationComponentDataWrapper.DatePeriod();
            
            startYearDate = Date.newInstance(startDate.year()+yearIndex, 1, 1);
            endYearDate = Date.newInstance(startDate.year()+yearIndex, 12, 31);
            
            if(yearIndex == 0){
                // yearPeriod.add(Date.newInstance(startDate.year(), startDate.month(), startDate.day()));
                // yearPeriod.add(endYearDate);

                if (yearRange > 0) {
                    yearPeriod.startDate = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
                    yearPeriod.endDate = endYearDate;
                    yearPeriod.isOptionToRenew = false;
                }else{
                    yearPeriod.startDate = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
                    yearPeriod.endDate = endDate;
                    yearPeriod.isOptionToRenew = false;
                }
            }else if(yearIndex == yearRange){
                yearPeriod.startDate = startYearDate;
                yearPeriod.endDate = endDate;
                yearPeriod.isOptionToRenew = false;
            }else{
                // yearPeriod.add(startYearDate);
                // yearPeriod.add(endYearDate);

                yearPeriod.startDate = startYearDate;
                yearPeriod.endDate = endYearDate;
                yearPeriod.isOptionToRenew = false;
            }

            System.debug(yearPeriod);
            yearPeriodMap.put(yearIndex+1,yearPeriod);
        }

        System.debug('yearPeriodMap' + yearPeriodMap);

        return yearPeriodMap;
    }
    public static Map<Integer,QuotationComponentDataWrapper.DatePeriod> getYearCalendarPeriod(Date startDate, Date endDate, String leaseType, Integer optionToRenewYear, Integer optionToRenewMonth, String longleaseType){

        Map<Integer,QuotationComponentDataWrapper.DatePeriod> yearPeriodMap = new Map<Integer,QuotationComponentDataWrapper.DatePeriod>();
        QuotationComponentDataWrapper.DatePeriod yearPeriod;

        Integer yearRange = 0;
        if (leaseType == 'Short-Term' || (leaseType == 'Long-Term' && longleaseType == 'ระบุราคาทุกปีตามปีสัญญา')) {
            yearRange = (endDate.year()-startDate.year());
        }else if(leaseType == 'Long-Term' && longleaseType == 'ระบุราคาปีปฏิทินแรก'){
            yearRange = 1;
        }

        Date startYearDate;
        Date endYearDate;

        for(Integer yearIndex =0; yearIndex <= yearRange; yearIndex++){
            yearPeriod = new QuotationComponentDataWrapper.DatePeriod();
            
            startYearDate = Date.newInstance(startDate.year()+yearIndex, 1, 1);
            endYearDate = Date.newInstance(startDate.year()+yearIndex, 12, 31);
            
            if(yearIndex == 0){
                // yearPeriod.add(Date.newInstance(startDate.year(), startDate.month(), startDate.day()));
                // yearPeriod.add(endYearDate);

                if (yearRange > 0){
                    yearPeriod.startDate = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
                    yearPeriod.endDate = endYearDate;
                    yearPeriod.isOptionToRenew = false;
                }else{
                    yearPeriod.startDate = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
                    yearPeriod.endDate = endDate;
                    yearPeriod.isOptionToRenew = false;    
                }
            }else if(yearIndex == yearRange){
                yearPeriod.startDate = startYearDate;
                yearPeriod.endDate = endDate;
                yearPeriod.isOptionToRenew = false;
            }else{
                // yearPeriod.add(startYearDate);
                // yearPeriod.add(endYearDate);

                yearPeriod.startDate = startYearDate;
                yearPeriod.endDate = endYearDate;
                yearPeriod.isOptionToRenew = false;
            }

            System.debug(yearPeriod);
            yearPeriodMap.put(yearIndex+1,yearPeriod);
        }

        Date optionToRenewStartDate = yearPeriodMap.get(yearPeriodMap.size()).endDate.addDays(1);
        Date optionToRenewEndDate = Date.newInstance(optionToRenewStartDate.year()+optionToRenewYear, optionToRenewStartDate.month()+optionToRenewMonth, optionToRenewStartDate.day()-1);
        Integer optionToRenewYearRange = optionToRenewEndDate.year() - optionToRenewStartDate.year();
        // Integer optionToRenewMonthRange = optionToRenewEndDate.month() - optionToRenewStartDate.month();

        Integer numberOfYear = optionToRenewYearRange;

        for(Integer yearIndex = 0; yearIndex <= numberOfYear ; yearIndex++){
            yearPeriod = new QuotationComponentDataWrapper.DatePeriod();
            
            startYearDate = Date.newInstance(optionToRenewStartDate.year()+yearIndex, 1, 1);
            endYearDate = Date.newInstance(optionToRenewStartDate.year()+yearIndex, 12, 31);

            if(yearIndex == 0){
                // yearPeriod.add(Date.newInstance(startDate.year(), startDate.month(), startDate.day()));
                // yearPeriod.add(endYearDate);

                yearPeriod.startDate = Date.newInstance(optionToRenewStartDate.year(), optionToRenewStartDate.month(), optionToRenewStartDate.day());
                yearPeriod.endDate = endYearDate;
                yearPeriod.isOptionToRenew = true;
            }else if(yearIndex == numberOfYear){
                yearPeriod.startDate = startYearDate;
                yearPeriod.endDate = optionToRenewEndDate;
                yearPeriod.isOptionToRenew = true;
            }else{

                yearPeriod.startDate = startYearDate;
                yearPeriod.endDate = endYearDate;
                yearPeriod.isOptionToRenew = true;
            }

            System.debug(yearPeriod);
            yearPeriodMap.put(yearPeriodMap.size()+1,yearPeriod);
        }

        System.debug('yearPeriodMap' + yearPeriodMap);

        return yearPeriodMap;
    }

    public static Map<Integer,QuotationComponentDataWrapper.DatePeriod> getPricingDatePeriod(Date startDate, Date endDate){

        Map<Integer,QuotationComponentDataWrapper.DatePeriod> yearPeriodMap = new Map<Integer,QuotationComponentDataWrapper.DatePeriod>();
        QuotationComponentDataWrapper.DatePeriod yearPeriod;
        Integer yearRange = (endDate.year()-startDate.year());
        Integer monthRange = (endDate.month()-startDate.month() == 0 && endDate.year()-startDate.year() == 0) ? 1 : endDate.month()-startDate.month();

        for(Integer yearIndex =1; yearIndex <= ((monthRange>0)?yearRange+1:yearRange); yearIndex++){
            yearPeriod = new QuotationComponentDataWrapper.DatePeriod();
                if(yearIndex == yearRange || yearIndex > yearRange ){
                    
                    if(yearIndex > yearRange){
                        // yearPeriod.add(Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day()));
                        // yearPeriod.add(Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), endDate.month(), endDate.day()));

                        yearPeriod.startDate = Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day());
                        yearPeriod.endDate = Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), endDate.month(), endDate.day());
                        yearPeriod.isOptionToRenew = false;
                        
                        yearPeriodMap.put(yearIndex,yearPeriod);
                    }
                    if(yearIndex == yearRange){
                        if(monthRange>0){
                            // yearPeriod.add(Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day()));
                            // yearPeriod.add(Date.newInstance(endDate.year()+(yearIndex-yearRange), startDate.month(), (startDate.day()-1)));

                            yearPeriod.startDate = Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day());
                            yearPeriod.endDate = Date.newInstance(endDate.year()+(yearIndex-yearRange), startDate.month(), (startDate.day()-1));
                            yearPeriod.isOptionToRenew = false;

                            yearPeriodMap.put(yearIndex,yearPeriod);
                        }else{
                            // yearPeriod.add(Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day()));
                            // yearPeriod.add(Date.newInstance(endDate.year()+(yearIndex-yearRange), endDate.month(), endDate.day()));

                            yearPeriod.startDate = Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day());
                            yearPeriod.endDate = Date.newInstance(endDate.year()+(yearIndex-yearRange), endDate.month(), endDate.day());
                            yearPeriod.isOptionToRenew = false;

                            yearPeriodMap.put(yearIndex,yearPeriod);
                        }
                        
                    }
                        
                }else{
                    // yearPeriod.add(Date.newInstance(startDate.year()+(yearIndex-1), startDate.month(), startDate.day()));
                    // yearPeriod.add(Date.newInstance(endDate.year()+(yearIndex-yearRange), startDate.month(), (startDate.day()-1)));

                    yearPeriod.startDate = Date.newInstance(startDate.year()+(yearIndex-1), startDate.month(), startDate.day());
                    yearPeriod.endDate = Date.newInstance(endDate.year()+(yearIndex-yearRange), startDate.month(), (startDate.day()-1));
                    yearPeriod.isOptionToRenew = false;

                    yearPeriodMap.put(yearIndex,yearPeriod);
                }
            
            System.debug(yearPeriod);
        }

        return yearPeriodMap;
    }

    public static Map<Integer,QuotationComponentDataWrapper.DatePeriod> getPricingDatePeriod(Date startDate, Date endDate, Integer optionToRenewYear, Integer optionToRenewMonth){

        Integer yearRange = (endDate.year()-startDate.year());
        Integer monthRange = (endDate.month()-startDate.month());

        System.debug('yearRange ' + yearRange);
        System.debug('monthRange ' + monthRange);

        Map<Integer,QuotationComponentDataWrapper.DatePeriod> yearPeriodMap = new Map<Integer,QuotationComponentDataWrapper.DatePeriod>();
        QuotationComponentDataWrapper.DatePeriod yearPeriod;

        for(Integer yearIndex =1; yearIndex <= ((monthRange>0)?yearRange+1:yearRange); yearIndex++){
            yearPeriod = new QuotationComponentDataWrapper.DatePeriod();
                if(yearIndex == yearRange || yearIndex > yearRange ){
                    System.debug('Is Final');
                    
                    if(yearIndex > yearRange){
                        // yearPeriod.add(Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day()));
                        // yearPeriod.add(Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), endDate.month(), endDate.day()));

                        yearPeriod.startDate = Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day());
                        yearPeriod.endDate = Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), endDate.month(), endDate.day());
                        yearPeriod.isOptionToRenew = false;

                        yearPeriodMap.put(yearIndex,yearPeriod);
                    }
                    if(yearIndex == yearRange){
                        if(monthRange>0){
                            // yearPeriod.add(Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day()));
                            // yearPeriod.add(Date.newInstance(endDate.year()+(yearIndex-yearRange), startDate.month(), (startDate.day()-1)));

                            yearPeriod.startDate = Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day());
                            yearPeriod.endDate = Date.newInstance(endDate.year()+(yearIndex-yearRange), startDate.month(), (startDate.day()-1));
                            yearPeriod.isOptionToRenew = false;

                            yearPeriodMap.put(yearIndex,yearPeriod);
                        }else{
                            // yearPeriod.add(Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day()));
                            // yearPeriod.add(Date.newInstance(endDate.year()+(yearIndex-yearRange), endDate.month(), endDate.day()));

                            yearPeriod.startDate = Date.newInstance(endDate.year()+((yearIndex-1)-yearRange), startDate.month(), startDate.day());
                            yearPeriod.endDate = Date.newInstance(endDate.year()+(yearIndex-yearRange), endDate.month(), endDate.day());
                            yearPeriod.isOptionToRenew = false;

                            yearPeriodMap.put(yearIndex,yearPeriod);
                        }
                        
                    }
                        
                }else{
                    System.debug('Is not Final');
                    // yearPeriod.add(Date.newInstance(startDate.year()+(yearIndex-1), startDate.month(), startDate.day()));
                    // yearPeriod.add(Date.newInstance(endDate.year()+(yearIndex-yearRange), startDate.month(), (startDate.day()-1)));

                    yearPeriod.startDate = Date.newInstance(startDate.year()+(yearIndex-1), startDate.month(), startDate.day());
                    yearPeriod.endDate = Date.newInstance(endDate.year()+(yearIndex-yearRange), startDate.month(), (startDate.day()-1));
                    yearPeriod.isOptionToRenew = false;

                    yearPeriodMap.put(yearIndex,yearPeriod);
                }
            
            System.debug(yearPeriod);
        }

        Date optionToRenewStartDate = yearPeriodMap.get(yearPeriodMap.size()).endDate.addDays(1);
        Date optionToRenewEndDate = Date.newInstance(optionToRenewStartDate.year()+optionToRenewYear, optionToRenewStartDate.month()+optionToRenewMonth, optionToRenewStartDate.day());
        Integer optionToRenewYearRange = optionToRenewEndDate.year() - optionToRenewStartDate.year();
        Integer optionToRenewMonthRange = optionToRenewEndDate.month() - optionToRenewStartDate.month();

        System.debug('optionToRenewYearRange '+optionToRenewYearRange);
        System.debug('optionToRenewMonthRange '+optionToRenewMonthRange);

        System.debug('optionToRenewStartDate ' + optionToRenewStartDate);
        System.debug('optionToRenewEndDate ' + optionToRenewEndDate);

        for(Integer yearIndex =1; yearIndex <=((optionToRenewMonthRange>0)?optionToRenewYearRange+1:optionToRenewYearRange) ; yearIndex++){
            yearPeriod = new QuotationComponentDataWrapper.DatePeriod();
            
            if(yearIndex == optionToRenewYearRange || yearIndex > optionToRenewYearRange ){
                    System.debug('Is Final');
                    
                    if(yearIndex > optionToRenewYearRange){
                        // yearPeriod.add(Date.newInstance(optionToRenewEndDate.year()+((yearIndex-1)-optionToRenewYearRange), optionToRenewStartDate.month(), optionToRenewStartDate.day()));
                        // yearPeriod.add(Date.newInstance(optionToRenewEndDate.year()+((yearIndex-1)-optionToRenewYearRange), optionToRenewEndDate.month(), optionToRenewEndDate.day()));

                        yearPeriod.startDate = Date.newInstance(optionToRenewEndDate.year()+((yearIndex-1)-optionToRenewYearRange), optionToRenewStartDate.month(), optionToRenewStartDate.day());
                        yearPeriod.endDate = Date.newInstance(optionToRenewEndDate.year()+((yearIndex-1)-optionToRenewYearRange), optionToRenewEndDate.month(), optionToRenewEndDate.day()-1);
                        yearPeriod.isOptionToRenew = true;
                        System.debug('Option To Renew YearPeriod size'+(yearPeriodMap.size()));
                        yearPeriodMap.put((yearPeriodMap.size()+1),yearPeriod);
                    }
                    if(yearIndex == optionToRenewYearRange){
                        if(optionToRenewMonthRange>0){
                            // yearPeriod.add(Date.newInstance(optionToRenewEndDate.year()+((yearIndex-1)-optionToRenewYearRange), optionToRenewStartDate.month(), optionToRenewStartDate.day()));
                            // yearPeriod.add(Date.newInstance(optionToRenewEndDate.year()+(yearIndex-optionToRenewYearRange), optionToRenewStartDate.month(), (optionToRenewStartDate.day()-1)));

                            yearPeriod.startDate = Date.newInstance(optionToRenewEndDate.year()+((yearIndex-1)-optionToRenewYearRange), optionToRenewStartDate.month(), optionToRenewStartDate.day());
                            yearPeriod.endDate = Date.newInstance(optionToRenewEndDate.year()+(yearIndex-optionToRenewYearRange), optionToRenewStartDate.month(), (optionToRenewStartDate.day()-1));
                            yearPeriod.isOptionToRenew = true;
                            System.debug('Option To Renew YearPeriod size'+yearPeriodMap.size());
                            yearPeriodMap.put((yearPeriodMap.size()+1),yearPeriod);
                        }else{
                            // yearPeriod.add(Date.newInstance(optionToRenewEndDate.year()+((yearIndex-1)-optionToRenewYearRange), optionToRenewStartDate.month(), optionToRenewStartDate.day()));
                            // yearPeriod.add(Date.newInstance(optionToRenewEndDate.year()+(yearIndex-optionToRenewYearRange), optionToRenewEndDate.month(), optionToRenewEndDate.day()));

                            yearPeriod.startDate = Date.newInstance(optionToRenewEndDate.year()+((yearIndex-1)-optionToRenewYearRange), optionToRenewStartDate.month(), optionToRenewStartDate.day());
                            yearPeriod.endDate =  Date.newInstance(optionToRenewEndDate.year()+(yearIndex-optionToRenewYearRange), optionToRenewEndDate.month(), (optionToRenewEndDate.day()-1));
                            yearPeriod.isOptionToRenew = true;

                            System.debug('Option To Renew YearPeriod size'+(yearPeriodMap.size()+1));
                            yearPeriodMap.put((yearPeriodMap.size()+1),yearPeriod);
                        }
                        
                    }
                        
                }else{
                    System.debug('Is not Final');
                    // yearPeriod.add(Date.newInstance(optionToRenewStartDate.year()+(yearIndex-1), optionToRenewStartDate.month(), optionToRenewStartDate.day()));
                    // yearPeriod.add(Date.newInstance(optionToRenewEndDate.year()+(yearIndex-optionToRenewYearRange), optionToRenewStartDate.month(), (optionToRenewStartDate.day()-1)));

                    yearPeriod.startDate = Date.newInstance(optionToRenewStartDate.year()+(yearIndex-1), optionToRenewStartDate.month(), optionToRenewStartDate.day());
                    yearPeriod.endDate = Date.newInstance(optionToRenewEndDate.year()+(yearIndex-optionToRenewYearRange), optionToRenewStartDate.month(), (optionToRenewStartDate.day()-1));
                    yearPeriod.isOptionToRenew = true;

                    System.debug('Option To Renew YearPeriod size'+(yearPeriodMap.size() + yearIndex));        
                    yearPeriodMap.put((yearPeriodMap.size() + 1),yearPeriod);

                }
            System.debug('Option To Renew YearPeriod'+yearPeriod);
        }

        System.debug(yearPeriodMap);

        return yearPeriodMap;
    }
}