global class ContactsScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		ContactsBatch b = new ContactsBatch();
		database.executebatch(b);
	}
}