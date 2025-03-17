@isTest
public class ConnectedAdmin_test {  
    static testmethod void faults_test(){
        String res=ConnectedAdmin.faultTable('D828C9122E11');
        System.assertNotEquals(null, res);
    }
    static testmethod void cycle_test(){
        String res=ConnectedAdmin.cycle('D828C9122E11');
        System.assertNotEquals(null, res);
    }
    static testmethod void connectionstatus_test(){
        String res=ConnectedAdmin.connectionStatus('D828C9122E11');
        System.assertNotEquals(null, res);
    }
    
}