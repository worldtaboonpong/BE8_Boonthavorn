public with sharing class numberToWord {

    static List<String> intNumb = new List<String>{ '', 'One',  'Two', 'Three', 'Four',  'Five',  'Six',  
        'Seven', 'Eight', 'Nine', 'Ten',  'Eleven', 'Twelve', 'Thirteen','Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen' };
    static List<String> tens = new List<String>{ 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};
    static List<String> denoms = new List<String> {'', 'Thousand',   'Million',  'Billion',    'Trillion',    'Quadrillion', 'Quintillion', 'Sixtillion',   'Septillion',  'Octillion',   'Nonillion', 'Decillion',  'Undecillion',   'Duodecillion', 'Tredecillion',  'Quattuordecillion', 'Sixdecillion', 'Septendecillion', 'Octodecillion', 'Novemdecillion', 'Vigintillion' };

    public static String numberToWordTH(Decimal nub,Boolean isTrillion) { 
        return numberToWordTH(nub, isTrillion, true);
    }

    public static String numberToWordTH(Decimal nub,Boolean isTrillion, Boolean isCurrency) {
        System.debug(nub);
        String bathText = '';
        String strTrillion = '';
        List<String> strThaiNumber = new List<String>{'ศูนย์','หนึ่ง','สอง','สาม','สี่','ห้า','หก','เจ็ด','แปด','เก้า'};
        List<String> strThaiPos = new List<String>{'','สิบ','ร้อย','พัน','หมื่น','แสน','ล้าน'};

        if(nub != 0){
            String strNumber = String.valueOf(nub.setScale(2));
            String strInteger = strNumber.split('\\.')[0];
            String strSatang = strNumber.split('\\.')[1];
            if(strInteger.length() > 13){
                return 'รองรับตัวเลขได้เพียง ล้านล้าน เท่านั้น';
            }else{
                Boolean overTrillion = strInteger.length() > 7;
                if(overTrillion){
                    strTrillion = strInteger.substring(0,strInteger.length() - 6);
                    System.debug(strTrillion);
                    bathText = numberToWordTH(decimal.valueOf(strTrillion),overTrillion);
                    strInteger = strInteger.substring(strTrillion.length());
                    System.debug(strInteger);
                }
                Integer strLength = strInteger.length();
                for(Integer i = 0; i < strInteger.length(); i++) {
                    String num = strInteger.substring(i, i+1);
                    System.debug(num);
                    if(num != '0' && num != '-'){
                        if(i == strLength - 1 && num == '1' && strLength != 1){
                            bathText += 'เอ็ด';
                        }
                        else if (i == strLength -2 && num == '2' && strLength != 1){
                            bathText += 'ยี่';
                        }else if(i != strLength -2 || num != '1'){
                            bathText += strThaiNumber[Integer.valueOf(num)];
                        }
                        bathText +=  strThaiPos[(strLength - i)-1];
                    }
                    System.debug(bathText);
                }
                if(isTrillion){
                    return bathText + 'ล้าน';
                }
                if(isCurrency) {
                    if(strInteger != '0'){
                        bathText += 'บาท';
                    }
                    if(strSatang == '00'){
                        bathText += 'ถ้วน';
                    }
                    else{
                        Integer satangLength = strSatang.length();
                        for(Integer i = 0; i < satangLength; i++){
                            String stNum = strSatang.substring(i, i+1);
                            if(stNum != '0'){
                                System.debug(strSatang.substring(0, 1));
                                if(i == satangLength -1 && stNum == '1' && strSatang.substring(0, 1) != '0'){
                                    bathText += 'เอ็ด';
                                }
                                else if(i == satangLength -2 && stNum == '2' &&  strSatang.substring(0, 1) != '0'){
                                    bathText += 'ยี่';
                                }
                                else if(i != satangLength -2 || stNum != '1'){
                                    bathText += strThaiNumber[Integer.valueOf(stNum)];
                                }
                                bathText += strThaiPos[(satangLength - i)-1];
                            }
                        }
                        bathText += 'สตางค์';
                    }
                }
            }
            return bathText;

        } else if(nub == null) {
            return null;
        } else{
            if(isCurrency) bathText = 'ศูนย์บาทถ้วน';
            else bathText = 'ศูนย์';
            return bathText;
        }
    }

    public static String numberToWordEN(Decimal value){
        String str = String.valueOf(value.setScale(2));
        String strVal = str.split('\\.')[0];
        String strValSatang = str.split('\\.')[1];
        Decimal val = Decimal.valueOf(strVal);
        Decimal valSatang = Decimal.valueOf(strValSatang);
        String intValue = numberToWordENSumUp(val);
        String returnValue = intValue + 'Baht';
        if(valSatang != 0){
            String satangValue = numberToWordENSumUp(valSatang);
            returnValue = returnValue + ' and '+ satangValue + 'Satang';
        }
        return returnValue;
    }

    public static String numberToWordENSumUp(Decimal val){

        if(val == 0){
            return 'zero TH Baht';
        }
        if(val < 100){
            return convertNN(val.intValue());
        }
        if(val < 1000){
            return convertNNN(val.intValue());
        }
        for(Integer i = 0; i < denoms.size(); i++){
            Integer didx = i-1;
            Integer dval = (Integer)Math.pow(1000,i);
            if( dval>val){
                Integer mod = (Integer)Math.pow(1000,didx); 
                Integer l = (Integer) val/mod;
                Integer r = (Integer) val - (l*mod);
                String ret = convertNNN(l)+denoms[didx]+' ';
                if(r>0){
                    ret += numberToWordENSumUp(r);
                }
                return String.valueOf(ret);
            }
        }
        return 'Fail,bottom out failur';
    }

    public static String convertNN(Integer val){
        System.debug(val);
        if(val < 20){
            return intNumb[val]+' ';
        }
        if(val == 100){
            return 'One Hundred ';
        }
        for(Integer i = 0;i < tens.size(); i++){
            String dcap = tens[i];
            Integer dval = 20+10*i;
            if(dval + 10 > val){
                if(Math.mod(val,10) != 10){
                    // System.debug(Math.mod(val,10));
                    // System.debug(Math.mod(dval,10));
                    // System.debug(dval);
                    if(intNumb[Math.mod(val,10)] == ''){
                        return dcap+' ';
                    }else{
                        return dcap+' '+intNumb[Math.mod(val,10)]+' ';
                    }
                }
                else return dcap+' ';
            }
        }
        return 'Fail, less than 100 failure';
    }

    public static String convertNNN(Integer val){
        String word = '';
        Integer rem = val/100;
        Integer mod = Math.mod(val,100);
        if(rem > 0){
            word = intNumb[rem] + ' Hundred ';
            if(mod > 0){
                word+='';
            }
        }
        if(mod > 0){
            word += convertNN(mod);
        }
        return word;
    }

}