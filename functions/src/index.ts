import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

admin.initializeApp();
const db = getFirestore();

export const getExpenseSummary = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated");
  }
  const userId = request.auth.uid;
  const now = new Date();

  const startOfToday = new Date((
    now.getFullYear(),
    now.getMonth(),
    now.getDate()
  ));

  const startOfTomorrow = new Date(startOfToday);
  startOfTomorrow.setDate(startOfTomorrow.getDate() + 1);

  const startOfWeek = new Date(startOfToday);
  startOfWeek.setDate(startOfWeek.getDate() - startOfWeek.getDay());

  const startOfNextWeek = new Date(startOfWeek);
  startOfNextWeek.setDate(startOfNextWeek.getDate() + 7);

  const startOfMonth = new Date(Date.UTC(
    now.getFullYear(),
    now.getMonth(),
    1
  ));

  const startOfNextMonth = new Date(Date.UTC(
    now.getFullYear(),
    now.getMonth() + 1,
    1
  ));

  const today = Timestamp.fromDate(startOfToday);
  const tomorrow = Timestamp.fromDate(startOfTomorrow);
  const week = Timestamp.fromDate(startOfWeek);
  const nextWeek = Timestamp.fromDate(startOfNextWeek);
  const month = Timestamp.fromDate(startOfMonth);
  const nextMonth = Timestamp.fromDate(startOfNextMonth);

  const expensesRef = db
    .collection("users")
    .doc(userId)
    .collection("expenses");

  const [todaySnap, weekSnap, monthSnap] = await Promise.all([
    expensesRef.where("date", ">=", today).where("date", "<", tomorrow).get(),
    expensesRef.where("date", ">=", week).where("date", "<", nextWeek).get(),
    expensesRef.where("date", ">=", month).where("date", "<", nextMonth).get(),
  ]);


  const sum = (snap: FirebaseFirestore.QuerySnapshot) =>
    snap.docs.reduce(
      (total, doc) => total + (doc.data().amount || 0),
      0
    );

  const summary = {
    totalToday: sum(todaySnap),
    totalThisWeek: sum(weekSnap),
    totalThisMonth: sum(monthSnap),
    updatedAt: Timestamp.now(),
  };

  await db
    .collection("users")
    .doc(userId)
    .collection("stats")
    .doc("expenseSummary")
    .set(summary, { merge: true });

  return summary;
});
