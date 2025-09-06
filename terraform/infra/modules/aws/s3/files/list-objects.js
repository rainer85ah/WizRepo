// Replace with your bucket info
const bucketName = "wiz-s3-bucket-db-backups";
const region = "us-east-1";

// The S3 website endpoint (not the REST one!)
const endpoint = `http://${bucketName}.s3-website-${region}.amazonaws.com`;

// Use the S3 REST API (unauthenticated, since bucket is public)
const s3url = `https://${bucketName}.s3.${region}.amazonaws.com/?list-type=2`;

async function listObjects() {
  try {
    const response = await fetch(s3url);
    const text = await response.text();

    // Parse XML response from S3
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(text, "application/xml");
    const contents = xmlDoc.getElementsByTagName("Contents");

    const listEl = document.getElementById("file-list");

    for (let i = 0; i < contents.length; i++) {
      const key = contents[i].getElementsByTagName("Key")[0].textContent;

      // Skip index.html and script files so they don’t show up
      if (key.endsWith("index.html") || key.endsWith("list-objects.js")) continue;

      const li = document.createElement("li");
      const link = document.createElement("a");
      link.href = `${endpoint}/${key}`;
      link.textContent = key;
      li.appendChild(link);
      listEl.appendChild(li);
    }
  } catch (err) {
    console.error("Error listing objects:", err);
  }
}

listObjects();
