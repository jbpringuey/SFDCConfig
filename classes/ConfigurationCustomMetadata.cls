/**
*  Helper apex class to available values in configurations.
*  Another way to do that is to create new custom metadata types and store those options as records 
*/
public class ConfigurationCustomMetadata {

    public static String CONFIG_MD_NAME = 'Configuration__mdt';
    
    public static String VERTICAL_PHARMA = 'Pharma';
    public static String VERTICAL_MEDDEV = 'Meddev';
    public static String VERTICAL_FINANCIAL= 'Financial';
    
    static public List<SelectOption> VERTICAL_VALUES {
        get {
            if (VERTICAL_VALUES == null) {
                VERTICAL_VALUES = new list<SelectOption>();
                VERTICAL_VALUES.add(new SelectOption(VERTICAL_PHARMA,VERTICAL_PHARMA));
                VERTICAL_VALUES.add(new SelectOption(VERTICAL_MEDDEV,VERTICAL_MEDDEV));
                VERTICAL_VALUES.add(new SelectOption(VERTICAL_FINANCIAL,VERTICAL_FINANCIAL));
            }
            return VERTICAL_VALUES;
        }
        private set;
    }
    
    public static String ACCURACY_LEVEL_LOW = 'Low';
    public static String ACCURACY_LEVEL_MEDIUM = 'Medium';
    public static String ACCURACY_LEVEL_HIGH = 'High';
    
    static public List<SelectOption> ACCURACY_LEVEL_VALUES {
        get {
            if (ACCURACY_LEVEL_VALUES == null) {
                ACCURACY_LEVEL_VALUES = new list<SelectOption>();
                ACCURACY_LEVEL_VALUES.add(new SelectOption(ACCURACY_LEVEL_LOW,ACCURACY_LEVEL_LOW));
                ACCURACY_LEVEL_VALUES.add(new SelectOption(ACCURACY_LEVEL_MEDIUM,ACCURACY_LEVEL_MEDIUM));
                ACCURACY_LEVEL_VALUES.add(new SelectOption(ACCURACY_LEVEL_HIGH,ACCURACY_LEVEL_HIGH));
            }
            return ACCURACY_LEVEL_VALUES;
        }
        private set;
    }
    
    static public void addSelectLists(Map<string,List<SelectOption>> selectLists){
        selectLists.put(CONFIG_MD_NAME+'.Vertical__c',VERTICAL_VALUES);    
        selectLists.put(CONFIG_MD_NAME+'.AccuracyLevel__c',ACCURACY_LEVEL_VALUES);    
    }

}