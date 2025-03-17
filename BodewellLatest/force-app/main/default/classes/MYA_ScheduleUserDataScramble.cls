/**
 * @author         Akhil Raj
 * @company        TCS
 * @created        22.09.2022
 * @description    For scramble user data after deactivation
 */
global class MYA_ScheduleUserDataScramble implements Schedulable {
   //Execute
   global void execute(SchedulableContext sc) {
      MYA_BatchUserDataScramble b = new MYA_BatchUserDataScramble();
      database.executebatch(b);
   }
}