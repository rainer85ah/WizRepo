const BUCKET_URL = "https://wiz-s3-bucket-db-backups.s3.us-east-1.amazonaws.com/";
const DIRECTORY_PREFIX = "mongodb_backups/";

async function getBucketContents() {
    const response = await fetch(BUCKET_URL, {
        method: 'GET'
    });
    const text = await response.text();
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(text, "text/xml");
    const contents = xmlDoc.getElementsByTagName("Contents");

    return Array.from(contents)
    .map(item => {
        const key = item.getElementsByTagName("Key")[0].textContent;
        return {
            key: key,
            url: `${BUCKET_URL}${key}`
        };
    })
    .filter(item => item.key.startsWith(DIRECTORY_PREFIX))
    .map(item => ({
        key: item.key.replace(DIRECTORY_PREFIX, ""),
        url: item.url
    }));
}

function renderFileList(files) {
    const container = document.getElementById("file-list-container");
    container.innerHTML = '';

    if (files.length === 0) {
        container.innerHTML = '<p>This bucket is empty.</p>';
        return;
    }

    const list = document.createElement('ul');
    files.forEach(file => {
        const listItem = document.createElement('li');
        const link = document.createElement('a');
        link.href = file.url;
        link.textContent = file.key;
        listItem.appendChild(link);
        list.appendChild(listItem);
    });

    container.appendChild(list);
}

// Main function to execute when the page loads
(async () => {
    try {
        const files = await getBucketContents();
        renderFileList(files);
    } catch (error) {
        console.error("Error fetching bucket contents:", error);
        document.getElementById("file-list-container").innerHTML = '<p class="error">Failed to load file list. Check your bucket configuration.</p>';
    }
})();
