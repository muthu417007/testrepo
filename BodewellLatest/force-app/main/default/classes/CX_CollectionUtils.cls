/**
 * @author         Matheus Lopes
 * @company        PolSource
 * @created        26.05.2021
 * @description    Class with reusable methods involving Collections to help with common tasks
 * @testClass      CX_CollectionUtilsTest
 */
public with sharing class CX_CollectionUtils {

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        26.05.2021
     * @description    Transforms a List<SObject> in a Set<Id> of a field values (removing the null value)
     * @param          Set<Id> - A Set to be loaded
     * @param          String - The name of the field to get the values from
     * @param          List<SObject> - A list of SObjects to extract the values
     */
    public static void loadSet(Set<Id> setLoad, String keyField, List<SObject> records) {
        setLoad.addAll((Set<Id>)JSON.deserialize(JSON.serialize(loadSetObject(keyField, records)), Set<Id>.class));
        setLoad.remove(null);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        26.05.2021
     * @description    Transforms a List<SObject> in a Set<String> of a field values (removing the null value)
     * @param          Set<String> - A Set to be loaded
     * @param          String - The name of the field to get the values from
     * @param          List<SObject> - A list of SObjects to extract the values
     */
    public static void loadSet(Set<String> setLoad, String keyField, List<SObject> records) {
        setLoad.addAll((Set<String>)JSON.deserialize(JSON.serialize(loadSetObject(keyField, records)), Set<String>.class));
        setLoad.remove(null);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        26.05.2021
     * @description    Creates a Set with the values of a field
     * @param          String - The name of the field to get the values from
     * @param          List<SObject> - A list of SObjects to extract the values
     * @return         Set<SObject> - A Set with the values of a field from the SObject list
     */
    public static Set<Object> loadSetObject(String keyField, List<SObject> records) {
        Set<Object> setLoad = new Set<Object>();

        for(SObject record : records) {
            setLoad.add(record.get(keyField));
        }

        return setLoad;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Transforms a List<SObject> in a Map, where the key is the value of the key field and the value is the SObject that matches the key
     * @param          Map<String, SObject> - A Map to be loaded
     * @param          String - The name of the field to get the values from
     * @param          List<SObject> - A list of SObjects to transform
     */
    public static void loadMap(Map<String, SObject> mapLoad, String keyField, List<SObject> records) {
        Map<Object, SObject> mapAux = loadMapObject(keyField, records);

        for(Object key : mapAux.keySet()){
            mapLoad.put((String)key, mapAux.get(key));
        }

        mapLoad.remove(null);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        07.06.2021
     * @description    Transforms a List<SObject> in a Map using a defined field
     * @param          String - The name of the field to get the values from
     * @param          List<SObject> - A list of SObjects to transform
     * @return         Map<Object, SObject> - A map where the key is the value of the key field and the value is the SObject that matches the key
     */
    private static Map<Object, SObject> loadMapObject(String keyField, List<SObject> records) {
        Map<Object, SObject> mapLoad = new Map<Object, SObject>();
        String parentObject = null;
        String parentField = null;
        Object key = null;

        for(SObject record : records) {
            if(keyField.indexOf('.') > 0){
                List<String> objectFieldArray = keyField.split('\\.');
                parentObject = objectFieldArray.get(0);
                parentField = objectFieldArray.get(1);
            }

            key = (parentObject == null ? record.get(keyField) : record.getSObject(parentObject).get(parentField));
            mapLoad.put(key, record);
        }

        return mapLoad;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        26.05.2021
     * @description    Transforms a List<SObject> in a Map, where the key is the value of the key field and the value is a list of SObjects that matches the key
     * @param          Map<String, List<SObject>> - A Map to be loaded
     * @param          String - The name of the field to get the values from
     * @param          List<SObject> - A list of SObjects to transform
     */
    public static void loadMap(Map<String, List<SObject>> mapLoad, String keyField, List<SObject> records) {
        Map<Object, List<SObject>> mapAux = loadMapListSObject(keyField, records);

        for(Object key : mapAux.keySet()) {
            if(!mapLoad.containsKey((String)key)) {
                mapLoad.put(((String)key), new List<SObject>());
            }

            mapLoad.get((String)key).addAll(mapAux.get(key));
        }

        mapLoad.remove(null);
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        26.05.2021
     * @description    Transforms a List<SObject> in a Map using a defined field
     * @param          String - The name of the field to get the values from
     * @param          List<SObject> - A list of SObjects to transform
     * @return         Map<Object, List<SObject>> - A map where the key is the value of the key field and the value is a list of SObjects that matches the key
     */
    private static Map<Object, List<SObject>> loadMapListSObject(String keyField, List<SObject> records) {
        Map<Object, List<SObject>> mapLoad = new Map<Object, List<SObject>>();
        String parentObject = null;
        String parentField = null;
        Object key = null;

        for(SObject record : records) {
            parentObject = null;
            parentField = null;
            key = null;

            if(keyField.indexOf('.') > 0){
                List<String> objectFieldArray = keyField.split('\\.');
                parentObject = objectFieldArray.get(0);
                parentField = objectFieldArray.get(1);
            }

            key = (parentObject == null ? record.get(keyField) : record.getSObject(parentObject).get(parentField));

            List<SObject> lst = mapLoad.get(key);
            if(lst == null) {
                lst = new List<SObject>();
                mapLoad.put(key, lst);
            }

            lst.add(record);
        }

        return mapLoad;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Splits a list of sObject into multiple lists
     * @param          List<SObject> - A list of SObjects to split
     * @param          Integer - Max size of the sub lists
     * @return         List<List<SObject>> - A list of the sObjects sub lists
     */
    public static List<List<SObject>> splitToSubList(List<SObject> sObjectList, Integer listSize) {
        List<List<SObject>> parentList = new List<List<SObject>>();

        Integer numberOfSubLists = 0;
        Integer startValue = 0;
        Integer endValue = 0;

        if(sObjectList.size() <= listSize) {
            parentList.add(sObjectList);
        }
        else {
            numberOfSubLists = Math.mod(sObjectList.size(), listSize) == 0 ? (sObjectList.size() / listSize) : (sObjectList.size() / listSize) + 1;

            for(Integer i = 1; i <= numberOfSubLists; i++) {
                startValue = endValue;
                endValue = i * listSize;

                if(endValue > sObjectList.size()) {
                    endValue = sObjectList.size();
                }

                parentList.add(sliceList(sObjectList, startValue, endValue));
            }
        }
        
        return parentList;
    }

    /**
     * @author         Matheus Lopes
     * @company        PolSource
     * @created        01.06.2021
     * @description    Slices a list using the start and end index
     * @param          List<SObject> - A list of SObjects to slice
     * @param          Integer - The first index to cut the new sub list from
     * @param          Integer - The last index to cut the new sub list from
     * @return         List<SObject> - The new sub list
     */
    private static List<SObject> sliceList(List<SObject> sObjectList, Integer startValue, Integer endValue){
        List<SObject> slicedList = new List<SObject>();

        for(Integer i = startValue; i < endValue; i++)
        {
            slicedList.add(sObjectList.get(i));
        }

        return slicedList;
    }
}