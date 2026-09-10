const {
  BlobServiceClient,
  StorageSharedKeyCredential
} = require('@azure/storage-blob');

const keys = require('../config/keys');

const getBlobServiceClient = () => {
  const { connectionString, accountName, accountKey } = keys.azure || {};

  if (connectionString) {
    return BlobServiceClient.fromConnectionString(connectionString);
  }

  if (accountName && accountKey) {
    const sharedKeyCredential = new StorageSharedKeyCredential(
      accountName,
      accountKey
    );
    return new BlobServiceClient(
      `https://${accountName}.blob.core.windows.net`,
      sharedKeyCredential
    );
  }

  return null;
};

exports.azureUpload = async image => {
  try {
    let imageUrl = '';
    let imageKey = '';

    const blobServiceClient = getBlobServiceClient();

    if (!blobServiceClient) {
      console.warn(
        'Missing Azure Blob Storage configuration (AZURE_STORAGE_CONNECTION_STRING or AZURE_STORAGE_ACCOUNT_NAME & AZURE_STORAGE_ACCOUNT_KEY)'
      );
      return { imageUrl, imageKey };
    }

    if (image) {
      const containerName = keys.azure.containerName || 'products';
      const containerClient = blobServiceClient.getContainerClient(containerName);

      // Create container if it doesn't already exist with public blob read access
      await containerClient.createIfNotExists({ access: 'blob' });

      const blobName = `${Date.now()}-${image.originalname}`;
      const blockBlobClient = containerClient.getBlockBlobClient(blobName);

      await blockBlobClient.uploadData(image.buffer, {
        blobHTTPHeaders: {
          blobContentType: image.mimetype
        }
      });

      imageUrl = blockBlobClient.url;
      imageKey = blobName;
    }

    return { imageUrl, imageKey };
  } catch (error) {
    console.error('Azure Blob Storage upload error:', error.message);
    return { imageUrl: '', imageKey: '' };
  }
};

// Backwards compatibility alias to prevent breaking existing callers
exports.s3Upload = exports.azureUpload;
