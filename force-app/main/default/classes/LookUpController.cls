/**
 * Provides methods for retrieving lookup values 
 * @Author Sri Ram Kumar
 * @Date 13-05-2022
 */
public with sharing class LookUpController {

    /**
      *Method to get record of SObject by Search key word
     	* @param Searchkeyword, SObject API Name, Field API Name
		* @return Serialized Wrapper Object to JS for Custom Lookup Field, Sends Name and Id
	*/
    @AuraEnabled(cacheable=true)
    public static string fetchLookupData(string searchKey , string sObjectApiName, string qFieldName,list<string> filter, Boolean isFilter) {    
        string sQuery;
        String fieldApiName;
         string searchText = '%' + searchKey + '%';
       // filter.add('Name Like : searchText');
        SObjectType type = Schema.getGlobalDescribe().get(sObjectApiName);
        if(qFieldName!=null && qFieldName!=''){
    Map<String,Schema.SObjectField> mapfields = type.getDescribe().fields.getMap();
    for(String strField:mapfields.keySet())
    {
        SObjectField fl = mapfields.get(strField);
        if(qFieldName == fl.getDescribe().getlabel())
        {
            fieldApiName=strField;
            }
        }
    }
    if(filter.size()>0 && isFilter==true){
	    if(fieldApiName!='' && fieldApiName!=null){
 		sQuery=String.format('SELECT Id,Name,'+ fieldApiName +' FROM ' + sObjectApiName + ' WHERE {0} ORDER BY createdDate DESC LIMIT 10',new list<String>{
        	String.join(filter, ' AND ')});
           // sQuery = 'SELECT Id,Name,'+ fieldApiName +' FROM ' + sObjectApiName + ' WHERE Name Like : searchText ORDER BY createdDate DESC LIMIT 10'; 
	    }else{
		sQuery=String.format('SELECT Id,Name FROM ' + sObjectApiName + ' WHERE {0} ORDER BY createdDate DESC LIMIT 10',new list<String>{
        	String.join(filter, ' AND ')});
	    //sQuery = 'SELECT Id,Name FROM ' + sObjectApiName + ' WHERE Name Like : searchText ORDER BY createdDate DESC LIMIT 10';
	    }
	    }else if(fieldApiName!='' && fieldApiName!=null) {
            sQuery = 'SELECT Id,Name,'+ fieldApiName +' FROM ' + sObjectApiName + ' WHERE Name Like : searchText ORDER BY createdDate DESC LIMIT 10'; 
    	}else{
            fieldApiName='';
               sQuery = 'SELECT Id,Name FROM ' + sObjectApiName + ' WHERE Name Like : searchText ORDER BY createdDate DESC LIMIT 10';
        }
        system.debug('Query : '+ sQuery);
        MainWrapper objWrap=new MainWrapper();
      	objWrap.rcc=new list <RecordFields>();
          objWrap.results=new list <RecordField>();
        for (sObject obj: database.query(sQuery)) {
            if(fieldApiName!=''){
                objWrap.rcc.add( new RecordFields((String)obj.get('id'),(String)obj.get('Name'),(String)obj.get(fieldApiName)));
            }else{
                objWrap.results.add( new RecordField((String)obj.get('id'),(String)obj.get('Name')));
            }
        }
        system.debug('Result : '+objWrap);
        return JSON.serialize(objWrap);
    }
    /**
      *Getting the record id of selected record
     	* @param SObject API Name, RecordId For Filter
		* @return Sobject record for SObject API Name from filtered
	*/
    @AuraEnabled
    public static sObject selectedValue(string sObjectApiName, string strRecordId){
    List<String> strObject = new List<String>();
    List<String> filters = new List<String>();
    strObject.add(sObjectApiName);
    filters.add('Id=:strRecordId');
  string sQuery = String.format('Select Id,Name From {0} Where {1}', new List<String> {
                String.join(strObject, ' AND '), String.join(filters, ' AND ')
            });
        system.debug('Query : '+ sQuery);
        sObject strRecords=database.query(sQuery);
        return strRecords;
    }
    //Wrapper of Wrappers
    public class MainWrapper{
        @AuraEnabled public list<RecordFields> rcc;
        @AuraEnabled public list<RecordField> results;
    }
    // Data of the Record Wrapper
    public class RecordFields{
        @AuraEnabled public string Id;
        @AuraEnabled public string Name;
        @AuraEnabled public string otherField;
    public RecordFields(string Id, string Name, string otherField){
            this.Id=Id;
            this.Name=Name;
            this.otherField=otherField;
        }
    } 
    //Actual Selected Field
    public class RecordField{
        @AuraEnabled public string Id;
        @AuraEnabled public string Name;
    public RecordField(string Id, string Name){
            this.Id=Id;
            this.Name=Name;
        }
    } 
}
