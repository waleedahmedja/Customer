// Helper Functions
// Helper to fetch FCM tokens from a collection
async function fetchFcmTokens(collection, filters) {
  const query = admin.firestore().collection(collection);
  let querySnapshot = query;

  // Apply filters dynamically
  for (const [field, condition, value] of filters) {
    querySnapshot = querySnapshot.where(field, condition, value);
  }

  const tokens = [];
  (await querySnapshot.get()).forEach((doc) => {
    const data = doc.data();
    if (data.fcmToken) tokens.push(data.fcmToken);
  });

  return tokens;
}

// Helper to send batched notifications
async function sendBatchedNotifications(tokens, payload) {
  const chunkSize = 500;
  for (let i = 0; i < tokens.length; i += chunkSize) {
    const chunk = tokens.slice(i, i + chunkSize);
    await admin.messaging().sendToDevice(chunk, payload);
    console.log(`Notification sent to ${chunk.length} tokens`);
  }
}
// Notify Workers of Job Request
exports.notifyWorkersOfJobRequest = functions.firestore
  .document("jobs/{jobId}")
  .onCreate(async (snap, context) => {
    const jobData = snap.data();

    if (jobData.status === "pending") {
      try {
        // Fetch nearby workers (add geolocation filtering as needed)
        const tokens = await fetchFcmTokens("users", [
          ["role", "==", "worker"],
          ["isAvailable", "==", true],
        ]);

        if (tokens.length > 0) {
          const payload = {
            notification: {
              title: "New Job Request",
              body: `A new job is available near you.`,
            },
          };

          await sendBatchedNotifications(tokens, payload);
        } else {
          console.log("No available workers found.");
        }
      } catch (error) {
        console.error("Error notifying workers:", error);
      }
    }
  });
// Notify Customer of Job Status
exports.notifyCustomerOfJobStatus = functions.firestore
  .document("jobs/{jobId}")
  .onUpdate(async (change, context) => {
    const newData = change.after.data();
    const prevData = change.before.data();

    if (newData.status !== prevData.status) {
      try {
        // Fetch the customer's FCM token
        const customerDoc = await admin
          .firestore()
          .collection("users")
          .doc(newData.customerId)
          .get();

        if (customerDoc.exists && customerDoc.data().fcmToken) {
          const payload = {
            notification: {
              title: "Job Status Update",
              body: `Your job is now ${newData.status}.`,
            },
          };

          await admin.messaging().sendToDevice(
            customerDoc.data().fcmToken,
            payload
          );
          console.log(`Notification sent to customer: ${newData.customerId}`);
        } else {
          console.log(
            `Customer not found or FCM token is missing for ID: ${newData.customerId}`
          );
        }
      } catch (error) {
        console.error("Error notifying customer:", error);
      }
    }
  });
