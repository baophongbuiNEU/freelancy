const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendEnrollmentNotification = functions.firestore
    .document('jobs/{jobId}/enrollments/{enrollmentId}')
    .onCreate((snapshot, context) => {
      const enrollment = snapshot.data();
      const jobId = context.params.jobId;
      const enrollmentId = context.params.enrollmentId;

      // Get the job details
      return admin.firestore().collection('jobs').doc(jobId).get()
          .then((jobSnapshot) => {
            const job = jobSnapshot.data();

            // Send a notification to the user who posted the job
            const payload = {
              notification: {
                title: 'Ứng tuyển mới',
                body: `${enrollment.name} đã ứng tuyển vào việc "${job.title}" của bạn.`,
              },
              data: {
                jobId: jobId,
                enrollmentId: enrollmentId,
              },
            };

            return admin.messaging().sendToDevice(job.uid, payload);
          })
          .then(() => {
            // Get the current user's device token
            return admin.firestore().collection('users').doc(enrollment.uid).get()
                .then((userSnapshot) => {
                  const user = userSnapshot.data();

                  // Send a notification to the current user's device
                  const payload = {
                    notification: {
                      title: 'Ứng tuyển của bạn',
                      body: `${job.title} đã nhận ứng tuyển của ${enrollment.name}.`,
                    },
                    data: {
                      jobId: jobId,
                      enrollmentId: enrollmentId,
                    },
                  };

                  return admin.messaging().sendToDevice(user.deviceToken, payload);
                });
          })
          .catch((error) => {
            console.error('Error sending enrollment notification:', error);
          });
    });