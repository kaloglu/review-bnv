const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.giveTicketToUsers = functions.pubsub
    .schedule("every 24 hours") // Trigger every 24 hours
    .timeZone("your-time-zone")
    .onRun(async (context) => {
      const now = new Date();
      const usersCollection = admin.firestore().collection("users");

      const usersSnapshot = await usersCollection.get();
      usersSnapshot.forEach(async (userDoc) => {
        const userId = userDoc.id;
        const ticketsCollection = usersCollection
            .doc(userId)
            .collection("tickets");

        // Check if the user has received a ticket in the last 24 hours.
        // If not, add a new ticket.
        const lastTicketQuery = await ticketsCollection
            .where("date", ">=", new Date(now - 24 * 60 * 60 * 1000))
            .get(); // 24 hours ago

        if (lastTicketQuery.empty) {
          await ticketsCollection.add({
            source: "system",
            date: now,
            earn: '1',
            remain: 1,
          });
        }
      });

      return null;
    });
