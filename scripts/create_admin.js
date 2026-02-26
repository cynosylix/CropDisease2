/**
 * One-time script to create an admin user in Firebase Realtime Database.
 *
 * Prerequisites:
 * 1. Firebase project with Realtime Database created.
 * 2. Service account key JSON from Firebase Console:
 *    Project settings → Service accounts → Generate new private key.
 * 3. Save the JSON file (e.g. as scripts/serviceAccountKey.json) and do NOT commit it.
 *
 * Setup:
 *   cd scripts
 *   npm install
 *
 * Run:
 *   node create_admin.js --email admin@yourdomain.com --password YourPassword123
 *
 * Optional:
 *   node create_admin.js --email admin@yourdomain.com --password YourPassword123 --name "Admin"
 *   node create_admin.js --key path/to/serviceAccountKey.json --database-url https://YOUR_PROJECT-default-rtdb.firebaseio.com --email admin@example.com --password Pass123
 */

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

function parseArgs() {
  const args = process.argv.slice(2);
  const out = { email: null, password: null, name: 'Admin', key: null, databaseUrl: null };
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--email' && args[i + 1]) { out.email = args[i + 1].trim().toLowerCase(); i++; }
    else if (args[i] === '--password' && args[i + 1]) { out.password = args[i + 1]; i++; }
    else if (args[i] === '--name' && args[i + 1]) { out.name = args[i + 1].trim(); i++; }
    else if (args[i] === '--key' && args[i + 1]) { out.key = args[i + 1]; i++; }
    else if (args[i] === '--database-url' && args[i + 1]) { out.databaseUrl = args[i + 1]; i++; }
  }
  return out;
}

async function main() {
  const { email, password, name, key, databaseUrl } = parseArgs();

  if (!email || !password) {
    console.error('Usage: node create_admin.js --email <email> --password <password> [--name "Admin"] [--key path/to/serviceAccountKey.json] [--database-url https://PROJECT-default-rtdb.firebaseio.com]');
    process.exit(1);
  }

  if (password.length < 6) {
    console.error('Password must be at least 6 characters.');
    process.exit(1);
  }

  const keyPath = key || path.join(__dirname, 'serviceAccountKey.json');
  if (!fs.existsSync(keyPath)) {
    console.error('Service account key not found at:', keyPath);
    console.error('Download it from Firebase Console → Project settings → Service accounts → Generate new private key.');
    process.exit(1);
  }

  const serviceAccount = require(keyPath);
  const dbUrl = databaseUrl || `https://${serviceAccount.project_id}-default-rtdb.firebaseio.com`;

  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: dbUrl,
    });
  }

  const db = admin.database();
  const usersRef = db.ref('users');

  const snapshot = await usersRef.once('value');
  const val = snapshot.val();
  let existingKey = null;
  if (val && typeof val === 'object') {
    for (const [k, v] of Object.entries(val)) {
      if (v && v.email && String(v.email).trim().toLowerCase() === email) {
        existingKey = k;
        break;
      }
    }
  }
  if (existingKey) {
    await usersRef.child(existingKey).update({ isAdmin: true });
    console.log('Updated existing user to admin:', email);
    console.log('User key:', existingKey);
  } else {
    const newRef = usersRef.push();
    await newRef.set({
      name: name || 'Admin',
      email: email,
      password: password,
      createdAt: new Date().toISOString(),
      isAdmin: true,
    });
    console.log('Created new admin user:', email);
    console.log('User key:', newRef.key);
  }

  console.log('Done. Log in to the app with this email and password to access Admin.');
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
